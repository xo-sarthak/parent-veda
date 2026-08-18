// =============================================================================
//  Language model + localized text
// -----------------------------------------------------------------------------
//  ParentVeda is fully bilingual. The toggle swaps the language WHOLESALE:
//
//    Hinglish : everything in natural Hinglish  ("chhota aam", "Main shaant hoon")
//    English  : everything in plain English     ("a small mango", "I am calm")
//
//  No language ever leaks into the other mode. Content strings come from the
//  bilingual JSON as {en, hi} pairs (-> LocalizedText). Fixed UI chrome lives
//  in [S] below so titles, labels and buttons translate too.
// =============================================================================

enum AppLanguage { hinglish, english }

extension AppLanguageX on AppLanguage {
  bool get isEnglish => this == AppLanguage.english;
  bool get isHinglish => this == AppLanguage.hinglish;

  /// The non-English language, read by name rather than by script.
  ///
  /// ParentVeda is moving from Hinglish-in-Latin to Hindi in Devanagari. The
  /// enum value is still `hinglish` while the content is converted file by
  /// file; this alias lets new code say what it means (`isHindi`) instead of
  /// carrying the old script's name, so the eventual rename touches the enum
  /// and not every call site written from here on.
  bool get isHindi => this == AppLanguage.hinglish;
}

/// A piece of content available in both languages.
class LocalizedText {
  const LocalizedText({required this.en, required this.hi});

  final String en;
  final String hi;

  factory LocalizedText.fromJson(Object? json) {
    if (json is Map) {
      return LocalizedText(
        en: (json['en'] ?? '').toString(),
        hi: (json['hi'] ?? json['en'] ?? '').toString(),
      );
    }
    // Tolerate a plain string (same in both languages).
    final s = json?.toString() ?? '';
    return LocalizedText(en: s, hi: s);
  }

  String of(AppLanguage lang) => lang.isEnglish ? en : hi;

  /// The text in the language the app is currently rendering in.
  ///
  /// The companion to [S.now], and for the same reason: a `const` data table
  /// has no controller in scope, so `meta.label.of(controller.language)` means
  /// threading a controller into every data read. `meta.label.now` is the same
  /// answer without the plumbing.
  ///
  /// Use `of(lang)` where a language is genuinely at hand — a widget already
  /// holding one, or a test asserting both sides. Reach for `now` when the
  /// alternative is passing a language through three layers to reach a string.
  String get now => of(S.current);

  /// Renders as the language on screen when interpolated into a string.
  ///
  /// Without this, `'${y.duration} · ${y.focus}'` compiles, passes every test,
  /// and puts **Instance of 'LocalizedText'** in front of a mother — which is
  /// exactly what the prenatal yoga screen did after its model widened. An
  /// interpolated LocalizedText is valid Dart, so neither the analyzer nor a
  /// grep can find these; the only reliable fix is at the type itself.
  ///
  /// The trade-off, stated plainly: this makes interpolation DISPLAY-correct,
  /// and therefore makes it silently language-dependent. That is wrong in the
  /// one place it has always been wrong — building a key, an id, or anything
  /// persisted. `.en` remains the answer there, and
  /// test/localized_identity_test.dart guards it. Choosing this direction
  /// because a wrong key is a bug we can test for, while "Instance of" is a
  /// bug only the user ever sees.
  @override
  String toString() => now;
}

/// Fixed UI strings (chrome). Construct with the active language and read the
/// getters: `final s = S(lang); Text(s.howBig);`.
class S {
  const S(this.lang);
  final AppLanguage lang;

  /// The language the app is currently rendering in.
  ///
  /// `S(lang)` needs a language, which means a call site needs the controller
  /// in scope. Most screens have it — but a string inside a helper method, a
  /// `showDialog` builder or a widget file that never touches the controller
  /// does not, and those are exactly the places hardcoded English survived.
  ///
  /// `main.dart` keeps this in sync on every rebuild, in the same place it
  /// tells `PvType` which language to draw. That makes `S.now` correct
  /// wherever it is read, at the cost of being a global — the same trade the
  /// rest of this codebase already makes with its singleton stores.
  ///
  /// Prefer `S(p.language)` when a controller is already at hand; reach for
  /// `S.now` when threading one through would be the only reason to.
  static AppLanguage current = AppLanguage.english;
  static S get now => S(current);

  bool get _e => lang.isEnglish;
  T _p<T>(T en, T hi) => _e ? en : hi;

  // ---- App / screen chrome -------------------------------------------------
  String get appName => 'ParentVeda';
  String weekOf(int w, int total) => _p('Week $w of $total', 'हफ़्ता $w / $total');
  String get wkShort => _p('wk', 'हफ़्ता');
  String get weekWord => _p('Week', 'हफ़्ता');
  String get weeksLabel => _p('weeks', 'हफ़्ते');
  String get noContent =>
      _p('No content for this week yet.', 'इस हफ़्ते के लिए अभी कोई सामग्री नहीं है।');
  String get loadError =>
      _p('We could not load this week.', 'हम यह हफ़्ता लोड नहीं कर पाए।');
  String get tryAgain => _p('Try again', 'दोबारा कोशिश करें');

  // ---- Locked week ---------------------------------------------------------
  String get onItsWay => _p('is gently on its way', 'धीरे-धीरे आ रहा है');
  String get openNextWeek =>
      _p('This chapter opens next week. One day at a time, Maa.',
         'यह अध्याय अगले हफ़्ते खुलेगा। एक-एक दिन करके, माँ।');
  String openInWeeks(int n) => _p(
      'This chapter opens in $n weeks. There is no rush - enjoy where you are today.',
      'यह अध्याय $n हफ़्तों में खुलेगा। कोई जल्दी नहीं — आज आप जहाँ हैं, उसका आनंद लीजिए।');
  String youAreInWeek(int w) =>
      _p("You're in week $w right now", 'अभी आप हफ़्ते $w में हैं');

  // ---- Card 1 · Size -------------------------------------------------------
  String get sizeEyebrow => _p('This week', 'इस हफ़्ते');
  String get howBig => _p('How big am I?', 'मैं कितना बड़ा हूँ?');
  String get sizeOf => _p('I am about the size of', 'मैं लगभग इतना बड़ा हूँ —');
  String get lengthLabel => _p('Length', 'लंबाई');
  String get weightLabel => _p('Weight', 'वज़न');

  // ---- Card 2 · Baby update ------------------------------------------------
  String get babyEyebrow => _p("Baby's update", 'शिशु का अपडेट');
  String get whatImDoing => _p('What I am doing', 'मैं क्या कर रहा हूँ');
  String get ownPace =>
      _p('Every baby grows at their own gentle pace.',
         'हर शिशु अपनी ही प्यारी रफ़्तार से बढ़ता है।');
  String get phaseReassurance => _p('Reassurance', 'तसल्ली');
  String get phaseBonding => _p('Bonding', 'जुड़ाव');
  String get phasePreparation => _p('Preparation', 'तैयारी');
  String get phaseDefault => _p('Your journey', 'आपका सफ़र');

  // ---- Card 3 · Mother body ------------------------------------------------
  String get motherEyebrow => _p('For you, Maa', 'आपके लिए, माँ');
  String get yourBody => _p('Your body this week', 'इस हफ़्ते आपका शरीर');
  String get gentleHeadsUp => _p('Gentle heads-up', 'एक प्यारी सी याद');
  String get headsUpFooter => _p(
      'If anything here worries you, call your doctor. You are doing beautifully.',
      'अगर इनमें से कुछ भी आपको परेशान करे तो डॉक्टर को कॉल करें। आप बहुत अच्छा कर रही हैं।');

  // ---- Card 4 · Nutrition --------------------------------------------------
  String get nutritionEyebrow => _p('Nourishment', 'पोषण');
  String get whatToEat => _p('What to eat', 'क्या खाएँ');
  String get foodsToFavour =>
      _p('Foods to favour this week', 'इस हफ़्ते ये चीज़ें खाएँ');
  String get ayurvedicTip =>
      _p("Ayurvedic · Mother's care tip", 'आयुर्वेदिक · माँ की देखभाल');

  // ---- Card 5 · Do / Skip / Myth ------------------------------------------
  String get guidanceEyebrow => _p('Gentle guidance', 'प्यारी सलाह');
  String get doSkipTruth => _p('Do, skip & truth', 'करें, न करें और सच');
  String get doThisWeek => _p('Do this week', 'इस हफ़्ते करें');
  String get skipThisWeek => _p('Skip this week', 'इस हफ़्ते न करें');
  String get mythBuster => _p('Myth-buster', 'मिथक बनाम सच');

  // ---- Card 6 · Garbh Sanskar ---------------------------------------------
  String get garbhSanskar => 'Garbh Sanskar'; // proper noun, same in both
  String get bondingRitual => _p('Bonding ritual', 'जुड़ाव का पल');
  String get todaysAffirmation =>
      _p("Today's Affirmation", 'आज का संकल्प');
  String ragaNamed(String raga) => _p('Raga $raga', 'राग $raga');
  String get soothingRaga =>
      _p('Soothing prenatal raga', 'सुकून देने वाला राग');
  String get audioComingSoon => _p(
      'Your guided raga & affirmations begin in the bonding phase. For now, gently repeat the affirmation above.',
      'आपके गाइडेड राग और संकल्प जुड़ाव के दौर में शुरू होंगे। अभी के लिए, ऊपर दिया संकल्प प्यार से दोहराइए।');

  // ---- Card 7 · Partner ----------------------------------------------------
  String get partnerEyebrow => _p('For your partner', 'आपके साथी के लिए');
  String get shareJourney => _p('Share the journey', 'सफ़र साझा करें');
  String get thisWeekTogether =>
      _p('This week, together', 'इस हफ़्ते, साथ में');
  String get forwardWhatsapp => _p(
      'Forward to Partner via WhatsApp', 'साथी को WhatsApp पर भेजें');
  String get partnerPrivacy => _p(
      'We never message anyone for you - you choose where it goes.',
      'हम आपकी तरफ़ से किसी को मैसेज नहीं करते — आप ख़ुद चुनती हैं कि यह कहाँ जाए।');
  String partnerShareHeader(int w) =>
      _p('ParentVeda · Week $w', 'ParentVeda · हफ़्ता $w');
  String get partnerShareFooter =>
      _p('- Sent with love from ParentVeda', '— ParentVeda से प्यार के साथ');
  String partnerShareSubject(int w) => _p(
      'A note from our Week $w journey', 'हमारे हफ़्ता $w के सफ़र से एक नोट');
  String get shareFailed =>
      _p('Could not open the share sheet.', 'शेयर शीट नहीं खुल पाई।');

  // ===========================================================================
  //  Rich (PDF-schema) card strings
  // ===========================================================================

  // Baby update
  String get funFact => _p('Fun fact', 'मज़ेदार बात');

  // Mom journey
  String get physicalChanges => _p('Physical changes', 'शारीरिक बदलाव');
  String get howYouFeel => _p('How you may feel', 'आप कैसा महसूस कर सकती हैं');
  String get commonSymptoms => _p('Common symptoms', 'आम लक्षण');
  String get selfCare => _p('Self-care', 'अपना ख़याल');
  String get reassuranceLabel => _p('A gentle reminder', 'एक प्यारी सी याद');

  // Nutrition
  String get nutritionThemeLabel => _p('Theme', 'थीम');
  String get whyNow => _p('Why now', 'अभी क्यों');
  String get superfoodOfWeek =>
      _p('Indian superfood of the week', 'इस हफ़्ते का भारतीय सुपरफ़ूड');
  String get howToEat => _p('How to enjoy it', 'कैसे खाएँ');
  String get mealIdeaLabel => _p('Meal idea', 'खाने का सुझाव');
  String get nourishTwoLives =>
      _p('You are nourishing two lives today.', 'आज आप दो ज़िंदगियों को पोषण दे रही हैं।');

  // Action plan
  String get mythLabel => _p('Myth', 'मिथक');
  String get truthLabel => _p('Truth', 'सच');

  // Garbh Sanskar
  String get reflectMoment => _p('A moment to reflect', 'सोचने का एक पल');

  // Reflect & Remember
  String get reflectEyebrow => _p('A memory for later', 'आगे के लिए एक याद');
  String get reflectTitle => _p('Reflect & remember', 'यादें सहेजें');
  String get reflectionLabel => _p('Reflection', 'सोच-विचार');
  String get journalLabel => _p('Journal prompt', 'जर्नल का सवाल');
  String get photoLabel => _p('Photo prompt', 'फ़ोटो का सुझाव');

  // Share Your Journey (partner, last card)
  String get shareJourneyTitle => _p('Share your journey', 'अपना सफ़र साझा करें');
  String get whatSheMayFeel => _p('What she may feel', 'वह कैसा महसूस कर सकती है');
  String get whatYouCanDo => _p('What you can do', 'आप क्या कर सकते हैं');
  String get oneMission => _p("This week's one mission", 'इस हफ़्ते का एक काम');

  // Journal & memories
  String get tapToWrite => _p('Tap to write…', 'लिखने के लिए टैप करें…');
  String get saveToJournal => _p('Save to Journal', 'जर्नल में सेव करें');
  String get writePlaceholder =>
      _p('Pour your heart out here…', 'यहाँ अपने दिल की बात लिखिए…');
  String get journalSaved => _p('Saved to your journal 💜', 'आपके जर्नल में सेव हो गया 💜');
  String get myJournal => _p('Your journal', 'आपका जर्नल');
  String get memoriesTitle => _p('Memories', 'यादें');
  String get addPhoto => _p('Add photo', 'फ़ोटो जोड़ें');
  String get noMemories => _p(
      'Your memories will appear here as you add them.',
      'आपकी यादें यहाँ दिखेंगी, जैसे-जैसे आप इन्हें जोड़ती जाएँगी।');
  String get edit => _p('Edit', 'बदलें');
  String get delete => _p('Delete', 'हटाएँ');
  String get cameraFailed =>
      _p('Could not open the camera.', 'कैमरा नहीं खुल पाया।');
  String entriesCount(int n) =>
      _p(n == 1 ? '1 entry' : '$n entries', '$n एंट्री');

  // ---- Weekly journal (single "How was your last week?" prompt) ------------
  String get howWasYourWeek =>
      _p('How was your last week?', 'आपका पिछला हफ़्ता कैसा रहा?');
  String get journalCardSubtitle => _p(
      'Write it down, or just speak - and keep up to two photos with it.',
      'लिख लीजिए, या बस बोल दीजिए — साथ में दो तक फ़ोटो भी रखिए।');
  String get writeOrSpeak => _p('Write or speak', 'लिखें या बोलें');
  String get tapToShareWeek =>
      _p('Tap to share how this week felt', 'टैप करके इस हफ़्ते का हाल लिखिए');
  String get tapMicToSpeak =>
      _p('Tap the mic and speak', 'माइक दबाइए और बोलिए');
  String get listening => _p('Listening…', 'सुन रहे हैं…');
  String get micUnavailable => _p(
      'Microphone is not available right now.',
      'माइक्रोफ़ोन अभी उपलब्ध नहीं है।');
  String get micPermissionNeeded => _p(
      'Please allow microphone access to speak your note.',
      'बोलकर नोट लिखने के लिए माइक्रोफ़ोन की अनुमति दीजिए।');
  String get addUpToTwoPhotos => _p('Add photo (up to 2)', 'फ़ोटो जोड़ें (2 तक)');
  String get photoLimitReached =>
      _p('You can add up to 2 photos per note.', 'एक नोट में 2 तक फ़ोटो जोड़ सकती हैं।');
  String get remove => _p('Remove', 'निकालें');
  String get cancel => _p('Cancel', 'रहने दें');
  String get deleteEntryQ =>
      _p('Delete this note?', 'यह नोट हटाएँ?');
  String get deletePhotoQ =>
      _p('Delete this photo?', 'यह फ़ोटो हटाएँ?');
  String get memoryBook => _p('Your memory book', 'आपकी यादों की किताब');
  String get noEntriesYet => _p(
      'No notes yet - your weekly reflections will gather here.',
      'अभी कोई नोट नहीं — आपके हर हफ़्ते की यादें यहाँ जमा होंगी।');

  // ---- "Your Week" - the week-scoped journal (weeks 4 & 5 preview) ----------
  String get yourWeek => _p('Your Week', 'आपका हफ़्ता');
  String get tapToEdit => _p('Tap to edit', 'बदलने के लिए टैप करें');
  String get addAPhoto => _p('Add a photo', 'एक फ़ोटो जोड़ें');

  // Week strip / trimester
  String trimesterName(int week) {
    if (week <= 13) return _p('Trimester 1', 'पहली तिमाही');
    if (week <= 26) return _p('Trimester 2', 'दूसरी तिमाही');
    return _p('Trimester 3', 'तीसरी तिमाही');
  }

  String get dueLabel => _p('Due', 'डिलीवरी');

  // Week 40 celebration
  String get celebrationTitle => _p('Welcome, little one.', 'स्वागत है, नन्हे।');
  String get celebrationSubtitle => _p(
      '40 weeks of love, strength, and magic.',
      '40 हफ़्तों का प्यार, ताक़त और जादू।');
  String get celebrationBody => _p(
      'You carried a whole world inside you. Every week, every kick, every quiet moment brought you here.',
      'आपने एक पूरी दुनिया अपने अंदर सँभाली। हर हफ़्ता, हर हलचल, हर शांत पल आपको यहाँ ले आया।');
  String get saveMemory => _p('Download this memory', 'यह याद डाउनलोड करें');
  String get savingMemory => _p('Saving…', 'सेव हो रहा है…');
  String get savedMemory => _p('Saved! Choose where to keep it.', 'सेव हो गया! चुनिए कहाँ रखना है।');
  String get celebrationBadge => _p('Journey complete', 'सफ़र पूरा');
  String get celebrationMemoriesTitle =>
      _p('Your journey in memories', 'यादों में आपका सफ़र');
  String photosCount(int n) => _p(
      n == 1 ? '1 photo' : '$n photos', '$n फ़ोटो');
  String get celebrationShareText => _p(
      '40 weeks complete 🎉 Our little one is here! - ParentVeda',
      '40 हफ़्ते पूरे 🎉 हमारा नन्हा आ गया! — ParentVeda');

  // ---- Week-40 keepsake PDF booklet ----------------------------------------
  String get createBooklet =>
      _p('Download your Keepsake Booklet', 'अपनी यादों की किताब डाउनलोड करें');
  String get buildingBooklet =>
      _p('Building your booklet…', 'आपकी किताब बन रही है…');
  String get bookletReady =>
      _p('Your booklet is ready 💕', 'आपकी किताब तैयार है 💕');
  String get bookletFailed => _p(
      'Could not create the booklet. Please try again.',
      'किताब नहीं बन पाई। कृपया फिर कोशिश करें।');
  String get missingWeeksTitle =>
      _p('Add a little more?', 'थोड़ा और जोड़ें?');
  String get missingWeeksIntro => _p(
      'These weeks have no memory yet. Add one to include it in your booklet - or skip and create it now.',
      'इन हफ़्तों में अभी कोई याद नहीं। किताब में शामिल करने के लिए एक जोड़िए — या छोड़कर अभी बना लीजिए।');
  String get noMissingWeeks => _p(
      'Every week with a memory will be included. Ready to create your booklet?',
      'जिस हफ़्ते में याद है, वह शामिल होगा। किताब बनाने के लिए तैयार?');
  String get addMemory => _p('Add memory', 'याद जोड़ें');
  String get createNow => _p('Create booklet now', 'अभी किताब बनाएँ');
  String get bookletPreviewTitle =>
      _p('Your keepsake booklet', 'आपकी यादों की किताब');
  String weeksWithNoEntry(int n) => _p(
      n == 1 ? '1 week with no memory' : '$n weeks with no memory',
      n == 1 ? '1 हफ़्ता बिना याद के' : '$n हफ़्ते बिना याद के');

  // PDF page text (kept short; the booklet is a calm keepsake).
  String get bookletCoverTitle =>
      _p('Our Pregnancy Journey', 'हमारा गर्भावस्था का सफ़र');
  String get bookletCoverSubtitle => _p(
      'Forty weeks of waiting, hoping and loving.',
      'चालीस हफ़्तों का इंतज़ार, उम्मीद और प्यार।');
  String bookletCompletedOn(String date) =>
      _p('Completed on $date', '$date को पूरा हुआ');
  String get bookletClosingTitle =>
      _p('With all our love', 'हमारे सारे प्यार के साथ');
  String get bookletClosingBody => _p(
      'One day you will read this, little one, and know how deeply you were wanted, every single week.',
      'एक दिन तुम यह पढ़ोगे, नन्हे, और जानोगे कि हर हफ़्ते तुम्हें कितना चाहा गया।');
  String get bookletEmptyEntry =>
      _p('A quiet week, simply held close.', 'एक शांत हफ़्ता, बस दिल के क़रीब।');

  // ===========================================================================
  //  HOME SCREEN - Daily Moment
  // ===========================================================================

  // ---- Header --------------------------------------------------------------
  String greeting(int hour, String name) {
    final part = hour < 12
        ? _p('Good Morning', 'शुभ प्रभात')
        : hour < 17
            ? _p('Good Afternoon', 'शुभ दोपहर')
            : _p('Good Evening', 'शुभ संध्या');
    return '$part, $name';
  }

  /// Encouraging, journey-style progress line (never task language).
  String journeyLine(int week) {
    if (week == 20) {
      return _p("Week 20 · You're halfway there 💜",
          'हफ़्ता 20 · आप आधा सफ़र पूरा कर चुकी हैं 💜');
    }
    if (week >= 36) {
      return _p('Week $week · Almost there, mamma 💜',
          'हफ़्ता $week · बस थोड़ा और, माँ 💜');
    }
    if (week <= 13) {
      return _p('Week $week · A new chapter begins 💜',
          'हफ़्ता $week · एक नया अध्याय शुरू 💜');
    }
    return _p('Week $week · Growing together 💜',
        'हफ़्ता $week · साथ-साथ बढ़ रहे हैं 💜');
  }

  String littleOneSize(String fruit) => _p(
      'Your little one is the size of $fruit this week',
      'आपका नन्हा इस हफ़्ते $fruit जितना बड़ा है');
  String sizeAndLearning(String length, String learning) =>
      '$length · $learning';

  String get todaysMoment => _p("Today's Moment", 'आज का पल');
  String get momentMinutes => _p('~6 min', '~6 मिनट');
  String get momentSummary => _p('A small moment for you and your baby.',
      'आप और आपके शिशु के लिए एक छोटा सा पल।');

  // ---- Direction B "Warm Nest" Home (hero, rituals, quick row, splash) ------
  String weekDayLine(int week, int day) =>
      _p('Week $week, Day $day', 'हफ़्ता $week, दिन $day');
  String babyIsSize(String fruit) =>
      _p('Your baby is $fruit', 'आपका शिशु $fruit जितना');
  String momentDone(int done, int total) =>
      _p('$done of $total done', '$total में से $done पूरे');
  String get ritualGrow => _p('Grow', 'बढ़त');
  String get ritualRead => _p('Read', 'पढ़ें');
  String get ritualTalk => _p('Talk', 'बात');
  String get ritualSanskar => _p('Sanskar', 'संस्कार');
  String get ritualForYou => _p('For you', 'आपके लिए');
  String get quickKicks => _p('Kicks', 'हलचल');
  String quickKicksValue(int n) => _p('$n today', 'आज $n');
  String get quickWater => _p('Water', 'पानी');
  String quickWaterValue(int n) => _p('$n glasses', '$n गिलास');
  String get splashTagline => _p('Nurturing wisdom', 'पोषण की समझ');
  String get splashFooter =>
      _p('Your calm companion 💜', 'आपका शांत साथी 💜');

  // ===========================================================================
  //  MY JOURNAL - the mother's pregnancy memory timeline
  // ===========================================================================
  String get jrTitle => _p('My Journal', 'मेरा जर्नल');
  String get jrSubtitle =>
      _p('Your pregnancy story, one day at a time',
          'आपकी गर्भावस्था की कहानी, एक-एक दिन');
  String get jrFilterAll => _p('All', 'सब');
  String get jrFilterMemories => _p('Memories', 'यादें');
  String get jrFilterPhotos => _p('Photos', 'फ़ोटो');
  String get jrTakePhoto => _p('Take a photo', 'फ़ोटो खींचें');
  String get jrChooseGallery => _p('Choose from gallery', 'गैलरी से चुनें');
  String get jrFilterMilestones => _p('Milestones', 'पड़ाव');
  String get jrFilterHealth => _p('Health', 'सेहत');
  String get jrFilterScans => _p('Scans', 'स्कैन');
  String get jrFilterBaby => _p('Baby', 'शिशु');
  String get jrEmptyTitle => _p('Your pregnancy story begins here.',
      'आपकी गर्भावस्था की कहानी यहीं से शुरू होती है।');
  String get jrEmptyBody => _p(
      'Capture a memory, a photo, or a note for your baby - it all gathers here.',
      'एक याद, एक फ़ोटो, या शिशु के लिए एक नोट सहेजिए — सब यहीं जमा होगा।');
  String get jrCreateFirst => _p('Create First Memory', 'पहली याद बनाएँ');
  String get jrCreateMemory => _p('Create Memory', 'याद बनाएँ');
  String get jrWriteMemory => _p('Write Memory', 'याद लिखें');
  String get jrAddPhoto => _p('Add Photo', 'फ़ोटो जोड़ें');
  String get jrRecordVoice =>
      _p('Record Voice Note', 'वॉइस नोट रिकॉर्ड करें');
  String get jrNoteForBaby => _p('Note for Baby', 'शिशु के लिए नोट');
  String get jrVoiceSoon =>
      _p('Voice memories are coming soon 💜', 'वॉइस यादें जल्द आ रही हैं 💜');
  String get jrSearchHint =>
      _p('Search your journal', 'अपने जर्नल में खोजें');
  String get jrExport => _p('Export', 'एक्सपोर्ट');
  String get jrExportSoon => _p(
      'Your printable memory book is coming soon 💜',
      'आपकी छपने वाली यादों की किताब जल्द आ रही है 💜');
  String get jrMemoryHint => _p('Write your memory…', 'अपनी याद लिखिए…');
  String get jrNoteForBabyHint =>
      _p('Write to your baby…', 'अपने शिशु को लिखिए…');
  String get jrCaptionHint =>
      _p('Add a caption (optional)', 'कैप्शन जोड़ें (ज़रूरी नहीं)');
  String get jrSaveMemory => _p('Save', 'सेव करें');
  String get jrSavedMemory =>
      _p('Saved to your journal 💜', 'आपके जर्नल में सेव हो गया 💜');
  // Daily "My Journal" section + create flows
  String get jcMyJournal => _p('My Journal', 'मेरा जर्नल');
  String get jcViewTimeline =>
      _p('View My Journal Timeline', 'मेरे जर्नल की टाइमलाइन देखें');
  String get jcCustom => _p('Custom', 'अपना');
  String get jcCustomTagHint =>
      _p('Tag (e.g. Cravings, A dream)', 'टैग (जैसे क्रेविंग, एक सपना)');
  String get jcCustomBodyHint => _p(
      'Write anything you want to remember…', 'जो याद रखना हो, लिखिए…');
  String get jcRecordTitle =>
      _p('Record a voice note', 'वॉइस नोट रिकॉर्ड करें');
  String get jcTapToRecord =>
      _p('Tap the mic to start', 'शुरू करने के लिए माइक टैप करें');
  String get jcRecording =>
      _p('Recording… tap to stop', 'रिकॉर्ड हो रहा है… रोकने के लिए टैप करें');
  String get jcRecordAnother =>
      _p('Tap to record another', 'एक और रिकॉर्ड करने के लिए टैप करें');
  String get jcMicNeeded => _p('Microphone permission is needed to record.',
      'रिकॉर्ड करने के लिए माइक्रोफ़ोन की अनुमति चाहिए।');
  // "Entry saved" confirmation snackbars.
  String get jcSavedMemory => _p('Memory saved 💜', 'याद सेव हो गई 💜');
  String get jcSavedNote =>
      _p('Note for baby saved 💜', 'शिशु के लिए नोट सेव हो गया 💜');
  String get jcSavedPhoto =>
      _p('Photo added to your journal', 'फ़ोटो आपके जर्नल में जुड़ गई');
  String get jcSavedVoice =>
      _p('Voice note saved', 'वॉइस नोट सेव हो गया');
  String get jcUpdated => _p('Entry updated', 'एंट्री अपडेट हो गई');
  // Speech-to-text mic button.
  String get micTap => _p('Tap to dictate', 'बोलकर लिखने के लिए टैप करें');
  String get micListening => _p('Listening…', 'सुन रहे हैं…');
  String get micDenied => _p('Microphone/speech permission is needed to dictate.',
      'बोलकर लिखने के लिए माइक्रोफ़ोन/स्पीच की अनुमति चाहिए।');
  String get jcVoiceNote => _p('Voice note', 'वॉइस नोट');
  String get jrDeleteEntryQ =>
      _p('Delete this entry?', 'यह एंट्री हटाएँ?');
  String get jrNothingHere => _p(
      'Nothing here yet - add your first one with the button below.',
      'अभी यहाँ कुछ नहीं — नीचे बटन से अपनी पहली जोड़िए।');
  String jrWeekLabel(int w) => _p('Week $w', 'हफ़्ता $w');
  // Journal views (grouped list + flip-through booklet).
  String get jrListView => _p('List view', 'सूची');
  String get jrBookletView => _p('Booklet', 'किताब');
  String get jrGroupBy => _p('Group by', 'क्रम');
  String get jrByMonth => _p('Month', 'महीना');
  String get jrByWeek => _p('Week', 'हफ़्ता');
  String jrMonthYear(DateTime d) =>
      '${_months[(d.month - 1).clamp(0, 11)]} ${d.year}';
  String jrWeekdayDate(DateTime d) =>
      '${_weekdays[(d.weekday - 1).clamp(0, 6)]}, ${d.day} ${_months[(d.month - 1).clamp(0, 11)]}';
  String jrDayRange(DateTime a, DateTime b) {
    final ma = _months[(a.month - 1).clamp(0, 11)];
    final mb = _months[(b.month - 1).clamp(0, 11)];
    if (a.month == b.month && a.year == b.year) return '${a.day}–${b.day} $ma';
    return '${a.day} $ma – ${b.day} $mb';
  }

  String jrCoverTitle(String name) => name.trim().isEmpty
      ? _p('My Pregnancy Journal', 'मेरा गर्भावस्था जर्नल')
      : _p("$name's Pregnancy Journal", "$name का गर्भावस्था जर्नल");
  String jrCoverWeeks(int a, int b) => _p('Weeks $a–$b', 'हफ़्ते $a–$b');
  String get jrCoverHint =>
      _p('Swipe to flip through', 'पलटने के लिए स्वाइप करें');
  // Rotating memory prompts (for mothers unsure what to write).
  List<String> get jrPrompts => _e
      ? const [
          'What made you smile today?',
          'What are you most excited about right now?',
          'What do you want your baby to know about today?',
          'What surprised you this week?',
          'Write a message for your baby.',
          'What are you grateful for today?',
        ]
      : const [
          'आज किस बात ने आपको मुस्कुरा दिया?',
          'अभी आपको सबसे ज़्यादा किस बात का इंतज़ार है?',
          'आज के बारे में आप अपने शिशु को क्या बताना चाहेंगी?',
          'इस हफ़्ते किस बात ने आपको हैरान किया?',
          'अपने शिशु के लिए एक संदेश लिखिए।',
          'आज आप किस बात के लिए शुक्रगुज़ार हैं?',
        ];
  // Auto-entry titles.
  String jrWeekDone(int w) => _p('Week $w completed', 'हफ़्ता $w पूरा हुआ');
  String get jrFirstTriDone =>
      _p('First trimester complete', 'पहली तिमाही पूरी');
  String get jrSecondTriDone =>
      _p('Second trimester complete', 'दूसरी तिमाही पूरी');
  String get jrThirdTriStart =>
      _p('Third trimester started', 'तीसरी तिमाही शुरू');
  String get jrHalfway => _p('Halfway there', 'आधा सफ़र पूरा');
  String get jrViability =>
      _p('Viability milestone reached', 'Viability का पड़ाव पार');
  String get jrFullTerm => _p('Full term reached', 'पूरे समय तक पहुँचे');
  String get jrWeightLogged => _p('Weight logged', 'वज़न दर्ज हुआ');
  String get jrKickSession => _p('Kick session logged', 'हलचल का सेशन दर्ज हुआ');
  String get jrFirstKick => _p('First kick recorded', 'पहली हलचल दर्ज हुई');
  String jrMovementsCount(int n) =>
      _p(n == 1 ? '1 movement' : '$n movements', '$n हलचल');
  // "Where your journal fills from" info sheet + per-filter empty states.
  String get jrInfoTitle =>
      _p('Where your journal fills from', 'आपका जर्नल कहाँ से भरता है');
  String get jrInfoIntro => _p(
      'Some entries you add yourself; others appear automatically as you use the app.',
      'कुछ एंट्री आप ख़ुद जोड़ती हैं; कुछ ऐप इस्तेमाल करते हुए अपने आप आ जाती हैं।');
  String get jrSrcMemories =>
      _p('Memories - written by you.', 'यादें — आप लिखती हैं।');
  String get jrSrcBaby => _p(
      'Notes for baby - written by you, in their own space.',
      'शिशु के लिए नोट — आप लिखती हैं, उनकी अपनी जगह पर।');
  String get jrSrcPhotos => _p('Photos - added by you from your gallery.',
      'फ़ोटो — आप अपनी गैलरी से जोड़ती हैं।');
  String get jrSrcMilestones => _p('Milestones - automatic, from your due date.',
      'पड़ाव — अपने आप, आपकी डिलीवरी की तारीख़ से।');
  String get jrSrcHealth => _p(
      'Weight, kicks & symptoms - from your trackers and Symptoms Companion.',
      'वज़न, हलचल और लक्षण — आपके ट्रैकर और Symptoms Companion से।');
  String get jrSrcScans => _p(
      'Scans & reports - appear once uploads are available (coming soon).',
      'स्कैन और रिपोर्ट — अपलोड शुरू होने पर आएँगे (जल्द आ रहा है)।');
  String get jrEmptyMemories => _p(
      'Your memories will gather here. Tap Create Memory to write your first.',
      'आपकी यादें यहाँ जमा होंगी। पहली लिखने के लिए "याद बनाएँ" दबाइए।');
  String get jrEmptyPhotos => _p(
      'Your photos will gather here. Add one with Create Memory.',
      'आपकी फ़ोटो यहाँ जमा होंगी। "याद बनाएँ" से एक जोड़िए।');
  String get jrEmptyMilestones => _p(
      'Milestones appear here automatically as your pregnancy grows 💜',
      'पड़ाव यहाँ अपने आप आते हैं, जैसे-जैसे आपकी गर्भावस्था आगे बढ़ती है 💜');
  String get jrEmptyHealth => _p(
      'Your weight and kick logs gather here automatically from the trackers.',
      'आपके वज़न और हलचल के रिकॉर्ड यहाँ ट्रैकर से अपने आप आते हैं।');
  String get jrEmptyScans => _p(
      'Scans & reports will appear here once uploads are available - coming soon 💜',
      'स्कैन और रिपोर्ट यहाँ अपलोड शुरू होने पर आएँगे — जल्द आ रहा है 💜');
  String get jrEmptyBaby => _p(
      'Your notes for baby will gather here. Write your first with Create Memory.',
      'शिशु के लिए आपके नोट यहाँ जमा होंगे। पहला "याद बनाएँ" से लिखिए।');

  // ===========================================================================
  //  MY CALENDAR - the pregnancy command center
  // ===========================================================================
  String get tabCalendar => _p('Calendar', 'कैलेंडर');
  String get calTitle => _p('My Calendar', 'मेरा कैलेंडर');
  String get calTabTimeline => _p('Timeline', 'टाइमलाइन');
  String get calTabCalendar => _p('Calendar', 'कैलेंडर');
  String get calTabUpcoming => _p('Upcoming', 'आगे');
  String calDaysTogether(int n) => _p('$n Days Together', '$n दिन साथ');
  String get calFilterAll => _p('All', 'सब');
  String get calFilterMilestones => _p('Milestones', 'पड़ाव');
  String get calFilterMedical => _p('Medical', 'मेडिकल');
  String get calFilterJournal => _p('Journal', 'जर्नल');
  String get calFilterPersonal => _p('Personal', 'निजी');
  String get calFilterParentveda => _p('ParentVeda', 'ParentVeda');
  String get calSearchHint => _p('Search events', 'इवेंट खोजें');
  String get calThisWeek => _p('This week', 'इस हफ़्ते');
  String get calNext2Weeks => _p('Next 2 weeks', 'अगले 2 हफ़्ते');
  String get calThisMonth => _p('This month', 'इस महीने');
  String get calLater => _p('Later', 'बाद में');
  String get calTimelineEmpty => _p(
      'Your journey will appear here as it unfolds.',
      'आपका सफ़र यहाँ दिखेगा, जैसे-जैसे वह आगे बढ़ेगा।');
  String get calUpcomingEmpty => _p(
      'Nothing scheduled ahead right now.', 'अभी आगे कुछ तय नहीं है।');
  String get calNoEventsDay => _p('Nothing on this day.', 'इस दिन कुछ नहीं।');
  String get calAddPersonal =>
      _p('Add personal event', 'निजी इवेंट जोड़ें');
  String get calEventTitleHint => _p('Event name', 'इवेंट का नाम');
  String get calEventNoteHint => _p('Note (optional)', 'नोट (ज़रूरी नहीं)');
  String get calStatusCompleted => _p('Completed', 'पूरा');
  String get calStatusUpcoming => _p('Upcoming', 'आने वाला');
  String calOpenWeek(int n) => _p('Open Week $n', 'हफ़्ता $n खोलें');
  String get calOpenJournal => _p('Open Journal', 'जर्नल खोलें');
  String calInDays(int n) => n <= 0
      ? _p('Today', 'आज')
      : (n == 1 ? _p('Tomorrow', 'कल') : _p('In $n days', '$n दिन में'));
  String calMonthYear(DateTime d) =>
      '${_months[(d.month - 1).clamp(0, 11)]} ${d.year}';
  List<String> get calWeekdayLetters =>
      const ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  // ===========================================================================
  //  MY BUMP JOURNEY - the visual pregnancy timeline
  // ===========================================================================
  String get bumpTitle => _p('My Bump Journey', 'मेरा बंप सफ़र');
  String get bumpSubtitle =>
      _p('Your bump, week by week', 'आपका बंप, हफ़्ते-दर-हफ़्ते');
  String get bumpEmptyTitle => _p('Your bump journey begins here.',
      'आपका बंप सफ़र यहीं से शुरू होता है।');
  String get bumpEmptyBody =>
      _p('Capture your first memory ❤', 'अपनी पहली याद क़ैद कीजिए ❤');
  String get bumpAddFirst => _p('Add First Photo', 'पहली फ़ोटो जोड़ें');
  String get bumpAddPhoto => _p('Add Photo', 'फ़ोटो जोड़ें');
  String get bumpTakePhoto => _p('Take Photo', 'फ़ोटो खींचें');
  String get bumpUpload => _p('Upload Photo', 'फ़ोटो अपलोड करें');
  String bumpPhotosAdded(int n) => _p('$n Photos Added', '$n फ़ोटो जुड़ीं');
  String get bumpThenNow => _p('Then & Now', 'पहले और अब');
  String get bumpThen => _p('Then', 'पहले');
  String get bumpNow => _p('Now', 'अब');
  String bumpCaptureThisWeek(int w) => _p(
      'Week $w - would you like to capture this week?',
      'हफ़्ता $w — इस हफ़्ते को क़ैद करना चाहेंगी?');
  String get bumpFilterAll => _p('All', 'सब');
  String get bumpFilterT1 => _p('Trimester 1', 'पहली तिमाही');
  String get bumpFilterT2 => _p('Trimester 2', 'दूसरी तिमाही');
  String get bumpFilterT3 => _p('Trimester 3', 'तीसरी तिमाही');
  String get bumpFilterCaptioned => _p('With captions', 'कैप्शन के साथ');
  String get bumpFilterFavorites => _p('Favorites', 'पसंदीदा');
  String get bumpNothingForFilter =>
      _p('No photos here yet.', 'यहाँ अभी कोई फ़ोटो नहीं।');
  String get bumpExportSoon => _p('Your bump memory book is coming soon ❤',
      'आपकी बंप यादों की किताब जल्द आ रही है ❤');
  String get bumpSaved => _p('Saved to your bump journey ❤',
      'आपके बंप सफ़र में सेव हो गया ❤');
  String bumpJournalTitle(int w) =>
      _p('Bump photo · Week $w', 'बंप फ़ोटो · हफ़्ता $w');
  String get bumpEditCaption => _p('Edit caption', 'कैप्शन बदलें');
  List<String> get bumpCaptionSuggestions => _e
      ? const [
          'Today I felt stronger.',
          'Halfway there ❤',
          'Baby is growing beautifully.',
          'Feeling excited.',
          'Our journey continues.',
        ]
      : const [
          'आज ख़ुद को और मज़बूत महसूस किया।',
          'आधा सफ़र पूरा ❤',
          'शिशु ख़ूबसूरती से बढ़ रहा है।',
          'मन उत्साह से भरा है।',
          'हमारा सफ़र जारी है।',
        ];

  // ===========================================================================
  //  DAILY MEDICATION & SUPPLEMENTS
  // ===========================================================================
  String get medTitle =>
      _p('Medication & Supplements', 'दवाइयाँ और सप्लीमेंट');
  String get medTodayNourishment =>
      _p("Today's Nourishment ❤", 'आज का पोषण ❤');
  String medProgress(int done, int total) =>
      _p('$done of $total completed today', 'आज $total में से $done पूरे');
  String get medTaken => _p('Taken', 'ले लिया');
  String get medTakenDone => _p('Taken ✓', 'ले लिया ✓');
  String medLogged(String name) => _p('$name logged ❤', '$name दर्ज हो गया ❤');
  String get medAddNew => _p('Add New', 'नया जोड़ें');
  String get medSetupTitle => _p(
      "Let's set up your supplements ❤", 'आइए आपके सप्लीमेंट सेट करें ❤');
  String get medSetupBody => _p(
      'Which supplements has your doctor recommended?',
      'आपके डॉक्टर ने कौन से सप्लीमेंट बताए हैं?');
  String get medAddCustom =>
      _p('Add custom medication', 'अपनी दवा जोड़ें');
  String get medTabDaily => _p('Daily', 'रोज़ाना');
  String get medTabWeekly => _p('Weekly', 'साप्ताहिक');
  String get medWeekOverview => _p('Week overview', 'हफ़्ते का ब्योरा');
  String medDaysOf7(int n) => _p('$n/7 days', '$n/7 दिन');
  String medConsistency(int n) => _p(
      'You recorded your supplements on $n of the last 30 days.',
      'आपने पिछले 30 दिनों में से $n दिन अपने सप्लीमेंट दर्ज किए।');
  String get medName => _p('Name', 'नाम');
  String get medDose => _p('Dose', 'ख़ुराक');
  String get medTime => _p(
      'Time (e.g. 8 PM, after breakfast)', 'समय (जैसे 8 PM, नाश्ते के बाद)');
  String get medFrequency => _p(
      'Frequency (e.g. once daily)', 'कितनी बार (जैसे रोज़ाना एक बार)');
  String get medNotes => _p('Notes (optional)', 'नोट (ज़रूरी नहीं)');
  String get medAddTitle => _p('Add medication', 'दवा जोड़ें');
  String get medDeleteQ =>
      _p('Remove this from your list?', 'इसे अपनी सूची से हटाएँ?');
  String get medDisclaimer => _p('Tracking only - always follow your doctor.',
      'सिर्फ़ रिकॉर्ड के लिए — हमेशा अपने डॉक्टर की सलाह मानें।');
  String medPresetName(String k) {
    switch (k) {
      case 'iron':
        return _p('Iron', 'Iron');
      case 'calcium':
        return _p('Calcium', 'Calcium');
      case 'folicAcid':
        return _p('Folic Acid', 'Folic Acid');
      case 'vitaminD':
        return _p('Vitamin D', 'Vitamin D');
      case 'dha':
        return _p('DHA', 'DHA');
      case 'multivitamin':
        return _p('Prenatal Multivitamin', 'Prenatal Multivitamin');
      default:
        return k;
    }
  }

  String medPresetInfo(String k) {
    switch (k) {
      case 'iron':
        return _p('Supports healthy blood production during pregnancy.',
            'गर्भावस्था में सेहतमंद ख़ून बनाने में मदद करता है।');
      case 'calcium':
        return _p("Supports your baby's bone development.",
            'आपके शिशु की हड्डियों के विकास में मदद करता है।');
      case 'folicAcid':
        return _p("Supports your baby's early development.",
            'आपके शिशु के शुरुआती विकास में मदद करता है।');
      case 'vitaminD':
        return _p('Supports calcium absorption and immunity.',
            'Calcium सोखने और रोग-प्रतिरोधक क्षमता में मदद करता है।');
      case 'dha':
        return _p("Supports your baby's brain and eye development.",
            'आपके शिशु के दिमाग़ और आँखों के विकास में मदद करता है।');
      case 'multivitamin':
        return _p('A daily blend of key pregnancy nutrients.',
            'गर्भावस्था के ज़रूरी पोषक तत्वों का रोज़ाना मिश्रण।');
      default:
        return '';
    }
  }

  // ---- Tools hub + Home Garbh ----------------------------------------------
  String get toolCanI => _p('Can I?', 'Can I?');
  String get toolsSupportNote => _p(
      'Supportive, never clinical - always check with your doctor.',
      'सहयोगी, कभी क्लिनिकल नहीं — हमेशा अपने डॉक्टर से पूछें।');
  String get homeGarbhSubtitle =>
      _p('Five gentle daily rituals', 'पाँच प्यारी रोज़ाना आदतें');

  // ===========================================================================
  //  WATCH & LEARN - contextual videos
  // ===========================================================================
  // Standardised "Today's" heading — decorative heart removed (design rule).
  String get vidTodaysVideo => _p("Today's Video", "आज का वीडियो");
  String get vidWhyNow =>
      _p('Why this matters now', 'यह अभी क्यों मायने रखता है');
  String get vidWatch => _p('Watch', 'देखें');
  String get vidSave => _p('Save', 'सेव');
  String get vidSaved => _p('Saved', 'सेव किया');
  String get vidMoreVideos => _p('More videos', 'और वीडियो');
  String get vidComingSoon => _p('This video is on its way - coming soon ❤',
      'यह वीडियो जल्द आ रहा है ❤');
  String get vidScreenTitle => _p('Watch & Learn', 'Watch & Learn');
  String get vidSecRecommended =>
      _p('Recommended for this week', 'इस हफ़्ते के लिए');
  String get vidSecSkill => _p('Learn a skill', 'एक हुनर सीखें');
  String get vidSecExpert => _p('Expert explains', 'विशेषज्ञ समझाते हैं');
  String get vidSecBirth => _p('Birth preparation', 'जन्म की तैयारी');
  String get vidSecNewborn => _p('Newborn preparation', 'नवजात की तैयारी');
  String get vidSecSaved => _p('Saved videos', 'सेव किए वीडियो');
  String get savedVaultTitle => _p('Saved', 'सेव किया');
  String get savedVaultSubtitle => _p(
      'Your bookmarked videos, in one place.',
      'आपके सेव किए वीडियो, एक जगह।');
  // Saved hub (Profile › Saved).
  String get savedHubSubtitle => _p(
      'Your saved reads, videos & read-to-baby, all here.',
      'आपके सेव किए reads, वीडियो और read-to-baby, सब यहाँ।');
  String get shTitle => _p('Saved', 'सेव किया');
  String get shReadToBaby => _p('Saved read-to-baby', 'सेव किए read-to-baby');
  String get shReads => _p('Saved reads', 'सेव किए reads');
  String get shWatch => _p('Watch & Learn', 'Watch & Learn');
  String get shRead => _p('Read more', 'और पढ़ें');
  String get shEmpty => _p(
      "Nothing saved yet. Tap the bookmark on a read, a video or a read-to-baby piece and it'll show up here.",
      'अभी कुछ सेव नहीं हुआ। किसी read, वीडियो या read-to-baby पर बुकमार्क दबाइए — वह यहाँ दिखेगा।');
  // Per-section empty notes. Each saved section renders its header even when it
  // has nothing in it, so she learns that read-to-baby pieces, reads AND videos
  // are all savable - not just the one kind she happens to have used.
  String get shReadToBabyEmpty => _p(
      'Nothing saved yet - tap the bookmark on any read-to-baby piece to keep it here.',
      'अभी कुछ सेव नहीं हुआ — किसी भी read-to-baby पर बुकमार्क दबाइए।');
  String get shReadsEmpty => _p(
      'Nothing saved yet - tap the bookmark on any read to keep it here.',
      'अभी कुछ सेव नहीं हुआ — किसी भी read पर बुकमार्क दबाइए।');
  String get shVideosEmpty => _p(
      'Nothing saved yet - tap the bookmark on any video to watch it later.',
      'अभी कुछ सेव नहीं हुआ — किसी भी वीडियो पर बुकमार्क दबाइए, बाद में देखिए।');
  String get shBrowseRtb => _p('Browse read-to-baby', 'read-to-baby देखें');
  String get rtbSave => _p('Save', 'सेव करें');

  // ===========================================================================
  //  SYMPTOMS COMPANION
  // ===========================================================================
  String get symTitle => _p('Symptoms Companion ❤', 'Symptoms Companion ❤');
  String get symToolTitle => _p('Symptoms', 'लक्षण');
  String get symSearchHint => _p(
      'What are you experiencing today?', 'आज आप क्या महसूस कर रही हैं?');
  String symCommonNow(int week) =>
      _p('Common around Week $week', 'हफ़्ता $week के आस-पास आम');
  String get symBrowse => _p('Browse by category', 'श्रेणी से देखें');
  String get symAll => _p('All symptoms', 'सारे लक्षण');
  String get symHowCommon => _p('How common is it?', 'यह कितना आम है?');
  String get symWhy => _p('Why it happens', 'यह क्यों होता है');
  String get symWhatHelps => _p('What may help', 'क्या मदद कर सकता है');
  String get symWhenDoctor =>
      _p('When to contact your doctor', 'डॉक्टर से कब संपर्क करें');
  String get symLog => _p('Log this symptom', 'यह लक्षण दर्ज करें');
  String symLogged(String name) => _p('Logged: $name', '$name दर्ज हुआ');
  String get symSeverity => _p('How strong is it?', 'कितना तेज़ है?');
  String get symMild => _p('Mild', 'हल्का');
  String get symModerate => _p('Moderate', 'मध्यम');
  String get symSevere => _p('Severe', 'तेज़');
  String get symAddToJournal =>
      _p('Add to my journal', 'मेरे जर्नल में जोड़ें');
  String get symUrgentTitle => _p('When to seek care', 'कब तुरंत मदद लें');
  String get symUrgentBody => _p(
      'These are signs to contact your doctor or maternity unit.',
      'ये संकेत हैं जब डॉक्टर या मैटरनिटी यूनिट से संपर्क करें।');
  String symInsight(String name, int n) => _p(
      "You've noted $name $n times this week.",
      'आपने इस हफ़्ते $name $n बार दर्ज किया।');
  String symJournalText(String name) =>
      _p('You noted $name today.', 'आपने आज $name दर्ज किया।');
  String get symNoResults =>
      _p('No matches - try another word.', 'कोई नतीजा नहीं — दूसरा शब्द आज़माइए।');
  String get symDisclaimer => _p(
      'For understanding, not diagnosis - your doctor is always the best guide.',
      'समझने के लिए, निदान नहीं — आपका डॉक्टर हमेशा सबसे अच्छी सलाह देते हैं।');
  String get symCatDigestive => _p('Digestive', 'पाचन');
  String get symCatPhysical => _p('Physical', 'शारीरिक');
  String get symCatSleep => _p('Sleep', 'नींद');
  String get symCatEmotional => _p('Emotional', 'भावनाएँ');
  String get symCatCirculation => _p('Circulation', 'रक्त-संचार');
  String get symCatMovement => _p('Baby movement', 'शिशु की हलचल');
  String get symCatLabour => _p('Labour signs', 'प्रसव के संकेत');
  String get symCatUrgent => _p('Urgent', 'तुरंत');

  // ===========================================================================
  //  SCANS & APPOINTMENTS - care roadmap
  // ===========================================================================
  String get calFilterAppointments => _p('Appointments', 'अपॉइंटमेंट');
  String get calChildbirth => _p('Birth', 'जन्म');
  String get calAddNote => _p('Add Note', 'नोट जोड़ें');
  String get calNoNotesDay =>
      _p('No notes for this day yet.', 'इस दिन के लिए अभी कोई नोट नहीं।');
  String get calWeeksUpper => _p('WEEKS', 'हफ़्ते');
  // Selected-day panel + colour-code legend.
  String get calOnThisDay => _p('On this day', 'इस दिन');
  String get calLegendTitle =>
      _p('What the dots mean', 'इन बिंदुओं का मतलब');
  String calTrimesterTag(int t) => switch (t) {
        1 => _p('1st tri', 'ति. 1'),
        2 => _p('2nd tri', 'ति. 2'),
        _ => _p('3rd tri', 'ति. 3'),
      };
  String calTrimesterStart(int t) => switch (t) {
        1 => _p('1st trimester begins', 'पहली तिमाही शुरू'),
        2 => _p('2nd trimester begins', 'दूसरी तिमाही शुरू'),
        _ => _p('3rd trimester begins', 'तीसरी तिमाही शुरू'),
      };
  String get calMeanMilestone =>
      _p('A pregnancy milestone', 'गर्भावस्था का एक पड़ाव');
  String get calMeanMedical =>
      _p('A scan, test or vaccination', 'स्कैन, टेस्ट या टीका');
  String get calMeanAppointment =>
      _p('A doctor appointment', 'डॉक्टर का अपॉइंटमेंट');
  String get calMeanJournal => _p(
      'A memory, photo or log you saved', 'आपकी सेव की गई याद, फ़ोटो या रिकॉर्ड');
  String get calMeanPersonal =>
      _p('A personal note you added', 'आपका जोड़ा हुआ नोट');
  String get calMeanParentveda => _p(
      'A ParentVeda unlock or "days together"',
      'ParentVeda का अनलॉक या "साथ के दिन"');
  String get calMeanWeekStart =>
      _p('The start of a pregnancy week', 'गर्भावस्था के हफ़्ते की शुरुआत');
  String get calMeanTrimester =>
      _p('A new trimester begins', 'नई तिमाही शुरू');
  String get calMeanBirth => _p('Your due date', 'आपकी डिलीवरी की तारीख़');
  String get calLegendWeekStart => _p('Week start', 'हफ़्ते की शुरुआत');
  String get calLegendTrimester => _p('Trimester start', 'तिमाही शुरू');
  String get calLegendBirth => _p('Due date', 'डिलीवरी की तारीख़');
  String get scnTitle => _p('Scans & Appointments ❤', 'स्कैन और अपॉइंटमेंट ❤');
  // Daily-home "Scans & appointments" card (the due-now list + view-all).
  String get scnDailyTitle => _p('Scans & appointments', 'स्कैन और अपॉइंटमेंट');
  String get scnAlreadyDone => _p('Already done', 'पहले से हो गया');
  String get scnViewAll => _p('View all scans', 'सभी स्कैन देखें');
  String get scnToolTitle => _p('Scans & Care', 'स्कैन और देखभाल');
  // Merged "Tests, Scans & Reports" feature (Section 16) - replaces the old
  // "Understanding Your Report" + "Scans & Care" tools.
  String get tsrTitle =>
      _p('Tests, Scans & Reports', 'टेस्ट, स्कैन और रिपोर्ट');
  String get scnTabUpcoming => _p('Upcoming', 'आगे');
  String get scnTabCompleted => _p('Completed', 'पूरे');
  String get scnTabRoadmap => _p('Care roadmap', 'देखभाल का नक़्शा');
  String get scnNextUp => _p('NEXT UP', 'अगला');
  String get scnLearnMore => _p('Learn more', 'और जानें');
  String get scnMarkDone => _p('Mark completed', 'पूरा मार्क करें');
  String get scnMarkedDone => _p('Completed ✓', 'पूरा ✓');
  String get scnImportantNote => _p(
      'Every pregnancy is unique - your doctor will guide you based on your situation.',
      'हर गर्भावस्था अलग है — आपके डॉक्टर आपकी स्थिति के हिसाब से सलाह देंगे।');
  // Scan guide - "what is this scan" + "how to interpret the report".
  String get scnWhatIs => _p('What is this scan?', 'यह स्कैन क्या है?');
  String get scnHowToInterpret =>
      _p('How to interpret the report', 'रिपोर्ट कैसे समझें');
  String get scnInterpretSub => _p('Understand the terms on your report',
      'अपनी रिपोर्ट के शब्द समझें');
  String get scnInterpretHeading =>
      _p('Reading your report', 'अपनी रिपोर्ट पढ़ना');
  String get scnInterpretDisclaimerTitle =>
      _p('Not for medical diagnosis', 'मेडिकल निदान के लिए नहीं');
  String get scnInterpretDisclaimer => _p(
      'This explains common terms to help you understand YOUR report and ask better questions. It is general information - NOT a diagnosis or medical advice, and ParentVeda is not a medical service. Always rely on your doctor or sonographer to interpret your actual results.',
      'यह आम शब्दों को समझाता है ताकि आप अपनी रिपोर्ट समझ सकें और बेहतर सवाल पूछ सकें। यह सामान्य जानकारी है — कोई निदान या मेडिकल सलाह नहीं, और ParentVeda कोई मेडिकल सेवा नहीं है। अपने असली नतीजे समझने के लिए हमेशा अपने डॉक्टर या sonographer पर भरोसा कीजिए।');
  String get scnUpToDate => _p("You're up to date - nothing due right now ❤",
      'आप अप-टू-डेट हैं — अभी कुछ बाक़ी नहीं ❤');
  String get scnNoCompleted => _p(
      'Scans you mark completed will gather here.',
      'जो स्कैन आप पूरे मार्क करेंगी, वे यहाँ जमा होंगे।');
  String get scnDelivery => _p('Delivery', 'डिलीवरी');
  String get scnAppts => _p('Your appointments', 'आपके अपॉइंटमेंट');
  String get scnAddAppt => _p('Add appointment', 'अपॉइंटमेंट जोड़ें');
  String get scnApptTitle => _p('Title', 'शीर्षक');
  String get scnApptTime => _p('Time (optional)', 'समय (ज़रूरी नहीं)');
  String get scnApptLocation => _p('Location (optional)', 'जगह (ज़रूरी नहीं)');
  String get scnApptDoctor => _p('Doctor (optional)', 'डॉक्टर (ज़रूरी नहीं)');
  String get scnTypeDoctor => _p('Doctor visit', 'डॉक्टर से मिलना');
  String get scnTypeScan => _p('Scan', 'स्कैन');
  String get scnTypeTest => _p('Test', 'टेस्ट');
  String get scnTypeVaccination => _p('Vaccination', 'टीका');
  String get scnTypeCustom => _p('Custom', 'अपना');
  String scnCompletedJournal(String name) =>
      _p('$name - completed', '$name — पूरा');

  // ===========================================================================
  //  DUE DATE CALCULATOR
  // ===========================================================================
  String get ddcTitle => _p('Due Date Calculator', 'डिलीवरी तारीख़ कैलकुलेटर');
  String get ddcToolTitle => _p('Due Date', 'डिलीवरी की तारीख़');
  String get ddcHeader => _p('When is my baby due?', 'मेरा शिशु कब आने वाला है?');
  String get ddcSub => _p(
      'Calculate your due date, timeline and upcoming milestones.',
      'अपनी डिलीवरी की तारीख़, टाइमलाइन और आने वाले पड़ाव जानिए।');
  String get ddcMethod =>
      _p('How would you like to calculate?', 'आप कैसे हिसाब लगाना चाहेंगी?');
  String get ddcLmp => _p('Last period (LMP)', 'पिछला पीरियड (LMP)');
  String get ddcConception => _p('Conception date', 'गर्भधारण की तारीख़');
  String get ddcIvf => _p('IVF transfer', 'IVF ट्रांसफ़र');
  String get ddcUltrasound => _p('Ultrasound dating', 'अल्ट्रासाउंड डेटिंग');
  String get ddcKnown =>
      _p('I know my due date', 'मुझे मेरी डिलीवरी की तारीख़ पता है');
  String get ddcLmpDate => _p('First day of your last period',
      'आपके पिछले पीरियड का पहला दिन');

  /// Shown when the date is one WE calculated. A dating scan is more accurate
  /// than counting from a last period, and the clinic owns the scan - so we say
  /// so at the moment she is choosing, rather than quietly holding a number
  /// that may already disagree with her doctor.
  String get ddcScanWins => _p(
      'If a scan has already given you a date, use that instead. A dating scan is more accurate than counting from a period, and your clinic\'s date is the one that counts.',
      'अगर स्कैन से आपको तारीख़ मिल चुकी है तो वही इस्तेमाल कीजिए। डेटिंग स्कैन पीरियड से गिनने के मुक़ाबले ज़्यादा सही होता है, और आपकी क्लिनिक की तारीख़ ही मायने रखती है।');
  /// The after-the-fact half of the same idea (§9.1b).
  ///
  /// `ddcScanWins` above says it while she is choosing. This says it later, once
  /// a dating scan has probably happened and we are still counting from
  /// something weaker.
  ///
  /// "If you have had" — an offer, not a correction. The app does not know she
  /// had a scan and does not get to tell her her date is wrong. `TruthSource`
  /// puts her clinician above our calculation; this is the one place we can act
  /// on that with no clinician in the room.
  String get ddcMayBeStale => _p(
      'If you have had a dating scan since, its date is the better one.',
      'अगर उसके बाद डेटिंग स्कैन हुआ है, तो उसकी तारीख़ बेहतर है।');

  String get ddcCycle => _p('Cycle length', 'साइकिल की लंबाई');
  String get ddcDays => _p('days', 'दिन');
  String get ddcDaysLabel => _p('Days', 'दिन');
  String get ddcConceptionDate =>
      _p('Conception date', 'गर्भधारण की तारीख़');
  String get ddcTransferDate =>
      _p('Embryo transfer date', 'Embryo ट्रांसफ़र की तारीख़');
  String get ddcEmbryoDay => _p('Embryo age', 'Embryo की उम्र');
  String get ddcDay3 => _p('Day 3', 'दिन 3');
  String get ddcDay5 => _p('Day 5', 'दिन 5');
  String get ddcScanDate => _p('Date of ultrasound', 'अल्ट्रासाउंड की तारीख़');
  String get ddcGa => _p('Gestational age at scan', 'स्कैन के समय gestational age');
  String get ddcKnownDate => _p('Your due date', 'आपकी डिलीवरी की तारीख़');
  String get ddcPickDate => _p('Pick a date', 'तारीख़ चुनिए');
  String get ddcCalculate =>
      _p('Calculate My Due Date', 'मेरी डिलीवरी की तारीख़ निकालें');
  String get ddcResultLead => _p(
      'Your baby is expected around', 'आपका शिशु आने वाला है लगभग');
  String get ddcTimeline => _p('Your timeline', 'आपकी टाइमलाइन');
  String get ddcMilestones =>
      _p('Key milestones ahead', 'आगे के ख़ास पड़ाव');
  String get ddcTrimesters =>
      _p('Trimester breakdown', 'तिमाही का ब्योरा');
  String get ddcConceptionTitle =>
      _p('Conception & months', 'गर्भधारण और महीने');
  String get ddcConceptionAround =>
      _p('Estimated conception around', 'अनुमानित गर्भधारण लगभग');
  String get ddcMonths => _p('Month by month', 'महीने-दर-महीने');
  String get ddcMsHeartbeat => _p('Heartbeat', 'धड़कन');
  String get ddcMsNt => _p('NT Scan', 'NT Scan');
  String get ddcMsAnomaly => _p('Anomaly Scan', 'Anomaly Scan');
  String get ddcMsViability => _p('Viability', 'Viability');
  String get ddcMsThirdTri => _p('Third Trimester', 'तीसरी तिमाही');
  String get ddcMsFullTerm => _p('Full Term', 'पूरा समय');
  String get ddcMsDue => _p('Due Date', 'डिलीवरी की तारीख़');
  String get ddcReady => _p('Your pregnancy journey is ready 💜',
      'आपकी गर्भावस्था का सफ़र तैयार है 💜');
  String get ddcBenWeekly => _p('Weekly development', 'साप्ताहिक विकास');
  String get ddcBenDaily => _p('Daily guidance', 'रोज़ाना मार्गदर्शन');
  String get ddcBenScans => _p('Scan reminders', 'स्कैन के रिमाइंडर');
  String get ddcBenGarbh => _p('Garbh Sanskar', 'गर्भ संस्कार');
  String get ddcBenSymptoms => _p('Symptom support', 'लक्षणों में मदद');
  String get ddcBenBag => _p('Hospital bag', 'अस्पताल बैग');
  String get ddcStart => _p('Start My Pregnancy Journey',
      'मेरा गर्भावस्था सफ़र शुरू करें');
  String get ddcStarted =>
      _p('Your journey is set 💜', 'आपका सफ़र तय हो गया 💜');
  String get ddcRecalculate => _p('Recalculate', 'दोबारा निकालें');

  // ===========================================================================
  //  ASK VEDA - companion (preview)
  // ===========================================================================
  String get vedaTitle => _p('Ask Veda', 'Ask Veda');
  String get vedaToolTitle => _p('Ask Veda', 'Ask Veda');
  String get vedaTagline => _p('Your pregnancy & parenting companion',
      'आपकी गर्भावस्था और परवरिश की साथी');
  String get vedaComingSoon => _p('Coming soon', 'जल्द आ रहा है');
  String get vedaBeta => _p('Beta', 'Beta');
  String get vedaWelcome => _p(
      "Hello 💜 I'm Veda. Ask me about a food, a symptom or your week, and I'll share what we know - drawn from ParentVeda's guidance. I'm still learning, and I'll get better as we grow.",
      'नमस्ते 💜 मैं वेदा हूँ। मुझसे किसी खाने, लक्षण या अपने हफ़्ते के बारे में पूछिए — मैं ParentVeda की जानकारी से जो पता है वह बताऊँगी। मैं अभी सीख रही हूँ, और आगे और बेहतर होती जाऊँगी।');
  String get vedaHint => _p('Ask AskVeda', 'Ask AskVeda');
  String get vedaTrySomething => _p('Try asking', 'यह पूछिए');
  String get vedaReply => _p(
      "I'm almost ready 💜 Veda is launching soon - I'll answer this with your week, scans and journal in mind. I'll let you know the moment I'm here.",
      'मैं लगभग तैयार हूँ 💜 वेदा जल्द आ रही है — मैं इसका जवाब आपके हफ़्ते, स्कैन और जर्नल को ध्यान में रखकर दूँगी। आते ही आपको बता दूँगी।');
  String get vedaVoice => _p('Voice', 'आवाज़');
  String get vedaVoiceSoon =>
      _p('Voice questions are coming soon 💜', 'आवाज़ से सवाल जल्द आ रहे हैं 💜');
  String get vedaImage => _p('Photo', 'फ़ोटो');
  String get vedaImageSoon => _p(
      'Photo questions (rashes, reports, labels) are coming soon 💜',
      'फ़ोटो से सवाल (रैश, रिपोर्ट, लेबल) जल्द आ रहे हैं 💜');
  // Offline "answer from our own content" (Can I? + Symptoms).
  String get vedaDisclaimer => _p(
      'This is general guidance from what I know - please confirm anything important with your doctor. 💜',
      'यह मेरी जानकारी से सामान्य मार्गदर्शन है — कुछ भी ज़रूरी हो तो अपने डॉक्टर से ज़रूर पुष्टि कीजिए। 💜');
  String get vedaNoMatch => _p(
      "I don't have a confident answer on that yet - I'm still learning. Try asking about a food (\"Can I eat papaya?\"), a symptom, or use the Can I? tool. I'll answer more as ParentVeda grows. 💜",
      "इसका पक्का जवाब अभी मेरे पास नहीं है — मैं अभी सीख रही हूँ। किसी खाने (\"क्या मैं पपीता खा सकती हूँ?\"), लक्षण के बारे में पूछिए, या Can I? टूल इस्तेमाल कीजिए। ParentVeda के बढ़ने के साथ मैं और जवाब दूँगी। 💜");
  String get vedaFromYourApp =>
      _p('From your ParentVeda', 'आपके ParentVeda से');
  // Structured showcase result-page section headers.
  String get vedaWhatMeans =>
      _p('What this means for you', 'आपके लिए इसका मतलब');
  String get vedaNextActions =>
      _p('Recommended next actions', 'आगे के सुझाए क़दम');
  String get vedaPvContent => _p('From ParentVeda', 'ParentVeda से');
  String get vedaCommunityInsights =>
      _p('Community insights', 'कम्युनिटी की बातें');
  String get vedaProductsHdr => _p('Products', 'प्रोडक्ट');
  String get vedaServices => _p('Services', 'सेवाएँ');
  String get vedaUrgentBanner => _p(
      'Please act now - contact your maternity unit',
      'कृपया अभी क़दम उठाइए — अपनी मैटरनिटी यूनिट से संपर्क कीजिए');
  // Stage-wise suggested questions (the Ask Veda home, before you type).
  String get vedaSuggestHeader =>
      _p("What's on your mind?", 'क्या पूछना चाहती हैं?');
  String get vedaSuggestSub => _p(
      'Tap a question, or type your own below.',
      'कोई सवाल टैप कीजिए, या नीचे अपना लिखिए।');
  String get vedaStageSoon =>
      _p('As your journey grows', 'जैसे-जैसे आपका सफ़र बढ़ेगा');
  String get vedaShuffle => _p('Shuffle questions', 'नए सवाल');
  // Ask Veda structured result page (the "Ask Veda Results" design).
  String get vedaAnswerLabel => _p('Veda Answer', 'वेदा का जवाब');
  String get vedaWhenChecked =>
      _p('When to get checked', 'कब डॉक्टर को दिखाएँ');
  String get vedaMoreInfo => _p('More information', 'और जानकारी');
  // Retrieval-path 7-section answer: personalization default, default actions,
  // community social-proof, and content-TYPE labels for Section 4.
  String get vedaMeansDefault => _p(
      "Here's what ParentVeda's guidance suggests for where you are right now.",
      'ParentVeda का मार्गदर्शन आपकी अभी की स्थिति के लिए यह सुझाता है।');
  String get vedaActionExplore => _p(
      'Explore the related ParentVeda content below.',
      'नीचे दी गई ParentVeda सामग्री देखिए।');
  String get vedaActionTrack => _p(
      'Note how you\'re feeling and track it over the next few days.',
      'आप कैसा महसूस कर रही हैं, यह दर्ज कीजिए और अगले कुछ दिन ध्यान रखिए।');
  String get vedaActionDoctor => _p(
      'If it persists or worries you, check with your doctor.',
      'अगर यह बना रहे या चिंता हो, तो अपने डॉक्टर से बात कीजिए।');
  String vedaCommunitySocial(int n) => _p(
      'Other ParentVeda mothers have asked about this too.',
      'ParentVeda की दूसरी माँओं ने भी इसके बारे में पूछा है।');
  String get vedaTypeCanI => _p('Can-I guide', 'Can-I गाइड');
  String get vedaTypeSymptom => _p('Symptom guide', 'लक्षण गाइड');
  String get vedaTypeWeekly => _p('Weekly journey', 'साप्ताहिक सफ़र');
  String get vedaTypeRead => _p('Read', 'पढ़ें');
  String get vedaTypeTip => _p('Trimester tip', 'तिमाही की सलाह');
  String get vedaTypeReflection => _p('Reflection', 'सोच-विचार');
  String get vedaTypeReadBaby => _p('Read to baby', 'Read to baby');
  String get vedaTypeGarbh => _p('Garbh Sanskar', 'गर्भ संस्कार');
  String get vedaTypeBody => _p('Body changes', 'शरीर के बदलाव');
  String get vedaTypeTool => _p('Tool', 'टूल');
  String get vedaTypeProduct => _p('Product', 'प्रोडक्ट');
  String get vedaTypeCommunity => _p('Community', 'कम्युनिटी');
  String get vedaTypeScan => _p('Scan guide', 'स्कैन गाइड');
  String get vedaTalkExpert => _p('Talk to an expert', 'विशेषज्ञ से बात करें');
  String get vedaProductsHint =>
      _p('Suggested for your question', 'आपके सवाल के हिसाब से');
  String get vedaBook => _p('Book', 'बुक करें');
  String get vedaCall => _p('Call', 'कॉल करें');
  String get vedaVerdictSafe => _p('Generally safe ✅', 'आम तौर पर सुरक्षित ✅');
  String get vedaVerdictModeration =>
      _p('Fine in moderation ⚖️', 'सीमित मात्रा में ठीक ⚖️');
  String get vedaVerdictDepends => _p('It depends 🤔', 'यह निर्भर करता है 🤔');
  String get vedaVerdictAvoid => _p('Best avoided 🚫', 'बेहतर है बचें 🚫');
  String get vedaVerdictAskDoctor =>
      _p('Ask your doctor 🩺', 'अपने डॉक्टर से पूछें 🩺');
  List<String> get vedaExamples => _e
      ? const [
          'Can I eat papaya?',
          'Is coffee safe now?',
          'Can I eat pineapple?',
          'Is back pain normal now?',
          'What helps with heartburn?',
          'How can I sleep better?',
        ]
      : const [
          'क्या मैं पपीता खा सकती हूँ?',
          'क्या कॉफ़ी पीना ठीक है?',
          'क्या अभी कमर दर्द होना सामान्य है?',
          'एसिडिटी कम कैसे करें?',
          'बेहतर नींद कैसे आए?',
          'क्या मैं अनानास खा सकती हूँ?',
        ];

  // ===========================================================================
  //  WEEK'S TO GO (weekly header)
  // ===========================================================================
  String weeksToGo(int n) => _p(n == 1 ? '1 week to go' : '$n weeks to go',
      n == 1 ? '1 हफ़्ता बाक़ी' : '$n हफ़्ते बाक़ी');
  String get weeksToGoNow => _p('Any day now 💜', 'कभी भी 💜');
  String get flowDaily => _p('Daily', 'रोज़ाना');
  String get flowWeekly => _p('Weekly', 'साप्ताहिक');
  String get snapThisWeek => _p('This week', 'इस हफ़्ते');
  String get snapOpenWeek => _p('View week', 'हफ़्ता देखें');
  String get sizeWord => _p('Size', 'आकार');
  String get wkVideoEyebrow => _p('Watch this week', 'इस हफ़्ते देखें');
  // The weekly video is labelled by the week it covers (replaces "Watch this
  // week"), so it reads as that week's video.
  String wkPregnancyWeek(int n) =>
      _p('Pregnancy Week $n', 'गर्भावस्था हफ़्ता $n');
  String get wkVideoSoon =>
      _p('Playback coming soon 💜', 'प्लेबैक जल्द आ रहा है 💜');
  String get ttEyebrow => _p('Trimester tips', 'तिमाही की सलाह');
  String ttTitle(int week) => _p('Tips for week $week', 'हफ़्ता $week की सलाह');
  String get journeyTrailKicker =>
      _p('Your trail to birth', 'जन्म तक का आपका रास्ता');
  String gsKicker(int week) =>
      _p('Garbh Sanskar · Week $week', 'गर्भ संस्कार · हफ़्ता $week');
  String get gsFiveRituals =>
      _p('Five gentle rituals', 'पाँच कोमल आदतें');

  // Week 20 "ParentVeda Journey" overview accordions (design preview)
  String get ovBaby => _p('Baby', 'शिशु');
  String get ovBabySub =>
      _p("What I'm doing this week", 'इस हफ़्ते मैं क्या कर रहा हूँ');
  String get ovMother => _p('Mother', 'माँ');
  String get ovMotherSub =>
      _p("How you're feeling", 'आप कैसा महसूस कर रही हैं');
  String get ovHealth => _p('Health', 'सेहत');
  String get ovHealthSub => _p("This week's care", 'इस हफ़्ते की देखभाल');
  String get ovVideoWhy => _p('Why this matters', 'यह क्यों ज़रूरी है');
  String get msEyebrow => _p('Milestones', 'पड़ाव');
  String get msTitle => _p("Baby's journey", 'शिशु का सफ़र');
  String get msThisWeek => _p('This week', 'इस हफ़्ते');

  // ===========================================================================
  //  WEEK FLOW (V2 - week 20 vertical-flow preview)
  // ===========================================================================
  String get wfClassic => _p('Classic', 'क्लासिक');
  String get wfNew => _p('New', 'नया');
  String get weeklyBackToDaily => _p('Daily', 'रोज़ाना');
  // Global search (Home search icon).
  String get searchHint =>
      _p('Search ParentVeda…', 'ParentVeda में खोजें…');
  String get searchEmptyHint => _p(
      'Search products, reads, foods, symptoms and tools.',
      'प्रोडक्ट, reads, खाना, लक्षण और टूल खोजें।');
  String get searchNoResults =>
      _p('No results for', 'कोई नतीजा नहीं मिला');
  String get searchTools => _p('Tools & sections', 'टूल और सेक्शन');
  String get searchProducts => _p('Products', 'प्रोडक्ट');
  String get searchReads => _p('Reads', 'Reads');
  String get searchCanI => _p('Can I?', 'Can I?');
  String get searchSymptoms => _p('Symptoms', 'लक्षण');
  String get navProducts => _p('Products', 'प्रोडक्ट');
  String get wfBabySection => _p('About your baby', 'आपके शिशु के बारे में');
  String get wfMotherSection => _p('For you, mum', 'आपके लिए, माँ');
  String get wfNextSection => _p("What's next", 'आगे क्या');
  String get wfNextBrief => _p(
      'Scans, appointments and milestones coming up around now.',
      'आने वाले स्कैन, अपॉइंटमेंट और पड़ाव।');
  String get wfVideosSection => _p("This week's videos", 'इस हफ़्ते के वीडियो');
  String get wfArticlesSection => _p("This week's reads", 'इस हफ़्ते के reads');
  String get wfPartnerSection =>
      _p('Share with your partner', 'साथी के साथ साझा करें');
  String get wfTapExplore =>
      _p('Tap to explore', 'देखने के लिए टैप करें');
  String get wfBabyScience => _p('Baby Science', 'Baby Science');
  String get wfSwipeHint =>
      _p('Swipe for Baby Science', 'Baby Science के लिए स्वाइप करें');
  String get wfBabyMilestones =>
      _p('Milestones around now', 'अभी के आस-पास के पड़ाव');
  String get wfMotherThisWeek => _p('Mother this week', 'माँ इस हफ़्ते');
  // Combined Mother page (the "for you, mum" read + "mother this week" merged).
  String get wfYouThisWeek => _p('You this week', 'आप इस हफ़्ते');
  // Organic "daily moment" nudge woven into the weekly flow.
  String get wfDailyBridgeKicker =>
      _p('DON\'T MISS', 'छूट न जाए');
  String get wfDailyBridgeTitle =>
      _p('Your daily moment is waiting', 'आपका रोज़ का पल इंतज़ार में है');
  String get wfDailyBridgeBody => _p(
      "Today's reads, Garbh Sanskar and a journal prompt are ready for you on Home.",
      'आज के reads, गर्भ संस्कार और एक जर्नल सवाल Home पर तैयार हैं।');
  String get wfDailyBridgeCta => _p('Go to today', 'आज पर जाएँ');
  // Mother health page - three toggles on one page.
  String get wfTabSymptoms => _p('Symptoms', 'लक्षण');
  String get wfTabDiet => _p('Diet', 'खानपान');
  String get wfTabActions => _p('Actions', 'काम');
  // Inline media-placeholder tags woven into the reads.
  String get wfMediaVideo => _p('VIDEO', 'वीडियो');
  String get wfMediaPhoto => _p('PHOTO', 'फ़ोटो');
  String get wfHealthThisWeek => _p('Health this week', 'सेहत इस हफ़्ते');
  String get wfEatThisWeek =>
      _p('What to eat this week', 'इस हफ़्ते क्या खाएँ');
  String get wfDoThisWeek => _p('What to do this week', 'इस हफ़्ते क्या करें');
  String get wfSwipeMore =>
      _p('Swipe for more', 'और देखने के लिए स्वाइप करें');
  String get wfHealthIntro => _p(
      'Common, normal things you may notice now - tap any to understand it and what helps.',
      'आम, सामान्य बातें जो आप अभी महसूस कर सकती हैं — किसी को भी समझने के लिए टैप कीजिए।');
  String get wfTapToRead => _p('Read about it', 'इसके बारे में पढ़ें');
  String get wfMilestonesTitle =>
      _p('Upcoming milestones', 'आने वाले पड़ाव');
  String get wfScansTitle =>
      _p('Scans & appointments', 'स्कैन और अपॉइंटमेंट');
  String get wfNextIntro => _p(
      "Here's what's coming up in your journey - the milestones your baby will reach, and the scans worth keeping on your radar. A little glimpse ahead helps you feel prepared and calm.",
      'आगे आपके सफ़र में क्या आने वाला है — शिशु के पड़ाव और ध्यान रखने लायक़ स्कैन। आगे की थोड़ी झलक, ताकि आप तैयार और शांत महसूस करें।');
  String get wfNextRadar => _p('On your radar', 'आपके ध्यान में');
  // What's-next tab labels (single page, no swipe) + the "for you" forward look.
  String get wfNextTabScans => _p('Scans', 'स्कैन');
  String get wfNextTabYou => _p('For you', 'आपके लिए');
  String get wfNextTabMilestones => _p('Milestones', 'पड़ाव');
  String get wfNextMotherIntro => _p(
      'A gentle look at how you may feel in the weeks just ahead - your body changing, step by step.',
      'आने वाले हफ़्तों में आप कैसा महसूस कर सकती हैं — आपका शरीर धीरे-धीरे बदलता हुआ, एक हल्की सी झलक।');
  String get wfBodyLabel => _p('Your body', 'आपका शरीर');
  String get wfFeelLabel => _p('How you may feel', 'कैसा लग सकता है');
  String get wfGotIt => _p('Got it', 'समझ गई');
  String get wfTipsTitle => _p('Trimester tips', 'तिमाही की सलाह');
  String wfTrimesterLabel(int t) => _p('Trimester $t', 'तिमाही $t');
  String wfWeeksToGo(int n) => _p('$n weeks to go', '$n हफ़्ते बाक़ी');
  String wfPercentThere(int pct) => _p('$pct% there', '$pct% पूरा');

  // Garbh tool + Products (daily carousel)
  String get garbhToolTitle => _p('Garbh Sanskar', 'गर्भ संस्कार');
  // Spiritual Reading (a gentle, neutral, surface-level testing feature).
  String get sprToolTitle => _p('Spiritual Reading', 'आध्यात्मिक पाठ');
  String get sprTitle => _p('Spiritual Reading', 'आध्यात्मिक पाठ');
  String get sprDisclaimer => _p(
      'A gentle, surface-level look at how a few traditions approach pregnancy and motherhood - shared for comfort and curiosity, with respect for all beliefs. Not religious instruction.',
      'कुछ परंपराएँ गर्भावस्था और मातृत्व को कैसे देखती हैं, उसकी एक हल्की सी झलक — सुकून और जिज्ञासा के लिए, सभी विश्वासों के सम्मान के साथ। यह कोई धार्मिक निर्देश नहीं है।');
  String get sprFootnote => _p(
      'Shared respectfully for comfort and reflection - not as religious advice. Every family’s beliefs are their own.',
      'सुकून और सोच के लिए सम्मान के साथ साझा किया गया — धार्मिक सलाह के तौर पर नहीं। हर परिवार के विश्वास उनके अपने हैं।');
  String sprViewAll(int n) =>
      _p('View all $n readings', 'सभी $n पाठ देखें');
  String get prodSectionTitle => _p(
      "Today's product recommendation", 'आज का प्रोडक्ट सुझाव');
  String get prodSeeAll => _p('See all', 'सब देखें');
  // Weekly snapshot + Today's journey (Home segregation).
  String get snapshotTitle => _p('Weekly snapshot', 'हफ़्ते की झलक');
  String get todaysJourney => _p("Today's journey", 'आज का सफ़र');
  String weeksLeftShort(int n) => _p('$n wks to go', '$n हफ़्ते बाक़ी');
  // ---- Trimester progress bar (replaces the circular ring app-wide) ---------
  String trimesterLabel(int t) => _p('Trimester $t', 'तिमाही $t');
  String trimesterShort(int t) => _p('T$t', 'ति$t');
  /// "4 weeks 2 days to go" / "Baby's here!" — the calm remaining-time line.
  String timeToGo(int weeks, int days) {
    if (weeks <= 0 && days <= 0) return _p("Baby's almost here", 'शिशु आने ही वाला है');
    final w = weeks > 0
        ? _p('$weeks ${weeks == 1 ? 'week' : 'weeks'}',
            '$weeks ${weeks == 1 ? 'हफ़्ता' : 'हफ़्ते'}')
        : '';
    final d = days > 0
        ? _p('$days ${days == 1 ? 'day' : 'days'}', '$days दिन')
        : '';
    final joined = [w, d].where((e) => e.isNotEmpty).join(' ');
    return _p('$joined to go', '$joined बाक़ी');
  }
  String get medManageCta => _p('Manage', 'मैनेज करें');
  String get prodSeeNow => _p('See now', 'अभी देखें');
  String get wfTabThisWeek => _p('This week', 'इस हफ़्ते');
  String get wfTabHealth => _p('Health', 'सेहत');
  String get wfTabEat => _p('Eat', 'खाएँ');
  String get wfTabDo => _p('To-do', 'करने को');
  String get wfTabScans => _p('Scans', 'स्कैन');
  String get wfTabMilestones => _p('Milestones', 'पड़ाव');
  String get wfAvoid => _p('What to avoid', 'क्या न खाएँ');
  String get wfDisclaimer => _p(
      'This is for understanding, not diagnosis - your doctor is always the best guide.',
      'यह समझने के लिए है, निदान नहीं — आपका डॉक्टर हमेशा सबसे अच्छी सलाह देते हैं।');
  String get wfPartnerCta =>
      _p('Share update on WhatsApp', 'WhatsApp पर अपडेट भेजें');
  String get wfPartnerBlurb => _p(
      'Send your partner a crisp summary of this week - baby, you, scans and how they can help.',
      'अपने साथी को इस हफ़्ते का साफ़ ब्योरा भेजिए — शिशु, आप, स्कैन और वे कैसे मदद कर सकते हैं।');
  String wfPartnerHeader(int week) =>
      _p('Our pregnancy · Week $week', 'हमारी गर्भावस्था · हफ़्ता $week');
  String get wfPartnerScans =>
      _p('Check upcoming scans together in the app.',
          'ऐप में आने वाले स्कैन साथ देखिए।');
  String get wfPartnerHelp =>
      _p('How you can help', 'आप कैसे मदद कर सकते हैं');
  String get wfPartnerScansHeader =>
      _p('Scans & appointments coming up:', 'आने वाले स्कैन और अपॉइंटमेंट:');
  String get wfPartnerSignoff => _p(
      "You're in this together 💜", 'आप दोनों इस सफ़र में साथ हैं 💜');

  // ---- Module eyebrows -----------------------------------------------------
  String get growEyebrow =>
      _p("Today's Parenting Tip", 'आज की परवरिश सलाह');
  String get readEyebrow => _p('Read To Your Baby', 'अपने शिशु को सुनाइए');
  String get medDailyTitle => _p(
      'Daily medication and supplements', 'रोज़ाना दवाइयाँ और सप्लीमेंट');
  String get medHomeSubtitle => _p("Track today's medicines & supplements",
      'आज की दवाइयाँ और सप्लीमेंट दर्ज करें');
  String get medTrackCta => _p('Track today', 'आज दर्ज करें');
  String get talkEyebrow => _p('Talk To Your Baby', 'अपने शिशु से बात कीजिए');
  String get momentForYouEyebrow => _p('A Moment For You', 'आपके लिए एक पल');
  String get movementEyebrow =>
      _p('Baby Movement Check-In', 'शिशु की हलचल का हाल');

  // ---- Shared CTAs / labels ------------------------------------------------
  String get readMore => _p('Read More', 'और पढ़ें');
  String get readCta => _p('Read', 'पढ़ें');
  String get listenCta => _p('Listen', 'सुनें');
  // Read-to-your-baby customizable feed.
  String get rtbCustomize => _p('Customize', 'अपने हिसाब से');
  String get rtbCustomizeTitle =>
      _p('Customize this feed', 'यह फ़ीड अपने हिसाब से बनाएँ');
  String get rtbCustomizeSub => _p('Choose what your daily read draws from.',
      'चुनिए कि आपका रोज़ का पाठ कहाँ से आए।');
  String get rtbSpeaking => _p('Speaking cards', 'बोलने के कार्ड');
  String get rtbStories => _p("Children's stories", 'बच्चों की कहानियाँ');
  String get rtbSpiritual => _p('Spiritual reading', 'आध्यात्मिक पाठ');
  String get rtbRhymes => _p('Rhymes & lullabies', 'तुकबंदी और लोरियाँ');
  String get rtbAffirmations =>
      _p('Affirmations & blessings', 'संकल्प और आशीर्वाद');
  String get rtbPickReligions =>
      _p('Pick traditions', 'परंपराएँ चुनें');
  String get recordCta => _p('Record', 'रिकॉर्ड करें');
  String get writeCta => _p('Write', 'लिखें');
  String get maybeLater => _p('Maybe later', 'बाद में');
  String get playCta => _p('Play', 'चलाएँ');
  String get beginCta => _p('Begin', 'शुरू करें');
  String get keepThisWithMe =>
      _p('Keep This With Me', 'इसे अपने पास रखें');
  String get keptLabel => _p('Kept 💜', 'रख लिया 💜');
  String get rememberLabel => _p('Remember', 'याद रखें');
  String get deepDiveLabel => _p('A little deeper', 'थोड़ा गहराई में');

  // ---- Garbh Sanskar (home) ------------------------------------------------
  String get todaysPractice => _p("Today's Practice", 'आज का अभ्यास');
  String get ragaLabel => _p('RAGA', 'राग');
  String get meditationLabel => _p('GUIDED MEDITATION', 'निर्देशित ध्यान');
  String get affirmationLabel => _p('AFFIRMATION', 'संकल्प');
  String minutesShort(int m) => _p('$m min', '$m मिनट');
  String get aboutGarbhTitle =>
      _p('About Garbh Sanskar', 'गर्भ संस्कार के बारे में');
  String get whyItMatters => _p('Why it matters', 'यह क्यों मायने रखता है');
  String get howToUseIt => _p('How to use it', 'इसे कैसे इस्तेमाल करें');
  String get infoTooltip =>
      _p('What is this?', 'यह क्या है?');
  String get gotIt => _p('Got it', 'समझ गई');

  // ---- Talk To Your Baby ---------------------------------------------------
  String get talkWriteHint => _p('Write your message to your baby…',
      'अपने शिशु के लिए अपना संदेश लिखिए…');
  String get talkListening =>
      _p('Listening… speak now', 'सुन रहे हैं… अब बोलिए');
  String get talkSpeakHint => _p(
      'Tap the mic and speak - we will gently write it down.',
      'माइक दबाइए और बोलिए — हम उसे प्यार से लिख देंगे।');
  String get talkSaved =>
      _p('Saved to Dear Baby 💜', 'Dear Baby में सेव हो गया 💜');
  String get talkSaveCta => _p('Save to Dear Baby', 'Dear Baby में सेव करें');
  String get talkSavedBadge => _p('Saved to Dear Baby', 'Dear Baby में सेव');

  // ---- Completion ----------------------------------------------------------
  String get completionTitle => _p('You gave yourself 6 minutes today.',
      'आज आपने ख़ुद को 6 मिनट दिए।');
  String get completionSubtitle => _p('That matters more than you know.',
      'यह आपकी सोच से ज़्यादा मायने रखता है।');

  // ---- Emotional Check-In --------------------------------------------------
  String get feelingQuestion => _p('How are you feeling right now?',
      'अभी आप कैसा महसूस कर रही हैं?');
  String get feelingSubtext => _p('No right answer. Just checking in with you.',
      'कोई सही जवाब नहीं। बस आपका हाल पूछ रहे हैं।');
  String get moodSaved => _p('Saved 💜', 'सेव हो गया 💜');
  String moodLabel(String id) {
    switch (id) {
      case 'happy':
        return _p('Happy', 'ख़ुश');
      case 'grateful':
        return _p('Grateful', 'शुक्रगुज़ार');
      case 'calm':
        return _p('Calm', 'शांत');
      case 'hopeful':
        return _p('Hopeful', 'उम्मीद से भरी');
      case 'tired':
        return _p('Tired', 'थकी हुई');
      case 'anxious':
        return _p('Anxious', 'चिंतित');
      case 'overwhelmed':
        return _p('Overwhelmed', 'बोझ महसूस');
      case 'loved':
        return _p('Loved', 'प्यार महसूस');
      default:
        return id;
    }
  }

  // ---- Baby Movement (Week 28+) --------------------------------------------
  String get movementQuestion =>
      _p('Did your baby move today?', 'क्या आज आपके शिशु ने हलचल की?');
  String get movementSubtext => _p('No counting. No targets. Just awareness.',
      'कोई गिनती नहीं। कोई लक्ष्य नहीं। बस ध्यान।');
  String get yesWord => _p('Yes', 'हाँ');
  String get notYet => _p('Not yet', 'अभी नहीं');
  String get movementYes =>
      _p('Wonderful 💚 Your baby is active today.',
         'बहुत अच्छा 💚 आपका शिशु आज सक्रिय है।');
  String get movementNotYet => _p(
      "That's okay. Try lying on your left side, drink something cold, and spend 30 minutes focusing on movement.",
      'कोई बात नहीं। बाईं करवट लेटने की कोशिश कीजिए, कुछ ठंडा पीजिए, और 30 मिनट हलचल पर ध्यान दीजिए।');
  String get movementEscalation => _p(
      'Still not feeling movement? Contact your doctor.',
      'फिर भी हलचल महसूस नहीं हो रही? अपने डॉक्टर से संपर्क कीजिए।');

  // ---- Bottom navigation + tabs --------------------------------------------
  // Direction B (Warm Nest) floating tab bar:
  String get tabToday => _p('Today', 'आज');
  String get tabJourney => _p('Journey', 'सफ़र');
  String get tabPrepare => _p('Prepare', 'तैयारी');
  String get tabSanskar => _p('Sanskar', 'संस्कार');
  String get tabRead => _p('Read', 'पढ़ें');
  String get tabCommunity => _p('Community', 'कम्युनिटी');

  String get homeTab => _p('Home', 'होम');
  String get myBabyTab => _p('My Baby', 'मेरा शिशु');
  String get dearBabyTab => _p('Dear Baby', 'Dear Baby');
  String get toolsTab => _p('Tools', 'टूल');
  String get exploreTab => _p('Explore', 'एक्सप्लोर');
  String get profileTab => _p('Profile', 'प्रोफ़ाइल');

  // ===========================================================================
  //  PROFILE TAB + DEAR BABY MEMORY VAULT
  // ===========================================================================

  String get profileTitle => _p('Profile', 'प्रोफ़ाइल');
  String get profileSignOut => _p('Sign out', 'साइन आउट');
  String get languageLabel => _p('Language', 'भाषा');
  String get languageEnglish => 'English';
  /// The LABEL on the language toggle. Devanagari, because it names a language
  /// to the person who reads that language — "हिन्दी" is what she calls it.
  ///
  /// It said "Hinglish" until 2026-08-12, which by then was simply untrue: the
  /// house style moved to Devanagari on 2026-08-03 and every string behind this
  /// toggle is now Hindi. A mother looking for her language saw the name of a
  /// style the app no longer uses, and one many people read as "broken English".
  ///
  /// The ENUM stays `AppLanguage.hinglish` on purpose — see CLAUDE.md. That is
  /// an identifier, persisted in shared_preferences as the literal string
  /// `hinglish`; renaming it would strand every mother who has already chosen
  /// it. Identity and display, kept apart, exactly as `.en` and `.now` are.
  String get languageHinglish => 'हिन्दी';
  String get moreComingSoon =>
      _p('More coming soon', 'और भी जल्द आ रहा है');

  String get dearBabyVaultTitle => _p('Dear Baby', 'Dear Baby');
  String get dearBabyVaultSubtitle => _p(
      'Your baby memory vault - every message you save for your little one.',
      'आपकी शिशु यादों की तिजोरी — हर संदेश जो आप अपने नन्हे के लिए सहेजती हैं।');
  String dearBabyEntries(int n) => _p(
      n == 1 ? '1 message' : '$n messages',
      '$n संदेश');
  String get dearBabyEmpty => _p(
      'Your messages to your baby will gather here. Open "Talk To Your Baby" on Home to write your first one. 💜',
      'आपके शिशु के लिए संदेश यहाँ जमा होंगे। पहला लिखने के लिए Home पर "अपने शिशु से बात कीजिए" खोलिए। 💜');
  String get spokenLabel => _p('Spoken', 'बोला गया');
  String get writtenLabel => _p('Written', 'लिखा गया');

  // ===========================================================================
  //  TOOLS TAB + YOUR PREGNANCY JOURNEY (map)
  // ===========================================================================

  // ---- Tools landing (grid of tools) ---------------------------------------
  String get toolsTitle => _p('Tools', 'टूल');
  String get toolsIntro => _p(
      'Helpful companions for your journey - more arriving soon.',
      'आपके सफ़र के साथी — और भी जल्द आ रहे हैं।');
  String get toolJourneyTitle =>
      _p('Your Pregnancy Journey', 'आपका गर्भावस्था सफ़र');
  String get toolJourneySubtitle => _p(
      'See your whole journey, week by week.',
      'अपना पूरा सफ़र देखिए, हफ़्ते-दर-हफ़्ते।');
  String get toolWeightTitle => _p('Weight Tracker', 'वज़न ट्रैकर');
  String get toolKickTitle => _p('Kick Counter', 'हलचल काउंटर');
  String get toolContractionTitle =>
      _p('Contraction Timer', 'संकुचन टाइमर');
  String get toolHospitalBagTitle =>
      _p('Hospital Bag Planner', 'अस्पताल बैग प्लानर');
  String get toolKegelTitle => _p('Kegel Care', 'Kegel Care');
  String get openLabel => _p('Open', 'खोलें');

  // ---- Journey map chrome --------------------------------------------------
  String get journeyTitle => _p('Your Pregnancy Journey', 'आपका गर्भावस्था सफ़र');
  String get youAreHere => _p('YOU ARE HERE', 'आप यहाँ हैं');
  String get journeyHerePill => _p("You're here", 'आप यहाँ');
  String get journeyWelcome => _p('Welcome', 'स्वागत');
  String get journeyStart => _p('Start', 'शुरुआत');
  String get journeyBirth => _p('Birth', 'जन्म');
  String trimesterBandLabel(int i) => i == 0
      ? _p('First Trimester', 'पहली तिमाही')
      : i == 1
          ? _p('Second Trimester', 'दूसरी तिमाही')
          : _p('Third Trimester', 'तीसरी तिमाही');
  String get currentWeekLabel => _p('Current Week', 'यह हफ़्ता');
  String get completedLabel => _p('Completed', 'पूरा हुआ');
  String journeyWeekDay(int week, int day) =>
      _p('Week $week • Day $day', 'हफ़्ता $week • दिन $day');
  String journeyDaysCompleted(int done, int total) => _p(
      '$done of $total Days Completed', '$total में से $done दिन पूरे');
  String journeyDaysRemaining(int n) =>
      _p('$n Days Remaining', '$n दिन बाक़ी');
  String journeyPercentComplete(int p) => _p('$p% Complete', '$p% पूरा');

  // ---- Journey filters + upcoming ------------------------------------------
  String get filterAll => _p('All', 'सब');
  String get filterAchievements => _p('Achievements', 'उपलब्धि');
  String get filterBaby => _p('Baby', 'शिशु');
  String get filterMedical => _p('Medical', 'मेडिकल');
  String get filterMother => _p('Mother', 'माँ');
  String get filterFeatures => _p('Tools', 'टूल');
  String get filterJourney => _p('Journey', 'सफ़र');
  String get comingUpTitle => _p('Coming Up', 'आगे आने वाला');
  String inWeeksShort(int n) => _p(
      n <= 1 ? 'In about 1 week' : 'In about $n weeks',
      n <= 1 ? 'लगभग 1 हफ़्ते में' : 'लगभग $n हफ़्तों में');
  String get nothingUpcoming => _p(
      'You have reached every milestone on your journey 💜',
      'आप अपने सफ़र के हर पड़ाव तक पहुँच चुकी हैं 💜');

  // ---- Journey node cards --------------------------------------------------
  String get typeAchievementLabel => _p('Achievement', 'उपलब्धि');
  String get typeMedicalLabel => _p('Medical milestone', 'मेडिकल पड़ाव');
  String get typeBabyLabel => _p('Baby development', 'शिशु का विकास');
  String get typeMotherLabel => _p('For you, Maa', 'आपके लिए, माँ');
  String get typePvLabel => _p('Your journey', 'आपका सफ़र');
  String get typeFeatureLabel => _p('New tool', 'नया टूल');

  String reachedOn(String date) => _p('Reached on $date', '$date को पहुँचा');
  String expectedInWeeks(int n) => _p(
      n == 1 ? 'Expected in about 1 week' : 'Expected in about $n weeks',
      n == 1 ? 'लगभग 1 हफ़्ते में उम्मीद' : 'लगभग $n हफ़्तों में उम्मीद');
  String viewWeekN(int n) => _p('View Week $n', 'हफ़्ता $n देखें');
  String get continueJourney => _p('Continue journey', 'सफ़र जारी रखें');
  // Journey-map milestone dates ("jm*").
  String jmShortDate(DateTime d) =>
      '${d.day} ${_months[(d.month - 1).clamp(0, 11)].substring(0, 3)}';
  String get jmEditDate => _p('Edit date', 'तारीख़ बदलें');
  String get jmWhenHappened => _p('When did this happen?', 'यह कब हुआ था?');
  String jmHappenedOn(String date) => _p('Happened on $date', '$date को हुआ');
  String get jmEditedHint => _p('edited by you', 'आपने सेट किया');
  // Appointment-style milestones (scans/visits the clinic schedules).
  String get jmSetAppointment =>
      _p('Set appointment date', 'अपॉइंटमेंट की तारीख़ सेट करें');
  String get jmEditAppointment =>
      _p('Edit appointment date', 'अपॉइंटमेंट की तारीख़ बदलें');
  String jmAppointmentOn(String date) =>
      _p('Appointment · $date', 'अपॉइंटमेंट · $date');
  // Late-joiner "catch up" - set real dates for moments already behind you.
  String get jmCatchUpTitle => _p('Joined along the way?', 'बीच में जुड़ीं?');
  String get jmCatchUpBody => _p(
      'Set when these moments actually happened, so this map is truly yours.',
      'सेट कीजिए कि ये पल असल में कब हुए, ताकि यह नक़्शा सच में आपका हो।');
  String get jmCatchUpCta => _p('Catch up', 'पूरा कर लें');
  String get jmCatchUpSheet =>
      _p('When did these happen?', 'ये कब हुए थे?');
  String get jmSetWhen => _p('Set date', 'तारीख़ सेट करें');
  String get jmAllCaughtUp =>
      _p("You're all caught up ❤️", 'आप सब पूरा कर चुकी हैं ❤️');
  // Overdue (past the due date) - calm, reassuring.
  String get jmOverdueTitle => _p('Past your due date', 'डिलीवरी की तारीख़ निकल गई');
  String jmOverdueBody(int days) => _p(
      '$days ${days == 1 ? 'day' : 'days'} past your due date - your baby will come when ready 💛',
      '$days दिन डिलीवरी की तारीख़ के बाद — आपका शिशु तैयार होने पर आएगा 💛');
  String get launchFeatureCta => _p('Launch', 'शुरू करें');
  String get featureComingSoonTitle =>
      _p('Coming soon 💜', 'जल्द आ रहा है 💜');
  String get featureComingSoonBody => _p(
      'This tool is on its way. We will gently let you know the moment it is ready.',
      'यह टूल जल्द आ रहा है। तैयार होते ही हम आपको प्यार से बता देंगे।');
  String get medicalDisclaimer => _p(
      'Educational only - not medical advice. Always follow your doctor.',
      'सिर्फ़ जानकारी के लिए — मेडिकल सलाह नहीं। हमेशा अपने डॉक्टर की सलाह मानें।');
  String get whatItDoesLabel => _p('What it does', 'यह क्या करता है');

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // Mon..Sun (DateTime.weekday is 1=Monday .. 7=Sunday).
  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  String formatLongDate(DateTime d) =>
      '${d.day} ${_months[(d.month - 1).clamp(0, 11)]} ${d.year}';

  /// e.g. "19 June"
  String formatShortDate(DateTime d) =>
      '${d.day} ${_months[(d.month - 1).clamp(0, 11)]}';

  /// e.g. "7:12 PM"
  String formatClock(DateTime d) {
    final h24 = d.hour;
    final ampm = h24 < 12 ? 'AM' : 'PM';
    int h = h24 % 12;
    if (h == 0) h = 12;
    final mm = d.minute.toString().padLeft(2, '0');
    return '$h:$mm $ampm';
  }

  // ===========================================================================
  //  TOOLS - Baby Movement Tracker
  // ===========================================================================
  String get movementToolTitle => _p('Baby Movement', 'शिशु की हलचल');
  String get historyLabel => _p('History', 'इतिहास');
  // The History section renders even before the first session, so she knows her
  // sessions will be kept and can see the streak build.
  String get historyEmptyNote => _p(
      'No sessions logged yet - each one you complete will appear here.',
      'अभी कोई सेशन दर्ज नहीं हुआ — आप जो भी पूरा करेंगी वह यहाँ दिखेगा।');
  String get movementDisclaimer => _p(
      'Most babies move several times a day and that is perfectly normal. Use this tracker only if your doctor has asked you to monitor movements.',
      'ज़्यादातर शिशु दिन में कई बार हिलते हैं और यह बिलकुल सामान्य है। इस ट्रैकर का इस्तेमाल सिर्फ़ तब कीजिए जब आपके डॉक्टर ने हलचल पर नज़र रखने को कहा हो।');
  String get babyMovedLabel => _p('Baby Moved', 'शिशु ने हलचल की');
  String get babyMovedSub =>
      _p('Tap whenever you feel movement', 'जब भी हलचल महसूस हो, टैप कीजिए');
  String get movementLogged => _p('Movement Logged', 'हलचल दर्ज हो गई');
  String get babyActiveTodayMsg =>
      _p('Your baby was active today.', 'आपका शिशु आज सक्रिय था।');
  String get todaysMovements => _p("Today's Movements", 'आज की हलचल');
  String get rememberThisMoment =>
      _p('Remember This Moment', 'इस पल को याद रखें');
  String get movementNoteHint => _p(
      'Today you started moving while daddy was talking…',
      'आज तुमने तब हिलना शुरू किया जब पापा बात कर रहे थे…');
  String get movementNoteSaved =>
      _p('Saved to Dear Baby 💜', 'Dear Baby में सेव हो गया 💜');
  String get movementNotePrompt =>
      _p('A baby movement memory', 'शिशु की हलचल की एक याद');
  String get movementRecordsTitle =>
      _p('Movement Records', 'हलचल के रिकॉर्ड');
  String get movementRecordsIntro => _p(
      'For your reference and your doctor. Counts appear here, never on the tracking screen.',
      'आपके और आपके डॉक्टर के लिए। गिनती यहाँ दिखती है, ट्रैकिंग स्क्रीन पर कभी नहीं।');
  String movementsLoggedCount(int n) => _p(
      n == 1 ? '1 movement logged' : '$n movements logged',
      '$n हलचल दर्ज');
  String get startWord => _p('Start', 'शुरू');
  String get endWord => _p('End', 'ख़त्म');
  String get viewDetails => _p('View Details', 'विवरण देखें');
  String get noMovementsYet => _p(
      'No movements recorded yet. Tap the heart whenever you feel your baby move.',
      'अभी कोई हलचल दर्ज नहीं हुई। जब भी शिशु हिले, दिल पर टैप कीजिए।');
  // Session-based tracking
  String get babyMovementTracker =>
      _p('Baby Movement Tracker', 'शिशु हलचल ट्रैकर');
  String get startSession => _p('Start Session', 'सेशन शुरू करें');
  String get endSession => _p('End Session', 'सेशन ख़त्म करें');
  String get sessionWord => _p('Session', 'सेशन');
  String sessionNumber(int n) => _p('Session $n', 'सेशन $n');
  String get thisSessionLabel => _p('This session', 'यह सेशन');
  String get startSessionTitle =>
      _p('Start a movement session', 'एक हलचल सेशन शुरू करें');
  String get startSessionSub => _p(
      'Begin a session, then tap the heart each time you feel your baby move. The session ends when you tap End - or when you leave this screen.',
      'सेशन शुरू कीजिए, फिर जब भी शिशु हिले दिल पर टैप कीजिए। सेशन तब ख़त्म होता है जब आप "ख़त्म" दबाएँ — या इस स्क्रीन से बाहर जाएँ।');
  String sessionStartedAt(String time) =>
      _p('Started at $time', '$time पर शुरू');
  String lastMovementAt(String time) => _p('Last at $time', 'आख़िरी $time पर');
  String get viewAllTimes => _p('View all times', 'सारे समय देखें');
  String get hideTimesLabel => _p('Hide times', 'समय छिपाएँ');
  String get sessionSavedMsg =>
      _p('Session saved to history 💜', 'सेशन इतिहास में सेव हो गया 💜');
  String get noMovementsThisSession => _p(
      'No movements logged yet - tap the heart above whenever you feel one.',
      'अभी कोई हलचल दर्ज नहीं हुई — जब भी महसूस हो, ऊपर दिल पर टैप कीजिए।');

  // ===========================================================================
  //  TOOLS - Weight Tracker
  // ===========================================================================
  String get weightToolTitle => _p('Weight Tracker', 'वज़न ट्रैकर');
  String get addWeightShort => _p('Add weight', 'वज़न जोड़ें');
  String get heightOptional => _p('Height (optional)', 'लंबाई (ज़रूरी नहीं)');
  String get gainNeedsHeight => _p(
      'Add your height anytime to see a personalized weight-gain range.',
      'अपने हिसाब से वज़न बढ़ने की सीमा देखने के लिए कभी भी अपनी लंबाई जोड़िए।');
  String get changeLabel => _p('Change', 'बदलाव');
  String get timeLabel => _p('Time', 'समय');
  String get noWeightEntriesYet => _p(
      'No entries yet. Add your weight to start your gentle record.',
      'अभी कोई एंट्री नहीं। अपना रिकॉर्ड शुरू करने के लिए वज़न जोड़िए।');
  String get weightWelcomeBody => _p(
      'Understanding your starting point helps us personalize your journey and offer gentle weight guidance. Your information is private and can be updated later.',
      'अपना शुरुआती बिंदु समझने से हम आपका सफ़र आपके हिसाब से बना पाते हैं और वज़न पर हल्की सलाह दे पाते हैं। आपकी जानकारी निजी है और बाद में बदली जा सकती है।');
  String get prePregnancyWeightLabel =>
      _p('Pre-pregnancy weight', 'गर्भावस्था से पहले का वज़न');
  String get prePregnancyWeightHelper => _p(
      'This helps us estimate a healthy weight-gain range.',
      'इससे हम सेहतमंद वज़न बढ़ने की सीमा का अंदाज़ा लगा पाते हैं।');
  String get heightLabel => _p('Your height', 'आपकी लंबाई');
  String get heightHelper => _p(
      'This helps personalize your pregnancy weight chart.',
      'इससे आपका गर्भावस्था वज़न चार्ट आपके हिसाब से बनता है।');
  String get kgUnit => _p('kg', 'kg');
  String get cmUnit => _p('cm', 'cm');
  String get continueCta => _p('Continue', 'आगे बढ़ें');
  String get profileTitleWeight =>
      _p('Your Pregnancy Profile', 'आपकी गर्भावस्था प्रोफ़ाइल');
  String get startingWeightLabel => _p('Starting weight', 'शुरुआती वज़न');
  String get recommendedGainLabel =>
      _p('Recommended pregnancy weight gain', 'सुझाई गई वज़न बढ़त');
  String get weightGuidelineNote => _p(
      'This is a general guideline. Your doctor may recommend something different for your pregnancy.',
      'यह एक आम दिशानिर्देश है। आपके डॉक्टर आपकी गर्भावस्था के लिए कुछ अलग सलाह दे सकते हैं।');
  String get startTrackingCta => _p('Start Tracking', 'रिकॉर्ड शुरू करें');
  String get currentWeightLabel => _p('Current weight', 'अभी का वज़न');
  String get lastUpdatedLabel => _p('Last updated', 'आख़िरी अपडेट');
  String get todayWord => _p('Today', 'आज');
  String weightEmptyState(int week) => _p(
      'No weight entries yet. Most mothers record their weight during doctor visits or once a week.',
      'अभी कोई वज़न एंट्री नहीं। ज़्यादातर माँएँ डॉक्टर के पास जाने पर या हफ़्ते में एक बार वज़न दर्ज करती हैं।');
  String get addTodaysWeight => _p("Add Today's Weight", 'आज का वज़न जोड़ें');
  String get bodySupportingTitle =>
      _p('Your body is supporting ❤️', 'आपका शरीर सहारा दे रहा है ❤️');
  String get supportGrowingBaby =>
      _p('Your growing baby', 'आपका बढ़ता शिशु');
  String get supportPlacenta => _p('Placenta development', 'Placenta का विकास');
  String get supportAmniotic => _p('Amniotic fluid', 'Amniotic fluid');
  String get supportBlood => _p('Increased blood volume', 'बढ़ा हुआ blood volume');
  String get everyPregnancyUnique => _p(
      'Every pregnancy is unique. Always follow your doctor\'s guidance.',
      'हर गर्भावस्था अलग है। हमेशा अपने डॉक्टर की सलाह मानें।');
  String get weightGainSince =>
      _p('Weight gain since pregnancy', 'गर्भावस्था से अब तक वज़न बढ़त');
  String get whereWeightComesFrom => _p(
      'Where pregnancy weight comes from', 'गर्भावस्था का वज़न कहाँ से आता है');
  String get contributorBaby => _p('Baby', 'शिशु');
  String get contributorPlacenta => _p('Placenta', 'Placenta');
  String get contributorAmniotic => _p('Amniotic fluid', 'Amniotic fluid');
  String get contributorBlood => _p('Blood volume', 'Blood volume');
  String get contributorBreast => _p('Breast tissue', 'Breast tissue');
  String get contributorEnergy => _p('Energy stores', 'ऊर्जा का भंडार');
  String get estimatesNote => _p(
      'Educational estimates based on pregnancy week. Not exact measurements.',
      'गर्भावस्था के हफ़्ते पर आधारित जानकारी भर। सटीक माप नहीं।');
  String get whatChangedTitle =>
      _p('What changed since your last entry?', 'पिछली एंट्री से क्या बदला?');
  String get changedBabyGrew =>
      _p('Your baby gained a little more', 'आपके शिशु का वज़न थोड़ा और बढ़ा');
  String get changedAmniotic =>
      _p('Amniotic fluid increased', 'Amniotic fluid बढ़ा');
  String get changedBlood =>
      _p('Blood volume continued expanding', 'Blood volume बढ़ता रहा');
  String get changedUterus => _p('Your uterus grew larger', 'आपकी बच्चेदानी और बड़ी हुई');
  String get thisWeekLabel => _p('This week', 'इस हफ़्ते');
  String get addWeightTitle => _p('Add weight', 'वज़न जोड़ें');
  String get dateLabel => _p('Date', 'तारीख़');
  String get notesOptional => _p('Notes (optional)', 'नोट (ज़रूरी नहीं)');
  String get saveCta => _p('Save', 'सेव करें');
  String get weightHistoryTitle => _p('Weight history', 'वज़न का इतिहास');
  String get weightChartTitle => _p('Weight chart', 'वज़न चार्ट');
  String get chartActualWeight => _p('Actual weight', 'असली वज़न');
  String get chartRecommendedRange =>
      _p('Recommended range', 'सुझाई गई सीमा');
  String get chartFooter => _p(
      'Your weight trend alongside the typical range for your stage. Every pregnancy is unique - discuss any concerns with your provider.',
      'आपके चरण की सामान्य सीमा के साथ आपके वज़न का रुझान। हर गर्भावस्था अलग है — किसी भी चिंता पर अपने डॉक्टर से बात कीजिए।');
  String weeklyWeightInsight(int week) {
    if (week <= 13) {
      return _p(
          'Your body is increasing blood volume to support your growing baby.',
          'आपका शरीर बढ़ते शिशु के लिए blood volume बढ़ा रहा है।');
    }
    if (week <= 27) {
      return _p(
          'Your baby, placenta and amniotic fluid now account for a meaningful portion of weight gain.',
          'आपका शिशु, placenta और amniotic fluid अब वज़न बढ़त का एक बड़ा हिस्सा हैं।');
    }
    return _p(
        'Late pregnancy weight gain is often influenced by fluid and rapid baby growth.',
        'गर्भावस्था के आख़िरी दौर में वज़न बढ़ना अक्सर fluid और शिशु की तेज़ बढ़त से होता है।');
  }

  // ===========================================================================
  //  TOOLS - Kegel Care
  // ===========================================================================
  String get kegelToolTitle => _p('Kegel Care', 'Kegel Care');
  String get kegelHeroTitle => _p('Pelvic floor care', 'Pelvic floor की देखभाल');
  String get kegelHeroBody => _p(
      'During pregnancy, your pelvic floor supports the increasing weight of your growing baby. Regular exercises may help support:',
      'गर्भावस्था में आपका pelvic floor बढ़ते शिशु का वज़न सँभालता है। नियमित व्यायाम इन चीज़ों में मदद कर सकते हैं:');
  String get kegelBenefitBladder => _p('Bladder control', 'Bladder पर नियंत्रण');
  String get kegelBenefitSupport => _p('Pelvic support', 'Pelvic सहारा');
  String get kegelBenefitRecovery =>
      _p('Postpartum recovery', 'डिलीवरी के बाद रिकवरी');
  String get kegelFollowProvider => _p(
      "Always follow your healthcare provider's advice.",
      'हमेशा अपने डॉक्टर की सलाह मानें।');
  String get currentRoutineLabel => _p('Current routine', 'अभी का रूटीन');
  /// Narration controls. Bilingual like everything else - the speaker sits
  /// on a card the mother is already reading in her language.
  String get listenLabel => _p('Listen', 'सुनिए');
  String get stopLabel => _p('Stop', 'रोकिए');

  String get holdLabel => _p('Hold', 'रोकें');
  String get relaxLabel => _p('Relax', 'ढीला छोड़ें');
  String get repsLabel => _p('Repetitions', 'दोहराव');
  String get estTimeLabel => _p('Estimated time', 'अनुमानित समय');
  String get secShort => _p('sec', 'सेकंड');
  String get whyThisRoutine => _p('Why this routine?', 'यह रूटीन क्यों?');
  String get whyThisRoutineBody => _p(
      'Most mothers at your stage of pregnancy benefit from this gentle level. It is personalized and may change as your pregnancy progresses.',
      'आपके चरण की ज़्यादातर माँओं को इस हल्के स्तर से फ़ायदा होता है। यह आपके हिसाब से है और गर्भावस्था के साथ बदल सकता है।');
  String get startCareSession => _p('Start Care Session', 'केयर सेशन शुरू करें');
  // "What are Kegels & how to do them" - for a first-timer.
  String get kegelHowTitle =>
      _p('What is a Kegel & how to do it', 'Kegel क्या है और कैसे करें');
  String get kegelHowBody => _p(
      'A Kegel is simply squeezing and lifting your pelvic-floor muscles - the same ones you would use to stop yourself passing urine or wind - then fully relaxing them. To find them, imagine gently stopping that flow (just to locate the muscle, not as a habit). Squeeze and hold for a few seconds, then relax for the same time. Keep breathing normally, and try not to tighten your tummy, thighs or buttocks. A Care Session below guides the hold-and-relax timing for you.',
      'Kegel यानी अपनी pelvic-floor मांसपेशियों को कसना और ऊपर उठाना — वही जो आप पेशाब या गैस रोकने के लिए इस्तेमाल करती हैं — फिर पूरी तरह ढीला छोड़ना। इन्हें पहचानने के लिए, हल्के से उस प्रवाह को रोकने की कल्पना कीजिए (सिर्फ़ मांसपेशी पहचानने के लिए, आदत के तौर पर नहीं)। कुछ सेकंड कसिए और रोकिए, फिर उतनी ही देर ढीला छोड़िए। साँस सामान्य रखिए, और पेट, जाँघ या कूल्हे मत कसिए। नीचे दिया केयर सेशन आपके लिए कसने और छोड़ने का समय बताता है।');
  String get whyAmIDoingThis => _p('Why am I doing this?', 'मैं यह क्यों कर रही हूँ?');
  String get whyAmIDoingThisBody => _p(
      'The pelvic floor supports the bladder, bowel and uterus. These muscles work harder throughout pregnancy. Regular exercises may help maintain strength and support recovery after birth.',
      'Pelvic floor bladder, bowel और बच्चेदानी को सहारा देता है। ये मांसपेशियाँ पूरी गर्भावस्था में ज़्यादा काम करती हैं। नियमित व्यायाम ताक़त बनाए रखने और जन्म के बाद रिकवरी में मदद कर सकते हैं।');
  String get kegelSafetyTitle => _p(
      'Stop and contact your provider if you experience:',
      'ये हो तो रुकिए और अपने डॉक्टर से संपर्क कीजिए:');
  String get kegelSafetyPain => _p('Pain', 'दर्द');
  String get kegelSafetyBleeding => _p('Vaginal bleeding', 'Vaginal bleeding');
  String get kegelSafetyDizziness => _p('Dizziness', 'चक्कर');
  String get kegelSafetyContractions =>
      _p('Contractions triggered by exercise', 'व्यायाम से होने वाले संकुचन');
  String get stageLabel => _p('Current stage', 'अभी का चरण');
  String get kegelStage1 => _p('Learning the technique', 'तरीक़ा सीखना');
  String get kegelStage2 => _p('Building consistency', 'नियमितता बनाना');
  String get kegelStage3 => _p('Preparing for birth', 'जन्म की तैयारी');
  String repOf(int cur, int total) =>
      _p('Rep $cur of $total', 'दोहराव $cur / $total');
  String get pauseLabel => _p('Pause', 'रोकें');
  String get resumeLabel => _p('Resume', 'जारी रखें');
  String get exitLabel => _p('Exit', 'बाहर');
  String get kegelSessionDoneTitle => _p('Well Done ❤️', 'शाबाश ❤️');
  String get kegelSessionDoneBody => _p(
      "You completed today's pelvic floor care session. Small moments of care can support your body throughout pregnancy.",
      'आपने आज का pelvic floor केयर सेशन पूरा किया। देखभाल के छोटे पल पूरी गर्भावस्था में आपके शरीर को सहारा देते हैं।');
  String get howDidItFeel =>
      _p("How did today's session feel?", 'आज का सेशन कैसा लगा?');
  String get feedbackEasy => _p('Easy', 'आसान');
  String get feedbackComfortable => _p('Comfortable', 'ठीक-ठाक');
  String get feedbackDifficult => _p('Difficult', 'मुश्किल');
  String get doneWord => _p('Done', 'हो गया');
  String get careJourneyTitle => _p('Your Care Journey ❤️', 'आपका केयर सफ़र ❤️');
  String get sessionsCompletedLabel =>
      _p('Sessions completed', 'सेशन पूरे');
  String get completedThisWeekLabel =>
      _p('Completed this week', 'इस हफ़्ते पूरे');
  String get lastCompletedLabel => _p('Last completed', 'आख़िरी बार');
  String get neverWord => _p('Not yet', 'अभी नहीं');
  String get careJourneyCta => _p('Care Journey', 'केयर सफ़र');
  // Routine customization + voice cues
  String get customizeLabel => _p('Customize', 'अपने हिसाब से');
  String get customizeRoutineTitle =>
      _p('Customize routine', 'रूटीन अपने हिसाब से बनाएँ');
  String get recommendedLabel => _p('Recommended', 'सुझाया गया');
  String get customLabel => _p('Custom', 'अपना');
  String get resetToRecommended =>
      _p('Reset to recommended', 'सुझाए गए पर लौटें');
  String get usingCustomRoutine =>
      _p('Using your custom routine', 'आपका अपना रूटीन चल रहा है');
  String get kegelCustomizeInfo => _p(
      'We recommend the routine set for your stage. If it feels too easy or too hard, you can gently adjust it - always listen to your body and your doctor. Estimated time updates automatically.',
      'हम आपके चरण के लिए बनाया रूटीन सुझाते हैं। अगर यह बहुत आसान या बहुत मुश्किल लगे, तो आप इसे हल्के से बदल सकती हैं — हमेशा अपने शरीर और डॉक्टर की सुनिए। अनुमानित समय अपने आप बदल जाता है।');
  String get voiceCuesLabel => _p('Voice cues', 'आवाज़ के संकेत');

  // ===========================================================================
  //  TOOLS - My Hospital Bag
  // ===========================================================================
  String get hbName => _p('My Hospital Bag', 'मेरा अस्पताल बैग');
  String rupees(int n) => '₹$n';

  // --- Simplified hospital bag (v2): the joyful, tap-only experience ---------
  String get hb2MyBag => _p('My Hospital Bag', 'मेरा अस्पताल बैग');
  String get hb2FillingUp =>
      _p('Your bag is filling up 💛', 'आपका बैग भर रहा है 💛');
  String get hb2ReadyBanner => _p('Your bag is ready for baby! 🎉',
      'आपका बैग शिशु के लिए तैयार है! 🎉');
  String get hb2HeroEmpty =>
      _p("Let's pack for the big day", 'बड़े दिन के लिए पैक करें');
  String hb2DaysToGo(int n) => _p('$n days to go', '$n दिन बाक़ी');
  String hb2ReadyPct(int n) => _p('$n% ready', '$n% तैयार');
  String get hb2AddItems => _p('Add items', 'चीज़ें जोड़ें');
  String get hb2EmptyTitle =>
      _p("Let's start your bag 🎒", 'अपना बैग शुरू करें 🎒');
  String get hb2EmptySub => _p(
      "Add the things you'd love to have for the big day.",
      'बड़े दिन के लिए जो चीज़ें चाहिए, उन्हें जोड़िए।');
  String get hb2GroupVeda =>
      _p('Buy from ParentVeda', 'ParentVeda से ख़रीदें');
  String get hb2GroupElse =>
      _p('Buy elsewhere', 'कहीं और से ख़रीदें');
  String get hb2GroupHave => _p('Already have', 'पहले से है');
  String get hb2GroupNeeded =>
      _p('Where will you get these?', 'ये कहाँ से लाएँगी?');
  String hb2Buy(int price) => _p('Buy ₹$price', '₹$price में लें');
  String get hb2ToBuy => _p('To buy', 'लेना है');
  String get hb2Bought => _p('Bought', 'ले लिया');
  String get hb2Pack => _p('Pack', 'पैक करें');
  String get hb2Packed => _p('Packed', 'पैक हो गया');
  String get hb2ChooseSource =>
      _p('Where will you get this?', 'यह कहाँ से लाएँगी?');
  String get hb2SrcVeda =>
      _p('Buy from ParentVeda', 'ParentVeda से ख़रीदें');
  String get hb2SrcElse => _p('Buy elsewhere', 'कहीं और से ख़रीदें');
  String get hb2SrcHave => _p('I already have it', 'यह मेरे पास है');
  String get hb2Remove => _p('Remove from bag', 'बैग से हटाएँ');
  String get hb2LinkOptional =>
      _p('Paste a link (optional)', 'लिंक डालिए (ज़रूरी नहीं)');
  String get hb2Save => _p('Save', 'सेव करें');
  String hb2PackedCheer(int i) {
    const en = [
      'One less thing to worry about 💛',
      'Your bag is getting ready ✨',
      'Lovely - packed! 🎒',
      "You're doing so well, mama 💛",
    ];
    const hi = [
      'एक चिंता कम 💛',
      'आपका बैग तैयार हो रहा है ✨',
      'बहुत ख़ूब — पैक हो गया! 🎒',
      'आप बहुत अच्छा कर रही हैं, माँ 💛',
    ];
    final n = i % en.length;
    return _p(en[n], hi[n]);
  }

  String get hb2AddTitle => _p('Add to my bag', 'मेरे बैग में जोड़ें');
  String get hb2Done => _p('Done', 'हो गया');
  String get hb2Search => _p('Search items…', 'चीज़ें ढूँढिए…');
  String get hb2MumsAlsoPacked => _p(
      'Mums like you also packed', 'आप जैसी माँओं ने यह भी पैक किया');
  String get hb2SocialProof =>
      _p('9 in 10 mums pack this', '10 में 9 माँएँ यह पैक करती हैं');
  String get hb2Add => _p('Add', 'जोड़ें');
  String get hb2CatLabour => _p('For labour', 'प्रसव के लिए');
  String get hb2CatAfter => _p('After delivery', 'डिलीवरी के बाद');
  String get hb2CatBaby => _p('For baby', 'शिशु के लिए');
  String get hb2CatPartner => _p('For partner', 'साथी के लिए');
  String get hb2CatDocs => _p('Documents', 'काग़ज़ात');
  String get hb2CatComfort => _p('Comfort', 'आराम के लिए');
  String get hb2CatCustom => _p('My own', 'मेरे अपने');
  String get hb2ShareTitle => _p('Share my bag', 'मेरा बैग साझा करें');
  String get hb2ShareToBuy => _p('Still to buy', 'अभी लेना है');
  String hb2SharePacked(int a, int b) =>
      _p('Packed: $a of $b 💛', 'पैक हुआ: $b में से $a 💛');
  String get hb2RemindMe => _p('Remind me to prep', 'मुझे याद दिलाएँ');
  String get hb2RemindOff => _p('Turn off reminder', 'रिमाइंडर बंद करें');
  String get hb2ReminderTitle =>
      _p('Your hospital bag 💛', 'आपका अस्पताल बैग 💛');
  String get hb2ReminderBody => _p(
      'A few minutes to add or pack something today?',
      'आज कुछ जोड़ने या पैक करने के लिए कुछ मिनट?');
  String get hb2ReminderSet => _p("Reminder set - I'll nudge you daily 💛",
      'रिमाइंडर सेट — मैं रोज़ याद दिलाऊँगी 💛');
  String get hb2ReminderOff =>
      _p('Reminder turned off', 'रिमाइंडर बंद हो गया');
  String get hb2KeepsakeTitle =>
      _p("Baby's bag is ready! 💛", 'शिशु का बैग तैयार है! 💛');
  String hb2KeepsakeSub(String date) =>
      _p('Packed on $date', '$date को पैक हुआ');
  String get hb2KeepsakeShare => _p('Share the moment', 'यह पल साझा करें');
  String hb2KeepsakeShareText(String date) => _p(
      'Our hospital bag is all packed and ready for baby 💛 ($date) - ParentVeda',
      'हमारा अस्पताल बैग शिशु के लिए तैयार है 💛 ($date) — ParentVeda');
  // Locked / "time to prepare" state
  String get hbTimeToPrepareTitle =>
      _p('Time to start preparing', 'तैयारी शुरू करने का समय');
  String get hbTimeToPrepareBody => _p(
      'Most mothers begin preparing their hospital bag around this stage.',
      'ज़्यादातर माँएँ इसी दौर में अपना अस्पताल बैग तैयार करना शुरू करती हैं।');
  String get hbCreateMyBag => _p('Create my bag', 'मेरा बैग बनाएँ');
  // Onboarding
  String get hbWelcomeTitle =>
      _p('Build your hospital bag', 'अपना अस्पताल बैग बनाएँ');
  String get hbWelcomeSub => _p(
      "Let's prepare for one of the most special days of your life. You can build your bag over time and come back whenever you want.",
      'आइए अपनी ज़िंदगी के सबसे ख़ास दिनों में से एक की तैयारी करें। आप अपना बैग धीरे-धीरे बना सकती हैं और जब चाहें वापस आ सकती हैं।');
  String get hbStartBuilding => _p('Start building', 'बनाना शुरू करें');
  String get hbDeliveryTitle =>
      _p('Any idea about your delivery?', 'अपनी डिलीवरी के बारे में कोई अंदाज़ा?');
  String get hbDeliveryHelper => _p(
      'This just helps us suggest a few extra items. You can change everything later.',
      'यह सिर्फ़ कुछ और चीज़ें सुझाने में मदद करता है। आप बाद में सब कुछ बदल सकती हैं।');
  String get hbDeliveryVaginal => _p('Vaginal', 'Vaginal');
  String get hbDeliveryCsection => _p('C-section', 'C-section');
  String get hbDeliveryUnsure => _p('Not sure yet', 'अभी पक्का नहीं');
  String get hbBuildMyBag => _p('Build my bag', 'मेरा बैग बनाएँ');
  // Tabs
  String get hbTabBag => _p('Bag', 'बैग');
  String get hbTabPlanner => _p('Planner', 'प्लानर');
  String get hbTabShopping => _p('Shopping', 'ख़रीदारी');
  // Progress
  String get hbPreparationProgress =>
      _p('Preparation progress', 'तैयारी की प्रगति');
  String hbPercentReady(int p) => _p('$p% Ready', '$p% तैयार');
  String hbSelectedCount(int n) => _p('$n selected', '$n चुने');
  String hbPackedCountLabel(int n) => _p('$n packed', '$n पैक हो गए');
  String hbRemainingCount(int n) => _p('$n remaining', '$n बाक़ी');
  String hbProgressLine(int p) {
    if (p == 0) {
      return _p("Let's begin, one item at a time ❤️",
          'आइए शुरू करें, एक-एक चीज़ ❤️');
    }
    if (p < 40) {
      return _p('A lovely start. Your bag is taking shape ❤️',
          'प्यारी शुरुआत। आपका बैग बन रहा है ❤️');
    }
    if (p < 75) {
      return _p("You're well on your way ❤️",
          'आप अच्छे से आगे बढ़ रही हैं ❤️');
    }
    if (p < 100) {
      return _p("You've prepared most of what you'll need for the big day ❤️",
          'बड़े दिन के लिए ज़रूरी ज़्यादातर चीज़ें तैयार हैं ❤️');
    }
    return _p('Your bag is ready ❤️', 'आपका बैग तैयार है ❤️');
  }
  String get hbLastUpdatedLabel => _p('Last updated', 'आख़िरी अपडेट');
  String get hbToday => _p('today', 'आज');
  String get hbYesterday => _p('yesterday', 'कल');
  String hbDaysAgo(int n) => _p('$n days ago', '$n दिन पहले');
  // Categories
  String hbCategory(String key) {
    switch (key) {
      case 'labour':
        return _p('For me during labour', 'प्रसव के दौरान मेरे लिए');
      case 'afterDelivery':
        return _p('For me after delivery', 'डिलीवरी के बाद मेरे लिए');
      case 'baby':
        return _p('For baby', 'शिशु के लिए');
      case 'partner':
        return _p('For partner', 'साथी के लिए');
      case 'documents':
        return _p('Documents', 'काग़ज़ात');
      case 'comfort':
        return _p('Comfort items', 'आराम की चीज़ें');
      default:
        return _p('My own items', 'मेरी अपनी चीज़ें');
    }
  }
  String hbItemsCount(int n) => _p(n == 1 ? '1 item' : '$n items',
      n == 1 ? '1 चीज़' : '$n चीज़ें');
  String hbReadyCount(int n) => _p('$n ready', '$n तैयार');
  // Item states
  String get hbStateNeeded => _p('To plan', 'तय करना है');
  String get hbStateHave => _p('Already have', 'पहले से है');
  String get hbStateBuyVeda => _p('Buy from ParentVeda', 'ParentVeda से ख़रीदें');
  String get hbStateBuyElse => _p('Buy elsewhere', 'कहीं और से ख़रीदें');
  String get hbStateSkip => _p('Skip', 'छोड़ें');
  String get hbStatusLabel => _p('Status', 'स्थिति');
  String get hbMarkPacked => _p('Mark as packed', 'पैक मार्क करें');
  String get hbPackedLabel => _p('Packed', 'पैक हो गया');

  // ===== Hospital Bag V2 (toggle-able redesign) =============================
  String get hb2vClassic => _p('Classic', 'क्लासिक');
  String get hb2vNew => _p('New', 'नया');
  // Onboarding
  String get hb2v2Title => _p('Build your hospital bag', 'अपना अस्पताल बैग तैयार करें');
  String get hb2v2Sub => _p(
      "Let's prepare for one of the most special days of your life. You don't need to finish today - we'll build it together over the coming weeks.",
      "आपकी ज़िंदगी के सबसे ख़ास दिन की तैयारी करें। आज पूरा करना ज़रूरी नहीं — हम इसे आने वाले हफ़्तों में साथ मिलकर बनाएँगे।");
  String get hb2v2StartCta => _p('Start preparing', 'तैयारी शुरू करें');
  String get hb2v2DeliveryQ =>
      _p('How are you planning to deliver?', 'आप डिलीवरी कैसे प्लान कर रही हैं?');
  // Plain-language stages
  String get hb2v2StageDecision => _p('Needs your decision', 'आपका फ़ैसला चाहिए');
  String get hb2v2StagePlanning => _p('Planning to buy', 'ख़रीदने का इरादा');
  String get hb2v2StageHome => _p('Ready at home', 'घर पर तैयार');
  String get hb2v2StagePacked => _p('Packed', 'पैक हो गया');
  String get hb2v2StageLater => _p('Maybe later', 'शायद बाद में');
  // Home
  String get hb2v2Attention => _p('Needs your attention', 'आपके ध्यान की ज़रूरत');
  String get hb2v2AllSorted => _p("You're all caught up 💛", 'सब सँभल गया 💛');
  String get hb2v2Categories => _p('Your bag, by area', 'आपका बैग, हिस्सों में');
  String get hb2v2Shopping => _p('Shopping', 'ख़रीदारी');
  String get hb2v2Packing => _p('Packing', 'पैकिंग');
  String hb2v2DaysToGo(int n) => _p('$n days to go', '$n दिन बाक़ी');
  String get hb2v2HeroReady => _p('Your bag is almost ready 💛', 'आपका बैग लगभग तैयार 💛');
  String get hb2v2HeroBuilding => _p('Building your bag, gently', 'आपका बैग, आराम से बन रहा है');
  // Action sheet
  String hb2v2WhatDo(String item) => _p('$item - what would you like to do?',
      '$item — आप क्या करना चाहेंगी?');
  String get hb2v2ChooseOne => _p('Help me choose one', 'चुनने में मदद करें');
  String get hb2v2HaveOne => _p('I already have one', 'मेरे पास पहले से है');
  String get hb2v2BuyElse => _p("I'll buy elsewhere", 'मैं कहीं और से लूँगी');
  String get hb2v2Later => _p("I'll decide later", 'बाद में तय करूँगी');
  String get hb2v2NotNeed => _p("I don't think I need this", 'मुझे शायद इसकी ज़रूरत नहीं');
  // Product experience
  String get hb2v2PvPick => _p('ParentVeda pick', 'ParentVeda की पसंद');
  String get hb2v2WhyRec => _p('Why ParentVeda recommends this', 'ParentVeda यह क्यों सुझाता है');
  String get hb2v2Consider => _p('Things to consider', 'ध्यान देने की बातें');
  String get hb2v2BuyingGuide => _p('Buying guide', 'ख़रीदने की गाइड');
  String get hb2v2BuyingGuideBody => _p(
      'Look for soft, breathable fabric and an easy fit. One or two is usually enough to start - you can always add more later.',
      'नरम, साँस लेने वाला कपड़ा और आरामदायक फ़िट देखिए। शुरू में एक-दो काफ़ी होते हैं — बाद में और ले सकती हैं।');
  String get hb2v2Reviews => _p('Real parent reviews', 'असली माता-पिता की राय');
  String get hb2v2ReviewsSoon => _p('Reviews from ParentVeda parents are coming soon.',
      'ParentVeda के माता-पिता की राय जल्द आ रही है।');
  String get hb2v2Compare => _p('Compare options', 'विकल्प तुलना करें');
  String get hb2v2SeeAll => _p('See all options', 'सभी विकल्प देखें');
  String get hb2v2Selected => _p('Selected', 'चुना गया');
  String get hb2v2ChooseThis => _p('Choose this', 'यह चुनें');
  String get hb2v2BuyOnPv => _p('Buy from ParentVeda', 'ParentVeda से ख़रीदें');
  // Buy elsewhere
  String get hb2v2WhereBuy => _p('Where will you buy it?', 'आप इसे कहाँ से लेंगी?');
  String get hb2v2SkipForNow => _p('Skip for now', 'अभी छोड़ दें');
  String get hb2v2AddDetails => _p('Add price / link / note (optional)',
      'दाम / लिंक / नोट जोड़ें (ज़रूरी नहीं)');
  // Maybe later
  String get hb2v2MaybeLaterTitle => _p('Maybe later', 'शायद बाद में');
  String get hb2v2RestoreItem => _p('Add back to bag', 'बैग में वापस जोड़ें');
  // Packing
  String get hb2v2TimeToPack => _p('Time to pack your bag', 'बैग पैक करने का समय');
  String get hb2v2InBag => _p('In my hospital bag', 'मेरे अस्पताल बैग में');
  String get hb2v2PackThis => _p('Pack this', 'इसे पैक करें');
  // Custom
  String get hb2v2AddOwn => _p('Add my own item', 'अपनी चीज़ जोड़ें');
  String get hb2v2ItemName => _p('Item name', 'चीज़ का नाम');
  String get hb2v2NotesOptional => _p('Notes (optional)', 'नोट (ज़रूरी नहीं)');
  String get hb2v2RemoveItem => _p('Remove item', 'चीज़ हटाएँ');
  // Shopping summary
  String get hb2v2SummaryTitle => _p('Shopping summary', 'ख़रीदारी का ब्योरा');
  String get hb2v2SecFromPv => _p('Buying from ParentVeda', 'ParentVeda से ख़रीद रही हैं');
  String get hb2v2SecElse => _p('Buying elsewhere', 'कहीं और से');
  String get hb2v2SecHome => _p('Already at home', 'घर पर पहले से');
  String get hb2v2SecWaiting => _p('Waiting to buy', 'ख़रीदना बाक़ी');
  String get hb2v2SecPacked => _p('Packed', 'पैक हो गया');
  String get hb2v2PvSpend => _p('ParentVeda spend', 'ParentVeda ख़र्च');
  String get hb2v2ExtSpend => _p('External spend', 'बाहर का ख़र्च');
  String get hb2v2TotalSpend => _p('Total planned', 'कुल तय');
  String get hb2v2SummaryCta => _p('Shopping summary', 'ख़रीदारी का ब्योरा');
  // Mark bought (elsewhere)
  String get hb2v2MarkBought => _p('Mark as bought', 'ख़रीदा मार्क करें');
  String get hb2v2Bought => _p('Bought', 'ख़रीद लिया');
  String get hbMarkFavourite =>
      _p('Add to favourites', 'पसंदीदा में जोड़ें');
  String get hbFavourites => _p('Favourites', 'पसंदीदा');
  String hbTapToExpand(int n) => _p('$n items', '$n चीज़ें');
  String get hbRestore => _p('Restore', 'वापस लाएँ');
  // Recommendation / trust layer
  String get hbRecommendation =>
      _p('ParentVeda Recommendation', 'ParentVeda का सुझाव');
  String get hbBestOverall => _p('Best Overall', 'सबसे बेहतर');
  String get hbWhyRecommend =>
      _p('Why ParentVeda recommends this', 'ParentVeda यह क्यों सुझाता है');
  String get hbThingsToConsider =>
      _p('Things to consider', 'ध्यान देने योग्य बातें');
  String get hbBuyVedaCta => _p('Buy from ParentVeda', 'ParentVeda से ख़रीदें');
  // Affiliate split (also-available-elsewhere - mirrors the product checklist).
  String get hbAlsoElsewhere =>
      _p('Also available elsewhere', 'कहीं और भी उपलब्ध');
  String get hbAffiliateNote => _p(
      'Opens the store in your browser. ParentVeda may earn a small commission.',
      'स्टोर आपके ब्राउज़र में खुलेगा। ParentVeda को छोटा कमीशन मिल सकता है।');
  String hbBuyOn(String store) => _p('Buy on $store', '$store पर ख़रीदें');
  String get hbStoreComingSoon => _p(
      'Our store is coming soon. For now it\'s saved to your plan - you can also buy it elsewhere.',
      'हमारा स्टोर जल्द आ रहा है। अभी यह आपके प्लान में सेव है — आप इसे कहीं और से भी ख़रीद सकती हैं।');
  // Buy elsewhere
  String get hbWhereBuy => _p('Where will you buy it?', 'आप कहाँ से ख़रीदेंगी?');
  String get hbProductLinkOptional =>
      _p('Product link (optional)', 'प्रोडक्ट लिंक (ज़रूरी नहीं)');
  String get hbPriceOptional => _p('Price (optional)', 'दाम (ज़रूरी नहीं)');
  String get hbNotesOptional => _p('Notes (optional)', 'नोट (ज़रूरी नहीं)');
  String get hbLinkSaved => _p('Link saved', 'लिंक सेव');
  String get hbPurchasePending => _p('Purchase pending', 'ख़रीदना बाक़ी');
  // Add custom
  String get hbAddCustom => _p('Add custom item', 'अपनी चीज़ जोड़ें');
  String get hbAddCustomTitle => _p('Add your own item', 'अपनी चीज़ जोड़ें');
  String get hbCustomNameHint =>
      _p('e.g. Special blanket, family photo…', 'जैसे ख़ास कंबल, परिवार की फ़ोटो…');
  String get hbWhichSection => _p('Which section?', 'कौन सा हिस्सा?');
  String get hbItemAdded => _p('Added to your bag ❤️', 'आपके बैग में जुड़ गया ❤️');
  // Suggested essentials
  String get hbSuggestedTitle => _p('Most mothers also pack', 'ज़्यादातर माँएँ यह भी रखती हैं');
  String get hbAddWord => _p('Add', 'जोड़ें');
  // Planner filters
  String hbFilter(String key) {
    switch (key) {
      case 'fav':
        return _p('Favourites', 'पसंदीदा');
      case 'veda':
        return _p('ParentVeda', 'ParentVeda');
      case 'else':
        return _p('Elsewhere', 'कहीं और');
      case 'owned':
        return _p('Owned', 'पहले से');
      case 'packed':
        return _p('Packed', 'पैक');
      case 'pending':
        return _p('Pending', 'बाक़ी');
      case 'skipped':
        return _p('Skipped', 'छोड़ा');
      default:
        return _p('All', 'सब');
    }
  }
  // Shopping
  String get hbShoppingTitle => _p('Shopping summary', 'ख़रीदारी का ब्योरा');
  String get hbVedaPurchases => _p('ParentVeda purchases', 'ParentVeda से ख़रीद');
  String get hbExternalPurchases => _p('External purchases', 'बाहर से ख़रीद');
  String get hbAlreadyOwnedTotal => _p('Already owned', 'पहले से');
  String get hbTotalPlanned => _p('Total planned spend', 'कुल अनुमानित ख़र्च');
  String get hbBuyingFromVeda => _p('Buying from ParentVeda', 'ParentVeda से ख़रीद रहे');
  String get hbBuyingElsewhere => _p('Buying elsewhere', 'कहीं और से ख़रीद रहे');
  String get hbOwnedGroup => _p('Already owned', 'पहले से है');
  String get hbPendingGroup => _p('Still to plan', 'अभी तय करना है');
  String get hbNothingHere =>
      _p('Nothing here yet.', 'यहाँ अभी कुछ नहीं।');
  // Partner share
  String get hbSharePartner => _p('Share with partner', 'साथी के साथ साझा करें');
  String hbShareProgress(int p) => _p(
      'Our hospital bag is $p% ready ❤️',
      'हमारा अस्पताल बैग $p% तैयार है ❤️');
  String get hbShareCanHelp =>
      _p('Things you can help with:', 'जिन चीज़ों में आप मदद कर सकते हैं:');
  String get hbShareNothingPending =>
      _p('Everything is planned for now ❤️', 'फ़िलहाल सब तय हो चुका है ❤️');
  // Emotional moments
  String hbCategoryReady(String name) => _p('$name ready 🎉', '$name तैयार 🎉');
  String get hbCategoryReadyBody =>
      _p('This section is all prepared.', 'यह हिस्सा पूरी तरह तैयार है।');
  String get hbBagReadyTitle =>
      _p('Your hospital bag is ready ❤️', 'आपका अस्पताल बैग तैयार है ❤️');
  String get hbBagReadyBody => _p(
      "You are prepared for one of life's most beautiful moments.",
      'आप ज़िंदगी के सबसे ख़ूबसूरत पलों में से एक के लिए तैयार हैं।');
  // Search
  String get hbSearchHint => _p('Search your bag…', 'अपने बैग में ढूँढिए…');
  String get hbNoResults => _p('Nothing found.', 'कुछ नहीं मिला।');
  // Product / marketplace
  String get hbChooseOption =>
      _p('Choose what works for you', 'जो आपके लिए सही हो वह चुनिए');
  String get hbDecideHow =>
      _p('Or, how will you get it?', 'या, आप इसे कैसे लेंगी?');
  String get hbEditDetails => _p('Edit details', 'विवरण बदलें');
  String get hbOrderFromVeda =>
      _p('Order from ParentVeda', 'ParentVeda से ऑर्डर करें');

  // ===========================================================================
  //  TOOLS - Contraction Tracker
  // ===========================================================================
  String get contractionToolTitle =>
      _p('Contraction Tracker', 'संकुचन ट्रैकर');
  String get contractionIntro => _p(
      'Record contraction timing and patterns that may be useful when speaking with your healthcare provider. Always follow your provider\'s advice.',
      'संकुचन का समय और पैटर्न दर्ज कीजिए जो डॉक्टर से बात करते वक़्त काम आ सकते हैं। हमेशा अपने डॉक्टर की सलाह मानें।');
  // "What is this" explainer - what a contraction is + true vs false (Braxton
  // Hicks) + how to time one. So a first-time user understands the tool.
  String get ctAboutTitle =>
      _p('Understanding contractions', 'संकुचन को समझना');
  String get ctAboutBody => _p(
      'A contraction is your womb tightening and then relaxing. Not every tightening is labour. "Braxton Hicks" (practice) contractions are common and usually harmless - they tend to be irregular, do not get stronger or closer together, and often ease when you rest, change position or drink water. True labour contractions tend to get longer, stronger and closer together over time, and do not fade. To time one: tap when it starts, and again when it ends.',
      'संकुचन यानी आपकी बच्चेदानी का कसना और फिर ढीला होना। हर कसाव प्रसव नहीं होता। "Braxton Hicks" (अभ्यास वाले) संकुचन आम और अक्सर हानिरहित होते हैं — ये अनियमित होते हैं, न तेज़ होते हैं न पास-पास आते हैं, और आराम करने, करवट बदलने या पानी पीने पर अक्सर कम हो जाते हैं। असली प्रसव के संकुचन समय के साथ लंबे, तेज़ और पास-पास होते जाते हैं, और कम नहीं होते। समय नापने के लिए: शुरू होने पर टैप कीजिए, और ख़त्म होने पर फिर टैप कीजिए।');
  // The not-a-medical-app disclaimer (kept clearly visible).
  String get ctDisclaimerTitle =>
      _p('A timer, not a diagnosis', 'एक टाइमर, निदान नहीं');
  String get ctDisclaimerBody => _p(
      'ParentVeda is not a medical or diagnostic service. This tool only records your contractions and shows the pattern - it cannot confirm that you are in labour, or rule it out. Only your doctor or midwife can. If anything feels off, contact them, even if the pattern here looks calm.',
      'ParentVeda कोई मेडिकल या डायग्नोस्टिक सेवा नहीं है। यह टूल सिर्फ़ आपके संकुचन दर्ज करके पैटर्न दिखाता है — यह न प्रसव की पुष्टि कर सकता है, न इनकार। सिर्फ़ आपकी डॉक्टर या midwife ही यह कह सकती हैं। अगर कुछ ठीक न लगे, तो उनसे संपर्क कीजिए — चाहे यहाँ पैटर्न शांत ही क्यों न दिखे।');
  // Universal "always consult" line shown under every (non-urgent) assessment.
  String get ctAlwaysConsult => _p(
      'Timing cannot confirm or rule out labour. If you are unsure, or something does not feel right, contact your doctor or midwife - even now.',
      'समय नापने से प्रसव की न पुष्टि हो सकती है न इनकार। अगर पक्का न हो, या कुछ ठीक न लगे, तो अभी अपनी डॉक्टर या midwife से संपर्क कीजिए।');

  // ---- Reminders (customizable local notifications) ------------------------
  String get rmdTitle => _p('Reminders', 'रिमाइंडर');
  String get rmdToolSub =>
      _p('Gentle nudges, your way', 'आपके तरीक़े से हल्की याद');
  String get rmdEmpty => _p('No reminders yet', 'अभी कोई रिमाइंडर नहीं');
  String get rmdEmptySub => _p(
      'Add a gentle nudge for anything - a Kegel session, your vitamin, reading to baby, or your own.',
      'किसी भी चीज़ के लिए हल्की याद जोड़िए — Kegel सेशन, विटामिन, शिशु को पढ़ना, या अपनी ख़ुद की।');
  String get rmdAdd => _p('Add reminder', 'रिमाइंडर जोड़ें');
  String get rmdRemindMe => _p('Remind me', 'मुझे याद दिलाएँ');
  String get rmdNew => _p('New reminder', 'नया रिमाइंडर');
  String get rmdEditTitle => _p('Edit reminder', 'रिमाइंडर बदलें');
  String get rmdWhatLabel => _p('What should we remind you about?',
      'हम आपको किस चीज़ की याद दिलाएँ?');
  String get rmdWhatHint =>
      _p('e.g. Time for your Kegels', 'जैसे Kegel का समय');
  String get rmdSuggestions => _p('Quick ideas', 'जल्दी सुझाव');
  String get rmdTime => _p('Time', 'समय');
  String get rmdRepeat => _p('Repeat', 'दोहराएँ');
  String get rmdOnce => _p('Once', 'एक बार');
  String get rmdDaily => _p('Daily', 'रोज़ाना');
  String get rmdWeekly => _p('Weekly', 'साप्ताहिक');
  String get rmdAddTime => _p('Add time', 'समय जोड़ें');
  String get rmdOnDay => _p('On', 'दिन');
  String get rmdSave => _p('Save reminder', 'रिमाइंडर सेव करें');
  String get rmdDelete => _p('Delete reminder', 'रिमाइंडर हटाएँ');
  String get rmdSaved => _p('Reminder saved 💜', 'रिमाइंडर सेव हो गया 💜');
  String get rmdRemoved => _p('Reminder removed', 'रिमाइंडर हटा दिया');
  String get rmdScheduleNote => _p('We\'ll nudge you at the time you set.',
      'आपके सेट किए समय पर हम याद दिलाएँगे।');
  // Extended repeat labels (used by medication reminders).
  String get rmdFortnightly => _p('Fortnightly', 'हर 2 हफ़्ते');
  String get rmdMonthly => _p('Monthly', 'हर महीने');
  String get rmdCustomDays => _p('Specific days', 'चुने हुए दिन');
  // --- Medication reminders (Daily Medication card; never tied to a medicine) -
  String get mrTitle => _p('My reminders', 'मेरे रिमाइंडर');
  String get mrAdd => _p('Add reminder', 'रिमाइंडर जोड़ें');
  String get mrNew => _p('Add a reminder', 'रिमाइंडर जोड़ें');
  String get mrEdit => _p('Edit reminder', 'रिमाइंडर बदलें');
  String get mrFreq => _p('How often?', 'कितनी बार?');
  String get mrFreqOnce => _p('Once a day', 'दिन में एक बार');
  String get mrFreqTwice => _p('Twice a day', 'दिन में दो बार');
  String get mrFreqThrice => _p('Thrice a day', 'दिन में तीन बार');
  String get mrFreqWeekly => _p('Weekly', 'हर हफ़्ते');
  String get mrFreqFortnightly => _p('Fortnightly', 'हर 2 हफ़्ते');
  String get mrFreqMonthly => _p('Monthly', 'हर महीने');
  String get mrFreqCustom => _p('Custom', 'अपना');
  String get mrTimes => _p('At these times', 'इन समयों पर');
  String mrTimeN(int n) => _p('Time $n', 'समय $n');
  String get mrDayOfMonth => _p('Day of month', 'महीने का दिन');
  String get mrOnDays => _p('On these days', 'इन दिनों पर');
  String get mrNote => _p('Note (what should it say?)', 'नोट (क्या लिखें?)');
  String get mrNoteHint =>
      _p('e.g. Iron tablet after lunch', 'जैसे: दोपहर के खाने के बाद Iron टैबलेट');
  String get mrDefaultTitle =>
      _p('Medication reminder 💊', 'दवा का रिमाइंडर 💊');
  String get mrSave => _p('Save reminder', 'रिमाइंडर सेव करें');
  String get mrDelete => _p('Delete', 'हटाएँ');
  String get mrEmpty => _p('No reminders yet - tap the bell to add one.',
      'अभी कोई रिमाइंडर नहीं — घंटी दबाकर जोड़िए।');
  String get mrSaved => _p('Reminder set 💜', 'रिमाइंडर सेट हो गया 💜');
  String mrTimesPerDay(int n) => _p('$n× daily', 'रोज़ाना $n बार');
  String rmdWeekdayShort(int wd) {
    const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const hi = ['सोम', 'मंगल', 'बुध', 'गुरु', 'शुक्र', 'शनि', 'रवि'];
    final i = (wd - 1).clamp(0, 6);
    return _p(en[i], hi[i]);
  }

  /// Month names, 1-indexed (`monthShort(1) == 'Jan'`).
  ///
  /// Six screens each carried their own `['Jan', 'Feb', …]` array, so a date
  /// stayed English on a Hindi phone in six different places. One helper means
  /// the next screen that needs a month cannot reintroduce the problem.
  ///
  /// The numerals stay Western (4, not ४) — that is what an Indian reader
  /// expects on a date, a price and a phone screen, and mixing scripts inside
  /// one date string reads worse than either choice alone.
  String monthShort(int m) {
    const en = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const hi = ['जन', 'फ़र', 'मार्च', 'अप्रैल', 'मई', 'जून',
                'जुल', 'अग', 'सित', 'अक्तू', 'नव', 'दिस'];
    final i = (m - 1).clamp(0, 11);
    return _p(en[i], hi[i]);
  }

  // ---- Ready for Birth ----------------------------------------------------
  // The category name arrives twice: `hi` for the Hindi sentence and a
  // lowercased `en` for the English one. Lowercasing is an English habit —
  // Devanagari has no case at all — so doing it at the call site would either
  // be wrong in Hindi or need a language check inside a widget.

  String get rfbFullyPacked => _p("You're fully packed — beautifully ready.",
      'आपका सब कुछ पैक है — बिलकुल तैयार।');

  String rfbOnlyLeft(String hi, String enLower) =>
      _p('Only your $enLower remain.', 'बस आपका $hi बाक़ी है।');

  String rfbNextUp(String hi, String enLower) =>
      _p('Next up: your $enLower.', 'अगला: आपका $hi।');

  String rfbDaysToDue(int n) =>
      _p('$n days to your due date', 'डिलीवरी की तारीख़ में $n दिन');
  String get rfbDueToday =>
      _p('Your due date is today', 'आज आपकी डिलीवरी की तारीख़ है');
  String get rfbPastDue => _p('A little past your due date — any day now',
      'डिलीवरी की तारीख़ थोड़ी निकल गई — अब कभी भी');
  String rfbWeekCaps(int w) => _p('WEEK $w', 'हफ़्ता $w');
  String get rfbReadyForBirth => _p('Ready for birth', 'जन्म के लिए तैयार');
  String get rfbGettingReady => _p('Getting ready', 'तैयारी चल रही है');
  String get rfbAllDone => _p('All done', 'सब हो गया');
  String rfbMinLeft(int m) => _p('~$m min left', '~$m मिनट बाक़ी');
  String rfbMin(int m) => _p('~$m min', '~$m मिनट');
  String get rfbAllPacked => _p('All packed', 'सब पैक');
  String rfbPackedToGo(int packed, int remaining) =>
      _p('$packed packed · $remaining to go',
          '$packed पैक · $remaining बाक़ी');
  String rfbPackedOf(int packed, int total) =>
      _p('$packed of $total packed', '$total में से $packed पैक');
  String rfbStepOf(int step, int total) =>
      _p('Step $step of $total', 'क़दम $step / $total');
  String get rfbAllDoneHere => _p('All done here', 'यहाँ सब हो गया');
  String rfbLeftToPack(int n) =>
      _p('$n left to pack', '$n पैक करने बाक़ी');
  String get rfbFinish => _p('Finish', 'ख़त्म करें');
  String get rfbDoneNext => _p('Done · next', 'हो गया · अगला');
  String get rfbDeliveryType => _p('Delivery type', 'डिलीवरी का तरीक़ा');
  String get rfbNotSure => _p('Not sure', 'पक्का नहीं');
  String get rfbSeasonOfDue =>
      _p('Season of your due date', 'आपकी डिलीवरी का मौसम');
  String get rfbHospitalProvides =>
      _p('My hospital already provides', 'मेरा अस्पताल यह पहले से देता है');
  String get rfbOptions => _p('Options', 'विकल्प');
  String rfbWhyThenPicks(String why) => _p(
      '$why Our picks below balance comfort, safety and value — or grab one '
          'from a store you already trust.',
      '$why नीचे हमारी पसंद आराम, सुरक्षा और दाम — तीनों में संतुलन रखती है। '
          'या किसी ऐसी दुकान से ले लीजिए जिस पर आप पहले से भरोसा करती हैं।');
  String rfbBuyOn(String store) => _p('Buy on $store', '$store पर ख़रीदें');
  String get rfbPackTogether =>
      _p("Let's Pack Together", 'आइए साथ में पैक करें');

  // ---- Notifications ------------------------------------------------------
  // A notification is read on a lock screen, hours after the app was last
  // open. It is the one place the app speaks to her without her asking, so an
  // English alarm from a Hindi app is jarring in a way an English button is
  // not.

  String medicationDue(String name, String dose) => _p(
      dose.isEmpty ? "It's time for your $name" : "It's time for your $name ($dose)",
      dose.isEmpty ? '$name का समय हो गया' : '$name ($dose) का समय हो गया');

  String get notifNotReady => _p(
      'Notifications are not ready on this device.',
      'इस फ़ोन पर सूचनाएँ अभी तैयार नहीं हैं।');

  String get notifExactAlarmsOff => _p(
      ' — but exact alarms are OFF for this app, so it may be delayed or '
          'dropped. Turn on "Alarms & reminders" in the app settings.',
      ' — पर इस ऐप के लिए exact alarms बंद हैं, इसलिए यह देर से आ सकता है या '
          'छूट सकता है। ऐप सेटिंग में "Alarms & reminders" चालू कीजिए।');

  String notifScheduledFor(String time, String gap) => _p(
      'Scheduled for $time. Lock the phone and wait a minute.$gap',
      '$time के लिए तय हो गया। फ़ोन लॉक कीजिए और एक मिनट रुकिए।$gap');

  String notifSchedulingFailed(Object e) =>
      _p('Scheduling FAILED: $e', 'तय नहीं हो पाया: $e');

  // ---- Transient messages: SnackBars, toasts, failures --------------------
  // These appear for three seconds and vanish, which is exactly why they were
  // the last English left: nobody screenshots a SnackBar. They are also where
  // a mother is most often being told something went wrong.

  String comingSoonLabel(String what) =>
      _p('$what — coming soon', '$what — जल्द आ रहा है');

  String opensSoon(String what) => _p('$what opens soon', '$what जल्द खुलेगा');

  // Social sign-in (Google / Apple / Facebook). Brand names stay Latin — she
  // is looking for the word on the button, and "गूगल" is not what it says.
  String socialNotSetUp(String what) => _p(
      '$what sign-in isn\'t set up yet. Please use email for now.',
      '$what साइन-इन अभी तैयार नहीं है। फ़िलहाल email से आइए।');
  String socialSignInFailed(String what) => _p(
      '$what sign-in failed. Please try again.',
      '$what साइन-इन नहीं हो पाया। फिर कोशिश कीजिए।');
  String get socialAppleSoon => _p(
      'Sign in with Apple is coming soon. Please use Google or email.',
      'Apple से साइन-इन जल्द आ रहा है। अभी Google या email से आइए।');
  String get socialNoSession => _p(
      'Signed in, but no session was created. Please try again.',
      'साइन-इन तो हुआ, पर session नहीं बना। फिर कोशिश कीजिए।');
  String get socialCouldNotOpen => _p(
      'Couldn\'t open the sign-in page.', 'साइन-इन पेज नहीं खुल पाया।');

  // Forgot password. `password`, `email` and `code` stay Latin — she reads them
  // on the very screen she is filling in, and translating the label while the
  // field beside it says "Password" helps nobody.
  String get authEnterEmail => _p('Enter your email.', 'अपना email डालिए।');
  // Deliberately does not say whether the account exists — see _sendResetCode.
  String get authResetCodeSent => _p(
      'If that email has an account, we\'ve sent a 6-digit code.',
      'अगर उस email पर account है, तो हमने 6 अंकों का code भेज दिया है।');
  String get authResetSendFailed => _p(
      'Couldn\'t send the code. Please try again.',
      'Code नहीं भेज पाए। फिर कोशिश कीजिए।');
  String get authEnterFullCode =>
      _p('Enter all 6 digits.', 'पूरे 6 अंक डालिए।');
  String get authCodeCheckFailed => _p(
      'Couldn\'t check the code. Please try again.',
      'Code जाँच नहीं पाए। फिर कोशिश कीजिए।');
  String get authPasswordTooShort => _p(
      'Password must be at least 6 characters.',
      'Password कम से कम 6 अक्षरों का होना चाहिए।');
  String get authPasswordsDoNotMatch =>
      _p('Both passwords must match.', 'दोनों password एक जैसे होने चाहिए।');
  String get authPasswordUpdated =>
      _p('Password updated ✓', 'Password बदल गया ✓');
  String get authPasswordUpdateFailed => _p(
      'Couldn\'t update the password. Please try again.',
      'Password नहीं बदल पाए। फिर कोशिश कीजिए।');
  String get authProfileSavedPending => _p(
      'Saved. Confirm your email to finish.',
      'सेव हो गया। पूरा करने के लिए अपना email confirm कीजिए।');

  // Account deletion. Said plainly and without softening: this is the one
  // action in the app that cannot be undone, and comforting wording here would
  // be a kindness that costs her everything she has written.
  String get deleteAccount => _p('Delete account', 'Account हटाइए');
  String get deleteAccountBody => _p(
      'This permanently deletes your account and everything in it — your '
          'journal, your entries and your records. It cannot be undone.\n\n'
          'Type DELETE to confirm.',
      'इससे आपका account और उसमें रखा सब कुछ हमेशा के लिए हट जाएगा — आपकी '
          'journal, आपकी entries और आपके records। यह वापस नहीं आ सकता।\n\n'
          'पक्का करने के लिए DELETE लिखिए।');
  // NOTE: the word she types to confirm is deliberately NOT in this table —
  // it is compared against her input, not rendered, so a translated copy would
  // silently stop matching the moment she switched language. It lives as a
  // plain const, `kDeleteAccountKeyword` in services/auth/delete_account.dart.
  String get deleteAccountConfirm => _p('Delete', 'हटाइए');
  String get deleteAccountWorking =>
      _p('Deleting your account…', 'आपका account हटाया जा रहा है…');
  String get deleteAccountFailed => _p(
      'Could not delete the account. Please try again.',
      'Account नहीं हट पाया। फिर कोशिश कीजिए।');
  String get cancelLabel => _p('Cancel', 'रहने दीजिए');
  String get closeLabel => _p('Close', 'बंद कीजिए');
  String get showPassword => _p('Show password', 'Password दिखाइए');
  String get hidePassword => _p('Hide password', 'Password छिपाइए');
  String get deleteAccountDoneTitle =>
      _p('Account deleted', 'Account हट गया');
  String get deleteAccountDoneBody => _p(
      'Your account and everything in it have been deleted. ParentVeda will '
          'close now.',
      'आपका account और उसमें रखा सब कुछ हट गया है। ParentVeda अब बंद हो जाएगा।');

  String get whatsappUpdatesOn =>
      _p('WhatsApp updates on', 'WhatsApp अपडेट चालू');
  String get whatsappUpdatesOff =>
      _p('WhatsApp updates off', 'WhatsApp अपडेट बंद');
  String get couldNotSaveRetry => _p(
      'Could not save - please try again', 'सेव नहीं हो पाया — फिर कोशिश कीजिए');

  String get videoComingSoon =>
      _p('This video is coming soon', 'यह वीडियो जल्द आ रहा है');
  String get explainerBeingFilmed => _p(
      'This explainer is still being filmed.',
      'इसकी वीडियो अभी बन रही है।');

  String get signInFirstToSend => _p(
      'Sign in first, so we know where to send it.',
      'पहले साइन इन कीजिए, ताकि हमें पता हो कहाँ भेजना है।');
  String get couldNotSaveConnection => _p(
      'Could not save that — check your connection and try again.',
      'यह सेव नहीं हो पाया — अपना इंटरनेट देखिए और फिर कोशिश कीजिए।');

  String get savedToGalleryAndMemories => _p(
      'Saved to your gallery and My Memories.',
      'आपकी गैलरी और "मेरी यादें" में सेव हो गया।');
  String get savedToMemoriesAllowPhoto => _p(
      'Saved to My Memories. Allow photo access to save to your gallery.',
      '"मेरी यादें" में सेव हो गया। गैलरी में सेव करने के लिए फ़ोटो की अनुमति दीजिए।');
  String get couldNotPrepareImage => _p(
      'Could not prepare the image. Try again.',
      'तस्वीर तैयार नहीं हो पाई। फिर कोशिश कीजिए।');
  String couldNotAddPhoto(Object e) =>
      _p('Could not add photo: $e', 'फ़ोटो नहीं जुड़ पाई: $e');

  String get referralNotRunning => _p(
      'This referral offer is not running right now',
      'यह निमंत्रण वाला ऑफ़र अभी चालू नहीं है');
  String get inviteLimitToday => _p(
      'You have hit today\'s invite limit. Try again tomorrow.',
      'आज के निमंत्रण की सीमा पूरी हो गई। कल फिर कोशिश कीजिए।');
  String get inviteLimitMonth => _p(
      'You have hit this month\'s invite limit.',
      'इस महीने के निमंत्रण की सीमा पूरी हो गई।');
  String get maxRewardsEarned => _p(
      'You have earned the maximum rewards for this campaign.',
      'इस कैंपेन के सारे इनाम आपको मिल चुके हैं।');

  // ---- Text that LEAVES the app -------------------------------------------
  // These reach people who have not installed ParentVeda, so they are read by
  // someone with no context at all. A mother who reads the app in Hindi should
  // be able to forward something her family reads in Hindi too — an English
  // invite from a Hindi app is the moment the localisation stops being real.

  String inviteShareText(String code, String reward, String link) => _p(
      'I am using ParentVeda through my pregnancy — it has been genuinely '
          'useful. Join with my code $code and you get $reward to start '
          'with.\n\n$link',
      'मैं अपनी गर्भावस्था में ParentVeda इस्तेमाल कर रही हूँ — सच में काम आया है। '
          'मेरे कोड $code से जुड़िए, शुरुआत में आपको $reward मिलेगा।\n\n$link');

  String get inviteCopied =>
      _p('Invite copied. Paste it wherever you like.',
          'निमंत्रण कॉपी हो गया। जहाँ चाहें चिपका दीजिए।');

  String pairingShareText(String code) => _p(
      'Join me on ParentVeda 💜  Download the app, choose "I\'m the father", '
          'and enter my pairing code: $code',
      'ParentVeda पर मेरे साथ जुड़िए 💜  ऐप डाउनलोड कीजिए, "मैं पिता हूँ" चुनिए, '
          'और मेरा कोड डालिए: $code');

  String get pairingShareSubject =>
      _p('Your ParentVeda pairing code', 'आपका ParentVeda जोड़ने वाला कोड');

  String rewardEarnedTitle(String label) =>
      _p('You earned $label', 'आपको $label मिला');

  String get rewardEarnedBody => _p(
      'A friend you invited finished setting up. It is in your account, '
          'ready whenever you need it.',
      'आपकी बुलाई सहेली ने अपना सेटअप पूरा कर लिया। यह आपके खाते में है, जब '
          'चाहें इस्तेमाल कीजिए।');

  String get rewardEarnedFootnote => _p(
      'Spend it on a consultation with any ParentVeda expert.',
      'इसे ParentVeda के किसी भी विशेषज्ञ से परामर्श पर इस्तेमाल कीजिए।');

  /// Stands in for a name when an invite has none — so the notification reads
  /// as a sentence rather than starting with a blank.
  String get someFriend => _p('Your friend', 'आपकी सहेली');

  String friendJoinedTitle(String who) =>
      _p('$who joined ParentVeda', '$who ParentVeda से जुड़ीं');

  String get friendJoinedBody => _p(
      'Because of you. Your reward unlocks once she finishes setting up.',
      'आपकी वजह से। उनका सेटअप पूरा होते ही आपका इनाम खुल जाएगा।');

  String get rewardReadyBody => _p(
      'It is in your account, ready whenever you need it.',
      'यह आपके खाते में है, जब चाहें इस्तेमाल कीजिए।');

  String unlockedTitle(String what) => _p('Unlocked: $what', 'खुल गया: $what');

  String get birthClubBetter => _p(
      'Your Birth Club just got a little better.',
      'आपका Birth Club अभी थोड़ा और बेहतर हो गया।');

  /// A derived Birth Club room, e.g. "November 2026 Moms".
  ///
  /// Built at read time rather than stored, so the room a mother sees follows
  /// the language she is reading in — the same room, named in her words.
  String birthClubName(int month, int year) =>
      _p('${monthLong(month)} $year Moms',
          '${monthLong(month)} $year की माँएँ');

  String birthClubDescription(int month, int year) => _p(
      'Mothers due in ${monthLong(month)} $year, going through it together '
          '- week by week.',
      'वे माँएँ जिनकी डिलीवरी ${monthLong(month)} $year में है — हफ़्ते-दर-हफ़्ते, '
          'यह सफ़र साथ में।');

  String monthLong(int m) {
    const en = ['January', 'February', 'March', 'April', 'May', 'June',
                'July', 'August', 'September', 'October', 'November',
                'December'];
    const hi = ['जनवरी', 'फ़रवरी', 'मार्च', 'अप्रैल', 'मई', 'जून',
                'जुलाई', 'अगस्त', 'सितंबर', 'अक्तूबर', 'नवंबर', 'दिसंबर'];
    final i = (m - 1).clamp(0, 11);
    return _p(en[i], hi[i]);
  }

  // Suggested reminder presets.
  String get rmdSugKegel => _p('Time for your Kegels 🌸', 'Kegel का समय 🌸');
  String get rmdSugVitamin =>
      _p('Take your prenatal vitamin 💊', 'अपना prenatal vitamin लीजिए 💊');
  String get rmdSugRead =>
      _p('Read to your baby 📖', 'अपने शिशु को पढ़िए 📖');
  String get rmdSugWater => _p('Sip some water 💧', 'थोड़ा पानी पीजिए 💧');
  String get rmdSugCalm =>
      _p('A calm moment for you 🕊️', 'आपके लिए एक शांत पल 🕊️');

  // ---- Trimester chart (Home) ----------------------------------------------
  String get tcTitle => _p('Trimester chart', 'तिमाही चार्ट');
  String get tcTrimester => _p('Trimester', 'तिमाही');
  String get tcMonth => _p('Month', 'महीना');
  String get tcWeek => _p('Week', 'हफ़्ता');
  String tcDueDate(String date) => _p('Due Date: $date', 'डिलीवरी की तारीख़: $date');
  String get contractionEmpty => _p(
      'Ready to start tracking? When a contraction begins, tap the button below.',
      'रिकॉर्ड शुरू करें? जब संकुचन शुरू हो, नीचे बटन दबाइए।');
  String get contractionStartedCta =>
      _p('CONTRACTION STARTED', 'संकुचन शुरू');
  String get contractionEndedCta =>
      _p('CONTRACTION ENDED', 'संकुचन ख़त्म');
  String get currentContraction => _p('Current contraction', 'अभी का संकुचन');
  String get tapWhenEnds =>
      _p('Tap when the contraction ends.', 'जब संकुचन ख़त्म हो, टैप कीजिए।');
  String get timeSinceLast =>
      _p('Time since last contraction', 'पिछले संकुचन से समय');
  String get lastContractionLabel => _p('Last contraction', 'पिछला संकुचन');
  String get avgDurationLabel => _p('Average duration', 'औसत अवधि');
  String get avgIntervalLabel => _p('Average interval', 'औसत अंतराल');
  String get longestDurationLabel => _p('Longest duration', 'सबसे लंबा');
  String get shortestIntervalLabel => _p('Shortest interval', 'सबसे छोटा अंतराल');
  String get contractionsLoggedLabel =>
      _p('Contractions logged', 'दर्ज संकुचन');
  String get currentPatternLabel => _p('Current pattern', 'अभी का पैटर्न');
  String get sessionSummaryTitle => _p('Session summary', 'सेशन का ब्योरा');
  String get viewSummaryCta => _p('View summary', 'ब्योरा देखें');
  String get endSessionCta => _p('End session', 'सेशन ख़त्म करें');
  String get doctorSummaryTitle => _p('Doctor summary', 'डॉक्टर के लिए ब्योरा');
  String get lastHourLabel => _p('Last hour', 'पिछला घंटा');
  String get copySummaryCta => _p('Copy summary', 'ब्योरा कॉपी करें');
  String get summaryCopied => _p('Summary copied 💜', 'ब्योरा कॉपी हो गया 💜');
  String get consultProvider => _p(
      'Please consult your healthcare provider for interpretation.',
      'व्याख्या के लिए अपने डॉक्टर से संपर्क कीजिए।');
  String secLabel(int n) => _p('$n sec', '$n सेकंड');
  String minLabel(int n) => _p('$n min', '$n मिनट');
  // Compact minutes + seconds (e.g. "8s", "1m 5s", "2m") - so short intervals
  // never read as "0 min".
  String minSecLabel(int seconds) {
    final m = seconds ~/ 60;
    final sec = seconds % 60;
    if (m == 0) return '${sec}s';
    if (sec == 0) return '${m}m';
    return '${m}m ${sec}s';
  }
  String contractionNumber(int n) => _p('Contraction #$n', 'संकुचन #$n');
  String get thisSessionContractions =>
      _p('This session', 'यह सेशन');
  // Live labour-signal banner (gentle, never a diagnosis)
  String get laborTrackingTitle => _p('Keep tracking', 'दर्ज करते रहें');
  String get laborTrackingBody => _p(
      "Log a few more and we'll show you the pattern.",
      'कुछ और दर्ज कीजिए, हम आपको पैटर्न दिखाएँगे।');
  String get laborIrregularTitle =>
      _p('Irregular for now', 'अभी अनियमित');
  String get laborIrregularBody => _p(
      'Your contractions are still spaced out and irregular - often early days.',
      'आपके संकुचन अभी दूर-दूर और अनियमित हैं — अक्सर शुरुआती दौर।');
  String get laborEarlyTitle => _p('Looks like early labour', 'शुरुआती प्रसव लगता है');
  String get laborEarlyBody => _p(
      'A pattern is forming. Rest, hydrate and keep tracking.',
      'एक पैटर्न बन रहा है। आराम कीजिए, पानी पीजिए और दर्ज करते रहिए।');
  String get laborActiveTitle =>
      _p('This could be active labour', 'यह सक्रिय प्रसव हो सकता है');
  String get laborActiveBody => _p(
      'Your contractions look regular and strong. Only you know how you feel - if unsure, it is always okay to call your doctor.',
      'आपके संकुचन नियमित और तेज़ लग रहे हैं। आप ही जानती हैं आप कैसा महसूस कर रही हैं — अगर पक्का न हो, तो डॉक्टर को कॉल करना हमेशा ठीक है।');
  // Labour confirmation prompt
  String get laborPromptTitle =>
      _p('Does this feel like labour?', 'क्या यह प्रसव जैसा लगता है?');
  String get laborPromptBody => _p(
      'Your recent contractions show a regular, strong pattern often seen in active labour. How are you feeling?',
      'आपके हाल के संकुचन नियमित और तेज़ पैटर्न दिखाते हैं जो अक्सर सक्रिय प्रसव में होता है। आप कैसा महसूस कर रही हैं?');
  String get laborYes => _p('Yes, I think so', 'हाँ, लगता है');
  String get laborNo => _p('Not yet', 'अभी नहीं');
  String get laborSavedNote =>
      _p('Saved to this session 💜', 'इस सेशन में सेव हो गया 💜');
  String feltInLabour(bool yes) => yes
      ? _p('Felt like labour', 'प्रसव जैसा लगा')
      : _p('Not labour yet', 'अभी प्रसव नहीं');
  // Two-layer assessment (pattern classification + medical override)
  String assessTitle(String level) {
    switch (level) {
      case 'emergency':
        return _p('Please seek medical advice', 'कृपया मेडिकल सलाह लीजिए');
      case 'preterm':
        return _p('Before 37 weeks - please check in',
            '37 हफ़्ते से पहले — कृपया संपर्क कीजिए');
      case 'active':
        return _p('Active labour likely', 'सक्रिय प्रसव की संभावना');
      case 'likely':
        return _p('Labour pattern likely', 'प्रसव पैटर्न की संभावना');
      case 'early':
        return _p('Possible early labour', 'संभावित शुरुआती प्रसव');
      case 'noPattern':
        return _p('No clear pattern yet', 'अभी कोई साफ़ पैटर्न नहीं');
      default:
        return _p('Keep tracking', 'दर्ज करते रहें');
    }
  }

  String assessSummary(String level) {
    switch (level) {
      case 'emergency':
        return _p(
            "Some symptoms you've reported may require prompt medical assessment. Contact your healthcare provider, maternity unit, or emergency services immediately.",
            'आपके बताए कुछ लक्षणों के लिए तुरंत मेडिकल जाँच ज़रूरी हो सकती है। अपने डॉक्टर, मैटरनिटी यूनिट या इमरजेंसी सेवा से तुरंत संपर्क कीजिए।');
      case 'preterm':
        return _p(
            'Regular contractions before 37 weeks may require medical assessment. Contact your healthcare provider promptly.',
            '37 हफ़्ते से पहले नियमित संकुचन के लिए मेडिकल जाँच ज़रूरी हो सकती है। अपने डॉक्टर से जल्दी संपर्क कीजिए।');
      case 'active':
        return _p(
            'Your contractions are frequent, longer, and fairly regular - a pattern often seen in active labour. Even so, strong contractions can sometimes be a false alarm, so this is NOT a confirmation. Please contact your healthcare provider, or follow your birth plan.',
            'आपके संकुचन बार-बार, लंबे और काफ़ी नियमित हैं — ऐसा पैटर्न अक्सर सक्रिय प्रसव में दिखता है। फिर भी, तेज़ संकुचन कभी-कभी झूठा संकेत भी हो सकते हैं, इसलिए यह पक्का नहीं है। कृपया अपने डॉक्टर से संपर्क कीजिए, या अपने बर्थ प्लान का पालन कीजिए।');
      case 'likely':
        return _p(
            'A steady, labour-like pattern seems to be forming. It might be early labour, or it might still settle - timing alone cannot tell for sure. Consider contacting your healthcare provider for guidance.',
            'एक नियमित, प्रसव जैसा पैटर्न बनता दिख रहा है। यह शुरुआती प्रसव हो सकता है, या अभी शांत भी पड़ सकता है — सिर्फ़ समय से पक्का नहीं कहा जा सकता। मार्गदर्शन के लिए अपने डॉक्टर से संपर्क करने पर विचार कीजिए।');
      case 'early':
        return _p(
            'Contractions may be showing an early labor pattern. Continue monitoring frequency and duration.',
            'संकुचन शुरुआती प्रसव का पैटर्न दिखा सकते हैं। बार-बार होने और अवधि पर नज़र रखिए।');
      case 'noPattern':
        return _p(
            'Current recordings do not show a clear labor pattern. Continue tracking additional contractions.',
            'अभी तक के रिकॉर्ड साफ़ प्रसव पैटर्न नहीं दिखाते। और संकुचन दर्ज करते रहिए।');
      default:
        return _p(
            'More contractions need to be recorded before a pattern can be identified.',
            'पैटर्न पहचानने से पहले और संकुचन दर्ज करने होंगे।');
    }
  }

  // Safety check (Layer 2 inputs)
  String get safetyCheckTitle => _p('Quick safety check', 'जल्दी सुरक्षा जाँच');
  String get safetyCheckSub => _p(
      'A few questions help us flag anything that may need prompt attention.',
      'कुछ सवाल हमें ऐसी चीज़ें पहचानने में मदद करते हैं जिन पर तुरंत ध्यान ज़रूरी हो।');
  String get safetyUpdate => _p('Update', 'अपडेट करें');
  String get safetyAllClear =>
      _p('No concerning symptoms reported', 'कोई चिंता वाला लक्षण नहीं');
  String get safetyReported => _p('Symptoms reported', 'लक्षण दर्ज किए');
  String get qWaterBroken => _p('Has your water broken?', 'क्या आपका पानी टूट गया?');
  String get qBleeding => _p('Any bleeding?', 'कोई ब्लीडिंग?');
  String get qMovementReduced =>
      _p('Reduced baby movement?', 'शिशु की हलचल कम?');
  String get qSeverePain => _p('Severe constant pain between contractions?',
      'संकुचन के बीच तेज़ लगातार दर्द?');
  String get optYes => _p('Yes', 'हाँ');
  String get optNo => _p('No', 'नहीं');
  String get optNotSure => _p('Not sure', 'पक्का नहीं');
  String get bleedNone => _p('None', 'कोई नहीं');
  String get bleedLight => _p('Light spotting', 'हल्की spotting');
  String get bleedHeavy => _p('Heavy', 'तेज़');
  String get timeColumn => _p('Time', 'समय');
  String get durationColumn => _p('Duration', 'अवधि');
  String get intervalColumn => _p('Interval', 'अंतराल');
  String get noContractionSessions => _p(
      'No sessions yet. Your tracked contractions will appear here.',
      'अभी कोई सेशन नहीं। आपके दर्ज संकुचन यहाँ दिखेंगे।');
  String get patternIrregular => _p(
      'Contractions are currently far apart and irregular. Continue monitoring.',
      'संकुचन अभी दूर-दूर और अनियमित हैं। नज़र रखना जारी रखिए।');
  String get patternBuilding => _p(
      'Contractions appear to be occurring more regularly. Continue tracking.',
      'संकुचन अब थोड़े नियमित होते लगते हैं। दर्ज करते रहिए।');
  String get patternRegular => _p(
      'Your contraction pattern appears more regular. You may wish to review your birth plan and contact your healthcare provider according to their advice.',
      'आपका संकुचन पैटर्न अब नियमित लगता है। आप अपना बर्थ प्लान देखना और डॉक्टर की सलाह के अनुसार संपर्क करना चाह सकती हैं।');
  String get eduTitle => _p('Learn', 'जानें');
  String get eduWhatAreContractions =>
      _p('What are contractions?', 'संकुचन क्या होते हैं?');
  String get eduWhatAreContractionsBody => _p(
      'Contractions are the tightening and relaxing of the uterus. Early on they can be irregular; closer to birth they often become longer, stronger and more regular.',
      'संकुचन यानी बच्चेदानी का कसना और ढीला होना। शुरू में ये अनियमित हो सकते हैं; जन्म के क़रीब ये अक्सर लंबे, तेज़ और नियमित हो जाते हैं।');
  String get eduFiveOneOne => _p('What is the 5-1-1 rule?', '5-1-1 नियम क्या है?');
  String get eduFiveOneOneBody => _p(
      'Some providers use the 5-1-1 guideline: contractions every 5 minutes, lasting around 1 minute, for at least 1 hour. Always follow your own provider\'s instructions.',
      'कुछ डॉक्टर 5-1-1 दिशानिर्देश इस्तेमाल करते हैं: हर 5 मिनट में संकुचन, लगभग 1 मिनट तक, कम से कम 1 घंटे के लिए। हमेशा अपने डॉक्टर के निर्देश मानें।');
  String get eduWhenCall =>
      _p('When should I call my provider?', 'डॉक्टर को कब कॉल करें?');
  String get eduWhenCallBody => _p(
      'Follow the guidance your provider gave you. Many suggest calling when contractions become regular, or sooner if you have any concern - bleeding, reduced movement, or your waters break.',
      'अपने डॉक्टर की दी हुई सलाह मानिए। कई कहते हैं कि जब संकुचन नियमित हो जाएँ तब कॉल कीजिए, या पहले अगर कोई चिंता हो — ब्लीडिंग, हलचल कम, या पानी टूट जाए।');

  /// mm:ss stopwatch text.
  String formatStopwatch(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  /// Warm, dynamic line under the progress bar - shifts with how far along.
  String journeyEmotional(int week, int percent) {
    if (percent >= 90) {
      return _p('Almost there - your little one is nearly here ❤️',
          'बस थोड़ा और — आपका नन्हा बहुत क़रीब है ❤️');
    }
    if (percent >= 50) {
      return _p('You have already completed over half of your journey ❤️',
          'आप अपना आधा सफ़र पार कर चुकी हैं ❤️');
    }
    if (percent >= 25) {
      return _p('Look how far you have already come ❤️',
          'देखिए आप कितनी दूर आ चुकी हैं ❤️');
    }
    return _p('Your journey has begun - one gentle day at a time ❤️',
        'आपका सफ़र शुरू हो गया — एक-एक प्यारा दिन ❤️');
  }

  String get weeklyJourneyTitle => _p('Weekly Journey', 'साप्ताहिक सफ़र');
  String get weeklyJourneySubtitle => _p(
      "Your week-by-week guide - baby's growth, your body, nutrition, bonding and more.",
      'आपकी हफ़्ते-दर-हफ़्ते गाइड — शिशु की बढ़त, आपका शरीर, पोषण, जुड़ाव और बहुत कुछ।');
  String get openWeeklyJourney => _p('Open Weekly Journey', 'साप्ताहिक सफ़र खोलें');
  String get comingSoon => _p('Coming soon', 'जल्द आ रहा है');
  String comingSoonBody(String tab) => _p(
      '$tab is on its way. For now, enjoy your daily moment and weekly journey.',
      '$tab जल्द आ रहा है। अभी के लिए, अपने रोज़ के पल और साप्ताहिक सफ़र का आनंद लीजिए।');

  // ===========================================================================
  //  FATHER MODE - Daily Moment
  // ===========================================================================

  /// Wordmark shown in the Father Mode header (kept as a brand label).
  String get fatherWordmark => 'Fatherhood';

  String fatherGreeting(int hour, String name) => '${greeting(hour, name)} ❤️';

  String fatherDayLine(int week, int day) =>
      _p('Week $week • Day $day', 'हफ़्ता $week • दिन $day');

  // ---- Today's Moment card -------------------------------------------------
  String get fatherMomentMinutes => _p('~3 min', '~3 मिनट');
  String get startMoment => _p('Start Moment', 'शुरू करें');

  // ---- Today | This Week toggle + Weekly Journey ---------------------------
  String get fatherTabToday => _p('Today', 'आज');
  String get fatherTabThisWeek => _p('This Week', 'इस हफ़्ते');
  String get fatherWeeklyIntro => _p(
      "This week, through a father's eyes.",
      'इस हफ़्ते, एक पिता की नज़र से।');
  String get fatherSecInsight => _p('Father Insight', 'पिता की सोच');
  String get fatherSecSupport =>
      _p('Supporting Your Partner', 'अपनी साथी का साथ');
  String get fatherSecConnect =>
      _p('Connecting With Your Baby', 'शिशु से जुड़ाव');
  String get fatherSecMission => _p("This Week's Mission", 'इस हफ़्ते का काम');

  // ---- Can I? (Explore tab) ------------------------------------------------
  String get canITitle => _p('Can I?', 'Can I?');
  String get canISubtitle => _p(
      'Quick, trustworthy answers to everyday pregnancy questions.',
      'गर्भावस्था के रोज़मर्रा सवालों के तुरंत, भरोसेमंद जवाब।');
  String get canISearchHint => _p(
      'Search food, drinks, medicines or activities',
      'खाना, पेय, दवा या गतिविधियाँ खोजें');
  String get canIPopularTitle => _p('Popular searches', 'लोकप्रिय खोज');
  String get canIBrowseTitle => _p('Browse by category', 'श्रेणी से देखें');
  String get canICatEat => _p('Can I eat?', 'क्या मैं खा सकती हूँ?');
  String get canICatDrink => _p('Can I drink?', 'क्या मैं पी सकती हूँ?');
  String get canICatTake => _p('Can I take?', 'क्या मैं ले सकती हूँ?');
  String get canICatDo => _p('Can I do?', 'क्या मैं कर सकती हूँ?');
  String canIDuringPregnancy(String name) =>
      _p('$name during pregnancy', 'गर्भावस्था में: $name');
  String get canIWhy => _p('Why?', 'क्यों?');
  String get canITrimesterNotes => _p('Trimester notes', 'तिमाही के नोट');
  String canITrimesterLabel(int i) => _p(
      const ['First trimester', 'Second trimester', 'Third trimester']
          [i.clamp(0, 2)],
      const ['पहली तिमाही', 'दूसरी तिमाही', 'तीसरी तिमाही'][i.clamp(0, 2)]);
  String get canINowBadge => _p("You're here", 'आप यहाँ');
  String get canIIndianContext =>
      _p('In the Indian context', 'भारतीय संदर्भ में');
  String get canIRelated => _p('Related questions', 'मिलते-जुलते सवाल');
  String get canIAskTitle =>
      _p('Still have a question?', 'अभी भी कोई सवाल है?');
  String get canIAskBody => _p('Ask Veda for guidance made for you.',
      'अपने लिए बनाए मार्गदर्शन के लिए Ask Veda।');
  String get canIAskCta => _p('Ask Veda', 'Ask Veda');
  String get canIAskComingSoon => _p(
      'Ask Veda is coming soon - your personal AI guide.',
      'Ask Veda जल्द आ रहा है — आपका अपना AI गाइड।');
  String get canISave => _p('Save', 'सेव');
  String get canISavedBadge => _p('Saved', 'सेव किया');
  String get canISavedTitle => _p('Saved questions', 'सेव किए सवाल');
  String get canISavedEmpty => _p(
      'Nothing saved yet. Tap the bookmark on any answer to keep it here.',
      'अभी कुछ सेव नहीं हुआ। किसी भी जवाब पर बुकमार्क दबाकर यहाँ रखिए।');
  String get canIDisclaimer => _p(
      "General guidance, not a substitute for your doctor's advice.",
      'यह सामान्य मार्गदर्शन है, आपके डॉक्टर की सलाह का विकल्प नहीं।');
  String get canINoResults => _p('No match yet. Try another word - or ask Veda.',
      'अभी कोई नतीजा नहीं। दूसरा शब्द आज़माइए — या वेदा से पूछिए।');
  String canIVerdictLabel(String key) {
    switch (key) {
      case 'safe':
        return _p('Safe', 'सुरक्षित');
      case 'moderation':
        return _p('Safe in moderation', 'सीमित मात्रा में सुरक्षित');
      case 'depends':
        return _p('It depends', 'यह निर्भर करता है');
      case 'avoid':
        return _p('Best avoided', 'बेहतर है न करें');
      case 'askDoctor':
        return _p('Ask your doctor', 'अपने डॉक्टर से पूछें');
      default:
        return '';
    }
  }

  // ---- Understanding Your Report (Tools) -----------------------------------
  String get rTitle => _p('Understanding Your Report', 'अपनी रिपोर्ट समझें');
  String get rSubtitle => _p(
      'Simple explanations for common pregnancy findings and conditions.',
      'आम गर्भावस्था नतीजों और स्थितियों की सरल व्याख्या।');
  String get rSearchHint => _p(
      'Search a report finding or condition', 'कोई नतीजा या स्थिति खोजें');
  String get rPopularTitle => _p('Popular topics', 'लोकप्रिय विषय');
  String get rAllTopics => _p('All topics', 'सभी विषय');
  String get rSecMeans => _p('What does this mean?', 'इसका मतलब क्या है?');
  String get rSecCommon => _p('How common is it?', 'यह कितना आम है?');
  String get rSecNext =>
      _p('What usually happens next?', 'आगे आम तौर पर क्या होता है?');
  String get rSecWhen =>
      _p('When is it usually discussed?', 'यह आम तौर पर कब देखा जाता है?');
  String get rTypicallyAround =>
      _p('Typically identified around', 'आम तौर पर पता चलता है');
  String rWeekRange(int? from, int? to) {
    if (from != null && to != null) return _p('Week $from–$to', 'हफ़्ता $from–$to');
    if (from != null) return _p('From Week $from', 'हफ़्ता $from से');
    if (to != null) return _p('Up to Week $to', 'हफ़्ता $to तक');
    return '';
  }

  String get rSecQuestions => _p(
      'Questions you may want to ask your doctor',
      'सवाल जो आप अपने डॉक्टर से पूछ सकती हैं');
  String get rSecRemember => _p('Things to remember', 'याद रखने की बातें');
  String get rReassurance => _p(
      'Every pregnancy is unique. Your healthcare provider understands your specific situation and will guide you on the right path for you and your baby.',
      'हर गर्भावस्था अलग होती है। आपके डॉक्टर आपकी स्थिति समझते हैं और आपको व आपके शिशु के लिए सही राह दिखाएँगे।');
  String get rAskTitle => _p('Still worried?', 'अभी भी चिंता हो रही है?');
  String get rAskBody => _p('Need help understanding your situation? Ask Veda.',
      'अपनी स्थिति समझने में मदद चाहिए? Ask Veda।');
  String get rAskCta => _p('Ask Veda', 'Ask Veda');
  String get rAskComingSoon => _p(
      'Ask Veda is coming soon - your personal AI guide.',
      'Ask Veda जल्द आ रहा है — आपका अपना AI गाइड।');

  // ---- Garbh Sanskar Journey (Tools) ---------------------------------------
  String get gsTitle => _p('Garbh Sanskar Journey', 'गर्भ संस्कार सफ़र');
  String get gsSubtitle => _p(
      'A space for calm, connection and reflection during pregnancy.',
      'गर्भावस्था में शांति, जुड़ाव और सोच के लिए एक जगह।');
  String get gsContinue => _p('Continue your practice', 'अपना अभ्यास जारी रखें');
  String get gsContinueCta => _p('Continue', 'जारी रखें');
  String get gsWhatToday => _p('What would you like today?', 'आज आप क्या करना चाहेंगी?');
  String get gsShravan => _p('Shravan', 'श्रवण');
  String get gsShravanTag => _p('Sacred Listening', 'पवित्र श्रवण');
  String get gsSamvad => _p('Samvad', 'संवाद');
  // Vichara folded into Samvad — the daily/home ritual now reads "Samvad & Vichara".
  String get gsSamvadVichara => _p('Samvad & Vichara', 'संवाद और विचार');
  String get gsSamvadTag => _p('Womb Connection', 'गर्भ से जुड़ाव');
  // Short "what/why/daily" intro shown above the Today's Rituals list on Home.
  String get gsHomeIntro => _p(
      'Garbh Sanskar is the age-old practice of nurturing your baby in the womb — through sound, thought, connection and gentle movement. A few mindful minutes each day calm you and help your baby feel loved from the very start.',
      'गर्भ संस्कार आपके गर्भ में पल रहे शिशु को ध्वनि, विचार, जुड़ाव और हल्की हलचल से पोषित करने की प्राचीन परंपरा है। रोज़ाना कुछ शांत मिनट आपको सुकून देते हैं और शिशु को शुरुआत से ही प्यार महसूस कराते हैं।');
  String get gsVichara => _p('Vichara', 'विचार');
  String get gsVicharaTag => _p('Positive Contemplation', 'सकारात्मक विचार');
  String get gsKriya => _p('Kriya', 'क्रिया');
  String get gsKriyaTag => _p('Breath & Grounding', 'साँस और स्थिरता');
  // Tools Garbh Sanskar = a calm LIBRARY (no "today" framing). Intro + tiles.
  String get gsAboutBody => _p(
      'Garbh Sanskar is the gentle, age-old practice of nurturing your bond and your baby\'s growth through sound, positive thoughts, loving connection and mindful movement during pregnancy.',
      'गर्भ संस्कार गर्भावस्था के दौरान ध्वनि, सकारात्मक विचारों, प्यार भरे जुड़ाव और सजग हलचल से आपके रिश्ते और शिशु के विकास को पोषित करने की सौम्य, प्राचीन परंपरा है।');
  String get gsAboutMeaning => _p(
      'A calm space to explore - pick whatever feels right for you today.',
      'एक शांत जगह — आज जो आपको ठीक लगे वह चुनिए।');
  String get gsShravanDesc => _p(
      'Calming ragas, tones and sounds for you and your baby.',
      'आपके और शिशु के लिए शांत राग, सुर और ध्वनियाँ।');
  String get gsVicharaDesc => _p(
      'Sacred insights, gentle brain games and uplifting reads.',
      'पवित्र विचार, हल्के दिमाग़ी खेल और मन उठाने वाले पाठ।');
  String get gsSamvadDesc => _p(
      'Speaking cards to read aloud - your voice, for your baby.',
      'पढ़कर सुनाने के कार्ड — आपकी आवाज़, आपके शिशु के लिए।');
  String get gsKriyaDesc => _p(
      'Gentle, safe prenatal movement and breathing practices.',
      'सौम्य, सुरक्षित prenatal हलचल और साँस के अभ्यास।');
  String get gsBrowseAll =>
      _p('Browse the full collection.', 'पूरा संग्रह देखें।');
  String get gsSamvadAffirm => _p('Affirmations', 'संकल्प');
  String get gsSamvadScripts =>
      _p('Read-aloud stories', 'पढ़कर सुनाने वाली कहानियाँ');
  String get gsSamvadVisualize => _p('Visualizations', 'कल्पना अभ्यास');
  String get gsYourJourney => _p('Your journey', 'आपका सफ़र');
  String get gsStatListening => _p('Listening', 'श्रवण');
  String get gsStatReflections => _p('Reflections', 'विचार');
  String get gsStatConnections => _p('Connections', 'जुड़ाव');
  String get gsStatBreathing => _p('Breathing', 'साँस');
  String get gsFavorites => _p('Favorites', 'पसंदीदा');
  String get gsFavEmpty => _p(
      'Nothing saved yet. Tap the heart on anything you love.',
      'अभी कुछ सेव नहीं हुआ। जो पसंद आए उस पर दिल दबाइए।');
  String get gsPlay => _p('Play', 'चलाएँ');
  String get gsRead => _p('Read', 'पढ़ें');
  String get gsStartPractice => _p('Start practice', 'अभ्यास शुरू करें');
  String get gsTodaysConnection => _p("Today's connection", 'आज का जुड़ाव');
  String get gsAnotherPrompt => _p('Another prompt', 'दूसरा सुझाव');
  String get gsRecordVoice => _p('Record voice', 'आवाज़ रिकॉर्ड करें');
  String get gsWriteMessage => _p('Write message', 'संदेश लिखें');
  String get gsSaveMemory => _p('Save to Memory Vault', 'यादों की तिजोरी में सेव करें');
  String get gsMemorySaved => _p('Memory saved', 'याद सेव हो गई');
  String get gsMemorySavedBody =>
      _p('One day, your child may hear this.', 'एक दिन, आपका बच्चा इसे सुन सकता है।');
  String get gsReflectMoment => _p('A moment to reflect', 'ठहरने का एक पल');
  String gsMinutes(int m) => _p('$m min', '$m मिनट');
  String gsMinRead(int m) => _p('$m minute read', '$m मिनट का पाठ');
  String get gsFinish => _p('Finish', 'समाप्त');
  String get gsWellDone => _p('Well done', 'बहुत अच्छे');
  String get gsWellDoneBody =>
      _p('Carry this calm with you.', 'इस शांति को अपने साथ ले जाइए।');
  String get gsSampleAudio =>
      _p('A calming sample plays here - full audio coming soon.',
          'यहाँ एक शांत नमूना बजता है — पूरा ऑडियो जल्द आएगा।');

  // ---- Garbh Sanskar v2.0 (daily ritual) ----------------------------------
  String get gsAhara => _p('Ahara', 'आहार');
  String get gsAharaTag => _p('Nourishment', 'पोषण');
  String gsDayOfWeek(int day, int week) =>
      _p('Day $day of Week $week', 'हफ़्ता $week का दिन $day');
  String get gsBabySize => _p('Baby size', 'शिशु का आकार');
  String get gsTodaysProgress => _p("Today's progress", 'आज की प्रगति');
  String gsRitualsDone(int done, int goal) =>
      _p('$done / $goal rituals completed', '$done / $goal आदतें पूरी');
  String gsDayStreak(int n) => _p('$n day streak', '$n दिन लगातार');
  String get gsTodaysRituals => _p("Today's Rituals", 'आज की आदतें');
  String get gsTodaysGarbhSanskar =>
      _p("Today's Garbh Sanskar", 'आज का गर्भ संस्कार');
  String get gsVicharaTodo => _p('A reflection, a puzzle, or an uplifting read',
      'एक विचार, एक पहेली, या एक प्रेरणादायी पाठ');
  String gsDailyGoalLine(int goal) =>
      _p('Goal: $goal / $goal each day', 'लक्ष्य: रोज़ $goal / $goal');
  String get gsAllDone =>
      _p('All 5 rituals complete - beautiful 💛', 'सारी 5 आदतें पूरी — बहुत सुंदर 💛');
  String get gsWhatToDo => _p('What to do', 'क्या करना है');
  String get gsWhyMatters => _p('Why it matters', 'यह क्यों ज़रूरी है');
  String get gsStart => _p('Start', 'शुरू करें');
  String get gsMarkDone => _p('Mark complete', 'पूरा हुआ');
  String get gsCompletedToday => _p('Completed today', 'आज पूरा हुआ');
  String get gsTodaysSession => _p("Today's listening session", 'आज का श्रवण सेशन');
  String get gsWhyToday =>
      _p('Why this is recommended today', 'यह आज क्यों सुझाया गया');
  String get gsTabSacred => _p('Sacred Insights', 'पवित्र विचार');
  String get gsTabBrain => _p('Brain Fitness', 'दिमाग़ी कसरत');
  String get gsTabUplifting => _p('Uplifting Vibrations', 'मन उठाने वाली ध्वनियाँ');
  String get gsSamvadTabAffirm =>
      _p('Affirmations & Blessings', 'संकल्प और आशीर्वाद');
  String get gsSamvadTabStories => _p('Stories & Fables', 'कहानियाँ और नीति-कथाएँ');
  String get gsSamvadTabMantras => _p('Mantras & Lullabies', 'मंत्र और लोरियाँ');
  String get gsSamvadTabSpiritual =>
      _p('Spiritual Reading', 'आध्यात्मिक पाठ');
  String get gsMeaning => _p('What it means', 'इसका मतलब');
  String get gsLesson => _p('Life lesson', 'जीवन का सबक़');
  String get gsReadAloud => _p('Read aloud', 'पढ़कर सुनाएँ');
  String get gsTodaysPractice => _p("Today's practice", 'आज का अभ्यास');
  String get gsSafetyNotes => _p('Safety notes', 'सुरक्षा नोट');
  String get gsTodaysNutrition => _p("Today's nutrition", 'आज का पोषण');
  String get gsRecipe => _p('Recommended recipe', 'सुझाई गई रेसिपी');
  String get gsFoodSwap => _p('Food swap', 'खाने का विकल्प');
  String get gsLifestyleHabit => _p('Lifestyle habit', 'जीवनशैली की आदत');
  String get gsLearnMore => _p('Learn more', 'और जानें');
  String get gsLearnMoreSoon =>
      _p('Ask Veda is coming soon - your personal AI guide.',
          'Ask Veda जल्द आ रहा है — आपका अपना AI गाइड।');
  String get gsRelatedDiscussions =>
      _p('Mothers are also discussing', 'माँएँ इस पर बात भी कर रही हैं');
  String get gsPuzzleSoon =>
      _p('This puzzle opens soon - counts as done for today ❤️',
          'यह पहेली जल्द — आज के लिए पूरा माना जाएगा ❤️');
  // Vichara brain games - shared chrome.
  String get gsGameDone =>
      _p('Well done - a calm few minutes 🌿', 'शाबाश — कुछ शांत पल 🌿');
  String get gsPlayAgain => _p('Play again', 'फिर से खेलें');
  String get gsGameClose => _p('Done', 'हो गया');
  String get gsWordSearchHow => _p(
      'Tap the first and last letter of a hidden word.',
      'छुपे शब्द के पहले और आख़िरी अक्षर पर टैप कीजिए।');
  String gsWordsFound(int a, int b) =>
      _p('$a of $b found', '$b में से $a मिले');
  String get gsSudokuHow => _p(
      'Fill 1–4 so every row, column and box has no repeats.',
      'ऐसे भरिए कि हर पंक्ति, स्तंभ और बॉक्स में 1–4 दोहराएँ नहीं।');
  String get gsLogicHow =>
      _p('Pick the answer that fits.', 'सही जवाब चुनिए।');
  String get gsLogicNudge =>
      _p('Not quite - try another 🌸', 'बिलकुल नहीं — दूसरा आज़माइए 🌸');
  String gsLogicProgress(int a, int b) => _p('$a of $b', '$b में से $a');
  String get gsMemoryHow => _p('Flip two cards to find the matching pairs.',
      'दो कार्ड पलटिए और जोड़ी मिलाइए।');

  // ---- Community (Tools) ---------------------------------------------------
  String get cmTitle => _p('Community', 'कम्युनिटी');
  String get cmSearchHint => _p(
      'Search communities, topics or posts', 'कम्युनिटी, विषय या पोस्ट खोजें');
  String get cmJoinedSection => _p('Your communities', 'आपकी कम्युनिटी');
  String get cmRecommended => _p('Recommended for you', 'आपके लिए सुझाव');
  String get cmRecommendedEmpty => _p(
      "You've joined every community 🎉 - they're all up in 'Your communities'.",
      "आपने सारी कम्युनिटी जॉइन कर लीं 🎉 — वे सब 'आपकी कम्युनिटी' में हैं।");
  // Shown when she hasn't joined anything yet. The section still renders, so she
  // learns that joining exists at all (a feature is never hidden for being empty).
  String get cmJoinedEmpty => _p(
      "You haven't joined any communities yet - join one below and its posts arrive in your feed.",
      "आपने अभी तक कोई कम्युनिटी जॉइन नहीं की — नीचे से एक जॉइन कीजिए और उसकी पोस्ट आपके फ़ीड में आएँगी।");
  String get cmPulse => _p('Community Pulse', 'कम्युनिटी की हलचल');
  String get cmFeed => _p('For you', 'आपके लिए');
  String get cmWalkingTogether => _p('Walking together', 'साथ चलते हैं');
  String get cmMyActivity => _p('My Activity', 'मेरी गतिविधि');
  String get cmMyBookmarks => _p('My Bookmarks', 'मेरे बुकमार्क');
  String get cmActPosts => _p('Your posts', 'आपकी पोस्ट');
  String get cmActLiked => _p('Liked', 'पसंद किए');
  String get cmActCommented => _p('Commented', 'कमेंट किए');
  String get cmActUpvoted => _p('Endorsed', 'समर्थन किए');
  String get cmActEmpty => _p(
      'Your posts, likes and comments will appear here.',
      'आपकी पोस्ट, पसंद और कमेंट यहाँ दिखेंगे।');
  String get cmBookmarksEmpty => _p(
      'Posts you bookmark will be saved here.',
      'जो पोस्ट आप बुकमार्क करेंगी वे यहाँ सेव होंगी।');
  String get cmJoin => _p('Join', 'जॉइन करें');
  String get cmJoinedBadge => _p('Joined', 'जॉइन किया');
  String get cmLeave => _p('Leave community', 'कम्युनिटी छोड़ें');
  String get cmMute => _p('Mute community', 'कम्युनिटी म्यूट करें');
  String get cmUnmute => _p('Unmute community', 'अनम्यूट करें');
  // Twitter-style post card + ⋯ menu + profiles.
  String get cmInCommunity => _p('in', 'में');
  String get cmReposted => _p('Reposted ✓', 'रीपोस्ट हो गया ✓');
  String get cmRepostUndone => _p('Repost removed', 'रीपोस्ट हटा दिया');
  String get cmShared => _p('Sharing… (preview)', 'शेयर हो रहा है… (प्रीव्यू)');
  String get cmFollow => _p('Follow', 'फ़ॉलो');
  String get cmUnfollow => _p('Unfollow', 'अनफ़ॉलो');
  String get cmFollowingState => _p('Following', 'फ़ॉलोइंग');
  String get cmFollowedToast =>
      _p('Following - their posts show in Following',
          'फ़ॉलो किया — उनकी पोस्ट फ़ॉलोइंग में दिखेंगी');
  String get cmUnfollowedToast => _p('Unfollowed', 'अनफ़ॉलो किया');
  String get cmNotInterested => _p('Not interested', 'रुचि नहीं');
  String get cmNotInterestedDone =>
      _p("Got it - we'll show fewer like this",
          'ठीक है — ऐसी पोस्ट कम दिखाएँगे');
  String get cmMuteUser => _p('Mute', 'म्यूट');
  String get cmMutedToast => _p('Muted', 'म्यूट किया');
  String get cmBlock => _p('Block', 'ब्लॉक');
  String get cmBlockedToast => _p('Blocked', 'ब्लॉक किया');
  String get cmReport => _p('Report post', 'पोस्ट रिपोर्ट करें');
  String get cmReportedToast =>
      _p('Reported - thank you', 'रिपोर्ट किया — शुक्रिया');
  String get cmYourFeed => _p('Your feed', 'आपका फ़ीड');
  String get cmFollowingEmpty =>
      _p('Your Following feed is empty', 'आपका फ़ॉलोइंग फ़ीड अभी ख़ाली है');
  String get cmFollowingEmptySub => _p(
      'Join communities or follow experts to see their posts here.',
      'कम्युनिटी जॉइन कीजिए या विशेषज्ञों को फ़ॉलो कीजिए — उनकी पोस्ट यहाँ दिखेंगी।');
  String get cmExpertBio => _p(
      'Verified expert on ParentVeda. Here to support mothers through pregnancy, birth and the early days with gentle, evidence-based guidance. 💜',
      'ParentVeda पर सत्यापित विशेषज्ञ। गर्भावस्था, जन्म और शुरुआती दिनों में माँओं का साथ देने के लिए — सौम्य, प्रमाण-आधारित मार्गदर्शन के साथ। 💜');
  String get cmMember => _p('Member', 'सदस्य');
  String get cmPostsCount => _p('Posts', 'पोस्ट');
  String get cmFollowers => _p('Followers', 'फ़ॉलोअर');
  String get cmFollowingCount => _p('Following', 'फ़ॉलोइंग');
  String get cmNoPostsYet => _p('No posts yet', 'अभी कोई पोस्ट नहीं');
  // Profile Videos tab + Experts-only feed filter + hashtag feed.
  String get cmVideos => _p('Videos', 'वीडियो');
  String get cmNoVideosYet => _p('No videos yet', 'अभी कोई वीडियो नहीं');
  String get cmExpertsOnly => _p('Experts only', 'सिर्फ़ विशेषज्ञ');
  String cmHashtagEmpty(String tag) => _p(
      'No posts with #$tag yet', 'अभी #$tag वाली कोई पोस्ट नहीं');
  String cmMembers(int n) => _p('$n members', '$n सदस्य');
  String get cmCreatePost => _p('Create post', 'पोस्ट बनाएँ');
  String get cmVote => _p('Vote', 'वोट');
  String get cmVoted => _p('Thanks for voting', 'वोट के लिए शुक्रिया');
  String get cmViewDiscussion => _p('View discussion', 'चर्चा देखें');
  String get cmComments => _p('Comments', 'कमेंट');
  String get cmEmptyComments =>
      _p('Be the first to comment.', 'सबसे पहले कमेंट कीजिए।');
  String get cmAddComment => _p('Add a comment…', 'कमेंट लिखिए…');
  String get cmRelated => _p('Related discussions', 'मिलती-जुलती चर्चाएँ');
  String get cmSuggested => _p('Suggested communities', 'सुझाई गई कम्युनिटी');
  String get cmAbout => _p('About', 'इसके बारे में');
  String get cmPosts => _p('Posts', 'पोस्ट');
  String get cmPostTo => _p('Post to', 'यहाँ पोस्ट करें');
  String get cmTypeLabel => _p('Type', 'प्रकार');
  String get cmSuggestedTags =>
      _p('Auto-detected topics', 'अपने आप पहचाने गए विषय');

  // ---- Products ❤️ (Tools) -------------------------------------------------
  // ---- Product Checklist (tool) --------------------------------------------
  String get pclTitle => _p('Product Checklist', 'प्रोडक्ट चेकलिस्ट');
  String get pclIntro => _p(
      'Build your own checklists from our products - add what you want, note when you need it, and tick things off as you get them.',
      'हमारे प्रोडक्ट से अपनी ख़ुद की चेकलिस्ट बनाइए — जो चाहिए जोड़िए, कब चाहिए लिखिए, और मिलते ही टिक कर दीजिए।');
  String get pclYourLists => _p('Your checklists', 'आपकी चेकलिस्ट');
  String get pclNewChecklist => _p('New checklist', 'नई चेकलिस्ट');
  String get pclNamePrompt =>
      _p('Name your checklist', 'अपनी चेकलिस्ट को नाम दीजिए');
  String get pclRename => _p('Rename', 'नाम बदलें');
  String get pclDelete => _p('Delete', 'हटाएँ');
  String get pclDeleteConfirm =>
      _p('Delete this checklist?', 'यह चेकलिस्ट हटाएँ?');
  String get pclDeleted => _p('Checklist deleted', 'चेकलिस्ट हट गई');
  String get pclCurated => _p('Curated starters', 'चुनी हुई शुरुआती सूचियाँ');
  String get pclCuratedSub => _p('Ready-made lists you can make your own.',
      'बनी-बनाई सूचियाँ, जिन्हें आप अपना बना सकती हैं।');
  String get pclAdopt =>
      _p('Add to my checklists', 'मेरी चेकलिस्ट में जोड़ें');
  String get pclAddProducts => _p('Add products', 'प्रोडक्ट जोड़ें');
  String get pclAdd => _p('Add', 'जोड़ें');
  String get pclAdded => _p('Added', 'जुड़ गया');
  String pclAddedTo(String name) =>
      _p('Added to $name', '$name में जुड़ गया');
  String get pclAddToChecklist =>
      _p('Add to checklist', 'चेकलिस्ट में जोड़ें');
  String pclGotChip(int got, int total) => _p('$got/$total', '$got/$total');
  String pclGotOf(int got, int total) =>
      _p('$got of $total ticked', '$total में से $got टिक हुए');
  String get pclSaveList => _p('Save list', 'सूची सेव करें');
  String get pclSavedSnack => _p('Checklist saved ✓', 'चेकलिस्ट सेव हो गई ✓');
  String get pclAddRemaining =>
      _p('Add remaining to cart', 'बाक़ी कार्ट में डालें');
  String get pclGotPromptTitle => _p('Already got this?', 'यह मिल गया?');
  String get pclGotPromptBody => _p(
      "Mark it as something you already have - it won't be added to your cart.",
      'इसे अपने पास मौजूद मान लीजिए — यह कार्ट में नहीं जाएगा।');
  String get pclGotPromptYes => _p('Yes, got it', 'हाँ, मिल गया');
  String get pclGotPromptNo => _p('Not yet', 'अभी नहीं');
  String get pclAffiliate => _p('Affiliate', 'Affiliate');
  String get pclCustomTag => _p('Yours', 'आपका');
  String get pclBoughtTag => _p('Bought ✓', 'ले लिया ✓');
  String get pclOpenLink => _p('Open link', 'लिंक खोलें');
  String get pclAddOwn => _p('Add your own product', 'अपना प्रोडक्ट जोड़ें');
  String get pclCustomName => _p('Product name', 'प्रोडक्ट का नाम');
  String get pclCustomLink => _p('Link (optional)', 'लिंक (ज़रूरी नहीं)');
  String get pclCustomPrice => _p('Price (optional)', 'दाम (ज़रूरी नहीं)');
  String get pclCustomNote =>
      _p('When / note (optional)', 'कब / नोट (ज़रूरी नहीं)');
  String pclCustomAdded(String name) =>
      _p('Added "$name" to your list', '"$name" सूची में जुड़ गया');
  String pclItemsCount(int n) => _p('$n items', '$n चीज़ें');
  String pclListSummary(int total, int got) => total == 0
      ? _p('No products yet', 'अभी कोई प्रोडक्ट नहीं')
      : _p('$total items · $got/$total got', '$total चीज़ें · $got/$total मिलीं');
  String get pclNotePrompt =>
      _p('When do you need it?', 'यह कब चाहिए?');
  String get pclAddWhen => _p('Add when', 'कब चाहिए, लिखिए');
  String get pclEditNote => _p('Edit note', 'नोट बदलें');
  String get pclRemove => _p('Remove', 'हटाएँ');
  String get pclEmpty => _p(
      'No checklists yet. Create one and add the products you love.',
      'अभी कोई चेकलिस्ट नहीं। एक बनाइए और अपने पसंद के प्रोडक्ट जोड़िए।');
  String get pclEmptyItems => _p(
      'No products yet. Add some from our catalogue.',
      'अभी कोई प्रोडक्ट नहीं। हमारे कैटलॉग से कुछ जोड़िए।');
  String get pclSearchHint => _p('Search products', 'प्रोडक्ट खोजें');
  String get pclNoResults => _p('No products found', 'कोई प्रोडक्ट नहीं मिला');
  String get pclSave => _p('Save', 'सेव');
  String get pclCancel => _p('Cancel', 'रहने दें');

  // ---- Shopping cart (preview, no real payment) ----------------------------
  String get cartProductsTitle => _p('Cart', 'कार्ट');
  String get cartHospitalTitle =>
      _p('Hospital Bag Cart', 'अस्पताल बैग कार्ट');
  String get cartAddToCart => _p('Add to cart', 'कार्ट में जोड़ें');
  String get cartAddAllToCart =>
      _p('Add all to cart', 'सब कार्ट में जोड़ें');
  String get cartBuyNow => _p('Buy now', 'अभी ख़रीदें');
  String get cartCheckout => _p('Checkout', 'चेकआउट');
  String get cartPlaceOrder => _p('Place order', 'ऑर्डर करें');
  String get cartSubtotal => _p('Subtotal', 'उप-योग');
  String get cartDelivery => _p('Delivery', 'डिलीवरी');
  String get cartFree => _p('Free', 'मुफ़्त');
  String get cartTotal => _p('Total', 'कुल');
  String get cartEach => _p('each', 'प्रति');
  String cartItems(int n) => _p('$n item${n == 1 ? '' : 's'}',
      '$n चीज़${n == 1 ? '' : 'ें'}');
  String get cartSize => _p('Size', 'साइज़');
  String get cartColor => _p('Colour', 'रंग');
  String get cartChooseSize => _p('Choose a size', 'साइज़ चुनिए');
  String get cartEmpty => _p('Your cart is empty', 'आपका कार्ट ख़ाली है');
  String get cartEmptyHint => _p(
      'Add products and they will show up here.',
      'प्रोडक्ट जोड़िए, वे यहाँ दिखेंगे।');
  String get cartAddedToCart => _p('Added to cart', 'कार्ट में जुड़ गया');
  String cartAddedN(int n) => _p('$n added to cart',
      '$n कार्ट में जुड़ गए');
  String get cartAllInCart =>
      _p('Already in your cart', 'पहले से आपके कार्ट में है');
  String get cartViewCart => _p('View cart', 'कार्ट देखें');
  String get cartOrderSummary => _p('Order summary', 'ऑर्डर का ब्योरा');
  String get cartDeliverTo => _p('Deliver to', 'यहाँ भेजें');
  String get cartDeliverToValue =>
      _p('Home · Add address', 'घर · पता जोड़ें');
  String get cartChange => _p('Change', 'बदलें');
  String get cartPaymentMethod => _p('Payment method', 'भुगतान का तरीक़ा');
  String get cartComingSoonTag => _p('Coming soon', 'जल्द आ रहा है');
  String get cartOrderPlaced => _p('Order placed', 'ऑर्डर हो गया');
  String get cartOrderPlacedSub => _p(
      'This is a preview - no payment was taken. We will let you know the moment checkout goes live. 💜',
      'यह एक प्रीव्यू है — कोई भुगतान नहीं लिया गया। चेकआउट लाइव होते ही आपको बता देंगे। 💜');
  String get cartContinueShopping =>
      _p('Continue shopping', 'ख़रीदारी जारी रखें');

  String get prTitle => _p('Products', 'प्रोडक्ट');
  String get prTabRecommended => _p('Recommended', 'सुझाए गए');
  String get prTabBrowse => _p('Browse all', 'सभी');
  String get prTabSaved => _p('Saved', 'सेव किए');
  String prRecommendedFor(int week) =>
      _p('Recommended for Week $week', 'हफ़्ता $week के लिए सुझाए गए');
  String get prRecommendedSub => _p(
      'Selected because they are most relevant at your current stage.',
      'आपके अभी के चरण के लिए सबसे काम की चीज़ें।');
  String get prGuidance => _p('ParentVeda Guidance', 'ParentVeda का मार्गदर्शन');
  String get prLookFor => _p('Look for', 'यह देखिए');
  String get prAvoid => _p('Avoid', 'इनसे बचें');
  String get prPicks => _p('ParentVeda Picks', 'ParentVeda की पसंद');
  String get prUsefulDuring => _p('Useful during', 'कब काम आता है');
  String get prYouAreHere => _p('You are here', 'आप यहाँ');
  String get prWhenHelps => _p('When this helps', 'यह कब काम आता है');
  String prYouWeek(int week) => _p('You · Wk $week', 'आप · हफ़्ता $week');
  String get prRelevantNow => _p('Useful for you now', 'अभी आपके लिए काम का');
  String prComingUp(int week) =>
      _p('Useful from around Week $week', 'लगभग हफ़्ता $week से काम का');
  String prHelpsSentence(int from, String toLabel) {
    final en = toLabel == 'Postpartum' ? 'after birth' : 'birth';
    final hi = toLabel == 'Postpartum' ? 'जन्म के बाद तक' : 'जन्म तक';
    return _p('Recommended from Week $from through $en.',
        'हफ़्ता $from से $hi सुझाया गया।');
  }
  String get prScore => _p('ParentVeda Score', 'ParentVeda स्कोर');
  String get prBestFor => _p('Best for', 'किसके लिए बेहतर');
  String get prWhy => _p('Why ParentVeda recommends this',
      'ParentVeda यह क्यों सुझाता है');
  String get prConsider => _p('Things to consider', 'ध्यान रखने की बातें');
  String get prBuyNow => _p('Buy now', 'अभी ख़रीदें');
  String get prCompare => _p('Compare', 'तुलना करें');
  String prBrowseAllCount(int n) => _p('Browse all $n', 'सभी $n देखें');
  String get prVerdict => _p('ParentVeda Verdict', 'ParentVeda का फ़ैसला');

  // ---- SHARED PRODUCT TEMPLATE ---------------------------------------------
  // The parenting product page and this one used different section names for
  // the same things, which is what the review meant by the template differing
  // "across pregnancy and parenting". These are the shared vocabulary; the
  // parenting side already uses the English of each.
  //
  // prVerdict above is kept: it is what the old "ParentVeda Verdict" heading
  // used, and leaving it means the rename is one line to undo.
  String get prAtAGlance => _p('At a glance', 'एक नज़र में');
  String get prWhatsInside =>
      _p("What's inside & how it works", 'इसमें क्या है और कैसे काम करता है');
  String get prPvTake => _p("ParentVeda's take", 'ParentVeda की राय');
  String get prVerifiedParents =>
      _p('From verified parents', 'सत्यापित माता-पिता से');
  String get prCompareAlternatives =>
      _p('Compare with alternatives', 'दूसरे विकल्पों से तुलना करें');
  String get prHowWeReview => _p('How ParentVeda reviews this',
      'ParentVeda इसे कैसे परखता है');
  String get prHowWeReviewSub => _p(
      'Every pick is checked the same way - so a rating means the same thing across the shelf.',
      'हर पसंद एक ही तरह से परखी जाती है — ताकि रेटिंग का मतलब हर जगह एक ही रहे।');
  String get prReviewSummary => _p('What parents say', 'माता-पिता क्या कहते हैं');
  String get prMostLoved => _p('Most loved', 'सबसे पसंद');
  String get prPraise => _p('Most mentioned praise', 'सबसे ज़्यादा तारीफ़');
  String get prDrawback => _p('Most mentioned drawback', 'सबसे ज़्यादा कमी');
  String get prWouldBuyAgain => _p('Would buy again', 'दोबारा ख़रीदेंगे');
  String get prReviews => _p('Real parent reviews', 'असली माता-पिता की राय');
  String get prUsedDuring => _p('Used during', 'कब इस्तेमाल किया');
  String get prLiked => _p('What I liked', 'मुझे क्या पसंद आया');
  String get prWatchOut => _p('Watch out for', 'इसका ध्यान रखें');
  String get prRelated => _p('Related products', 'मिलते-जुलते प्रोडक्ट');
  String get prSavedEmpty => _p(
      'Nothing saved yet. Tap the heart on any product to keep it here.',
      'अभी कुछ सेव नहीं हुआ। किसी भी प्रोडक्ट पर दिल दबाकर यहाँ रखिए।');
  String get prComingSoon =>
      _p('Buying opens soon - saving works now ❤️', 'ख़रीदारी जल्द — सेव करना अभी चलता है ❤️');
  String get prAffiliate => _p('Affiliate', 'Affiliate');
  String get prBuyOnAmazon => _p('Buy on Amazon', 'Amazon पर ख़रीदें');
  String get prAffiliateNote => _p('Sold on Amazon - opens externally.',
      'Amazon पर मिलता है — बाहर खुलता है।');
  String get prSearchHint => _p('Search products', 'प्रोडक्ट खोजें');
  String prBadge(String key) {
    switch (key) {
      case 'bestOverall':
        return _p('Best Overall', 'सबसे बेहतर');
      case 'bestBudget':
        return _p('Best Budget', 'कम दाम में बेहतर');
      case 'bestPremium':
        return _p('Best Premium', 'प्रीमियम में बेहतर');
      case 'sensitiveSkin':
        return _p('Best for Sensitive Skin', 'नाज़ुक त्वचा के लिए');
      case 'newborns':
        return _p('Best for Newborns', 'नवजात के लिए');
      default:
        return '';
    }
  }
  String get cmShareSomething =>
      _p('What would you like to share?', 'आप क्या साझा करना चाहेंगी?');
  String get cmShare => _p('Share', 'साझा करें');
  String get cmPosted => _p('Posted to your community ❤️', 'आपकी कम्युनिटी में पोस्ट हो गया ❤️');
  String get cmPostAsDoctor => _p('Post as doctor', 'डॉक्टर बनकर पोस्ट करें');
  String get cmPostedAsDoctor => _p('Posted as a verified doctor 🩺', 'सत्यापित डॉक्टर के रूप में पोस्ट हो गया 🩺');
  String get cmPostingAsDoctor => _p('Posting as a verified doctor', 'सत्यापित डॉक्टर के रूप में पोस्ट');
  String get cmExpertBadge => _p('Expert', 'विशेषज्ञ');
  String get cmComingSoon => _p('Coming soon', 'जल्द आ रहा है');
  String get cmRemindMe => _p('Remind me', 'याद दिलाएँ');
  // ---- Community Pro: trust-building expert endorsement layer ---------------
  String get cmSubtitle => _p(
      'A circle of mothers, walking the same path as you.',
      'माँओं का एक घेरा, जो आपके साथ उसी राह पर चल रही हैं।');
  String get cmFollowing => _p('Following', 'फ़ॉलो किए');
  String cmNew(int n) => _p('$n new', '$n नए');
  String get cmEndorsed => _p('Verified expert backs this experience',
      'सत्यापित विशेषज्ञ इस अनुभव का समर्थन करते हैं');
  String get cmExpertLiked => _p('Liked', 'पसंद');
  String get cmVerifiedExpert => _p('Verified expert', 'सत्यापित विशेषज्ञ');
  // Expert-endorsement credibility count + "who verified" sheet.
  String cmPlusExperts(int n) =>
      _p('+$n other experts', '+$n और विशेषज्ञ');
  String get cmExpertsWhoVerified =>
      _p('Verified by these experts', 'इन विशेषज्ञों ने सत्यापित किया');
  String cmAndMoreExperts(int n) =>
      _p('…and $n more verified experts', '…और $n सत्यापित विशेषज्ञ');
  // Doctor (test) mode + endorse flow.
  String get cmDoctorMode => _p('Doctor mode', 'डॉक्टर मोड');
  String get cmDoctorBanner => _p(
      "You're viewing as a verified doctor · test mode",
      'आप एक सत्यापित डॉक्टर के रूप में देख रहे हैं · टेस्ट मोड');
  String get cmDoctorOn =>
      _p('Doctor mode on - test', 'डॉक्टर मोड चालू — टेस्ट');
  String get cmDoctorOff => _p('Doctor mode off', 'डॉक्टर मोड बंद');
  String get cmEndorseThis => _p('Verify this', 'सत्यापित करें');
  String get cmYouVerified => _p('You verified this', 'आपने सत्यापित किया');
  String get cmExit => _p('Exit', 'बाहर');
  // Subtle "verified by an expert" hint (replaces the old full-width banner).
  String cmVerifiedBy(String name) =>
      _p('Verified by $name', '$name ने सत्यापित किया');
  String cmVerifiedByPlus(String name, int n) => _p(
      'Verified by $name +$n experts', '$name +$n विशेषज्ञों ने सत्यापित किया');
  // Request-an-expert-to-verify flow (composer toggle, pending tag, expert filter).
  String get cmAskVerifyTitle =>
      _p('Ask an expert to verify this', 'विशेषज्ञ से सत्यापित करने को कहें');
  String get cmAskVerifySub => _p(
      'A verified expert can review and confirm your post.',
      'एक सत्यापित विशेषज्ञ आपकी पोस्ट देखकर पुष्टि कर सकते हैं।');
  String get cmPendingVerify =>
      _p('Awaiting expert verification', 'विशेषज्ञ के सत्यापन का इंतज़ार');
  String get cmNeedsVerify => _p('Needs verification', 'सत्यापन चाहिए');
  String get cmNoVerifyRequests => _p(
      'No posts are waiting for verification right now.',
      'अभी कोई पोस्ट सत्यापन के लिए नहीं है।');
  // Specialty the mother prefers for verification + the new comment-to-verify flow.
  String cmSpecialty(String key) {
    switch (key) {
      case 'gynae':
        return _p('Gynaecologist', 'Gynaecologist');
      case 'pediatric':
        return _p('Pediatrician', 'Pediatrician');
      case 'lactation':
        return _p('Lactation expert', 'Lactation expert');
      case 'nutrition':
        return _p('Nutritionist', 'Nutritionist');
      case 'physio':
        return _p('Physiotherapist', 'Physiotherapist');
      case 'mental':
        return _p('Mental health', 'मानसिक सेहत');
      default:
        return _p('Any doctor', 'कोई भी डॉक्टर');
    }
  }

  String get cmChooseSpecialty =>
      _p('Which expert should we ask?', 'किस विशेषज्ञ से पूछें?');
  String cmAwaitingSpecialty(String specialty) => _p(
      'Awaiting $specialty verification', '$specialty सत्यापन का इंतज़ार');
  String get cmCommentToVerify =>
      _p('Comment to verify this post', 'सत्यापित करने के लिए कमेंट कीजिए');
  String get cmShareVia => _p('via ParentVeda Community', 'ParentVeda कम्युनिटी से');
  // Composer - write & add photos to a community.
  String get cmAddPhotos => _p('Add photos', 'फ़ोटो जोड़ें');
  String get cmCamera => _p('Camera', 'कैमरा');
  String get cmWritePrompt => _p('Share something with this group…',
      'इस समूह के साथ कुछ साझा कीजिए…');
  // Community Pulse cards (Community Pro design).
  String get cmPulse1Tag => _p('YOU ARE NOT ALONE', 'आप अकेली नहीं हैं');
  String get cmPulse1Text => _p('127 mothers are also due in November 2026.',
      '127 माँएँ भी नवंबर 2026 में डिलीवरी की उम्मीद में हैं।');
  String get cmPulse1Foot =>
      _p('+124 mamas online right now', '+124 माँएँ अभी ऑनलाइन');
  String get cmPulse2Tag => _p('TRENDING TODAY', 'आज चर्चा में');
  String get cmPulse2Text => _p('34 mamas are sharing their week-18 wins.',
      '34 माँएँ अपने हफ़्ता-18 की जीत साझा कर रही हैं।');
  String get cmPulse2Foot => _p('#Week18 · updated 2h ago',
      '#Week18 · 2 घंटे पहले अपडेट');
  String get cmPulse3Tag => _p('EXPERT LIVE', 'विशेषज्ञ लाइव');
  String get cmPulse3Text => _p('Dr. Meera is hosting a latch & feeding Q&A.',
      'डॉ. मीरा latch और feeding पर सवाल-जवाब ले रही हैं।');
  String get cmPulse3Foot => _p('Today · 6:00 PM · Tap to set a reminder',
      'आज · 6:00 PM · रिमाइंडर सेट करने के लिए टैप करें');
  String get cmPulse4Tag => _p('A GENTLE REMINDER', 'एक प्यारी याद');
  String get cmPulse4Text => _p('You grew a whole heartbeat this month. 💜',
      'इस महीने आपने एक पूरी धड़कन बढ़ाई। 💜');
  String get cmPulse4Foot => _p('Tap to log how you are feeling today',
      'आज कैसा लग रहा है, दर्ज करने के लिए टैप करें');
  String cmPostType(String key) {
    switch (key) {
      case 'question':
        return _p('Question', 'सवाल');
      case 'experience':
        return _p('Experience', 'अनुभव');
      case 'poll':
        return _p('Poll', 'पोल');
      case 'photo':
        return _p('Photo', 'फ़ोटो');
      case 'milestone':
        return _p('Milestone', 'पड़ाव');
      case 'expert':
        return _p('Expert', 'विशेषज्ञ');
      case 'parentVeda':
        return _p('ParentVeda', 'ParentVeda');
      default:
        return '';
    }
  }

  // ---- Daily Reads (Home - above Read Next) --------------------------------
  String get drTitle => _p("Today's Read", 'आज का पाठ');
  String get drArticles => _p('Articles', 'लेख');
  String get drResearch => _p('Research Summaries', 'शोध का सार');
  String get drBooks => _p('Book Summaries', 'किताबों का सार');
  String get drReadSummary => _p('Read summary', 'सार पढ़ें');
  String get drBuyBook => _p('Buy Book', 'किताब ख़रीदें');
  String get drSeeAll => _p('See all', 'सभी देखें');

  // ---- Read recommendations ❤️ (formerly "Read Next" / "Library") ----------
  String get rnTitle =>
      _p('Read recommendations', 'पढ़ने के सुझाव');
  String get rnSubtitle => _p('Handpicked reading for your stage of pregnancy.',
      'आपकी गर्भावस्था के चरण के लिए चुनी हुई पढ़ाई।');
  String get rnThisWeekPick => _p("This Week's Pick", 'इस हफ़्ते की पसंद');
  String get rnWhyNow => _p('Why this matters now', 'यह अभी क्यों ज़रूरी है');
  String get rnReadNow => _p('Read now', 'अभी पढ़ें');
  String get rnRecommended => _p('Recommended for this week', 'इस हफ़्ते के लिए सुझाए गए');
  String get rnLookingAhead => _p('Looking ahead', 'आगे की तैयारी');
  String rnComingUp(int week) => _p('Coming up around Week $week', 'लगभग हफ़्ता $week के आसपास');
  String get rnBooks => _p('Books we love', 'पसंदीदा किताबें');
  String get rnResearch => _p('Research simplified', 'शोध आसान भाषा में');
  String get rnExperts => _p('Expert recommendations', 'विशेषज्ञ की सलाह');
  String get rnRecommendedBy => _p('Recommended by', 'सुझाया गया');
  String get rnWhyRecommend =>
      _p('Why ParentVeda recommends it', 'ParentVeda इसे क्यों सुझाता है');
  String get rnSavedSection => _p('Saved for later', 'बाद के लिए सेव');
  String get rnSavedEmpty => _p(
      'Nothing saved yet. Tap the heart on anything you want to read later.',
      'अभी कुछ सेव नहीं हुआ। जो बाद में पढ़ना हो उस पर दिल दबाइए।');
  String get rnSaveBadge => _p('Saved', 'सेव किया');
  String get rnMarkReading => _p('Mark as reading', 'पढ़ रहे हैं, लगाएँ');
  String get rnReadingBadge => _p('Reading', 'पढ़ रहे हैं');
  String get rnMarkDone => _p('Mark as completed', 'पूरा हुआ, लगाएँ');
  String get rnCompletedBadge => _p('Completed', 'पूरा हुआ');
  String get rnMoreReading => _p('More reading', 'और पढ़ाई');
  String get rnKnowMore => _p('Know more', 'और जानें');
  String get rnBuyNow => _p('Buy now', 'अभी ख़रीदें');
  String get rnBuyComingSoon =>
      _p('Buying opens soon - saving works now ❤️', 'ख़रीदारी जल्द — सेव करना अभी चलता है ❤️');
  String get rnSearchHint => _p('Search reading', 'पढ़ाई खोजें');
  String get rnNewResearch => _p('New research', 'नया शोध');

  // ---- Learn ---------------------------------------------------------------
  String get learnOpen => _p('Open', 'खोलें');
  String get learnReaderTitle => _p("Today's Lesson", 'आज का सबक़');

  // ---- Mission -------------------------------------------------------------
  String get missionEyebrow => _p("Today's Mission", 'आज का काम');
  String get missionMarkDone => _p('Done', 'हो गया');
  String get missionDoneLabel => _p('Done 💪', 'हो गया 💪');

  // ---- Father completion + check-in ----------------------------------------
  String get fatherCompletionTitle =>
      _p('You showed up today.', 'आज आप हाज़िर थे।');
  String get fatherCompletionSubtitle => _p(
      "That's how fathers are made - one day at a time.",
      'पिता ऐसे ही बनते हैं — एक-एक दिन करके।');
  String get fatherFeelingQuestion => _p(
      'How are you feeling today?', 'आज आप कैसा महसूस कर रहे हैं?');
  String fatherMoodLabel(String id) {
    switch (id) {
      case 'happy':
        return _p('Happy', 'ख़ुश');
      case 'grateful':
        return _p('Grateful', 'शुक्रगुज़ार');
      case 'hopeful':
        return _p('Hopeful', 'उम्मीद से भरा');
      case 'calm':
        return _p('Calm', 'शांत');
      case 'connected':
        return _p('Connected', 'जुड़ा हुआ');
      case 'nervous':
        return _p('Nervous', 'घबराया');
      case 'anxious':
        return _p('Anxious', 'चिंतित');
      case 'tired':
        return _p('Tired', 'थका');
      case 'emotional':
        return _p('Emotional', 'भावुक');
      case 'overwhelmed':
        return _p('Overwhelmed', 'बोझ महसूस');
      default:
        return id;
    }
  }

  // =========================================================================
  //  INLINE UI COPY - lifted out of widgets so it can be translated
  // =========================================================================
  String get uiWorthCheckingDoctor => _p('Worth checking with a doctor', 'डॉक्टर से पूछ लेना बेहतर है');
  String get uiClose => _p('Close', 'बंद करें');
  String get uiMuted => _p('Muted', 'आवाज़ बंद');
  String get uiLeaveCall => _p('Leave call', 'कॉल छोड़ें');
  String get uiReadIngredientList => _p('Read the ingredient list', 'सामग्री की सूची पढ़िए');
  String get uiFragranceFreeBeatsLightly => _p('Fragrance-free beats lightly scented', 'बिना ख़ुशबू वाला, हल्की ख़ुशबू वाले से बेहतर');
  String get uiMakerSOwnStudy => _p('A maker\'s own study is a starting point', 'कंपनी का अपना अध्ययन शुरुआत भर है');
  String get uiUnderstandingBabySkin => _p('Understanding baby skin', 'शिशु की त्वचा को समझना');
  String get uiHowPatchTestAnything => _p('How to patch-test anything', 'किसी भी चीज़ को थोड़ा लगाकर कैसे जाँचें');
  String get uiTimingYoursChoose => _p('Timing is yours to choose', 'समय आप चुनिए');
  String get uiCheckFolateDose => _p('Check the folate dose', 'Folate की मात्रा जाँचिए');
  String get uiWhyFolateWhyNow => _p('Why folate, why now', 'Folate क्यों, और अभी क्यों');
  String get uiOneHandedWholeTest => _p('One-handed is the whole test', 'एक हाथ से चल जाए — बस यही परख है');
  String get uiPrettyOnesStayDrawer => _p('Pretty ones stay in the drawer', 'सुंदर वाले दराज़ में ही पड़े रह जाते हैं');
  String get uiSurvivingNightFeeds => _p('Surviving night feeds', 'रात की फ़ीड से पार पाना');
  String get uiTrySizeUpFirst => _p('Try a size up first', 'पहले एक साइज़ बड़ा आज़माइए');
  String get uiReadingNappyRash => _p('Reading a nappy rash', 'नैपी रैश को पढ़ना');
  String get uiSponsored => _p('SPONSORED', 'प्रायोजित');
  String get uiBrandStudio => _p('Brand Studio', 'Brand Studio');
  String get uiEngineWhoseJobShow => _p('An engine whose job is to show almost nothing. This page is the only way to see it working.', 'एक इंजन जिसका काम है लगभग कुछ न दिखाना। यह पन्ना ही उसे काम करते देखने का एकमात्र तरीक़ा है।');
  String get uiCampaigns => _p('CAMPAIGNS', 'कैंपेन');
  String get uiTapSlotNameLearn => _p('Tap a slot name to learn what it is. A blocked campaign says exactly why.', 'किसी स्लॉट का नाम दबाइए और जानिए वह क्या है। रुका हुआ कैंपेन साफ़ बताता है कि क्यों।');
  String get uiFlagged => _p('FLAGGED FOR YOU', 'आपके लिए चिह्नित');
  String get uiThingsGotBuiltDespite => _p('Things that got built despite a real argument against them. Each one is a decision waiting on you.', 'जो चीज़ें एक असली विरोध के बावजूद बनीं। हर एक पर आपका फ़ैसला बाक़ी है।');
  String get uiReplayEverything => _p('Replay everything', 'सब दोबारा चलाएँ');
  String get uiClearsImpressionsDismissalsSo => _p('Clears impressions and dismissals so a Premiere can be watched again.', 'impressions और dismissals हटा देता है, ताकि Premiere दोबारा देखा जा सके।');
  String get uiResetRestartAppSee => _p('Reset — restart the app to see the Premiere', 'रीसेट — Premiere देखने के लिए ऐप दोबारा खोलिए');
  String get uiReset => _p('Reset', 'रीसेट');
  String get uiPreviewAs => _p('Preview as', 'इस रूप में देखें');
  String get uiWhatStudioKnowsAbout => _p('WHAT THE STUDIO KNOWS ABOUT YOU', 'स्टूडियो आपके बारे में क्या जानता है');
  String get uiEverythingTargetingCanSee => _p('This is everything targeting can see. It is read from your family profile — nothing else.', 'targeting को बस इतना ही दिखता है। यह आपकी family profile से पढ़ा जाता है — और कहीं से नहीं।');
  String get uiEveryPlacement => _p('EVERY PLACEMENT', 'हर प्लेसमेंट');
  String get uiCompleteListClosedSet => _p('The complete list. A closed set — a placement cannot exist unless it is here.', 'पूरी सूची। एक बंद सूची — कोई प्लेसमेंट यहाँ हुए बिना हो ही नहीं सकता।');
  String get uiLaunches => _p('LAUNCHES', 'लॉन्च');
  String get uiNewWorthKnowingAbout => _p('New, and worth knowing about', 'नया, और जानने लायक़');
  String get uiProductsWeThinkAre => _p('Products we think are genuinely new, introduced by the people who made them and read honestly by a ParentVeda expert. Brands pay to launch here. They do not pay for what the expert says.', 'वे प्रोडक्ट जो हमें सचमुच नए लगते हैं — बनाने वालों की ज़ुबानी, और ParentVeda के विशेषज्ञ की ईमानदार राय के साथ। ब्रांड यहाँ लॉन्च करने के पैसे देते हैं। विशेषज्ञ क्या कहेंगे, उसके नहीं।');
  String get uiNoLaunchesRightNow => _p('No launches right now', 'अभी कोई लॉन्च नहीं');
  String get uiWeOnlyRunThese => _p('We only run these a few times a year. An empty page here means nothing new is worth your attention yet.', 'हम ये साल में कुछ ही बार चलाते हैं। यहाँ ख़ाली पन्ने का मतलब है कि अभी कुछ भी आपका ध्यान माँगने लायक़ नहीं।');
  String get uiReadLaunch => _p('Read the launch', 'लॉन्च पढ़ें');
  String get uiWhatActually => _p('WHAT IT ACTUALLY IS', 'यह असल में है क्या');
  String get uiLearnProperly => _p('LEARN THIS PROPERLY', 'इसे ठीक से समझिए');
  String get uiParentvedaSOwnGuides => _p('ParentVeda\'s own guides on the subject. Free, and not about this product.', 'इस विषय पर ParentVeda की अपनी गाइड। मुफ़्त, और इस प्रोडक्ट के बारे में नहीं।');
  String get uiLaunchNotEndorsementNothing => _p('A launch is not an endorsement. Nothing here changes a product\'s ParentVeda rating, and no brand can buy one.', 'लॉन्च का मतलब सिफ़ारिश नहीं। यहाँ कुछ भी किसी प्रोडक्ट की ParentVeda रेटिंग नहीं बदलता, और कोई ब्रांड रेटिंग ख़रीद नहीं सकता।');
  String get uiParentvedaSExpert => _p('PARENTVEDA\'S EXPERT', 'ParentVeda के विशेषज्ञ');
  String get uiBrandLinkComingSoon => _p('Brand link coming soon', 'ब्रांड का लिंक जल्द');
  String get uiParentvedaLaunch => _p('A PARENTVEDA LAUNCH', 'एक ParentVeda लॉन्च');
  String get uiNeedsDecision => _p('NEEDS A DECISION', 'फ़ैसला चाहिए');
  String get uiNoteOnlyVisibleDebug => _p('This note is only visible in debug builds. Parents never see it.', 'यह नोट सिर्फ़ debug build में दिखता है। माता-पिता इसे कभी नहीं देखते।');
  String get uiSponsorshipResearchPage => _p('Sponsorship on a research page', 'शोध वाले पन्ने पर प्रायोजन');
  String get uiSponsorshipCompareTool => _p('Sponsorship on the Compare tool', 'Compare टूल पर प्रायोजन');
  String get uiEveryBrandHereInvented => _p('Every brand here is invented', 'यहाँ हर ब्रांड काल्पनिक है');
  String get uiPremiereHasNoBrand => _p('Premiere has no brand film', 'Premiere के पास कोई ब्रांड फ़िल्म नहीं');
  String get uiSamplingCollectsRequestsCannot => _p('Sampling collects requests it cannot fulfil', 'Sampling ऐसी माँगें जमा करता है जो पूरी नहीं हो सकतीं');
  String get uiNotNow => _p('Not now', 'अभी नहीं');
  String get uiWhatMeans => _p('What that means', 'इसका मतलब क्या है');
  String get uiFreeSample => _p('Free sample', 'मुफ़्त नमूना');
  String get uiWhereDetailsGo => _p('Where your details go', 'आपकी जानकारी कहाँ जाती है');
  String get uiWhereShouldWePost => _p('Where should we post it?', 'हम इसे कहाँ भेजें?');
  String get uiParentvedaMayUseAddress => _p('ParentVeda may use this address to post this sample.', 'ParentVeda इस पते का इस्तेमाल यह नमूना भेजने के लिए कर सकता है।');
  String get uiAreList => _p('You are on the list', 'आप सूची में हैं');
  String get uiWhenArrives => _p('When it arrives', 'कब पहुँचेगा');
  String get uiThankNoted => _p('Thank you — noted.', 'शुक्रिया — दर्ज कर लिया।');
  String get uiFlatHouseStreetArea => _p('Flat / house, street, area, city, PIN', 'मकान/फ़्लैट, गली, इलाक़ा, शहर, PIN');
  String get uiScanJoinParentveda => _p('Scan to join ParentVeda', 'ParentVeda से जुड़ने के लिए स्कैन कीजिए');
  String get uiWeekByWeekGuidance => _p('Week-by-week guidance for pregnancy and the early years.', 'गर्भावस्था और शुरुआती सालों के लिए हफ़्ते-दर-हफ़्ते मार्गदर्शन।');
  String get uiParentveda => _p('ParentVeda+', 'ParentVeda+');
  String get uiFreeConsultation => _p('1 free consultation', '1 मुफ़्त परामर्श');
  String get uiGentleExpertGuidancePregnancy => _p('Gentle, expert guidance for pregnancy and every milestone after.', 'गर्भावस्था और उसके बाद के हर पड़ाव के लिए सौम्य, विशेषज्ञ मार्गदर्शन।');
  String get uiLovedByParents => _p('Loved by 50,000+ parents', '50,000+ माता-पिता की पसंद');
  String get uiIAmCurrently => _p('I AM CURRENTLY', 'मैं अभी हूँ');
  String get uiAddDateAboveContinue => _p('Add the date above to continue — everything else is built around it.', 'ऊपर तारीख़ डालिए — बाक़ी सब उसी के हिसाब से बनता है।');
  String get uiSignAsWhichDoctor => _p('Sign in as which doctor?', 'किस डॉक्टर के रूप में साइन इन करें?');
  String get uiPairingCode => _p('Pairing code', 'जोड़ने का कोड');
  String get uiPairingPartner => _p('Pairing you with your partner…', 'आपको आपके साथी से जोड़ा जा रहा है…');
  String get uiReNowPairedNyour => _p("You're now paired with\nyour partner.",
      'अब आप अपने साथी से\nजुड़ गई हैं।');
  String get uiWeReHereHelp => _p('We\'re here to help you support her and understand her journey better.', 'हम यहाँ हैं ताकि आप उनका साथ दे सकें और उनके सफ़र को बेहतर समझ सकें।');
  String get uiReAllSet => _p('You\'re all set!', 'सब तैयार है!');
  String get uiWelcomeParentvedaFamilyJourney => _p('Welcome to the ParentVeda family. Your journey begins now. 💜', 'ParentVeda परिवार में स्वागत है। आपका सफ़र अभी से शुरू। 💜');
  String get uiHaveInviteCode => _p('Have an invite code?', 'कोई निमंत्रण कोड है?');
  String get uiPleaseAddDueDate => _p('Please add the due date or birthday first.', 'पहले डिलीवरी की तारीख़ या जन्मदिन डालिए।');
  String get uiCanDoLaterFrom => _p('You can do this later from Profile.', 'यह आप बाद में Profile से भी कर सकती हैं।');
  String get uiWhatsappUpdates => _p('WhatsApp updates', 'WhatsApp पर अपडेट');
  String get uiGetWeeklyGuideWhatsapp => _p('Get your weekly guide on WhatsApp. Optional.', 'अपनी साप्ताहिक गाइड WhatsApp पर पाइए। आपकी मर्ज़ी।');
  String get uiDonTKnowCalculate => _p('Don\'t know it? Calculate your due date', 'पता नहीं? अपनी डिलीवरी की तारीख़ निकालिए');
  String get uiEmbryoAgeTransfer => _p('Embryo age at transfer', 'ट्रांसफ़र के समय embryo की उम्र');
  String get uiGestationalAgeScan => _p('Gestational age at scan', 'स्कैन के समय gestational age');
  String get uiCalculateDueDate => _p('Calculate your due date', 'अपनी डिलीवरी की तारीख़ निकालिए');
  String get uiTellUsWhatKnow => _p('Tell us what you know - we\'ll do the math.', 'आपको जो पता है वह बताइए — हिसाब हम लगा देंगे।');
  String get uiWhatDoKnow => _p('WHAT DO YOU KNOW?', 'आपको क्या पता है?');
  String get uiEstimatedDueDate => _p('ESTIMATED DUE DATE', 'अनुमानित डिलीवरी तारीख़');
  String get uiUseDate => _p('Use this date', 'यही तारीख़ रखें');
  String get uiIMMother => _p('I\'m the mother', 'मैं माँ हूँ');
  String get uiIMFather => _p('I\'m the father', 'मैं पिता हूँ');
  String get uiIMDoctor => _p('I\'m a doctor', 'मैं डॉक्टर हूँ');
  String get uiEGXosU => _p('e.g. 0XOS1U', 'जैसे 0XOS1U');
  String get uiReadSummary => _p('Read summary', 'सार पढ़ें');
  String get uiTapAnyIdeaOpen => _p('Tap any idea to open it.', 'किसी भी विचार को खोलने के लिए टैप कीजिए।');
  String get uiTapChapterItsKey => _p('Tap a chapter for its key points.', 'किसी अध्याय की मुख्य बातें देखने के लिए टैप कीजिए।');
  String get uiParentvedaSTake => _p('PARENTVEDA\'S TAKE', 'ParentVeda की राय');
  String get uiKeyPointsCovered => _p('KEY POINTS COVERED', 'मुख्य बातें');
  String get uiBack => _p('Back', 'वापस');
  String get uiFifteenPremiumBrandProducts => _p('Fifteen premium brand products, plus Certification. Every one is a real placement in the real app - tap "Show me" to go and see it in context.', 'पंद्रह प्रीमियम ब्रांड प्रोडक्ट, साथ में Certification। हर एक असली ऐप में असली जगह पर है — "दिखाइए" दबाकर उसे वहीं जाकर देखिए।');
  String get uiDemoPartners => _p('DEMO PARTNERS', 'डेमो साथी');
  String get uiNotRealPartnershipsPlaceholders => _p('Not real partnerships - placeholders for review.', 'असली साझेदारी नहीं — समीक्षा के लिए रखे गए नमूने।');
  String get uiShowMe => _p('Show me', 'दिखाइए');
  String get uiNotBuilt => _p('Not built', 'अभी बना नहीं');
  String get uiCareCircle => _p('Your Care Circle', 'आपका देखभाल का घेरा');
  String get uiEvidenceBasedSupportEvery => _p('Evidence-based support, every week of the journey.', 'हर हफ़्ते, प्रमाण पर टिका साथ।');
  String get uiCarePartnerDebug => _p('Care Partner (debug)', 'Care Partner (debug)');
  String get uiWelcomeParentveda => _p('Welcome to ParentVeda', 'ParentVeda में स्वागत है');
  String get uiSomeoneWhoLooksAfter => _p('Someone who looks after you brought you here.', 'आपका ख़याल रखने वाले किसी ने आपको यहाँ भेजा है।');
  String get uiContinue => _p('Continue', 'आगे बढ़ें');
  String get uiToday => _p('TODAY FOR YOU', 'आज आपके लिए');
  String get uiWeeklySnapshot => _p('WEEKLY SNAPSHOT', 'हफ़्ते की झलक');
  String get uiOpenHerWeek => _p('Open her week', 'उनका हफ़्ता खोलिए');
  String get uiDailyTipDad => _p('DAILY TIP FOR DAD', 'पापा के लिए आज की बात');
  String get uiTonightDonTFix => _p('Tonight, don\'t fix it. Just sit with her.', 'आज रात हल मत ढूँढिए। बस उनके पास बैठिए।');
  String get uiWhenSheCanT => _p('When she can\'t sleep, presence beats solutions. A hand on her back says more than any advice.', 'जब नींद नहीं आती, तब सलाह से ज़्यादा साथ काम आता है। पीठ पर रखा एक हाथ किसी भी नसीहत से ज़्यादा कहता है।');
  String get uiReadTodaySTip => _p('Read today\'s tip · 2 min', 'आज की बात पढ़िए · 2 मिनट');
  String get uiSupportPartner => _p('SUPPORT YOUR PARTNER', 'अपनी साथी का साथ');
  String get uiWeekWhatSheS => _p('Week 20 - what she\'s carrying', 'हफ़्ता 20 — वे क्या सँभाल रही हैं');
  String get uiHerLowerBackTaking => _p('Her lower back is taking the strain this week, and by evening it aches.', 'इस हफ़्ते सारा ज़ोर उनकी कमर पर है, और शाम तक दर्द बढ़ जाता है।');
  String get uiDoToday => _p('DO THIS TODAY', 'आज यह कीजिए');
  String get uiTakeDinnerOffHer => _p('Take dinner off her plate - cook her favourite, or order it before she has to ask.', 'रात का खाना उनके ज़िम्मे से हटा दीजिए — उनकी पसंद का बनाइए, या माँगने से पहले मँगा लीजिए।');
  String get uiTodaySRead => _p('TODAY\'S READ', 'आज का पाठ');
  String get uiReadBaby => _p('READ TO YOUR BABY', 'अपने शिशु को सुनाइए');
  String get uiReadBabyTonight => _p('Read to your baby tonight', 'आज रात अपने शिशु को सुनाइए');
  String get uiScansAppointments => _p('SCANS & APPOINTMENTS', 'स्कैन और अपॉइंटमेंट');
  String get uiComingUpHer => _p('Coming up for her', 'उनके लिए आगे क्या');
  String get uiNothingDueRightNow => _p('Nothing due right now - you\'re both up to date.', 'अभी कुछ बाक़ी नहीं — आप दोनों अप-टू-डेट हैं।');
  String get uiAlreadyDone => _p('Already done', 'पहले से हो गया');
  String get uiAllScans => _p('All scans', 'सारे स्कैन');
  String get uiTickOffOnesAlready => _p('Tick off the ones already done - even older ones, if you joined late.', 'जो पहले हो चुके हैं उन्हें टिक कर दीजिए — पुराने भी, अगर आप बीच में जुड़े हैं।');
  String get uiStoriesFablesMyth => _p('STORIES, FABLES & MYTH', 'कहानियाँ, नीति-कथाएँ और पुराण');
  String get uiWhatWouldLikeRead => _p('What would you like to read?', 'आप क्या पढ़ना चाहेंगे?');
  String get uiPickKindsWantLeave => _p('Pick the kinds you want. Leave all off for a mix of everything.', 'जो पसंद हो चुन लीजिए। सब बंद छोड़ देंगे तो सबका मिला-जुला मिलेगा।');
  String get uiJournal => _p('YOUR JOURNAL', 'आपका जर्नल');
  String get uiNoteBaby => _p('A note to your baby', 'शिशु के नाम एक नोट');
  String get uiJournal2 => _p('Your journal', 'आपका जर्नल');
  String get uiMemoriesPhotosVoiceNotes => _p('Your memories, photos and voice notes will live here. Tap a circle above to add one - a memory, a note to your baby, a photo or a voice note.', 'आपकी यादें, फ़ोटो और वॉइस नोट यहाँ रहेंगे। ऊपर किसी गोले पर टैप करके एक जोड़िए — कोई याद, शिशु के नाम नोट, फ़ोटो या वॉइस नोट।');
  String get uiTakeDinnerOffHer2 => _p('Take dinner off her plate - cook her favourite, or order it before she has to ask. Then rub her lower back for five minutes, no phone.', 'रात का खाना उनके ज़िम्मे से हटा दीजिए — उनकी पसंद का बनाइए, या माँगने से पहले मँगा लीजिए। फिर पाँच मिनट उनकी कमर सहलाइए, बिना फ़ोन के।');
  String get uiMoreWaysHelpWeek => _p('MORE WAYS TO HELP THIS WEEK', 'इस हफ़्ते मदद के और तरीक़े');
  String get uiSaveEntry => _p('Save entry', 'एंट्री सेव करें');
  String get uiRecentEntries => _p('RECENT ENTRIES', 'हाल की एंट्री');
  String get uiSwitchMomSView => _p('Switch to Mom\'s view', 'माँ वाला रूप देखिए');
  String get uiLlBothStaySync => _p('You\'ll both stay in sync.', 'आप दोनों साथ-साथ रहेंगे।');
  String get uiMomSDailySpace => _p('Mom\'s daily space - her body this week, cravings, kicks and her own journal - lives one tap away. Anything you mark here shows up for her too.', 'माँ की रोज़ की जगह — इस हफ़्ते उनका शरीर, क्रेविंग, हलचल और उनका अपना जर्नल — बस एक टैप दूर है। आप यहाँ जो भी दर्ज करेंगे, वह उन्हें भी दिखेगा।');
  String get uiOpenMomSView => _p('Open Mom\'s view', 'माँ वाला रूप खोलिए');
  String get uiStayDadSView => _p('Stay in Dad\'s view', 'पापा वाले रूप में रहिए');
  String get uiHereSWhatScan => _p('Here\'s what this scan is - so you can be there for it with her, and understand what you\'re looking at together.', 'यह स्कैन क्या है — ताकि आप उनके साथ वहाँ रह सकें, और दोनों समझ सकें कि सामने क्या है।');
  String get uiGeneralGuidanceHelpSupport => _p('General guidance to help you support her - every pregnancy is different, so always follow her doctor.', 'उनका साथ देने के लिए सामान्य मार्गदर्शन — हर गर्भावस्था अलग होती है, इसलिए हमेशा उनके डॉक्टर की सलाह मानिए।');
  String get uiHowReadReport => _p('HOW TO READ THE REPORT', 'रिपोर्ट कैसे पढ़ें');
  String get uiPlainLanguageExplanationsNot => _p('Plain-language explanations, not a diagnosis. Numbers only mean something in full context - read the report with her doctor.', 'आसान भाषा में समझाइश, निदान नहीं। नंबर का मतलब पूरे संदर्भ में ही निकलता है — रिपोर्ट उनके डॉक्टर के साथ पढ़िए।');
  String get uiWhatScan => _p('What is this scan?', 'यह स्कैन क्या है?');
  String get uiTonightDonTFix2 => _p('Tonight, don\'t fix it - just sit with her', 'आज रात हल मत ढूँढिए — बस उनके पास बैठिए');
  String get uiWhatBabyCanHear => _p('What your baby can hear at 20 weeks', '20 हफ़्ते में आपका शिशु क्या सुन सकता है');
  String get uiChurningOcean => _p('The Churning of the Ocean', 'समुद्र मंथन');
  String get uiWriteBabyJustJot => _p('Write to your baby, or just jot today\'s thought…', 'शिशु को लिखिए, या बस आज का ख़याल दर्ज कीजिए…');
  String get uiMemories => _p('YOUR MEMORIES', 'आपकी यादें');
  String get uiFatherSJournal => _p('Father\'s Journal', 'पिता का जर्नल');
  String get uiStartJournal => _p('Start your journal', 'अपना जर्नल शुरू कीजिए');
  String get uiWriteMemoryNoteSomething => _p('Write a memory, note something for your baby, add a photo or record your voice. It all stays here for you.', 'कोई याद लिखिए, शिशु के लिए कुछ नोट कीजिए, फ़ोटो जोड़िए या अपनी आवाज़ रिकॉर्ड कीजिए। सब यहीं आपके पास रहेगा।');
  String get uiVoiceNote => _p('Voice note', 'वॉइस नोट');
  String get uiReadBaby2 => _p('Read to your baby', 'अपने शिशु को सुनाइए');
  String get uiSameWordsSheS => _p('The same words she\'s reading - say them aloud to the bump. Your voice is one they already know.', 'वही शब्द जो वे पढ़ रही हैं — उन्हें बंप के पास बोलकर सुनाइए। आपकी आवाज़ शिशु पहले से पहचानता है।');
  String get uiNothingChosenYetShe => _p('Nothing chosen yet - she picks the spiritual reading in her app, and it shows up here for you.', 'अभी कुछ नहीं चुना — आध्यात्मिक पाठ वे अपने ऐप में चुनती हैं, और वह यहाँ आपके लिए आ जाता है।');
  String get uiSave => _p('Save', 'सेव करें');
  String get uiDad => _p('FOR YOU, DAD', 'आपके लिए, पापा');
  String get uiReads => _p('Reads', 'पाठ');
  String get uiShortReadsAboutHer => _p('Short reads about her, the baby, and how to show up.', 'उनके बारे में, शिशु के बारे में, और साथ कैसे देना है — छोटे पाठ।');
  String get uiArticles => _p('ARTICLES', 'लेख');
  String get uiResearchSummaries => _p('RESEARCH SUMMARIES', 'शोध का सार');
  String get uiBookSummaries => _p('BOOK SUMMARIES', 'किताबों का सार');
  String get uiStoriesFablesMythology => _p('Stories, Fables & Mythology', 'कहानियाँ, नीति-कथाएँ और पुराण');
  String get uiTalesReadAloudBump => _p('Tales to read aloud to the bump', 'बंप के पास बोलकर सुनाने की कहानियाँ');
  String get uiContents => _p('Contents', 'विषय-सूची');
  String get uiReading => _p('Reading', 'पढ़ रहे हैं');
  String get uiRead => _p('The read', 'पाठ');
  String get uiWhyMatters => _p('Why this matters', 'यह क्यों मायने रखता है');
  String get uiResearchSimplified => _p('Research simplified', 'शोध आसान भाषा में');
  String get uiMythVsFact => _p('Myth vs fact', 'मिथक बनाम सच');
  String get uiReadingSettings => _p('Reading settings', 'पढ़ने की सेटिंग');
  String get uiReadAloud => _p('FOR YOU TO READ ALOUD', 'आपके बोलकर सुनाने के लिए');
  String get uiReadAloudLetVoice => _p('Read it aloud - let your voice rise and fall', 'बोलकर पढ़िए — आवाज़ को चढ़ने-उतरने दीजिए');
  String get uiLesson => _p('THE LESSON', 'सीख');
  String get uiFromDad => _p('FROM DAD', 'पापा की ओर से');
  String get uiFewQuietMinutesFocused => _p('A few quiet minutes of focused calm.', 'कुछ शांत मिनट, पूरी तरह ठहरे हुए।');
  String get uiNothingSelectedYetTap => _p('Nothing selected yet. Tap Customize to choose what to read to your baby.', 'अभी कुछ नहीं चुना। शिशु को क्या सुनाना है, यह चुनने के लिए "अपने हिसाब से" दबाइए।');
  String get uiDone => _p('Done', 'हो गया');
  String get uiPostPregnancy => _p('Post-Pregnancy', 'जन्म के बाद');
  String get uiBabySArrivedStep => _p('Baby\'s arrived? Step into the parenting app', 'शिशु आ गया? परवरिश वाले ऐप में चलिए');
  String get uiBest => _p('BEST', 'सबसे बेहतर');
  String get uiBudget => _p('BUDGET', 'कम दाम');
  String get uiPremium => _p('PREMIUM', 'प्रीमियम');
  String get uiGentle => _p('GENTLE', 'कोमल');
  String get uiNewborn => _p('NEWBORN', 'नवजात');
  String get uiDad2 => _p('You + Dad', 'आप + पापा');
  String get uiMemories2 => _p('MEMORIES', 'यादें');
  String get uiKeepsakesTreasure => _p('Keepsakes to treasure', 'सहेजने लायक़ निशानियाँ');
  String get uiMakeBeautifulCardMoments => _p('Make a beautiful card for the moments that matter most.', 'सबसे ख़ास पलों के लिए एक सुंदर कार्ड बनाइए।');
  String get uiMyMemories => _p('MY MEMORIES', 'मेरी यादें');
  String get uiAddDetailsEverythingOptional => _p('Add your details — everything is optional except a name.', 'अपनी जानकारी भरिए — नाम के अलावा सब कुछ आपकी मर्ज़ी।');
  String get uiAddPhotoOptional => _p('Add a photo (optional)', 'फ़ोटो जोड़िए (ज़रूरी नहीं)');
  String get uiCanZoomPositionAfter => _p('You can zoom & position it after', 'बाद में ज़ूम और जगह ठीक कर सकते हैं');
  String get uiPinchZoomDragPosition => _p('Pinch to zoom · drag to position', 'ज़ूम के लिए दो उँगलियाँ · जगह बदलने के लिए खींचिए');
  String get uiReplace => _p('Replace', 'बदलिए');
  String get uiRemove => _p('Remove', 'हटाइए');
  String get uiPreviewTemplates => _p('Preview templates', 'टेम्पलेट देखिए');
  String get uiChooseTemplate => _p('Choose a template', 'टेम्पलेट चुनिए');
  String get uiPersonaliseParentveda => _p('Personalise ParentVeda', 'ParentVeda को अपने हिसाब से बनाइए');
  String get uiNothingHereRequiredCan => _p('Nothing here is required, and you can change any of it later. Every answer just helps ParentVeda put the right things in front of you first - it never hides anything or moves things around.', 'यहाँ कुछ भी ज़रूरी नहीं, और सब कुछ बाद में बदला जा सकता है। हर जवाब बस ParentVeda को यह तय करने में मदद करता है कि पहले क्या दिखाए — यह कभी कुछ छिपाता नहीं, न चीज़ें इधर-उधर करता है।');
  String get uiAnswersStayDeviceOwn => _p('Your answers stay on your device and in your own ParentVeda account. They are used to choose what to show you - never to decide which features you get.', 'आपके जवाब आपके फ़ोन और आपके अपने ParentVeda खाते में रहते हैं। इनसे बस यह चुना जाता है कि आपको क्या दिखाया जाए — यह कभी तय नहीं करता कि आपको कौन से फ़ीचर मिलेंगे।');
  String get uiBirthingClasses => _p('Birthing Classes', 'जन्म की तैयारी की क्लास');
  String get uiEverythingBigDayTaught => _p('Everything for the big day, taught by a childbirth educator.', 'बड़े दिन के लिए सब कुछ, एक childbirth educator से सीखिए।');
  String get uiRe => _p('You\'re ', 'आप');
  String get uiExactlyWhenMostMums => _p(' - exactly when most mums prepare for birth.', 'पर हैं — ठीक वही समय जब ज़्यादातर माँएँ जन्म की तैयारी करती हैं।');
  String get uiCompleteBirthingCourse => _p('Complete Birthing Course', 'जन्म की तैयारी का पूरा कोर्स');
  String get uiClassesSelfPacedVideo => _p('6 classes · self-paced video + a monthly live Q&A', '6 क्लास · अपनी रफ़्तार से वीडियो + हर महीने एक लाइव सवाल-जवाब');
  String get uiClasses => _p('The 6 classes', 'छह क्लास');
  String get uiLeadsEveryLiveSession => _p('Leads every live session and the group.', 'हर लाइव सेशन और ग्रुप वही चलाती हैं।');
  String get uiParentvedaMembersAnyCohort => _p(' on any cohort.', '— किसी भी कोहॉर्ट पर।');
  String get uiJoinNextCohort => _p('Join the next cohort', 'अगले कोहॉर्ट में जुड़िए');
  String get uiCohortPrograms => _p('Cohort Programs', 'कोहॉर्ट प्रोग्राम');
  String get uiSmallGroupsRealCoach => _p('Small groups, a real coach, and mums due when you are.', 'छोटे समूह, एक असली कोच, और वे माँएँ जिनकी डिलीवरी आपके साथ है।');
  String get uiBirthReadyCohortStarts => _p(' - the Birth-Ready cohort starts Monday.', 'पर हैं — Birth-Ready कोहॉर्ट सोमवार से शुरू है।');
  String get uiWith => _p('with ', 'साथ:');
  String get uiChildbirthEducator => _p(', childbirth educator', '— childbirth educator');
  String get uiMorePrograms => _p('More programs', 'और प्रोग्राम');
  String get uiLiveSessionsSmallPeer => _p('Live sessions · a small peer group · weekly homework · a private WhatsApp group.', 'लाइव सेशन · एक छोटा साथी-समूह · हर हफ़्ते अभ्यास · एक निजी WhatsApp ग्रुप।');
  String get uiParentveda2 => _p('.', '।');
  String get uiTodayJul => _p('Today, 8 Jul', 'आज, 8 जुलाई');
  String get uiBedsideMannerRatedBy => _p('Bedside manner, rated by mothers.', 'माँओं ने बताया, वे कैसे पेश आते हैं।');
  String get uiPickSlotPrivateVideo => _p('Pick a slot → private video call → notes saved to your health record.', 'स्लॉट चुनिए → निजी वीडियो कॉल → नोट आपके हेल्थ रिकॉर्ड में सेव।');
  String get uiConsultations => _p('1:1 Consultations', '1:1 परामर्श');
  String get uiPrivateSessionRightExpert => _p('A private session with the right expert, whenever you need one.', 'सही विशेषज्ञ के साथ एक निजी सेशन, जब भी ज़रूरत हो।');
  String get uiSomethingMindAfterWeek => _p('Something on your mind after your 30-week scan? Talk it through.', '30-हफ़्ते के स्कैन के बाद कुछ मन में है? बात कर लीजिए।');
  String get uiPickExpertPickSlot => _p('Pick an expert → pick a slot → private video call. Notes saved to your health record.', 'विशेषज्ञ चुनिए → स्लॉट चुनिए → निजी वीडियो कॉल। नोट आपके हेल्थ रिकॉर्ड में सेव।');
  String get uiHindiEnglish => _p('Hindi / English', 'हिंदी / अंग्रेज़ी');
  String get uiCoursesCohorts => _p('Courses & Cohorts', 'कोर्स और कोहॉर्ट');
  String get uiSelfPacedCoursesSmall => _p('Self-paced courses, small live cohorts and one-evening masterclasses - all in one place. Search a topic, or browse everything below.', 'अपनी रफ़्तार वाले कोर्स, छोटे लाइव कोहॉर्ट और एक शाम की मास्टरक्लास — सब एक जगह। कोई विषय खोजिए, या नीचे सब देखिए।');
  String get uiEveryProgramLedBy => _p('Every program is led by a verified expert.', 'हर प्रोग्राम एक सत्यापित विशेषज्ञ चलाते हैं।');
  String get uiNoProgramsMatch => _p('No programs match', 'कोई प्रोग्राम नहीं मिला');
  String get uiTryAnotherTopicClear => _p('Try another topic or clear your filters.', 'दूसरा विषय आज़माइए या फ़िल्टर हटाइए।');
  String get uiWatchSecIntro => _p('Watch the 90-sec intro', '90 सेकंड का परिचय देखिए');
  String get uiReserveSeat => _p('Reserve a seat', 'सीट रोकिए');
  String get uiMasterclasses => _p('Masterclasses', 'मास्टरक्लास');
  String get uiDeepDiveLiveSessions => _p('Deep-dive live sessions with experts, on the moments that matter.', 'उन पलों पर विशेषज्ञों के साथ गहरे लाइव सेशन जो सबसे ज़्यादा मायने रखते हैं।');
  String get uiBirthMindStartHere => _p(' - birth is on your mind. Start here.', '— जन्म आपके मन में है। यहीं से शुरू कीजिए।');
  String get uiMoreMasterclasses => _p('More masterclasses', 'और मास्टरक्लास');
  String get uiLiveRecording => _p('live + recording', 'लाइव + रिकॉर्डिंग');
  String get uiNutrition => _p('Nutrition', 'पोषण');
  String get uiTwoMinuteCheckThen => _p('A two-minute check-in, then a plan built around you - and a nutritionist to make it yours.', 'दो मिनट की जाँच, फिर आपके हिसाब से बना एक प्लान — और उसे आपका बनाने के लिए एक nutritionist।');
  String get uiAnswerFewQuestionsWe => _p('Answer a few questions and we\'ll match you to the right plan and expert.', 'कुछ सवालों के जवाब दीजिए और हम आपको सही प्लान और विशेषज्ञ से मिला देंगे।');
  String get uiChooseMainFocusFirst => _p('Choose a main focus first', 'पहले एक मुख्य लक्ष्य चुनिए');
  String get uiRecommendedPlans => _p('Your recommended plans', 'आपके लिए सुझाए प्लान');
  String get uiBasedAnswersEachOne => _p('Based on your answers - each one is a starting point a nutritionist will personalise.', 'आपके जवाबों के आधार पर — हर एक शुरुआत भर है, जिसे nutritionist आपके हिसाब से बनाएँगी।');
  String get uiPreview => _p('Preview →', 'झलक →');
  String get uiTrailerSec => _p('Trailer · 60 sec', 'ट्रेलर · 60 सेकंड');
  String get uiWhatSInside => _p('What\'s inside', 'इसमें क्या है');
  String get uiDayPlan => _p('A day on this plan', 'इस प्लान का एक दिन');
  String get uiSampleNutritionistTailorsBody => _p('A sample - your nutritionist tailors it to your body and tastes.', 'एक नमूना — आपकी nutritionist इसे आपके शरीर और स्वाद के हिसाब से ढालेंगी।');
  String get uiEveryPlanFinalised => _p('Every plan is finalised with a ', 'हर प्लान आख़िरी रूप लेता है एक');
  String get uiConsultSoTrulyFits => _p(' in a 1:1 consult - so it truly fits you.', 'में, 1:1 परामर्श के दौरान — ताकि यह सचमुच आप पर बैठे।');
  String get uiConsult => _p('with a 1:1 consult', '1:1 परामर्श के साथ');
  String get uiPersonalizedDietPlan => _p('Your personalized diet plan', 'आपके हिसाब से बना खानपान प्लान');
  String get uiConsultBookedNutritionistWill => _p('Consult booked. Your nutritionist will fine-tune this plan on the call, then it lands here in full.', 'परामर्श बुक हो गया। आपकी nutritionist कॉल पर इस प्लान को ठीक करेंगी, फिर यह पूरा यहाँ आ जाएगा।');
  String get uiFocusPlan => _p('Your focus this plan', 'इस प्लान में आपका लक्ष्य');
  String get uiYoga => _p('Yoga', 'योग');
  String get uiTrimesterSafeMovementFeel => _p('Trimester-safe movement to feel strong, calm, and ready - matched to exactly where you are.', 'तिमाही के हिसाब से सुरक्षित हलचल — मज़बूत, शांत और तैयार महसूस करने के लिए, ठीक वहीं से जहाँ आप हैं।');
  String get uiRe2 => _p('You\'re in ', 'आप');
  String get uiWeVeOpenedYoga => _p(' - we\'ve opened your yoga here. Every session is filtered safe for your stage.', 'में हैं — आपका योग यहीं खोल दिया है। हर सेशन आपके चरण के लिए सुरक्षित छाँटा गया है।');
  String get uiPregnancyYogaProgram => _p('Pregnancy Yoga Program', 'गर्भावस्था योग प्रोग्राम');
  String get uiMonthJourneySanaKapoor => _p('9-month journey · with Sana Kapoor, certified prenatal instructor', '9 महीने का सफ़र · Sana Kapoor के साथ, प्रमाणित गर्भावस्था-योग प्रशिक्षक');
  String get uiChooseMonth => _p('CHOOSE A MONTH', 'महीना चुनिए');
  String get uiSessionsMonthAreComing => _p('Sessions for this month are coming soon.', 'इस महीने के सेशन जल्द आ रहे हैं।');
  String get uiEverySessionFilteredMonth => _p('Every session is filtered for your month - nothing unsafe for where you are ever surfaces.', 'हर सेशन आपके महीने के हिसाब से छाँटा जाता है — जो आपके लिए सुरक्षित नहीं, वह कभी सामने नहीं आता।');
  String get uiWeLlHoldSpot => _p('We\'ll hold your spot and remind you before it starts. Payments aren\'t live yet - nothing is charged now.', 'हम आपकी जगह रोक लेंगे और शुरू होने से पहले याद दिला देंगे। भुगतान अभी चालू नहीं है — अभी कुछ नहीं कटेगा।');
  String get uiCancel => _p('Cancel this?', 'इसे रद्द करें?');
  String get uiWillRemoveFromPrepare => _p('This will remove it from your Prepare list.', 'यह आपकी तैयारी सूची से हट जाएगा।');
  String get uiKeep => _p('Keep', 'रहने दें');
  String get uiCancel2 => _p('Cancel it', 'रद्द कर दें');
  String get uiPrepareBabyNoneGuided => _p(
      'Prepare for your baby,\none guided step at a time.',
      'अपने शिशु के लिए तैयार होइए,\nएक-एक क़दम, साथ-साथ।');
  String get uiCoursesLiveCohortsExpert => _p('Courses, live cohorts, expert sessions, and gentle movement - chosen for exactly where you are.', 'कोर्स, लाइव कोहॉर्ट, विशेषज्ञ सेशन और सौम्य हलचल — ठीक वहीं के लिए चुने गए जहाँ आप हैं।');
  String get uiRecommendedWeeks => _p('RECOMMENDED AT 30 WEEKS', '30 हफ़्ते पर सुझाया गया');
  String get uiMostFree => _p('Most of this is free with ', 'इसमें से ज़्यादातर मुफ़्त है —');

  /// ⚠️ REPLACES `uiMostFree` + a 'ParentVeda+' span.
  ///
  /// The old line was built as three spans so the membership name could be
  /// purple: "Most of this is free with **ParentVeda+**." With no membership,
  /// what is left is the true and simpler claim — most of the Prepare tab costs
  /// nothing — and it needs one span, not three.
  String get uiMostFreeRest =>
      _p('Most of this is free. Anything paid is bought on its own.',
          'इसमें से ज़्यादातर मुफ़्त है। जो paid है, वह अलग से लिया जाता है।');
  String get uiPrepare => _p('Prepare', 'तैयारी');
  String get uiVideoComingSoon => _p('Video coming soon', 'वीडियो जल्द आ रहा है');
  String get uiFullVideoLandsHere => _p('The full video lands here soon. We\'ll notify you when it\'s ready to watch.', 'पूरा वीडियो जल्द यहाँ आएगा। देखने लायक़ होते ही हम बता देंगे।');
  String get uiCohortHasAlreadyStarted => _p('This cohort has already started - reserve the next intake.', 'यह कोहॉर्ट शुरू हो चुका है — अगली बार के लिए जगह रोक लीजिए।');
  String get uiWhatLlLearn => _p('What you\'ll learn', 'आप क्या सीखेंगी');
  String get uiShortLessonsOrderStart => _p('Short lessons, in order - start anywhere.', 'छोटे पाठ, क्रम में — कहीं से भी शुरू कीजिए।');
  String get uiWhatCovers => _p('What this covers', 'इसमें क्या शामिल है');
  String get uiBooked => _p('✓  Booked', '✓  बुक हो गया');
  String get uiHowWouldLikeSee => _p('How would you like to see this?', 'आप इसे कैसे देखना चाहेंगी?');
  String get uiProductParentsOftenResearch => _p('This is a product parents often research — we can go deep, or keep it quick.', 'यह वह प्रोडक्ट है जिस पर माता-पिता अक्सर पढ़ते हैं — हम गहराई में जा सकते हैं, या बात छोटी रख सकते हैं।');
  String get uiTrusted => _p('TRUSTED', 'भरोसेमंद');
  String get uiReadParentvedaProductGuide => _p('Read the ParentVeda Product Guide', 'ParentVeda Product Guide पढ़िए');
  String get uiRightChildDecideSeconds => _p('Is it right for your child? Decide in 10 seconds.', 'क्या यह आपके बच्चे के लिए सही है? 10 सेकंड में तय कीजिए।');
  String get uiParentvedaProductGuide => _p('ParentVeda Product Guide', 'ParentVeda Product Guide');
  String get uiQuickProductPage => _p('Quick product page', 'छोटा प्रोडक्ट पन्ना');
  String get uiProductGuide => _p('PRODUCT GUIDE', 'PRODUCT GUIDE');
  String get uiHonestEvidenceInformedGuides => _p('Honest, evidence-informed guides for the products parents actually research — understand in 10 seconds, go deeper only if you want to.', 'उन प्रोडक्ट के लिए ईमानदार, प्रमाण पर टिकी गाइड जिन पर माता-पिता सचमुच पढ़ते हैं — 10 सेकंड में समझिए, और चाहें तो ही गहराई में जाइए।');
  String get uiGuidanceHelpChooseNever => _p('Guidance to help you choose — never a substitute for your doctor\'s advice.', 'चुनने में मदद के लिए मार्गदर्शन — आपके डॉक्टर की सलाह का विकल्प कभी नहीं।');
  String get uiCompareProducts => _p('Compare products', 'प्रोडक्ट की तुलना');
  String get uiTwoPicksSideBy => _p('Two picks, side by side.', 'दो पसंद, आमने-सामने।');
  String get uiWeOnlyGuideProducts => _p('We only guide products worth researching — more are on the way.', 'हम सिर्फ़ उन्हीं प्रोडक्ट पर गाइड देते हैं जिन पर पढ़ना बनता है — और आ रहे हैं।');
  String get uiSearchLotionDiapersStroller => _p('Search — lotion, diapers, stroller…', 'खोजिए — लोशन, डायपर, स्ट्रोलर…');
  String get uiExploreMoreIfD =>
      _p("EXPLORE MORE IF YOU'D LIKE", "चाहें तो और देखिए");
  String get uiGuidanceHelpDecideAlways => _p('Guidance to help you decide — always follow your doctor\'s advice for your child.', 'तय करने में मदद के लिए मार्गदर्शन — अपने बच्चे के लिए हमेशा डॉक्टर की सलाह मानिए।');
  String get uiBest2 => _p('BEST FOR', 'किसके लिए बेहतर');
  String get uiCompare => _p('Compare', 'तुलना');
  String get uiBuyNow => _p('Buy now', 'अभी ख़रीदें');
  String get uiParentvedaScore => _p('ParentVeda score', 'ParentVeda स्कोर');
  String get uiTake => _p('YOUR TAKE', 'आपकी राय');
  String get uiBeforeBuy => _p('BEFORE YOU BUY', 'ख़रीदने से पहले');
  String get uiWhatSGood => _p('WHAT\'S GOOD', 'क्या अच्छा है');
  String get uiWorthConsidering => _p('WORTH CONSIDERING', 'सोचने लायक़');
  String get uiNoRealDownsidesStood => _p('No real downsides stood out for this one.', 'इसमें कोई ख़ास कमी सामने नहीं आई।');
  String get uiHeadingAmazon => _p('Heading to Amazon', 'Amazon पर जा रहे हैं');
  String get uiContinueAmazon => _p('Continue to Amazon', 'Amazon पर जाइए');
  String get uiStayHere => _p('Stay here', 'यहीं रहिए');
  String get uiStillDeciding => _p('Still deciding?', 'अभी तय नहीं कर पाईं?');
  String get uiWhatMeans2 => _p('WHAT THIS MEANS FOR YOU', 'आपके लिए इसका मतलब');
  String get uiReadMore => _p('Read more', 'और पढ़ें');
  String get uiSummarisedPlainLanguageFrom => _p('Summarised in plain language from independent sources. Always confirm anything important with your paediatrician.', 'स्वतंत्र स्रोतों से आसान भाषा में सार। कुछ भी ज़रूरी हो तो अपने बाल-रोग विशेषज्ञ से ज़रूर पुष्टि कीजिए।');
  String get uiAllRatings => _p('ALL RATINGS', 'सारी रेटिंग');
  String get uiNoRatingsMatchFilter => _p('No ratings match this filter yet.', 'इस फ़िल्टर से अभी कोई रेटिंग नहीं मिली।');
  // Keepsake-card fallbacks, used when she has not named the baby yet. They sit
  // in the calligraphy slot on a card she is likely to screenshot and send to
  // her family, so they are warm rather than literal: "जो आने वाला है" carries
  // the anticipation that "बच्चा रास्ते में है" does not.
  String get uiMemoryBabyOnTheWay => _p('Baby on the way', 'जो आने वाला है');
  String get uiMemoryOurLittleOne => _p('Our little one', 'हमारा नन्हा सा');

  String get uiPersonalizationAnalytics => _p('Personalization analytics', 'Personalization analytics');
  String get uiRecording => _p('Recording', 'दर्ज हो रहा है');
  String get uiAlwaysOpenToolAsk => _p('Always on. Open a tool with an ask strip and events appear below. Nothing leaves this device.', 'हमेशा चालू। कोई ask strip वाला टूल खोलिए और नीचे घटनाएँ दिखेंगी। कुछ भी इस फ़ोन से बाहर नहीं जाता।');
  String get uiBothIdsAreRandom => _p('Both ids are random and anonymous - never a hardware identifier. The session id is new each launch; the install id persists, so a completion rate can be counted per mother rather than per view.', 'दोनों id बेतरतीब और गुमनाम हैं — कभी कोई hardware पहचान नहीं। session id हर बार नई बनती है; install id बनी रहती है, ताकि पूरा होने की दर हर बार देखने के बजाय हर माँ के हिसाब से गिनी जा सके।');
  String get uiMeasuresOurQuestionsNot => _p('This measures our questions, not you: whether a strip is worded well and placed well. It is never used to chase anyone into finishing a profile.', 'यह हमारे सवालों को नापता है, आपको नहीं: कि कोई strip ठीक शब्दों में और ठीक जगह पर है या नहीं। इसका इस्तेमाल कभी किसी को profile पूरा करने के पीछे भगाने के लिए नहीं होता।');
  String get uiProfileCompleteness => _p('Profile completeness', 'प्रोफ़ाइल कितनी पूरी है');
  String get uiClear => _p('Clear', 'साफ़ करें');
  String get uiNoEventsYetOpen => _p('No events yet. Open Symptom Companion, the Weight Tracker, Tests & Scans or the Tools hub — the ask strip fires as soon as it renders.', 'अभी कोई घटना नहीं। लक्षण साथी, वज़न ट्रैकर, टेस्ट व स्कैन या Tools hub खोलिए — ask strip दिखते ही चल जाती है।');
  String get uiPartnerAccount => _p('Partner account', 'साथी खाता');
  String get uiInviteFriend => _p('Invite a friend', 'किसी सहेली को बुलाइए');
  String get uiBothGetFreeConsultation => _p('You both get a free consultation.', 'आप दोनों को एक मुफ़्त परामर्श मिलेगा।');
  String get uiMemories3 => _p('Memories', 'यादें');
  String get uiAnnouncePregnancyBabyBeautifully => _p('Announce your pregnancy or baby, beautifully.', 'अपनी गर्भावस्था या शिशु की ख़बर, ख़ूबसूरती से सुनाइए।');
  String get uiResetWeekTesting => _p('Reset to Week 20 · testing', 'हफ़्ता 20 पर रीसेट · टेस्टिंग');
  String get uiEnterDoctorModeTesting => _p('Enter doctor mode · testing', 'डॉक्टर मोड में जाइए · टेस्टिंग');
  String get uiLogAsWhichDoctor => _p('Log in as which doctor?', 'किस डॉक्टर के रूप में लॉग इन करें?');
  String get uiResetWeekDueDate => _p('Reset to Week 20 - due date & pregnancy map cleared', 'हफ़्ता 20 पर रीसेट — डिलीवरी की तारीख़ और गर्भावस्था का नक़्शा हटा दिया गया');
  String get uiPairingCodeCopied => _p('Pairing code copied', 'जोड़ने का कोड कॉपी हो गया');
  String get uiInvitePartner => _p('Invite your partner', 'अपने साथी को जोड़िए');
  String get uiShareCodeSoPartner => _p('Share this code so your partner can pair with your journey.', 'यह कोड साझा कीजिए ताकि आपके साथी आपके सफ़र से जुड़ सकें।');
  String get uiShare => _p('Share', 'साझा करें');
  String get uiCopy => _p('Copy', 'कॉपी करें');
  String get uiWeeklyGuideRemindersTurn => _p('Weekly guide & reminders. Turn off anytime.', 'साप्ताहिक गाइड और रिमाइंडर। जब चाहें बंद कर दीजिए।');
  String get uiWeOnlyMessageNumber => _p('We only message this number for updates you turn on.', 'हम इस नंबर पर सिर्फ़ वही अपडेट भेजते हैं जो आप चालू करती हैं।');
  String get uiOrganisations => _p('ORGANISATIONS', 'संस्थाएँ');
  String get uiEmployerBenefits => _p('Employer benefits', 'कंपनी की सुविधाएँ');
  String get uiBirthClub => _p('Birth Club', 'Birth Club');
  String get uiSetDueDateFirst => _p('Set your due date first', 'पहले अपनी डिलीवरी की तारीख़ डालिए');
  String get uiFoundingMember => _p('Founding member', 'संस्थापक सदस्य');
  String get uiExpertQOpen => _p('Expert Q&A is open to you', 'विशेषज्ञ से सवाल-जवाब आपके लिए खुला है');
  String get uiClubPutsQuestionsSpecialist => _p('Your club puts questions to a specialist monthly.', 'आपका क्लब हर महीने किसी विशेषज्ञ से सवाल पूछता है।');
  String get uiWhatUnlock => _p('What you unlock', 'आपको क्या मिलता है');
  String get uiPaste => _p('Paste', 'चिपकाइए');
  String get uiApplyCode => _p('Apply code', 'कोड लगाइए');
  String get uiIDoNotHave => _p('I do not have one', 'मेरे पास नहीं है');
  String get uiInviteFriends => _p('Invite friends', 'सहेलियों को बुलाइए');
  String get uiGoingThroughNaFriend => _p(
      'Going through this with\na friend makes it easier',
      'किसी सहेली के साथ\nयह सफ़र आसान लगता है');
  String get uiCode => _p('YOUR CODE', 'आपका कोड');
  String get uiCopyCode => _p('Copy code', 'कोड कॉपी करें');
  String get uiBirthClub2 => _p('Your Birth Club', 'आपका Birth Club');
  String get uiInviteMothersDueSame => _p('Invite mothers due the same month as you.', 'उन माँओं को बुलाइए जिनकी डिलीवरी आपके ही महीने है।');
  String get uiNoInvitesYet => _p('No invites yet', 'अभी कोई निमंत्रण नहीं');
  String get uiThinkOneFriendWho => _p('Think of one friend who is pregnant too. That is usually all it takes.', 'किसी एक सहेली के बारे में सोचिए जो गर्भवती है। आम तौर पर इतना ही काफ़ी है।');
  String get uiInvites => _p('Your invites', 'आपके निमंत्रण');
  String get uiGoingThroughFriend => _p('Going through this with a friend?', 'किसी सहेली के साथ यह सफ़र?');
  String get uiLovely => _p('Lovely', 'बहुत अच्छा');
  String get uiTestNotificationSentCheck => _p('Test notification sent - check your tray', 'टेस्ट सूचना भेज दी — अपनी सूचनाओं में देखिए');
  String get uiSendTestNotificationNow => _p('Send a test notification now', 'अभी एक टेस्ट सूचना भेजिए');
  String get uiScheduleTestMinFrom => _p('Schedule a test for 1 min from now', '1 मिनट बाद के लिए एक टेस्ट तय कीजिए');
  String get uiTrustedParentingCompanion => _p('Your trusted parenting companion', 'परवरिश में आपका भरोसेमंद साथी');
  String get uiAskingVeda => _p('Asking Veda…', 'वेदा से पूछ रहे हैं…');
  String get uiConnectInternet => _p('Connect to the internet', 'इंटरनेट से जुड़िए');
  String get uiAskVedaNeedsConnection => _p('Ask Veda needs a connection to give you a personalized, up-to-date answer. Please check your internet and try again.', 'आपके हिसाब से और ताज़ा जवाब देने के लिए Ask Veda को इंटरनेट चाहिए। कृपया अपना इंटरनेट जाँचिए और फिर कोशिश कीजिए।');
  String get uiRetry => _p('Retry', 'फिर कोशिश करें');
  String get uiVideos => _p('Videos', 'वीडियो');
  String get uiWeek => _p('WEEK', 'हफ़्ता');
  String get uiWordSearch => _p('Word Search', 'शब्द खोज');
  String get uiSudoku => _p('Sudoku', 'सुडोकू');
  String get uiLogicPuzzle => _p('Logic Puzzle', 'तर्क पहेली');
  String get uiMemoryMatch => _p('Memory Match', 'याद मिलान');
  String get uiAnimatedGuideComingSoon => _p('Animated guide - coming soon', 'चलती-फिरती गाइड — जल्द आ रही है');
  String get uiWhatKegel => _p('What is Kegel?', 'Kegel क्या है?');
  String get uiWhyShouldIDo => _p('Why should I do Kegel?', 'मैं Kegel क्यों करूँ?');
  String get uiHowDoKegel => _p('How to do Kegel?', 'Kegel कैसे करें?');
  String get uiAlarms => _p('Alarms', 'अलार्म');
  String get uiAddAlarm => _p('Add alarm', 'अलार्म जोड़ें');
  String get uiAddTime => _p('Add time', 'समय जोड़ें');
  String get uiAlarmEnabled => _p('Alarm enabled', 'अलार्म चालू');
  String get uiSaveAlarm => _p('Save alarm', 'अलार्म सेव करें');
  String get uiEdit => _p('Edit', 'बदलें');
  String get uiAlarmTitle => _p('Alarm title', 'अलार्म का नाम');
  String get uiReadyBirth => _p('Ready for Birth', 'जन्म के लिए तैयार');
  String get uiFourSimpleParts => _p('Four simple parts', 'चार आसान हिस्से');
  String get uiTapAnyOneContinue => _p('Tap any one to continue — items only appear inside.', 'किसी एक पर टैप कीजिए — चीज़ें अंदर ही दिखती हैं।');
  String get uiReady => _p('ready', 'तैयार');
  String get uiEverythingPackedIfBaby => _p('Everything is packed. If your baby comes tonight, you know exactly what to grab.', 'सब पैक है। अगर आपका शिशु आज रात आ जाए, तो आपको ठीक पता है क्या उठाना है।');
  String get uiLetSPackTogether => _p('Let\'s pack together', 'आइए साथ में पैक करें');
  String get uiLabourStarted => _p('Labour started?', 'प्रसव शुरू हो गया?');
  String get uiStartAgain => _p('Start again?', 'फिर से शुरू करें?');
  String get uiClearsEverythingPackedItems => _p('This clears everything — packed items, anything you set aside, and your product choices — and brings back the full default list. This can\'t be undone.', 'यह सब कुछ हटा देगा — पैक की हुई चीज़ें, जो आपने अलग रखी थीं, और आपकी प्रोडक्ट पसंद — और पूरी शुरुआती सूची वापस ले आएगा। यह वापस नहीं हो सकता।');
  String get uiCancel3 => _p('Cancel', 'रहने दें');
  String get uiFreshStartFullList => _p('Fresh start — the full list is back.', 'नई शुरुआत — पूरी सूची वापस आ गई।');
  String get uiStartAgain2 => _p('Start again', 'फिर से शुरू करें');
  String get uiNeedOne => _p('Need one?', 'चाहिए?');
  String get uiIDonTNeed => _p('I don\'t need this', 'मुझे इसकी ज़रूरत नहीं');
  String get uiNotUs => _p('Not for us', 'हमारे लिए नहीं');
  String get uiSetAsideNotCounted => _p('Set aside and not counted. Tap to add back any time.', 'अलग रख दिया और गिनती से बाहर। जब चाहें वापस जोड़ लीजिए।');
  String get uiAddBack => _p('Add back', 'वापस जोड़ें');
  String get uiHospitalProvidesTheseNo => _p('Your hospital provides these — no need to pack', 'ये आपका अस्पताल देता है — पैक करने की ज़रूरत नहीं');
  String get uiAddOwn => _p('Add your own', 'अपनी चीज़ जोड़िए');
  String get uiAddMyBag => _p('Add to my bag', 'मेरे बैग में जोड़िए');
  String get uiSBigStepDone => _p('That’s a big step done', 'एक बड़ा काम पूरा हुआ');
  String get uiVeMovedThroughEverything => _p('You’ve moved through everything for now. Come back any time to add the last few things — you’re close.', 'अभी के लिए आप सब देख चुकी हैं। आख़िरी कुछ चीज़ें जोड़ने कभी भी लौट आइए — बस थोड़ा ही बाक़ी है।');
  String get uiBackMyReadiness => _p('Back to my readiness', 'अपनी तैयारी पर वापस');
  String get uiFirstTakeBreath => _p('First — take a breath.', 'पहले — एक गहरी साँस लीजिए।');
  String get uiHaveTimeCallDoctor => _p('You have time. Call your doctor or hospital, then take these with you. Everything else can follow later.', 'आपके पास वक़्त है। अपने डॉक्टर या अस्पताल को फ़ोन कीजिए, फिर ये चीज़ें साथ ले लीजिए। बाक़ी सब बाद में आ सकता है।');
  String get uiTakeTheseFirst => _p('Take these first', 'ये पहले ले लीजिए');
  String get uiThenLeaveHospitalVe => _p('Then leave for the hospital. You’ve got this.', 'फिर अस्पताल के लिए निकलिए। आप कर लेंगी।');
  String get uiPersonaliseBag => _p('Personalise your bag', 'अपना बैग अपने हिसाब से बनाइए');
  String get uiFewDetailsMakeSuggestions => _p('A few details make the suggestions smarter.', 'कुछ जानकारी से सुझाव और बेहतर हो जाते हैं।');
  String get uiExpectingTwins => _p('Expecting twins', 'जुड़वाँ की उम्मीद');
  String get uiWeLlSuggestFew => _p('We’ll suggest a few extras', 'हम कुछ और चीज़ें सुझा देंगे');
  String get uiHowChoose => _p('How to choose', 'कैसे चुनें');
  String get uiOurPicks => _p('Our picks', 'हमारी पसंद');
  String get uiAlsoAvailableElsewhere => _p('Also available elsewhere', 'कहीं और भी उपलब्ध');
  String get uiPreferStoreKnowThese => _p('Prefer a store you know? These open the shop directly.', 'कोई जाना-पहचाना स्टोर पसंद है? ये सीधे दुकान खोलते हैं।');
  String get uiIVeAlreadyGot => _p('I\'ve already got one', 'मेरे पास पहले से है');
  String get uiBestOverall => _p('Best overall', 'सबसे बेहतर');
  String get uiWhyWeRecommend => _p('Why we recommend it', 'हम इसे क्यों सुझाते हैं');
  String get uiThingsConsider => _p('Things to consider', 'ध्यान देने की बातें');
  String get uiPersonalise => _p('Personalise', 'अपने हिसाब से');
  String get uiWhatWouldLikeAdd => _p('What would you like to add?', 'आप क्या जोड़ना चाहेंगी?');
  String get uiNothingFilterYet => _p('Nothing in this filter yet.', 'इस फ़िल्टर में अभी कुछ नहीं।');
  String get uiMedicalDisclaimer => _p('Medical disclaimer', 'मेडिकल सूचना');
  String get uiWhat => _p('What it is', 'यह क्या है');
  String get uiWhySDone => _p('Why it\'s done', 'यह क्यों किया जाता है');
  String get uiWhen => _p('When', 'कब');
  String get uiPreparation => _p('Preparation', 'तैयारी');
  String get uiProcedure => _p('Procedure', 'प्रक्रिया');
  String get uiUnderstandingReportParameters => _p('Understanding your report parameters', 'अपनी रिपोर्ट के मानक समझिए');
  String get uiHowDoIInterpret => _p('How do I interpret the test results?', 'टेस्ट के नतीजे कैसे समझूँ?');
  String get uiWhat2 => _p('What is it?', 'यह क्या है?');
  String get uiWhyDoesHappen => _p('Why does it happen?', 'यह क्यों होता है?');
  String get uiSymptoms => _p('Symptoms', 'लक्षण');
  String get uiDiagnosis => _p('Diagnosis', 'निदान');
  String get uiPregnancyImplications => _p('Pregnancy implications', 'गर्भावस्था पर असर');
  String get uiManagement => _p('Management', 'सँभाल');
  String get uiWhenContactDoctor => _p('When to contact your doctor', 'डॉक्टर से कब संपर्क करें');
  String get uiFaq => _p('FAQ', 'आम सवाल');
  String get uiWeek2 => _p('Week 6 of 40', 'हफ़्ता 6 / 40');
  String get uiTrimester => _p('Trimester 1', 'पहली तिमाही');
  String get uiFeb => _p('12 – 18 FEB', '12 – 18 फ़रवरी');
  String get uiWeeks => _p('WEEKS', 'हफ़्ते');
  String get uiWeek3 => _p('THIS WEEK', 'इस हफ़्ते');
  String get uiHowBigAmI => _p('How big am I?', 'मैं कितना बड़ा हूँ?');
  String get uiBeatingHeart => _p('THE BEATING HEART', 'धड़कता हुआ दिल');
  String get uiIAmAboutSize => _p('I am about the size of', 'मैं लगभग इतना बड़ा हूँ');
  String get uiPomegranateSeed => _p('a pomegranate seed', 'अनार का एक दाना');
  String get uiHeartNowBeatingRhythmically => _p('Your heart is now beating rhythmically, and major organs are beginning to take shape.', 'शिशु का दिल अब एक लय में धड़क रहा है, और मुख्य अंग आकार लेने लगे हैं।');
  String get uiMaaMyLittleHeart => _p('“Maa, my little heart is beating steadily and helping me grow stronger every day.”', '“माँ, मेरा नन्हा दिल लगातार धड़क रहा है और हर दिन मुझे और मज़बूत बना रहा है।”');
  String get uiUpcomingMilestones => _p('Upcoming Milestones', 'आने वाले पड़ाव');
  String get uiViewFullTimeline => _p('VIEW FULL TIMELINE', 'पूरी टाइमलाइन देखिए');
  String get uiDailyReadNutrition => _p('DAILY READ · NUTRITION', 'आज का पाठ · पोषण');
  String get uiSurvivingMorningSickness => _p('Surviving Morning Sickness', 'सुबह की मतली से पार पाना');
  String get uiEatBeforeFeelHungry => _p('Eat before you feel hungry. An empty stomach often makes nausea worse.', 'भूख लगने से पहले खा लीजिए। ख़ाली पेट अक्सर मतली बढ़ा देता है।');
  String get uiLength => _p('LENGTH', 'लंबाई');
  String get uiWeight => _p('WEIGHT', 'वज़न');
  String get uiTinyFeaturesBegin => _p('Tiny Features Begin', 'नन्हे नक़्श बनने लगे');
  String get uiOfficiallyBaby => _p('Officially A Baby', 'अब आधिकारिक रूप से शिशु');
  String get uiFirstTrimesterComplete => _p('First Trimester Complete', 'पहली तिमाही पूरी');
  String get uiMain => _p('MAIN', 'मुख्य');
  String get uiList => _p('LIST', 'सूची');
  String get uiCounters => _p('COUNTERS', 'गिनती');
  String get uiSettings => _p('SETTINGS', 'सेटिंग');
  String get uiHowShowUp => _p('HOW TO SHOW UP', 'साथ कैसे दें');
  String get uiNew => _p('NEW', 'नया');
  String get uiPlayBabyVoice => _p('Play baby voice', 'शिशु की आवाज़ चलाइए');
  String get uiFruit => _p('Fruit', 'फल');

  // Found on a device, not by a scanner. These shipped as
  // `lang.isEnglish ? 'Scans' : 'Scans'` — a ternary whose branches are
  // identical, so the Hindi build rendered the English. Same defect as
  // `_t(x, x)`, wearing a shape no audit here was looking for.
  String get uiScans => _p('Scans', 'जाँचें');
  String get uiSelfCare => _p('Self-care', 'अपनी देखभाल');
  String get uiBaby => _p('Baby', 'शिशु');

  // =========================================================================
  //  INLINE UI COPY - lifted out of widgets so it can be translated
  // =========================================================================
  String get uiKmQxPdvr => _p('KM7QX2PDVR', 'KM7QX2PDVR');
  String get uiAbcd => _p('ABCD234', 'ABCD234');

  // =========================================================================
  //  PREPARE TAB - screen chrome
  // -------------------------------------------------------------------------
  //  The Prepare tab's DATA (lib/data/prepare_data.dart) was translated long
  //  before its chrome was. Opening the app in Hindi showed Hindi programme
  //  titles inside English scaffolding: English eyebrows, English buttons,
  //  English footers. These are the ~150 literals that were sitting bare in
  //  lib/screens/prepare/*.dart.
  //
  //  Prefixed `prep` rather than `ui` purely so the block stays greppable as
  //  one feature; the shape is the same `_p(english, 'हिन्दी')` as everything
  //  above it. Programme names, prices and brands are NOT here - they come
  //  from data and are identical in both languages by nature.
  // =========================================================================

  // ---- shared / booking sheet ---------------------------------------------
  String get prepBooking => _p('Booking', 'बुकिंग');
  String get prepBack => _p('Back', 'वापस');
  String get prepReserveYourSpot => _p('Reserve your spot', 'अपनी जगह रोक लीजिए');
  String get prepConfirm => _p('Confirm', 'पक्का कीजिए');
  String prepSavedToList(String title) => _p(
      '“$title” is saved to your Prepare list. We\'ll remind you before it starts.',
      '“$title” आपकी तैयारी सूची में सेव हो गया। शुरू होने से पहले हम याद दिला देंगे।');

  // The bolded run inside the "You're at **30 weeks** - ..." banners. It is a
  // separate span, so it needs its own pair; the surrounding halves are
  // uiRe / uiExactlyWhenMostMums and friends above.
  String get prepThirtyWeeksBold => _p('30 weeks', '30 हफ़्ते');
  String prepMonthBold(int m) => _p('month $m', '$m वें महीने');

  // ---- hub -----------------------------------------------------------------
  String get prepHubEyebrow => _p('30 weeks · third trimester', '30 हफ़्ते · तीसरी तिमाही');
  String get prepTagMasterclass => _p('Masterclass', 'मास्टरक्लास');
  String get prepTagCohortStartsMon => _p('Cohort · starts Mon', 'कोहॉर्ट · सोमवार से');
  String get prepTileCoursesSub =>
      _p('Self-paced courses, live cohorts & masterclasses.',
          'अपनी रफ़्तार वाले कोर्स, लाइव कोहॉर्ट और मास्टरक्लास।');
  String prepProgramsCount(int n) => _p('$n programs', '$n प्रोग्राम');
  String get prepTileBirthingSub =>
      _p('Everything for the big day.', 'बड़े दिन के लिए सब कुछ।');
  String get prepTileBirthingCount => _p('6-class course', '6 क्लास का कोर्स');
  String get prepTileYogaSub => _p('Trimester-safe classes, live or recorded.',
      'तिमाही के हिसाब से सुरक्षित क्लास — लाइव या रिकॉर्डेड।');
  String get prepTileYogaCount => _p('Prenatal & breath', 'गर्भावस्था योग और साँस');
  String get prepTileNutritionSub =>
      _p('A plan built around you, made yours by an expert.',
          'आपके हिसाब से बना प्लान, जिसे एक विशेषज्ञ आपका बनाती हैं।');
  String get prepTileNutritionCount => _p('Plan + consult', 'प्लान + परामर्श');
  String get prepYogaEyebrow => _p('ParentVeda Yoga', 'ParentVeda योग');
  String get prepYogaHeroTitle => _p('Prenatal yoga & classes', 'गर्भावस्था योग और क्लास');
  String get prepYogaIntro => _p(
      'Trimester-safe movement, labour breathing and calm - live with a teacher, or on your own time.',
      'तिमाही के हिसाब से सुरक्षित हलचल, प्रसव के लिए साँस और शांति — शिक्षिका के साथ लाइव, या अपने समय पर।');

  // ---- masterclasses list ---------------------------------------------------
  String get prepEyebrowLiveExpert => _p('Live with an expert', 'विशेषज्ञ के साथ लाइव');
  String get prepFreeOn => _p(' · free on ', ' · मुफ़्त — ');

  /// What sits beside a price now that the membership does not exist. Says the
  /// one thing she actually wants to know about a course price: that it is not
  /// a subscription.
  String get prepOneTimeNote =>
      _p('  ·  one-time', '  ·  एक बार');
  String get prepFreeOnPlusShort =>
      _p('one-time', 'एक बार');
  String get prepFooterMasterclasses => _p(
      'Always live with an expert. The recording is yours forever.',
      'हमेशा विशेषज्ञ के साथ लाइव। रिकॉर्डिंग हमेशा के लिए आपकी।');
  String prepWithCoach(String name) => _p('With $name', '$name के साथ');
  String prepWithCoaches(String a, String b) =>
      _p('With $a & $b', '$a और $b के साथ');

  // ---- consultations list ---------------------------------------------------
  String get prepEyebrowPrivate => _p('Private & personal', 'निजी और आपकी अपनी');
  String get prepHowItWorks => _p('How it works', 'यह कैसे चलता है');
  String get prepBook => _p('Book', 'बुक कीजिए');
  String get prepFooterConsultations => _p(
      'Verified specialists only - obstetric & paediatric, never generalists. Real ratings from real mothers. Transparent pricing, no surprises.',
      'सिर्फ़ सत्यापित विशेषज्ञ — obstetric और paediatric, कभी सामान्य डॉक्टर नहीं। असली माँओं की असली राय। क़ीमत साफ़-साफ़, कोई छिपी बात नहीं।');

  // ---- cohorts list ---------------------------------------------------------
  String get prepEyebrowTogether => _p('Together, guided', 'साथ-साथ, राह दिखाते हुए');
  String get prepYourCoachFallback => _p('your coach', 'आपकी कोच');
  String get prepWhatsInsideEveryCohort =>
      _p('What\'s inside every cohort', 'हर कोहॉर्ट में क्या मिलता है');
  String get prepFooterCohorts => _p(
      'Small cohorts, real accountability - our most-loved way to prepare.',
      'छोटे कोहॉर्ट, सच्ची ज़िम्मेदारी — तैयारी का हमारा सबसे पसंदीदा तरीक़ा।');

  // ---- birthing classes -----------------------------------------------------
  String get prepEyebrowBigDay => _p('For the big day', 'बड़े दिन के लिए');
  String get prepBirthingWhen => _p('6 classes · self-paced + monthly live Q&A',
      '6 क्लास · अपनी रफ़्तार से + हर महीने लाइव सवाल-जवाब');
  String get prepEnrollInCourse =>
      _p('Enroll in this course', 'इस कोर्स में दाख़िला लीजिए');
  String get prepEnrollNow => _p('Enroll now', 'अभी दाख़िला लीजिए');
  // The educator credit reads NAME-first in both languages. Hindi puts "के साथ"
  // after the name, so a leading "With " span would have had to translate to an
  // empty string - a hollow pair. Reordering keeps one span list for both.
  String get prepCertifiedChildbirthEducator =>
      _p(' — certified childbirth educator ', ' के साथ — प्रमाणित childbirth educator ');
  String get prepObReviewed => _p('(OB-reviewed)', '(OB की जाँची हुई)');
  String get prepEnrolledCheck => _p('✓ Enrolled', '✓ दाख़िला हो गया');
  String get prepEnrolled => _p('Enrolled', 'दाख़िला हो गया');
  String get prepStartWatching => _p('Start watching', 'देखना शुरू कीजिए');
  String get prepFreePreview => _p('Free preview', 'मुफ़्त झलक');
  String get prepEnrollUnlockAll =>
      _p('Enroll - unlock all 6 classes', 'दाख़िला लीजिए — छहों क्लास खुल जाएँगी');
  String get prepFooterBirthing => _p(
      'Taught by a certified childbirth educator, reviewed by an OB. Watch at your pace, rewatch anytime, and bring questions to the live Q&A.',
      'एक प्रमाणित childbirth educator सिखाती हैं, और एक OB ने जाँचा है। अपनी रफ़्तार से देखिए, जब चाहें दोबारा देखिए, और सवाल लाइव सवाल-जवाब में ले आइए।');

  // ---- cohort detail --------------------------------------------------------
  String get prepFactProgramme => _p('programme', 'प्रोग्राम');
  String get prepFlexible => _p('Flexible', 'लचीला');
  String get prepFactStart => _p('start', 'शुरुआत');
  String get prepFactTiming => _p('timing', 'समय');
  String get prepLive => _p('Live', 'लाइव');
  String get prepPlusPeerGroup => _p('+ peer group', '+ साथी-समूह');
  String get prepThePlan => _p('The plan', 'योजना');
  String get prepYourCoach => _p('Your coach', 'आपकी कोच');
  String get prepFromMumsWhoDidIt =>
      _p('From mums who did it', 'जिन माँओं ने यह किया, उनसे');
  String get prepJoinThisCohort => _p('Join this cohort', 'इस कोहॉर्ट में जुड़िए');
  String get prepJoinCohort => _p('Join cohort', 'कोहॉर्ट में जुड़िए');

  // ---- consultation detail --------------------------------------------------
  String prepMothersSeen(int n) => _p('$n mothers', '$n माँएँ');
  String get prepLangHindi => _p('Hindi', 'हिंदी');
  String get prepLangEnglish => _p('English', 'अंग्रेज़ी');
  String get prepVideoCall => _p('Video call', 'वीडियो कॉल');
  String prepAbout(String name) => _p('About $name', '$name के बारे में');
  String get prepSheCanHelpWith =>
      _p('She can help with', 'वे इनमें मदद कर सकती हैं');
  String get prepChooseATime => _p('Choose a time', 'समय चुनिए');
  String get prepFromMothersSheSeen =>
      _p('From mothers she\'s seen', 'जिन माँओं को उन्होंने देखा है, उनसे');
  String get prepFooterConsultDetail => _p(
      'Verified specialist. Transparent pricing, no surprises.',
      'सत्यापित विशेषज्ञ। क़ीमत साफ़-साफ़, कोई छिपी बात नहीं।');
  String get prepThirtyMinCall => _p('30-min call', '30 मिनट की कॉल');
  String prepBookFor(String slot) => _p('Book for $slot', '$slot के लिए बुक कीजिए');
  String get prepBooked => _p('Booked', 'बुक हो गया');
  String get prepThirtyMinVideoCall =>
      _p('30-min video call', '30 मिनट की वीडियो कॉल');
  String get prepConfirmYourConsult =>
      _p('Confirm your consult', 'अपना परामर्श पक्का कीजिए');
  String get prepConfirmBooking => _p('Confirm booking', 'बुकिंग पक्की कीजिए');

  // ---- masterclass detail ---------------------------------------------------
  String prepIntroOf(String title) => _p('$title - intro', '$title — परिचय');
  String get prepNinetySecPreview => _p('90-sec preview', '90 सेकंड की झलक');
  String get prepWalkAwayWith =>
      _p('What you\'ll walk away with', 'आप क्या लेकर जाएँगी');
  String get prepMeetYourCoaches => _p('Meet your coaches', 'अपनी कोचों से मिलिए');
  String get prepMeetYourCoach => _p('Meet your coach', 'अपनी कोच से मिलिए');
  String get prepWhatMothersSay => _p('What mothers say', 'माँएँ क्या कहती हैं');
  String get prepCommonQuestions => _p('Common questions', 'आम सवाल');
  String get prepFooterMasterclassDetail => _p(
      'Led by a verified expert.',
      'एक सत्यापित विशेषज्ञ चलाती हैं।');
  String get prepReserved => _p('Reserved', 'जगह रुक गई');
  String get prepReserveYourSeat =>
      _p('Reserve your seat', 'अपनी सीट रोक लीजिए');
  String get prepReserveMySeat => _p('Reserve my seat', 'मेरी सीट रोक दीजिए');

  // ---- courses & cohorts ----------------------------------------------------
  String get prepEyebrowLearnExperts =>
      _p('Learn with the experts', 'विशेषज्ञों से सीखिए');
  String get prepSearchHint => _p('Search birth, breathing, an expert…',
      'जन्म, साँस, कोई विशेषज्ञ खोजिए…');
  String get prepAll => _p('All', 'सब');
  String get prepAllTopics => _p('All topics', 'सभी विषय');
  String get prepNothingMatchesYet =>
      _p('NOTHING MATCHES YET', 'अभी कुछ नहीं मिला');
  String prepProgramCount(int n) =>
      _p(n == 1 ? '1 PROGRAM' : '$n PROGRAMS', n == 1 ? '1 प्रोग्राम' : '$n प्रोग्राम');
  String get prepLiveBadge => _p('LIVE', 'लाइव');
  String get prepClearFilters => _p('Clear filters', 'फ़िल्टर हटाइए');

  // ---- nutrition funnel -----------------------------------------------------
  String get prepEyebrowEatWell => _p('Eat well, for two', 'दो के लिए अच्छा खाइए');
  String get prepQTrimester =>
      _p('Which trimester are you in?', 'आप कौन-सी तिमाही में हैं?');
  String get prepQFocus => _p('What\'s your main focus right now?',
      'अभी आपका मुख्य लक्ष्य क्या है?');
  String get prepQDiet => _p('How do you eat?', 'आप कैसा खाना खाती हैं?');
  String get prepPickFocusToContinue =>
      _p('Pick a focus to continue', 'आगे बढ़ने के लिए एक लक्ष्य चुनिए');
  String get prepSeeMyPlans =>
      _p('See my recommended plans', 'मेरे लिए सुझाए प्लान देखिए');
  String get prepFooterNutritionAssessment => _p(
      'Your answers only shape your recommendation - nothing is shared without you.',
      'आपके जवाब सिर्फ़ आपका सुझाव तय करते हैं — आपके बिना कुछ भी किसी से साझा नहीं होता।');
  String get prepEyebrowMatchedToYou => _p('Matched to you', 'आपके लिए चुना हुआ');
  String get prepBackPlans => _p('Plans', 'प्लान');
  String get prepBookMyNutritionist =>
      _p('Book my nutritionist', 'अपनी nutritionist बुक कीजिए');
  // The purple run inside "Every plan is finalised with a **registered
  // nutritionist** in a 1:1 consult". `nutritionist` stays Latin because it is
  // a credential a mother reads off a clinic board, like `anomaly scan`, and
  // because every shipped Hindi string around it already spells it that way.
  // The qualifier is translated, so this is a real pair and not a hollow one.
  String get prepRegisteredNutritionist =>
      _p('registered nutritionist', 'रजिस्टर्ड nutritionist');
  String prepBuiltFromPlan(String plan) => _p(
      'Built from $plan and confirmed with your nutritionist. It updates after your consult.',
      '$plan से बना है, और आपकी nutritionist ने इसे देखा है। परामर्श के बाद यह अपने आप बदल जाएगा।');
  String prepStartingMenu(String weeks) =>
      _p('$weeks · your starting menu', '$weeks · आपका शुरुआती मेन्यू');
  String get prepDownloadFullPlan =>
      _p('Download full plan', 'पूरा प्लान डाउनलोड कीजिए');
  String get prepYourPlanPdf => _p('Your plan PDF', 'आपका प्लान PDF');
  String get prepBackToPrepare => _p('Back to Prepare', 'तैयारी पर वापस');
  String get prepFooterDietPlan => _p(
      'This is a preview plan. Payments and full meal plans go live with the nutrition backend.',
      'यह अभी एक झलक-प्लान है। भुगतान और पूरे खाने के प्लान जल्द चालू होंगे।');

  // ---- program detail -------------------------------------------------------
  String get prepAddToYourLibrary =>
      _p('Add to your library', 'अपनी लाइब्रेरी में जोड़िए');
  String get prepFactSeatsLeft => _p('seats left', 'सीटें बाक़ी');
  String get prepFactLiveLower => _p('live', 'लाइव');
  String get prepLiveQa => _p('Live Q&A', 'लाइव सवाल-जवाब');
  String get prepIncludedLower => _p('included', 'शामिल');
  String get prepForever => _p('Forever', 'हमेशा');
  String get prepRecording => _p('recording', 'रिकॉर्डिंग');
  String get prepRecorded => _p('recorded', 'रिकॉर्डेड');
  String get prepRated => _p('rated', 'रेटिंग');
  String get prepYours => _p('yours', 'आपका');
  String get prepLessonsLabel => _p('lessons', 'पाठ');
  String get prepMinutesLabel => _p('minutes', 'मिनट');
  String get prepLifetime => _p('lifetime', 'हमेशा के लिए');
  String get prepCourseLabel => _p('course', 'कोर्स');
  String prepPreviewOf(String title) => _p('$title - preview', '$title — झलक');
  String get prepYourInstructor => _p('Your instructor', 'आपकी शिक्षिका');
  String get prepYourSchedule => _p('Your schedule', 'आपका कार्यक्रम');
  String get prepWhenItRuns => _p('When it runs', 'यह कब चलता है');
  String prepMinutes(int n) => _p('$n min', '$n मिनट');
  String prepMinutesUnlocksLater(int n) => _p(
      '$n min · unlocks later, open anyway', '$n मिनट · बाद में खुलेगा, फिर भी खोलिए');
  String get prepIncluded => _p('Included', 'शामिल है');
  String get prepOnParentVedaPlus => _p('lifetime access', 'हमेशा के लिए access');
  String prepLedByVerifiedExpert(String note) => _p(
      'Led by a verified expert. $note.', 'एक सत्यापित विशेषज्ञ चलाती हैं। $note।');

  // ---- prenatal yoga (retired from the hub, still reachable in the module) ---
  String get prepEyebrowMoveWithMonth =>
      _p('Move with your month', 'अपने महीने के साथ चलिए');
  String get prepFreeWithPlus =>
      _p('Lifetime access', 'हमेशा के लिए access');
  String get prepThisMonthForYou =>
      _p('This month for you', 'इस महीने आपके लिए');
  String prepMonthN(int m) => _p('Month $m', 'महीना $m');
  String prepSessionCount(int n) =>
      _p(n == 1 ? '1 session' : '$n sessions', n == 1 ? '1 सेशन' : '$n सेशन');
  String get prepSafeForYou => _p('Safe for you', 'आपके लिए सुरक्षित');
  String get prepFooterYoga => _p(
      'Certified prenatal instructor. A calm, safe practice for all nine months.',
      'प्रमाणित गर्भावस्था-योग प्रशिक्षक। नौ महीने के लिए एक शांत, सुरक्षित अभ्यास।');

  // ---- progressive profiling (ProfileAskStrip + the pregnancy profile) ------
  //  One question, its payoff, and the two ways out. Every strip states what
  //  answering unlocks - a question that cannot explain itself is not asked -
  //  so each `ask*Q` has an `ask*Why` beside it and they translate as a pair.
  //  The pregnancy profile screen asks the SAME four questions in full-card
  //  form, so both surfaces read from these rather than drifting apart.
  String get askNotNow => _p('Not now', 'अभी नहीं');
  /// Replaces "Not now" once she has picked something in a multi-select — at
  /// that point the button no longer means "skip", and the Hindi has to move
  /// too or the strip contradicts itself mid-answer.
  String get askDone => _p('Done', 'हो गया');

  String get askHealthQ => _p('Has your doctor mentioned anything to watch?',
      'क्या आपके डॉक्टर ने ध्यान रखने लायक़ कुछ बताया है?');
  String get askHealthWhy => _p(
      'We use this to pick reads, foods and answers that fit you - and to skip the ones that do not.',
      'इससे हम आपके लिए सही पढ़ने की चीज़ें, खाना और जवाब चुनते हैं — और जो आप पर लागू नहीं होते, वे छोड़ देते हैं।');

  String get askPrioritiesQ => _p('What would you most like help with?',
      'आप किस बात में सबसे ज़्यादा मदद चाहेंगी?');
  String get askPrioritiesWhy => _p(
      'The tools you pick move to the top of this page.',
      'आप जो चुनेंगी, वे टूल इसी पन्ने पर सबसे ऊपर आ जाएँगे।');

  String get askDietQ => _p('How do you eat?', 'आपका खानपान कैसा है?');
  String get askDietWhy => _p(
      'So the meals and foods we suggest are ones you would actually eat.',
      'ताकि हम जो खाना सुझाएँ, वह वाक़ई वही हो जो आप खाती हैं।');

  String get askParityQ =>
      _p('Is this your first baby?', 'क्या यह आपका पहला गर्भ है?');
  String get askParityWhy => _p(
      'Changes how much we explain, and what we compare things to.',
      'इससे तय होता है कि हम कितना समझाएँ, और किस से तुलना करें।');

  // The pregnancy profile screen's fuller wording for the two multi-select
  // cards. Same questions as the strips above, but a card has room to say
  // "tap as many as apply", which a one-line strip does not.
  String get askHealthQLong => _p('Has your doctor mentioned any of these?',
      'क्या आपके डॉक्टर ने इनमें से कुछ बताया है?');
  String get askHealthWhyLong => _p(
      'We use these to pick articles, foods and answers that fit you. Tap any that apply.',
      'इनसे हम आपके लिए सही लेख, खाना और जवाब चुनते हैं। जो भी लागू हो, उस पर टैप कीजिए।');
  String get askPrioritiesWhyLong => _p(
      'Pick as many as you like. These float to the top of your tools and reads.',
      'जितने चाहें चुनिए। ये आपके टूल और पढ़ने की चीज़ों में ऊपर आ जाएँगे।');
  String get askDietWhyLong => _p(
      'Shapes recipes and food suggestions, now and after the baby arrives.',
      'इससे रेसिपी और खाने के सुझाव तय होते हैं — अभी भी, और शिशु के आने के बाद भी।');
}
