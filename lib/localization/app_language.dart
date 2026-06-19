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
}

/// Fixed UI strings (chrome). Construct with the active language and read the
/// getters: `final s = S(lang); Text(s.howBig);`.
class S {
  const S(this.lang);
  final AppLanguage lang;

  bool get _e => lang.isEnglish;
  T _p<T>(T en, T hi) => _e ? en : hi;

  // ---- App / screen chrome -------------------------------------------------
  String get appName => 'ParentVeda';
  String weekOf(int w, int total) => _p('Week $w of $total', 'Hafta $w / $total');
  String get wkShort => _p('wk', 'hafta');
  String get weekWord => _p('Week', 'Hafta');
  String get weeksLabel => _p('weeks', 'hafte');
  String get noContent =>
      _p('No content for this week yet.', 'Is hafte ke liye abhi content nahi hai.');
  String get loadError =>
      _p('We could not load this week.', 'Hum yeh hafta load nahi kar paaye.');
  String get tryAgain => _p('Try again', 'Dobara koshish karein');

  // ---- Locked week ---------------------------------------------------------
  String get onItsWay => _p('is gently on its way', 'dheere-dheere aa raha hai');
  String get openNextWeek =>
      _p('This chapter opens next week. One day at a time, Maa.',
         'Yeh chapter agle hafte khulega. Ek-ek din karke, Maa.');
  String openInWeeks(int n) => _p(
      'This chapter opens in $n weeks. There is no rush — enjoy where you are today.',
      'Yeh chapter $n hafton mein khulega. Koi jaldi nahi — aaj jahan hain, use enjoy karein.');
  String youAreInWeek(int w) =>
      _p("You're in week $w right now", 'Abhi aap hafte $w mein hain');

  // ---- Card 1 · Size -------------------------------------------------------
  String get sizeEyebrow => _p('This week', 'Is hafte');
  String get howBig => _p('How big am I?', 'Main kitna bada hoon?');
  String get sizeOf => _p('I am about the size of', 'Main lagbhag itna bada hoon —');
  String get lengthLabel => _p('Length', 'Lambai');
  String get weightLabel => _p('Weight', 'Wazan');

  // ---- Card 2 · Baby update ------------------------------------------------
  String get babyEyebrow => _p("Baby's update", 'Baby ka update');
  String get whatImDoing => _p('What I am doing', 'Main kya kar raha hoon');
  String get ownPace =>
      _p('Every baby grows at their own gentle pace.',
         'Har baby apni apni pyaari raftaar se badhta hai.');
  String get phaseReassurance => _p('Reassurance', 'Tasalli');
  String get phaseBonding => _p('Bonding', 'Bonding');
  String get phasePreparation => _p('Preparation', 'Taiyaari');
  String get phaseDefault => _p('Your journey', 'Aapka safar');

  // ---- Card 3 · Mother body ------------------------------------------------
  String get motherEyebrow => _p('For you, Maa', 'Aapke liye, Maa');
  String get yourBody => _p('Your body this week', 'Is hafte aapka body');
  String get gentleHeadsUp => _p('Gentle heads-up', 'Pyaari si yaad-dahaani');
  String get headsUpFooter => _p(
      'If anything here worries you, call your doctor. You are doing beautifully.',
      'Inme se kuch bhi pareshaan kare toh doctor ko call karein. Aap bahut achha kar rahi hain.');

  // ---- Card 4 · Nutrition --------------------------------------------------
  String get nutritionEyebrow => _p('Nourishment', 'Poshan');
  String get whatToEat => _p('What to eat', 'Kya khaayein');
  String get foodsToFavour =>
      _p('Foods to favour this week', 'Is hafte ye cheezein khaayein');
  String get ayurvedicTip =>
      _p("Ayurvedic · Mother's care tip", 'Ayurvedic · Maa ki care tip');

  // ---- Card 5 · Do / Skip / Myth ------------------------------------------
  String get guidanceEyebrow => _p('Gentle guidance', 'Pyaari salah');
  String get doSkipTruth => _p('Do, skip & truth', 'Karein, na karein & sach');
  String get doThisWeek => _p('Do this week', 'Is hafte karein');
  String get skipThisWeek => _p('Skip this week', 'Is hafte na karein');
  String get mythBuster => _p('Myth-buster', 'Myth-buster');

  // ---- Card 6 · Garbh Sanskar ---------------------------------------------
  String get garbhSanskar => 'Garbh Sanskar'; // proper noun, same in both
  String get bondingRitual => _p('Bonding ritual', 'Bonding ka pal');
  String get todaysAffirmation =>
      _p("Today's affirmation", 'Aaj ka affirmation');
  String ragaNamed(String raga) => _p('Raga $raga', 'Raag $raga');
  String get soothingRaga =>
      _p('Soothing prenatal raga', 'Sukoon dene wala raag');
  String get audioComingSoon => _p(
      'Your guided raga & affirmations begin in the bonding phase. For now, gently repeat the affirmation above.',
      'Aapka guided raag aur affirmations bonding phase mein shuru honge. Abhi ke liye, upar diya affirmation pyaar se dohraayein.');

  // ---- Card 7 · Partner ----------------------------------------------------
  String get partnerEyebrow => _p('For your partner', 'Aapke partner ke liye');
  String get shareJourney => _p('Share the journey', 'Safar share karein');
  String get thisWeekTogether =>
      _p('This week, together', 'Is hafte, saath mein');
  String get forwardWhatsapp => _p(
      'Forward to Partner via WhatsApp', 'Partner ko WhatsApp par bhejein');
  String get partnerPrivacy => _p(
      'We never message anyone for you — you choose where it goes.',
      'Hum aapki taraf se kisi ko message nahi karte — aap khud chunte hain kahan bhejna hai.');
  String partnerShareHeader(int w) =>
      _p('ParentVeda · Week $w', 'ParentVeda · Hafta $w');
  String get partnerShareFooter =>
      _p('— Sent with love from ParentVeda', '— ParentVeda se pyaar ke saath');
  String partnerShareSubject(int w) => _p(
      'A note from our Week $w journey', 'Hamare Hafta $w ke safar se ek note');
  String get shareFailed =>
      _p('Could not open the share sheet.', 'Share sheet nahi khul paayi.');

  // ===========================================================================
  //  Rich (PDF-schema) card strings
  // ===========================================================================

  // Baby update
  String get funFact => _p('Fun fact', 'Mazedaar baat');

  // Mom journey
  String get physicalChanges => _p('Physical changes', 'Sharirik badlaav');
  String get howYouFeel => _p('How you may feel', 'Aap kaisa feel kar sakti hain');
  String get commonSymptoms => _p('Common symptoms', 'Aam lakshan');
  String get selfCare => _p('Self-care', 'Apna khayal');
  String get reassuranceLabel => _p('A gentle reminder', 'Ek pyaari yaad');

  // Nutrition
  String get nutritionThemeLabel => _p('Theme', 'Theme');
  String get whyNow => _p('Why now', 'Abhi kyun');
  String get superfoodOfWeek =>
      _p('Indian superfood of the week', 'Is hafte ka Indian superfood');
  String get howToEat => _p('How to enjoy it', 'Kaise khaayein');
  String get mealIdeaLabel => _p('Meal idea', 'Meal idea');
  String get nourishTwoLives =>
      _p('You are nourishing two lives today.', 'Aaj aap do zindagiyon ko paal rahi hain.');

  // Action plan
  String get mythLabel => _p('Myth', 'Myth');
  String get truthLabel => _p('Truth', 'Sach');

  // Garbh Sanskar
  String get reflectMoment => _p('A moment to reflect', 'Sochne ka ek pal');

  // Reflect & Remember
  String get reflectEyebrow => _p('A memory for later', 'Aage ke liye yaad');
  String get reflectTitle => _p('Reflect & remember', 'Yaadein sahejein');
  String get reflectionLabel => _p('Reflection', 'Soch-vichaar');
  String get journalLabel => _p('Journal prompt', 'Journal prompt');
  String get photoLabel => _p('Photo prompt', 'Photo prompt');

  // Share Your Journey (partner, last card)
  String get shareJourneyTitle => _p('Share your journey', 'Apna safar share karein');
  String get whatSheMayFeel => _p('What she may feel', 'Woh kaisa feel kar sakti hai');
  String get whatYouCanDo => _p('What you can do', 'Aap kya kar sakte hain');
  String get oneMission => _p("This week's one mission", 'Is hafte ka ek mission');

  // Journal & memories
  String get tapToWrite => _p('Tap to write…', 'Likhne ke liye tap karein…');
  String get saveToJournal => _p('Save to Journal', 'Journal mein save karein');
  String get writePlaceholder =>
      _p('Pour your heart out here…', 'Yahan apne dil ki baat likhein…');
  String get journalSaved => _p('Saved to your journal 💜', 'Aapke journal mein save ho gaya 💜');
  String get myJournal => _p('Your journal', 'Aapka journal');
  String get memoriesTitle => _p('Memories', 'Yaadein');
  String get addPhoto => _p('Add photo', 'Photo add karein');
  String get noMemories => _p(
      'Your memories will appear here as you add them.',
      'Aapki yaadein yahan dikhengi jaise aap inhe add karengi.');
  String get edit => _p('Edit', 'Edit karein');
  String get delete => _p('Delete', 'Delete karein');
  String get cameraFailed =>
      _p('Could not open the camera.', 'Camera nahi khul paaya.');
  String entriesCount(int n) =>
      _p(n == 1 ? '1 entry' : '$n entries', n == 1 ? '1 entry' : '$n entries');

  // ---- Weekly journal (single "How was your last week?" prompt) ------------
  String get howWasYourWeek =>
      _p('How was your last week?', 'Aapka pichhla hafta kaisa raha?');
  String get journalCardSubtitle => _p(
      'Write it down, or just speak — and keep up to two photos with it.',
      'Likh lein, ya bas bol dein — saath mein do tak photo bhi rakhein.');
  String get writeOrSpeak => _p('Write or speak', 'Likhein ya bolein');
  String get tapToShareWeek =>
      _p('Tap to share how this week felt', 'Tap karke is hafte ka haal likhein');
  String get tapMicToSpeak =>
      _p('Tap the mic and speak', 'Mic dabaayein aur bolein');
  String get listening => _p('Listening…', 'Sun rahe hain…');
  String get micUnavailable => _p(
      'Microphone is not available right now.',
      'Microphone abhi uplabdh nahi hai.');
  String get micPermissionNeeded => _p(
      'Please allow microphone access to speak your note.',
      'Bolkar note likhne ke liye microphone ki anumati dein.');
  String get addUpToTwoPhotos => _p('Add photo (up to 2)', 'Photo add karein (2 tak)');
  String get photoLimitReached =>
      _p('You can add up to 2 photos per note.', 'Ek note mein 2 tak photo add kar sakti hain.');
  String get remove => _p('Remove', 'Hataayein');
  String get cancel => _p('Cancel', 'Cancel karein');
  String get deleteEntryQ =>
      _p('Delete this note?', 'Yeh note delete karein?');
  String get deletePhotoQ =>
      _p('Delete this photo?', 'Yeh photo delete karein?');
  String get memoryBook => _p('Your memory book', 'Aapki yaadon ki kitaab');
  String get noEntriesYet => _p(
      'No notes yet — your weekly reflections will gather here.',
      'Abhi koi note nahi — aapki har hafte ki yaadein yahan jamaa hongi.');

  // ---- "Your Week" — the week-scoped journal (weeks 4 & 5 preview) ----------
  String get yourWeek => _p('Your Week', 'Aapka Hafta');
  String get tapToEdit => _p('Tap to edit', 'Edit karne ke liye tap karein');
  String get addAPhoto => _p('Add a photo', 'Ek photo add karein');

  // Week strip / trimester
  String trimesterName(int week) {
    if (week <= 13) return _p('Trimester 1', 'Trimester 1');
    if (week <= 26) return _p('Trimester 2', 'Trimester 2');
    return _p('Trimester 3', 'Trimester 3');
  }

  String get dueLabel => _p('Due', 'Due');

  // Week 40 celebration
  String get celebrationTitle => _p('Welcome, little one.', 'Swagat hai, nanhe.');
  String get celebrationSubtitle => _p(
      '40 weeks of love, strength, and magic.',
      '40 hafton ka pyaar, taakat aur jaadu.');
  String get celebrationBody => _p(
      'You carried a whole world inside you. Every week, every kick, every quiet moment brought you here.',
      'Aapne ek poori duniya apne andar sambhaali. Har hafta, har kick, har shaant pal aapko yahan le aaya.');
  String get saveMemory => _p('Download this memory', 'Yeh yaad download karein');
  String get savingMemory => _p('Saving…', 'Save ho raha hai…');
  String get savedMemory => _p('Saved! Choose where to keep it.', 'Save ho gaya! Chunein kahan rakhna hai.');
  String get celebrationBadge => _p('Journey complete', 'Safar poora');
  String get celebrationMemoriesTitle =>
      _p('Your journey in memories', 'Yaadon mein aapka safar');
  String photosCount(int n) => _p(
      n == 1 ? '1 photo' : '$n photos', n == 1 ? '1 photo' : '$n photo');
  String get celebrationShareText => _p(
      '40 weeks complete 🎉 Our little one is here! — ParentVeda',
      '40 hafte poore 🎉 Hamara nanha aa gaya! — ParentVeda');

  // ---- Week-40 keepsake PDF booklet ----------------------------------------
  String get createBooklet =>
      _p('Download your Keepsake Booklet', 'Apni yaadon ki kitaab download karein');
  String get buildingBooklet =>
      _p('Building your booklet…', 'Aapki kitaab ban rahi hai…');
  String get bookletReady =>
      _p('Your booklet is ready 💕', 'Aapki kitaab taiyaar hai 💕');
  String get bookletFailed => _p(
      'Could not create the booklet. Please try again.',
      'Kitaab nahi ban paayi. Kripya phir try karein.');
  String get missingWeeksTitle =>
      _p('Add a little more?', 'Thoda aur jodein?');
  String get missingWeeksIntro => _p(
      'These weeks have no memory yet. Add one to include it in your booklet — or skip and create it now.',
      'In hafton mein abhi koi yaad nahi. Kitaab mein shaamil karne ke liye ek jodein — ya skip karke abhi banayein.');
  String get noMissingWeeks => _p(
      'Every week with a memory will be included. Ready to create your booklet?',
      'Har hafta jismein yaad hai woh shaamil hoga. Kitaab banane ke liye taiyaar?');
  String get addMemory => _p('Add memory', 'Yaad jodein');
  String get createNow => _p('Create booklet now', 'Abhi kitaab banayein');
  String get bookletPreviewTitle =>
      _p('Your keepsake booklet', 'Aapki yaadon ki kitaab');
  String weeksWithNoEntry(int n) => _p(
      n == 1 ? '1 week with no memory' : '$n weeks with no memory',
      n == 1 ? '1 hafta bina yaad ke' : '$n hafte bina yaad ke');

  // PDF page text (kept short; the booklet is a calm keepsake).
  String get bookletCoverTitle =>
      _p('Our Pregnancy Journey', 'Hamara Pregnancy Safar');
  String get bookletCoverSubtitle => _p(
      'Forty weeks of waiting, hoping and loving.',
      'Chaalis hafton ka intezaar, ummeed aur pyaar.');
  String bookletCompletedOn(String date) =>
      _p('Completed on $date', '$date ko poora hua');
  String get bookletClosingTitle =>
      _p('With all our love', 'Saare pyaar ke saath');
  String get bookletClosingBody => _p(
      'One day you will read this, little one, and know how deeply you were wanted, every single week.',
      'Ek din tum yeh padhoge, nanhe, aur jaanoge ki har hafte tumhe kitna chaaha gaya.');
  String get bookletEmptyEntry =>
      _p('A quiet week, simply held close.', 'Ek shaant hafta, bas dil ke kareeb.');

  // ===========================================================================
  //  HOME SCREEN — Daily Moment
  // ===========================================================================

  // ---- Header --------------------------------------------------------------
  String greeting(int hour, String name) {
    final part = hour < 12
        ? _p('Good Morning', 'Shubh Prabhat')
        : hour < 17
            ? _p('Good Afternoon', 'Shubh Dopahar')
            : _p('Good Evening', 'Shubh Sandhya');
    return '$part, $name';
  }

  /// Encouraging, journey-style progress line (never task language).
  String journeyLine(int week) {
    if (week == 20) {
      return _p("Week 20 · You're halfway there 💜",
          'Hafta 20 · Aap aadhe safar tak aa gayi 💜');
    }
    if (week >= 36) {
      return _p('Week $week · Almost there, mamma 💜',
          'Hafta $week · Bas thoda aur, mamma 💜');
    }
    if (week <= 13) {
      return _p('Week $week · A new chapter begins 💜',
          'Hafta $week · Ek naya adhyay shuru 💜');
    }
    return _p('Week $week · Growing together 💜',
        'Hafta $week · Saath badh rahe hain 💜');
  }

  String littleOneSize(String fruit) => _p(
      'Your little one is the size of $fruit this week',
      'Aapka nanha is hafte $fruit jitna bada hai');
  String sizeAndLearning(String length, String learning) =>
      '$length · $learning';

  String get todaysMoment => _p("Today's Moment", 'Aaj Ka Pal');
  String get momentMinutes => _p('~6 min', '~6 min');
  String get momentSummary => _p('A small moment for you and your baby.',
      'Aap aur aapke baby ke liye ek chhota sa pal.');

  // ---- Module eyebrows -----------------------------------------------------
  String get growEyebrow => _p('Grow', 'Grow');
  String get readEyebrow => _p('Read To Your Baby', 'Apne Baby Ko Sunaayein');
  String get talkEyebrow => _p('Talk To Your Baby', 'Apne Baby Se Baat Karein');
  String get momentForYouEyebrow => _p('A Moment For You', 'Aapke Liye Ek Pal');
  String get movementEyebrow =>
      _p('Baby Movement Check-In', 'Baby Movement Check-In');

  // ---- Shared CTAs / labels ------------------------------------------------
  String get readMore => _p('Read More', 'Aur Padhein');
  String get readCta => _p('Read', 'Padhein');
  String get listenCta => _p('Listen', 'Sunein');
  String get recordCta => _p('Record', 'Record karein');
  String get writeCta => _p('Write', 'Likhein');
  String get maybeLater => _p('Maybe later', 'Baad mein');
  String get playCta => _p('Play', 'Chalayein');
  String get beginCta => _p('Begin', 'Shuru karein');
  String get keepThisWithMe =>
      _p('Keep This With Me', 'Ise Apne Paas Rakhein');
  String get keptLabel => _p('Kept 💜', 'Rakh liya 💜');
  String get rememberLabel => _p('Remember', 'Yaad rakhein');
  String get deepDiveLabel => _p('A little deeper', 'Thoda gehraai mein');

  // ---- Garbh Sanskar (home) ------------------------------------------------
  String get todaysPractice => _p("Today's Practice", 'Aaj Ka Abhyas');
  String get ragaLabel => _p('RAGA', 'RAAG');
  String get meditationLabel => _p('GUIDED MEDITATION', 'GUIDED MEDITATION');
  String get affirmationLabel => _p('AFFIRMATION', 'AFFIRMATION');
  String minutesShort(int m) => _p('$m min', '$m min');
  String get aboutGarbhTitle =>
      _p('About Garbh Sanskar', 'Garbh Sanskar ke baare mein');
  String get whyItMatters => _p('Why it matters', 'Yeh kyun maayne rakhta hai');
  String get howToUseIt => _p('How to use it', 'Ise kaise istemaal karein');
  String get infoTooltip =>
      _p('What is this?', 'Yeh kya hai?');
  String get gotIt => _p('Got it', 'Samajh gayi');

  // ---- Talk To Your Baby ---------------------------------------------------
  String get talkWriteHint => _p('Write your message to your baby…',
      'Apne baby ke liye apna sandesh likhein…');
  String get talkListening =>
      _p('Listening… speak now', 'Sun rahe hain… ab bolein');
  String get talkSpeakHint => _p(
      'Tap the mic and speak — we will gently write it down.',
      'Mic dabaayein aur bolein — hum use pyaar se likh denge.');
  String get talkSaved =>
      _p('Saved to Dear Baby 💜', 'Dear Baby mein save ho gaya 💜');
  String get talkSaveCta => _p('Save to Dear Baby', 'Dear Baby mein save karein');
  String get talkSavedBadge => _p('Saved to Dear Baby', 'Dear Baby mein save');

  // ---- Completion ----------------------------------------------------------
  String get completionTitle => _p('You gave yourself 6 minutes today.',
      'Aaj aapne khud ko 6 minute diye.');
  String get completionSubtitle => _p('That matters more than you know.',
      'Yeh aapki soch se zyada maayne rakhta hai.');

  // ---- Emotional Check-In --------------------------------------------------
  String get feelingQuestion => _p('How are you feeling right now?',
      'Abhi aap kaisa mehsoos kar rahi hain?');
  String get feelingSubtext => _p('No right answer. Just checking in with you.',
      'Koi sahi jawaab nahi. Bas aapka haal pooch rahe hain.');
  String get moodSaved => _p('Saved 💜', 'Save ho gaya 💜');
  String moodLabel(String id) {
    switch (id) {
      case 'happy':
        return _p('Happy', 'Khush');
      case 'grateful':
        return _p('Grateful', 'Shukrguzaar');
      case 'calm':
        return _p('Calm', 'Shaant');
      case 'hopeful':
        return _p('Hopeful', 'Umeed se bhari');
      case 'tired':
        return _p('Tired', 'Thaki hui');
      case 'anxious':
        return _p('Anxious', 'Chintit');
      case 'overwhelmed':
        return _p('Overwhelmed', 'Bojh mehsoos');
      case 'loved':
        return _p('Loved', 'Pyaar mehsoos');
      default:
        return id;
    }
  }

  // ---- Baby Movement (Week 28+) --------------------------------------------
  String get movementQuestion =>
      _p('Did your baby move today?', 'Kya aaj aapke baby ne movement ki?');
  String get movementSubtext => _p('No counting. No targets. Just awareness.',
      'Koi ginti nahi. Koi target nahi. Bas dhyan.');
  String get yesWord => _p('Yes', 'Haan');
  String get notYet => _p('Not yet', 'Abhi nahi');
  String get movementYes =>
      _p('Wonderful 💚 Your baby is active today.',
         'Bahut achha 💚 Aapka baby aaj active hai.');
  String get movementNotYet => _p(
      "That's okay. Try lying on your left side, drink something cold, and spend 30 minutes focusing on movement.",
      'Koi baat nahi. Apni baayi karwat letne ki koshish karein, kuch thanda piyein, aur 30 minute movement par dhyan dein.');
  String get movementEscalation => _p(
      'Still not feeling movement? Contact your doctor.',
      'Phir bhi movement mehsoos nahi ho rahi? Apne doctor se sampark karein.');

  // ---- Bottom navigation + tabs --------------------------------------------
  String get homeTab => _p('Home', 'Home');
  String get myBabyTab => _p('My Baby', 'My Baby');
  String get dearBabyTab => _p('Dear Baby', 'Dear Baby');
  String get toolsTab => _p('Tools', 'Tools');
  String get exploreTab => _p('Explore', 'Explore');
  String get profileTab => _p('Profile', 'Profile');

  // ===========================================================================
  //  PROFILE TAB + DEAR BABY MEMORY VAULT
  // ===========================================================================

  String get profileTitle => _p('Profile', 'Profile');
  String get languageLabel => _p('Language', 'Bhasha');
  String get languageEnglish => 'English';
  String get languageHinglish => 'Hinglish';
  String get moreComingSoon =>
      _p('More coming soon', 'Aur bhi jaldi aa raha hai');

  String get dearBabyVaultTitle => _p('Dear Baby', 'Dear Baby');
  String get dearBabyVaultSubtitle => _p(
      'Your baby memory vault — every message you save for your little one.',
      'Aapki baby memory vault — har sandesh jo aap apne nanhe ke liye save karti hain.');
  String dearBabyEntries(int n) => _p(
      n == 1 ? '1 message' : '$n messages',
      n == 1 ? '1 sandesh' : '$n sandesh');
  String get dearBabyEmpty => _p(
      'Your messages to your baby will gather here. Open "Talk To Your Baby" on Home to write your first one. 💜',
      'Aapke baby ke liye sandesh yahan jamaa honge. Pehla likhne ke liye Home par "Apne Baby Se Baat Karein" kholein. 💜');
  String get spokenLabel => _p('Spoken', 'Bola gaya');
  String get writtenLabel => _p('Written', 'Likha gaya');

  // ===========================================================================
  //  TOOLS TAB + YOUR PREGNANCY JOURNEY (map)
  // ===========================================================================

  // ---- Tools landing (grid of tools) ---------------------------------------
  String get toolsTitle => _p('Tools', 'Tools');
  String get toolsIntro => _p(
      'Helpful companions for your journey — more arriving soon.',
      'Aapke safar ke saathi — aur bhi jaldi aa rahe hain.');
  String get toolJourneyTitle =>
      _p('Your Pregnancy Journey', 'Aapka Pregnancy Safar');
  String get toolJourneySubtitle => _p(
      'See your whole journey, week by week.',
      'Apna poora safar dekhein, hafte-dar-hafte.');
  String get toolWeightTitle => _p('Weight Tracker', 'Weight Tracker');
  String get toolKickTitle => _p('Kick Counter', 'Kick Counter');
  String get toolContractionTitle =>
      _p('Contraction Timer', 'Contraction Timer');
  String get toolHospitalBagTitle =>
      _p('Hospital Bag Planner', 'Hospital Bag Planner');
  String get toolKegelTitle => _p('Kegel Care', 'Kegel Care');
  String get openLabel => _p('Open', 'Kholein');

  // ---- Journey map chrome --------------------------------------------------
  String get journeyTitle => _p('Your Pregnancy Journey', 'Aapka Pregnancy Safar');
  String get youAreHere => _p('YOU ARE HERE', 'AAP YAHAN HAIN');
  String get currentWeekLabel => _p('Current Week', 'Yeh Hafta');
  String get completedLabel => _p('Completed', 'Poora hua');
  String journeyWeekDay(int week, int day) =>
      _p('Week $week • Day $day', 'Hafta $week • Din $day');
  String journeyDaysCompleted(int done, int total) => _p(
      '$done of $total Days Completed', '$total mein se $done Din Poore');
  String journeyDaysRemaining(int n) =>
      _p('$n Days Remaining', '$n Din Baaki');
  String journeyPercentComplete(int p) => _p('$p% Complete', '$p% Poora');

  // ---- Journey filters + upcoming ------------------------------------------
  String get filterAll => _p('All', 'Sab');
  String get filterAchievements => _p('Achievements', 'Upalabdhi');
  String get filterBaby => _p('Baby', 'Baby');
  String get filterMedical => _p('Medical', 'Medical');
  String get filterMother => _p('Mother', 'Maa');
  String get filterFeatures => _p('Tools', 'Tools');
  String get filterJourney => _p('Journey', 'Safar');
  String get comingUpTitle => _p('Coming Up', 'Aage Aane Waala');
  String inWeeksShort(int n) => _p(
      n <= 1 ? 'In about 1 week' : 'In about $n weeks',
      n <= 1 ? 'Lagbhag 1 hafte mein' : 'Lagbhag $n hafton mein');
  String get nothingUpcoming => _p(
      'You have reached every milestone on your journey 💜',
      'Aap apne safar ke har padaav tak pahunch chuki hain 💜');

  // ---- Journey node cards --------------------------------------------------
  String get typeAchievementLabel => _p('Achievement', 'Upalabdhi');
  String get typeMedicalLabel => _p('Medical milestone', 'Medical padaav');
  String get typeBabyLabel => _p('Baby development', 'Baby ka vikas');
  String get typeMotherLabel => _p('For you, Maa', 'Aapke liye, Maa');
  String get typePvLabel => _p('Your journey', 'Aapka safar');
  String get typeFeatureLabel => _p('New tool', 'Naya tool');

  String reachedOn(String date) => _p('Reached on $date', '$date ko pahuncha');
  String expectedInWeeks(int n) => _p(
      n == 1 ? 'Expected in about 1 week' : 'Expected in about $n weeks',
      n == 1 ? 'Lagbhag 1 hafte mein' : 'Lagbhag $n hafton mein');
  String viewWeekN(int n) => _p('View Week $n', 'Hafta $n dekhein');
  String get continueJourney => _p('Continue journey', 'Safar jaari rakhein');
  String get launchFeatureCta => _p('Launch', 'Shuru karein');
  String get featureComingSoonTitle =>
      _p('Coming soon 💜', 'Jaldi aa raha hai 💜');
  String get featureComingSoonBody => _p(
      'This tool is on its way. We will gently let you know the moment it is ready.',
      'Yeh tool jald aa raha hai. Taiyaar hote hi hum aapko pyaar se bata denge.');
  String get medicalDisclaimer => _p(
      'Educational only — not medical advice. Always follow your doctor.',
      'Sirf jaankaari ke liye — medical salah nahi. Hamesha apne doctor ki salah maanein.');
  String get whatItDoesLabel => _p('What it does', 'Yeh kya karta hai');

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
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
  //  TOOLS — Baby Movement Tracker
  // ===========================================================================
  String get movementToolTitle => _p('Baby Movement', 'Baby Movement');
  String get historyLabel => _p('History', 'History');
  String get movementDisclaimer => _p(
      'Most babies move several times a day and that is perfectly normal. Use this tracker only if your doctor has asked you to monitor movements.',
      'Zyadatar babies din mein kai baar move karte hain aur yeh bilkul normal hai. Is tracker ka istemal sirf tab karein jab aapke doctor ne movements monitor karne ko kaha ho.');
  String get babyMovedLabel => _p('Baby Moved', 'Baby Ne Move Kiya');
  String get babyMovedSub =>
      _p('Tap whenever you feel movement', 'Jab bhi movement mehsoos ho, tap karein');
  String get movementLogged => _p('Movement Logged', 'Movement Note Ho Gaya');
  String get babyActiveTodayMsg =>
      _p('Your baby was active today.', 'Aapka baby aaj active tha.');
  String get todaysMovements => _p("Today's Movements", 'Aaj Ki Movements');
  String get rememberThisMoment =>
      _p('Remember This Moment', 'Is Pal Ko Yaad Rakhein');
  String get movementNoteHint => _p(
      'Today you started moving while daddy was talking…',
      'Aaj tum tab move karne lage jab papa baat kar rahe the…');
  String get movementNoteSaved =>
      _p('Saved to Dear Baby 💜', 'Dear Baby mein save ho gaya 💜');
  String get movementNotePrompt =>
      _p('A baby movement memory', 'Baby movement ki ek yaad');
  String get movementRecordsTitle =>
      _p('Movement Records', 'Movement Records');
  String get movementRecordsIntro => _p(
      'For your reference and your doctor. Counts appear here, never on the tracking screen.',
      'Aapke aur aapke doctor ke liye. Ginti yahan dikhti hai, tracking screen par kabhi nahi.');
  String movementsLoggedCount(int n) => _p(
      n == 1 ? '1 movement logged' : '$n movements logged',
      n == 1 ? '1 movement note hua' : '$n movements note hue');
  String get startWord => _p('Start', 'Shuru');
  String get endWord => _p('End', 'Khatm');
  String get viewDetails => _p('View Details', 'Vivran dekhein');
  String get noMovementsYet => _p(
      'No movements recorded yet. Tap the heart whenever you feel your baby move.',
      'Abhi koi movement record nahi hui. Jab bhi baby move kare, dil par tap karein.');

  // ===========================================================================
  //  TOOLS — Weight Tracker
  // ===========================================================================
  String get weightToolTitle => _p('Weight Tracker', 'Weight Tracker');
  String get weightWelcomeBody => _p(
      'Understanding your starting point helps us personalize your journey and offer gentle weight guidance. Your information is private and can be updated later.',
      'Aapka shuruaati point samajhne se hum aapka safar personalize kar sakte hain aur halki weight guidance de sakte hain. Aapki jaankaari private hai aur baad mein badli ja sakti hai.');
  String get prePregnancyWeightLabel =>
      _p('Pre-pregnancy weight', 'Pregnancy se pehle ka wazan');
  String get prePregnancyWeightHelper => _p(
      'This helps us estimate a healthy weight-gain range.',
      'Isse hum ek sehatmand weight-gain range ka andaza laga sakte hain.');
  String get heightLabel => _p('Your height', 'Aapki lambai');
  String get heightHelper => _p(
      'This helps personalize your pregnancy weight chart.',
      'Isse aapka pregnancy weight chart personalize hota hai.');
  String get kgUnit => _p('kg', 'kg');
  String get cmUnit => _p('cm', 'cm');
  String get continueCta => _p('Continue', 'Aage badhein');
  String get profileTitleWeight =>
      _p('Your Pregnancy Profile', 'Aapki Pregnancy Profile');
  String get startingWeightLabel => _p('Starting weight', 'Shuruaati wazan');
  String get recommendedGainLabel =>
      _p('Recommended pregnancy weight gain', 'Salah di gayi weight gain');
  String get weightGuidelineNote => _p(
      'This is a general guideline. Your doctor may recommend something different for your pregnancy.',
      'Yeh ek aam guideline hai. Aapke doctor aapki pregnancy ke liye kuch alag salah de sakte hain.');
  String get startTrackingCta => _p('Start Tracking', 'Tracking shuru karein');
  String get currentWeightLabel => _p('Current weight', 'Abhi ka wazan');
  String get lastUpdatedLabel => _p('Last updated', 'Aakhri update');
  String get todayWord => _p('Today', 'Aaj');
  String weightEmptyState(int week) => _p(
      'No weight entries yet. Most mothers record their weight during doctor visits or once a week.',
      'Abhi koi weight entry nahi. Zyadatar maayein doctor visit par ya hafte mein ek baar wazan record karti hain.');
  String get addTodaysWeight => _p("Add Today's Weight", 'Aaj ka wazan add karein');
  String get bodySupportingTitle =>
      _p('Your body is supporting ❤️', 'Aapka sharir sahaara de raha hai ❤️');
  String get supportGrowingBaby =>
      _p('Your growing baby', 'Aapka badhta hua baby');
  String get supportPlacenta => _p('Placenta development', 'Placenta ka vikas');
  String get supportAmniotic => _p('Amniotic fluid', 'Amniotic fluid');
  String get supportBlood => _p('Increased blood volume', 'Badha hua blood volume');
  String get everyPregnancyUnique => _p(
      'Every pregnancy is unique. Always follow your doctor\'s guidance.',
      'Har pregnancy alag hai. Hamesha apne doctor ki salah maanein.');
  String get weightGainSince =>
      _p('Weight gain since pregnancy', 'Pregnancy se ab tak weight gain');
  String get whereWeightComesFrom => _p(
      'Where pregnancy weight comes from', 'Pregnancy weight kahan se aata hai');
  String get contributorBaby => _p('Baby', 'Baby');
  String get contributorPlacenta => _p('Placenta', 'Placenta');
  String get contributorAmniotic => _p('Amniotic fluid', 'Amniotic fluid');
  String get contributorBlood => _p('Blood volume', 'Blood volume');
  String get contributorBreast => _p('Breast tissue', 'Breast tissue');
  String get contributorEnergy => _p('Energy stores', 'Energy stores');
  String get estimatesNote => _p(
      'Educational estimates based on pregnancy week. Not exact measurements.',
      'Pregnancy week par aadharit educational estimates. Theek maap nahi.');
  String get whatChangedTitle =>
      _p('What changed since your last entry?', 'Pichhli entry se kya badla?');
  String get changedBabyGrew =>
      _p('Your baby gained a little more', 'Aapke baby ka wazan thoda aur badha');
  String get changedAmniotic =>
      _p('Amniotic fluid increased', 'Amniotic fluid badha');
  String get changedBlood =>
      _p('Blood volume continued expanding', 'Blood volume badhta raha');
  String get changedUterus => _p('Your uterus grew larger', 'Aapka uterus bada hua');
  String get thisWeekLabel => _p('This week', 'Is hafte');
  String get addWeightTitle => _p('Add weight', 'Wazan add karein');
  String get dateLabel => _p('Date', 'Tareekh');
  String get notesOptional => _p('Notes (optional)', 'Notes (optional)');
  String get saveCta => _p('Save', 'Save karein');
  String get weightHistoryTitle => _p('Weight history', 'Weight history');
  String get weightChartTitle => _p('Weight chart', 'Weight chart');
  String get chartActualWeight => _p('Actual weight', 'Asli wazan');
  String get chartRecommendedRange =>
      _p('Recommended range', 'Salah di gayi range');
  String get chartFooter => _p(
      'Your weight trend alongside the typical range for your stage. Every pregnancy is unique — discuss any concerns with your provider.',
      'Aapka weight trend aapke stage ki typical range ke saath. Har pregnancy alag — kisi bhi chinta par apne doctor se baat karein.');
  String weeklyWeightInsight(int week) {
    if (week <= 13) {
      return _p(
          'Your body is increasing blood volume to support your growing baby.',
          'Aapka sharir badhte baby ke liye blood volume badha raha hai.');
    }
    if (week <= 27) {
      return _p(
          'Your baby, placenta and amniotic fluid now account for a meaningful portion of weight gain.',
          'Aapka baby, placenta aur amniotic fluid ab weight gain ka ek bada hissa hain.');
    }
    return _p(
        'Late pregnancy weight gain is often influenced by fluid and rapid baby growth.',
        'Late pregnancy weight gain aksar fluid aur tezi se baby growth se hota hai.');
  }

  // ===========================================================================
  //  TOOLS — Kegel Care
  // ===========================================================================
  String get kegelToolTitle => _p('Kegel Care', 'Kegel Care');
  String get kegelHeroTitle => _p('Pelvic floor care', 'Pelvic floor care');
  String get kegelHeroBody => _p(
      'During pregnancy, your pelvic floor supports the increasing weight of your growing baby. Regular exercises may help support:',
      'Pregnancy mein aapka pelvic floor badhte baby ka wazan sambhaalta hai. Niyamit exercises in cheezon mein madad kar sakti hain:');
  String get kegelBenefitBladder => _p('Bladder control', 'Bladder control');
  String get kegelBenefitSupport => _p('Pelvic support', 'Pelvic support');
  String get kegelBenefitRecovery =>
      _p('Postpartum recovery', 'Postpartum recovery');
  String get kegelFollowProvider => _p(
      "Always follow your healthcare provider's advice.",
      'Hamesha apne doctor ki salah maanein.');
  String get currentRoutineLabel => _p('Current routine', 'Abhi ki routine');
  String get holdLabel => _p('Hold', 'Rokein');
  String get relaxLabel => _p('Relax', 'Dheela chhodein');
  String get repsLabel => _p('Repetitions', 'Repetitions');
  String get estTimeLabel => _p('Estimated time', 'Anumaanit samay');
  String get secShort => _p('sec', 'sec');
  String get whyThisRoutine => _p('Why this routine?', 'Yeh routine kyun?');
  String get whyThisRoutineBody => _p(
      'Most mothers at your stage of pregnancy benefit from this gentle level. It is personalized and may change as your pregnancy progresses.',
      'Aapke stage ki zyadatar maayein is halke level se faayda paati hain. Yeh personalized hai aur pregnancy ke saath badal sakti hai.');
  String get startCareSession => _p('Start Care Session', 'Care Session shuru karein');
  String get whyAmIDoingThis => _p('Why am I doing this?', 'Main yeh kyun kar rahi hoon?');
  String get whyAmIDoingThisBody => _p(
      'The pelvic floor supports the bladder, bowel and uterus. These muscles work harder throughout pregnancy. Regular exercises may help maintain strength and support recovery after birth.',
      'Pelvic floor bladder, bowel aur uterus ko sahaara deta hai. Yeh muscles pregnancy bhar zyada kaam karti hain. Niyamit exercises taakat banaaye rakhne aur janm ke baad recovery mein madad kar sakti hain.');
  String get kegelSafetyTitle => _p(
      'Stop and contact your provider if you experience:',
      'Ye ho toh rukein aur apne doctor se sampark karein:');
  String get kegelSafetyPain => _p('Pain', 'Dard');
  String get kegelSafetyBleeding => _p('Vaginal bleeding', 'Vaginal bleeding');
  String get kegelSafetyDizziness => _p('Dizziness', 'Chakkar');
  String get kegelSafetyContractions =>
      _p('Contractions triggered by exercise', 'Exercise se contractions');
  String get stageLabel => _p('Current stage', 'Abhi ka stage');
  String get kegelStage1 => _p('Learning the technique', 'Technique seekhna');
  String get kegelStage2 => _p('Building consistency', 'Consistency banana');
  String get kegelStage3 => _p('Preparing for birth', 'Janm ki taiyaari');
  String repOf(int cur, int total) =>
      _p('Rep $cur of $total', 'Rep $cur / $total');
  String get pauseLabel => _p('Pause', 'Rokein');
  String get resumeLabel => _p('Resume', 'Jaari rakhein');
  String get exitLabel => _p('Exit', 'Bahar');
  String get kegelSessionDoneTitle => _p('Well Done ❤️', 'Shaabaash ❤️');
  String get kegelSessionDoneBody => _p(
      "You completed today's pelvic floor care session. Small moments of care can support your body throughout pregnancy.",
      'Aapne aaj ka pelvic floor care session poora kiya. Care ke chhote pal pregnancy bhar aapke sharir ko sahaara dete hain.');
  String get howDidItFeel =>
      _p("How did today's session feel?", 'Aaj ka session kaisa laga?');
  String get feedbackEasy => _p('Easy', 'Aasaan');
  String get feedbackComfortable => _p('Comfortable', 'Theek-thaak');
  String get feedbackDifficult => _p('Difficult', 'Mushkil');
  String get doneWord => _p('Done', 'Ho gaya');
  String get careJourneyTitle => _p('Your Care Journey ❤️', 'Aapka Care Safar ❤️');
  String get sessionsCompletedLabel =>
      _p('Sessions completed', 'Sessions poore');
  String get completedThisWeekLabel =>
      _p('Completed this week', 'Is hafte poore');
  String get lastCompletedLabel => _p('Last completed', 'Aakhri baar');
  String get neverWord => _p('Not yet', 'Abhi nahi');
  String get careJourneyCta => _p('Care Journey', 'Care Safar');

  // ===========================================================================
  //  TOOLS — Contraction Tracker
  // ===========================================================================
  String get contractionToolTitle =>
      _p('Contraction Tracker', 'Contraction Tracker');
  String get contractionIntro => _p(
      'Record contraction timing and patterns that may be useful when speaking with your healthcare provider. Always follow your provider\'s advice.',
      'Contraction timing aur patterns record karein jo doctor se baat karte waqt kaam aa sakte hain. Hamesha apne doctor ki salah maanein.');
  String get contractionEmpty => _p(
      'Ready to start tracking? When a contraction begins, tap the button below.',
      'Tracking shuru karein? Jab contraction shuru ho, neeche button dabaayein.');
  String get contractionStartedCta =>
      _p('CONTRACTION STARTED', 'CONTRACTION SHURU');
  String get contractionEndedCta =>
      _p('CONTRACTION ENDED', 'CONTRACTION KHATM');
  String get currentContraction => _p('Current contraction', 'Abhi ka contraction');
  String get tapWhenEnds =>
      _p('Tap when the contraction ends.', 'Jab contraction khatm ho, tap karein.');
  String get timeSinceLast =>
      _p('Time since last contraction', 'Pichhle contraction se samay');
  String get lastContractionLabel => _p('Last contraction', 'Pichhla contraction');
  String get avgDurationLabel => _p('Average duration', 'Average duration');
  String get avgIntervalLabel => _p('Average interval', 'Average interval');
  String get longestDurationLabel => _p('Longest duration', 'Sabse lamba');
  String get shortestIntervalLabel => _p('Shortest interval', 'Sabse chhota interval');
  String get contractionsLoggedLabel =>
      _p('Contractions logged', 'Contractions logged');
  String get currentPatternLabel => _p('Current pattern', 'Abhi ka pattern');
  String get sessionSummaryTitle => _p('Session summary', 'Session summary');
  String get viewSummaryCta => _p('View summary', 'Summary dekhein');
  String get endSessionCta => _p('End session', 'Session khatm karein');
  String get doctorSummaryTitle => _p('Doctor summary', 'Doctor summary');
  String get lastHourLabel => _p('Last hour', 'Pichhla ghanta');
  String get copySummaryCta => _p('Copy summary', 'Summary copy karein');
  String get summaryCopied => _p('Summary copied 💜', 'Summary copy ho gayi 💜');
  String get consultProvider => _p(
      'Please consult your healthcare provider for interpretation.',
      'Vyakhya ke liye apne doctor se sampark karein.');
  String secLabel(int n) => _p('$n sec', '$n sec');
  String minLabel(int n) => _p('$n min', '$n min');
  String get timeColumn => _p('Time', 'Samay');
  String get durationColumn => _p('Duration', 'Duration');
  String get intervalColumn => _p('Interval', 'Interval');
  String get noContractionSessions => _p(
      'No sessions yet. Your tracked contractions will appear here.',
      'Abhi koi session nahi. Aapke track kiye contractions yahan dikhenge.');
  String get patternIrregular => _p(
      'Contractions are currently far apart and irregular. Continue monitoring.',
      'Contractions abhi door-door aur anymit hain. Dhyan rakhna jaari rakhein.');
  String get patternBuilding => _p(
      'Contractions appear to be occurring more regularly. Continue tracking.',
      'Contractions ab thoda niyamit ho rahe lagte hain. Tracking jaari rakhein.');
  String get patternRegular => _p(
      'Your contraction pattern appears more regular. You may wish to review your birth plan and contact your healthcare provider according to their advice.',
      'Aapka contraction pattern ab niyamit lagta hai. Aap apna birth plan dekhna aur doctor ki salah ke anusaar sampark karna chah sakti hain.');
  String get eduTitle => _p('Learn', 'Jaanein');
  String get eduWhatAreContractions =>
      _p('What are contractions?', 'Contractions kya hote hain?');
  String get eduWhatAreContractionsBody => _p(
      'Contractions are the tightening and relaxing of the uterus. Early on they can be irregular; closer to birth they often become longer, stronger and more regular.',
      'Contractions uterus ke kasne aur dheela hone ko kehte hain. Shuru mein ye anymit ho sakte hain; janm ke kareeb ye aksar lambe, tej aur niyamit ho jaate hain.');
  String get eduFiveOneOne => _p('What is the 5-1-1 rule?', '5-1-1 rule kya hai?');
  String get eduFiveOneOneBody => _p(
      'Some providers use the 5-1-1 guideline: contractions every 5 minutes, lasting around 1 minute, for at least 1 hour. Always follow your own provider\'s instructions.',
      'Kuch doctor 5-1-1 guideline istemal karte hain: har 5 minute mein contraction, lagbhag 1 minute tak, kam se kam 1 ghante ke liye. Hamesha apne doctor ke nirdesh maanein.');
  String get eduWhenCall =>
      _p('When should I call my provider?', 'Doctor ko kab call karein?');
  String get eduWhenCallBody => _p(
      'Follow the guidance your provider gave you. Many suggest calling when contractions become regular, or sooner if you have any concern — bleeding, reduced movement, or your waters break.',
      'Apne doctor ki di hui salah maanein. Kai kehte hain ki jab contractions niyamit ho jaayein tab call karein, ya pehle agar koi chinta ho — bleeding, kam movement, ya paani toot jaaye.');

  /// mm:ss stopwatch text.
  String formatStopwatch(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  /// Warm, dynamic line under the progress bar — shifts with how far along.
  String journeyEmotional(int week, int percent) {
    if (percent >= 90) {
      return _p('Almost there — your little one is nearly here ❤️',
          'Bas thoda aur — aapka nanha bahut kareeb hai ❤️');
    }
    if (percent >= 50) {
      return _p('You have already completed over half of your journey ❤️',
          'Aap apna aadha safar paar kar chuki hain ❤️');
    }
    if (percent >= 25) {
      return _p('Look how far you have already come ❤️',
          'Dekhiye aap kitni door aa chuki hain ❤️');
    }
    return _p('Your journey has begun — one gentle day at a time ❤️',
        'Aapka safar shuru ho gaya — ek-ek pyaara din ❤️');
  }

  String get weeklyJourneyTitle => _p('Weekly Journey', 'Saptahik Safar');
  String get weeklyJourneySubtitle => _p(
      "Your week-by-week guide — baby's growth, your body, nutrition, bonding and more.",
      'Aapka hafte-dar-hafte guide — baby ki growth, aapka body, poshan, bonding aur bahut kuch.');
  String get openWeeklyJourney => _p('Open Weekly Journey', 'Saptahik Safar kholein');
  String get comingSoon => _p('Coming soon', 'Jaldi aa raha hai');
  String comingSoonBody(String tab) => _p(
      '$tab is on its way. For now, enjoy your daily moment and weekly journey.',
      '$tab jaldi aa raha hai. Abhi ke liye, apne daily pal aur saptahik safar ka anand lein.');

  // ===========================================================================
  //  FATHER MODE — Daily Moment
  // ===========================================================================

  /// Wordmark shown in the Father Mode header (kept as a brand label).
  String get fatherWordmark => 'Fatherhood';

  String fatherGreeting(int hour, String name) => '${greeting(hour, name)} ❤️';

  String fatherDayLine(int week, int day) =>
      _p('Week $week • Day $day', 'Hafta $week • Din $day');

  // ---- Today's Moment card -------------------------------------------------
  String get fatherMomentMinutes => _p('~4 min', '~4 min');
  String get startMoment => _p('Start Moment', 'Shuru Karein');

  // ---- Learn ---------------------------------------------------------------
  String get learnOpen => _p('Open', 'Kholein');
  String get learnReaderTitle => _p("Today's Lesson", 'Aaj Ka Sabak');

  // ---- Mission -------------------------------------------------------------
  String get missionEyebrow => _p("Today's Mission", 'Aaj Ka Mission');
  String get missionMarkDone => _p('Done', 'Ho Gaya');
  String get missionDoneLabel => _p('Done 💪', 'Ho Gaya 💪');

  // ---- Father completion + check-in ----------------------------------------
  String get fatherCompletionTitle =>
      _p('You showed up today.', 'Aaj aap haazir the.');
  String get fatherCompletionSubtitle => _p(
      "That's how fathers are made — one day at a time.",
      'Pita aise hi bante hain — ek-ek din karke.');
  String get fatherFeelingQuestion => _p(
      'How are you feeling today?', 'Aaj aap kaisa mehsoos kar rahe hain?');
  String fatherMoodLabel(String id) {
    switch (id) {
      case 'happy':
        return _p('Happy', 'Khush');
      case 'grateful':
        return _p('Grateful', 'Shukrguzaar');
      case 'hopeful':
        return _p('Hopeful', 'Umeed Se Bhara');
      case 'calm':
        return _p('Calm', 'Shaant');
      case 'connected':
        return _p('Connected', 'Juda Hua');
      case 'nervous':
        return _p('Nervous', 'Ghabraya');
      case 'anxious':
        return _p('Anxious', 'Chintit');
      case 'tired':
        return _p('Tired', 'Thaka');
      case 'emotional':
        return _p('Emotional', 'Bhaavuk');
      case 'overwhelmed':
        return _p('Overwhelmed', 'Bojh Mehsoos');
      default:
        return id;
    }
  }
}
