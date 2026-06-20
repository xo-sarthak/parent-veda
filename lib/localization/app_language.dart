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
  String trimesterBandLabel(int i) => i == 0
      ? _p('First Trimester', 'Pehli Trimester')
      : i == 1
          ? _p('Second Trimester', 'Doosri Trimester')
          : _p('Third Trimester', 'Teesri Trimester');
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
  // Session-based tracking
  String get babyMovementTracker =>
      _p('Baby Movement Tracker', 'Baby Movement Tracker');
  String get startSession => _p('Start Session', 'Session Shuru Karein');
  String get endSession => _p('End Session', 'Session Khatm Karein');
  String get sessionWord => _p('Session', 'Session');
  String sessionNumber(int n) => _p('Session $n', 'Session $n');
  String get thisSessionLabel => _p('This session', 'Yeh session');
  String get startSessionTitle =>
      _p('Start a movement session', 'Ek movement session shuru karein');
  String get startSessionSub => _p(
      'Begin a session, then tap the heart each time you feel your baby move. The session ends when you tap End — or when you leave this screen.',
      'Session shuru karein, phir jab bhi baby move kare dil par tap karein. Session tab khatm hota hai jab aap End dabaayein — ya is screen se bahar jaayein.');
  String sessionStartedAt(String time) =>
      _p('Started at $time', '$time par shuru');
  String lastMovementAt(String time) => _p('Last at $time', 'Aakhri $time par');
  String get viewAllTimes => _p('View all times', 'Saare times dekhein');
  String get hideTimesLabel => _p('Hide times', 'Times chhupayein');
  String get sessionSavedMsg =>
      _p('Session saved to history 💜', 'Session history mein save ho gaya 💜');
  String get noMovementsThisSession => _p(
      'No movements logged yet — tap the heart above whenever you feel one.',
      'Abhi koi movement note nahi hui — jab bhi mehsoos ho, upar dil par tap karein.');

  // ===========================================================================
  //  TOOLS — Weight Tracker
  // ===========================================================================
  String get weightToolTitle => _p('Weight Tracker', 'Weight Tracker');
  String get addWeightShort => _p('Add weight', 'Weight add karein');
  String get heightOptional => _p('Height (optional)', 'Height (optional)');
  String get gainNeedsHeight => _p(
      'Add your height anytime to see a personalized weight-gain range.',
      'Personalized weight-gain range dekhne ke liye kabhi bhi apni height add karein.');
  String get changeLabel => _p('Change', 'Badlaav');
  String get timeLabel => _p('Time', 'Samay');
  String get noWeightEntriesYet => _p(
      'No entries yet. Add your weight to start your gentle record.',
      'Abhi koi entry nahi. Apna record shuru karne ke liye wazan add karein.');
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
  // Routine customization + voice cues
  String get customizeLabel => _p('Customize', 'Customize');
  String get customizeRoutineTitle =>
      _p('Customize routine', 'Routine customize karein');
  String get recommendedLabel => _p('Recommended', 'Recommended');
  String get customLabel => _p('Custom', 'Custom');
  String get resetToRecommended =>
      _p('Reset to recommended', 'Recommended par reset karein');
  String get usingCustomRoutine =>
      _p('Using your custom routine', 'Aapki custom routine chal rahi hai');
  String get kegelCustomizeInfo => _p(
      'We recommend the routine set for your stage. If it feels too easy or too hard, you can gently adjust it — always listen to your body and your doctor. Estimated time updates automatically.',
      'Hum aapke stage ke liye banayi routine recommend karte hain. Agar yeh bahut aasaan ya bahut mushkil lage, toh aap ise halke se badal sakti hain — hamesha apne sharir aur doctor ki sunein. Anumaanit samay apne aap update hota hai.');
  String get voiceCuesLabel => _p('Voice cues', 'Voice cues');

  // ===========================================================================
  //  TOOLS — My Hospital Bag
  // ===========================================================================
  String get hbName => _p('My Hospital Bag', 'My Hospital Bag');
  String rupees(int n) => '₹$n';
  // Locked / "time to prepare" state
  String get hbTimeToPrepareTitle =>
      _p('Time to start preparing', 'Taiyaari shuru karne ka samay');
  String get hbTimeToPrepareBody => _p(
      'Most mothers begin preparing their hospital bag around this stage.',
      'Zyadatar maayein is samay ke aas-paas apna hospital bag taiyaar karna shuru karti hain.');
  String get hbCreateMyBag => _p('Create my bag', 'Mera bag banayein');
  // Onboarding
  String get hbWelcomeTitle =>
      _p('Build your hospital bag', 'Apna hospital bag banayein');
  String get hbWelcomeSub => _p(
      "Let's prepare for one of the most special days of your life. You can build your bag over time and come back whenever you want.",
      'Aaiye apni zindagi ke sabse khaas dinon mein se ek ki taiyaari karein. Aap apna bag dheere-dheere bana sakti hain aur jab chahein wapas aa sakti hain.');
  String get hbStartBuilding => _p('Start building', 'Banana shuru karein');
  String get hbDeliveryTitle =>
      _p('Any idea about your delivery?', 'Apni delivery ke baare mein koi andaaza?');
  String get hbDeliveryHelper => _p(
      'This just helps us suggest a few extra items. You can change everything later.',
      'Yeh sirf kuch extra cheezein suggest karne mein madad karta hai. Aap baad mein sab kuch badal sakti hain.');
  String get hbDeliveryVaginal => _p('Vaginal', 'Vaginal');
  String get hbDeliveryCsection => _p('C-section', 'C-section');
  String get hbDeliveryUnsure => _p('Not sure yet', 'Abhi pakka nahi');
  String get hbBuildMyBag => _p('Build my bag', 'Mera bag banayein');
  // Tabs
  String get hbTabBag => _p('Bag', 'Bag');
  String get hbTabPlanner => _p('Planner', 'Planner');
  String get hbTabShopping => _p('Shopping', 'Shopping');
  // Progress
  String get hbPreparationProgress =>
      _p('Preparation progress', 'Taiyaari ki pragati');
  String hbPercentReady(int p) => _p('$p% Ready', '$p% Taiyaar');
  String hbSelectedCount(int n) => _p('$n selected', '$n chune');
  String hbPackedCountLabel(int n) => _p('$n packed', '$n pack ho gaye');
  String hbRemainingCount(int n) => _p('$n remaining', '$n baaki');
  String hbProgressLine(int p) {
    if (p == 0) {
      return _p("Let's begin, one item at a time ❤️",
          'Aaiye shuru karein, ek-ek cheez ❤️');
    }
    if (p < 40) {
      return _p('A lovely start. Your bag is taking shape ❤️',
          'Pyaari shuruaat. Aapka bag ban raha hai ❤️');
    }
    if (p < 75) {
      return _p("You're well on your way ❤️",
          'Aap achhe se aage badh rahi hain ❤️');
    }
    if (p < 100) {
      return _p("You've prepared most of what you'll need for the big day ❤️",
          'Bade din ke liye zaroori zyadatar cheezein taiyaar hain ❤️');
    }
    return _p('Your bag is ready ❤️', 'Aapka bag taiyaar hai ❤️');
  }
  String get hbLastUpdatedLabel => _p('Last updated', 'Aakhri update');
  String get hbToday => _p('today', 'aaj');
  String get hbYesterday => _p('yesterday', 'kal');
  String hbDaysAgo(int n) => _p('$n days ago', '$n din pehle');
  // Categories
  String hbCategory(String key) {
    switch (key) {
      case 'labour':
        return _p('For me during labour', 'Labour ke dauraan mere liye');
      case 'afterDelivery':
        return _p('For me after delivery', 'Delivery ke baad mere liye');
      case 'baby':
        return _p('For baby', 'Baby ke liye');
      case 'partner':
        return _p('For partner', 'Partner ke liye');
      case 'documents':
        return _p('Documents', 'Documents');
      case 'comfort':
        return _p('Comfort items', 'Aaraam ki cheezein');
      default:
        return _p('My own items', 'Meri apni cheezein');
    }
  }
  String hbItemsCount(int n) => _p(n == 1 ? '1 item' : '$n items',
      n == 1 ? '1 cheez' : '$n cheezein');
  String hbReadyCount(int n) => _p('$n ready', '$n taiyaar');
  // Item states
  String get hbStateNeeded => _p('To plan', 'Plan karna hai');
  String get hbStateHave => _p('Already have', 'Pehle se hai');
  String get hbStateBuyVeda => _p('Buy from ParentVeda', 'ParentVeda se khareedein');
  String get hbStateBuyElse => _p('Buy elsewhere', 'Kahin aur se khareedein');
  String get hbStateSkip => _p('Skip', 'Chhodein');
  String get hbStatusLabel => _p('Status', 'Sthiti');
  String get hbMarkPacked => _p('Mark as packed', 'Packed mark karein');
  String get hbPackedLabel => _p('Packed', 'Pack ho gaya');
  String get hbRestore => _p('Restore', 'Wapas laayein');
  // Recommendation / trust layer
  String get hbRecommendation =>
      _p('ParentVeda Recommendation', 'ParentVeda Sujhaav');
  String get hbBestOverall => _p('Best Overall', 'Sabse Behtar');
  String get hbWhyRecommend =>
      _p('Why ParentVeda recommends this', 'ParentVeda yeh kyun suggest karta hai');
  String get hbThingsToConsider =>
      _p('Things to consider', 'Dhyaan dene yogya baatein');
  String get hbBuyVedaCta => _p('Buy from ParentVeda', 'ParentVeda se khareedein');
  String get hbStoreComingSoon => _p(
      'Our store is coming soon. For now it\'s saved to your plan — you can also buy it elsewhere.',
      'Hamaara store jald aa raha hai. Abhi yeh aapke plan mein save hai — aap ise kahin aur se bhi khareed sakti hain.');
  // Buy elsewhere
  String get hbWhereBuy => _p('Where will you buy it?', 'Aap kahan se khareedengi?');
  String get hbProductLinkOptional =>
      _p('Product link (optional)', 'Product link (optional)');
  String get hbPriceOptional => _p('Price (optional)', 'Price (optional)');
  String get hbNotesOptional => _p('Notes (optional)', 'Notes (optional)');
  String get hbLinkSaved => _p('Link saved', 'Link save');
  String get hbPurchasePending => _p('Purchase pending', 'Khareedna baaki');
  // Add custom
  String get hbAddCustom => _p('Add custom item', 'Apni cheez jodein');
  String get hbAddCustomTitle => _p('Add your own item', 'Apni cheez jodein');
  String get hbCustomNameHint =>
      _p('e.g. Special blanket, family photo…', 'jaise special blanket, family photo…');
  String get hbWhichSection => _p('Which section?', 'Kaunsa section?');
  String get hbItemAdded => _p('Added to your bag ❤️', 'Aapke bag mein jud gaya ❤️');
  // Suggested essentials
  String get hbSuggestedTitle => _p('Most mothers also pack', 'Zyadatar maayein yeh bhi rakhti hain');
  String get hbAddWord => _p('Add', 'Jodein');
  // Planner filters
  String hbFilter(String key) {
    switch (key) {
      case 'veda':
        return _p('ParentVeda', 'ParentVeda');
      case 'else':
        return _p('Elsewhere', 'Kahin aur');
      case 'owned':
        return _p('Owned', 'Pehle se');
      case 'packed':
        return _p('Packed', 'Packed');
      case 'pending':
        return _p('Pending', 'Baaki');
      case 'skipped':
        return _p('Skipped', 'Chhoda');
      default:
        return _p('All', 'Sab');
    }
  }
  // Shopping
  String get hbShoppingTitle => _p('Shopping summary', 'Shopping summary');
  String get hbVedaPurchases => _p('ParentVeda purchases', 'ParentVeda se khareed');
  String get hbExternalPurchases => _p('External purchases', 'Baahar se khareed');
  String get hbAlreadyOwnedTotal => _p('Already owned', 'Pehle se');
  String get hbTotalPlanned => _p('Total planned spend', 'Kul anumaanit kharch');
  String get hbBuyingFromVeda => _p('Buying from ParentVeda', 'ParentVeda se khareed rahe');
  String get hbBuyingElsewhere => _p('Buying elsewhere', 'Kahin aur se khareed rahe');
  String get hbOwnedGroup => _p('Already owned', 'Pehle se hai');
  String get hbPendingGroup => _p('Still to plan', 'Abhi plan karna hai');
  String get hbNothingHere =>
      _p('Nothing here yet.', 'Yahan abhi kuch nahi.');
  // Partner share
  String get hbSharePartner => _p('Share with partner', 'Partner ke saath share karein');
  String hbShareProgress(int p) => _p(
      'Our hospital bag is $p% ready ❤️',
      'Hamaara hospital bag $p% taiyaar hai ❤️');
  String get hbShareCanHelp =>
      _p('Things you can help with:', 'Jin cheezon mein aap madad kar sakte hain:');
  String get hbShareNothingPending =>
      _p('Everything is planned for now ❤️', 'Filhaal sab plan ho chuka hai ❤️');
  // Emotional moments
  String hbCategoryReady(String name) => _p('$name ready 🎉', '$name taiyaar 🎉');
  String get hbCategoryReadyBody =>
      _p('This section is all prepared.', 'Yeh section poori tarah taiyaar hai.');
  String get hbBagReadyTitle =>
      _p('Your hospital bag is ready ❤️', 'Aapka hospital bag taiyaar hai ❤️');
  String get hbBagReadyBody => _p(
      "You are prepared for one of life's most beautiful moments.",
      'Aap zindagi ke sabse khoobsurat palon mein se ek ke liye taiyaar hain.');
  // Search
  String get hbSearchHint => _p('Search your bag…', 'Apne bag mein dhoondhein…');
  String get hbNoResults => _p('Nothing found.', 'Kuch nahi mila.');
  // Product / marketplace
  String get hbChooseOption =>
      _p('Choose what works for you', 'Jo aapke liye sahi ho woh chunein');
  String get hbDecideHow =>
      _p('Or, how will you get it?', 'Ya, aap ise kaise lengi?');
  String get hbEditDetails => _p('Edit details', 'Vivran badlein');
  String get hbOrderFromVeda =>
      _p('Order from ParentVeda', 'ParentVeda se order karein');

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
  // Compact minutes + seconds (e.g. "8s", "1m 5s", "2m") — so short intervals
  // never read as "0 min".
  String minSecLabel(int seconds) {
    final m = seconds ~/ 60;
    final sec = seconds % 60;
    if (m == 0) return '${sec}s';
    if (sec == 0) return '${m}m';
    return '${m}m ${sec}s';
  }
  String contractionNumber(int n) => _p('Contraction #$n', 'Contraction #$n');
  String get thisSessionContractions =>
      _p('This session', 'Yeh session');
  // Live labour-signal banner (gentle, never a diagnosis)
  String get laborTrackingTitle => _p('Keep tracking', 'Tracking jaari rakhein');
  String get laborTrackingBody => _p(
      "Log a few more and we'll show you the pattern.",
      'Kuch aur log karein, hum aapko pattern dikhayenge.');
  String get laborIrregularTitle =>
      _p('Irregular for now', 'Abhi anymit');
  String get laborIrregularBody => _p(
      'Your contractions are still spaced out and irregular — often early days.',
      'Aapke contractions abhi door-door aur anymit hain — aksar shuruaati samay.');
  String get laborEarlyTitle => _p('Looks like early labour', 'Shuruaati labour lagta hai');
  String get laborEarlyBody => _p(
      'A pattern is forming. Rest, hydrate and keep tracking.',
      'Ek pattern ban raha hai. Aaram karein, paani peein aur tracking jaari rakhein.');
  String get laborActiveTitle =>
      _p('This could be active labour', 'Yeh active labour ho sakta hai');
  String get laborActiveBody => _p(
      'Your contractions look regular and strong. Only you know how you feel — if unsure, it is always okay to call your doctor.',
      'Aapke contractions niyamit aur tej lag rahe hain. Aap hi jaanti hain aap kaisa feel kar rahi hain — agar pakka nahi, toh doctor ko call karna hamesha theek hai.');
  // Labour confirmation prompt
  String get laborPromptTitle =>
      _p('Does this feel like labour?', 'Kya yeh labour jaisa lagta hai?');
  String get laborPromptBody => _p(
      'Your recent contractions show a regular, strong pattern often seen in active labour. How are you feeling?',
      'Aapke haal ke contractions niyamit aur tej pattern dikhate hain jo aksar active labour mein hota hai. Aap kaisa mehsoos kar rahi hain?');
  String get laborYes => _p('Yes, I think so', 'Haan, lagta hai');
  String get laborNo => _p('Not yet', 'Abhi nahi');
  String get laborSavedNote =>
      _p('Saved to this session 💜', 'Is session mein save ho gaya 💜');
  String feltInLabour(bool yes) => yes
      ? _p('Felt like labour', 'Labour jaisa laga')
      : _p('Not labour yet', 'Abhi labour nahi');
  // Two-layer assessment (pattern classification + medical override)
  String assessTitle(String level) {
    switch (level) {
      case 'emergency':
        return _p('Please seek medical advice', 'Kripya medical salah lein');
      case 'preterm':
        return _p('Before 37 weeks — please check in',
            '37 hafte se pehle — kripya sampark karein');
      case 'active':
        return _p('Active labour likely', 'Active labour ki sambhavna');
      case 'likely':
        return _p('Labour pattern likely', 'Labour pattern ki sambhavna');
      case 'early':
        return _p('Possible early labour', 'Sambhavit shuruaati labour');
      case 'noPattern':
        return _p('No clear pattern yet', 'Abhi koi saaf pattern nahi');
      default:
        return _p('Keep tracking', 'Tracking jaari rakhein');
    }
  }

  String assessSummary(String level) {
    switch (level) {
      case 'emergency':
        return _p(
            "Some symptoms you've reported may require prompt medical assessment. Contact your healthcare provider, maternity unit, or emergency services immediately.",
            'Aapke bataaye kuch lakshanon ke liye turant medical jaanch zaroori ho sakti hai. Apne doctor, maternity unit, ya emergency services se turant sampark karein.');
      case 'preterm':
        return _p(
            'Regular contractions before 37 weeks may require medical assessment. Contact your healthcare provider promptly.',
            '37 hafte se pehle niyamit contractions ke liye medical jaanch zaroori ho sakti hai. Apne doctor se jaldi sampark karein.');
      case 'active':
        return _p(
            'Contractions are frequent, lasting longer, and occurring at relatively regular intervals. Contact your healthcare provider or follow your birth plan instructions.',
            'Contractions baar-baar, lambe aur kaafi niyamit ho rahe hain. Apne doctor se sampark karein ya apne birth plan ke nirdesh follow karein.');
      case 'likely':
        return _p(
            'A consistent labor-like contraction pattern appears to be developing. Consider contacting your healthcare provider for guidance.',
            'Ek niyamit labour-jaisa pattern banta dikh raha hai. Margdarshan ke liye apne doctor se sampark karne par vichaar karein.');
      case 'early':
        return _p(
            'Contractions may be showing an early labor pattern. Continue monitoring frequency and duration.',
            'Contractions shuruaati labour pattern dikha sakte hain. Frequency aur duration par nazar rakhein.');
      case 'noPattern':
        return _p(
            'Current recordings do not show a clear labor pattern. Continue tracking additional contractions.',
            'Abhi tak ke record saaf labour pattern nahi dikhate. Aur contractions track karte rahein.');
      default:
        return _p(
            'More contractions need to be recorded before a pattern can be identified.',
            'Pattern pehchaanne se pehle aur contractions record karne hongi.');
    }
  }

  // Safety check (Layer 2 inputs)
  String get safetyCheckTitle => _p('Quick safety check', 'Quick safety check');
  String get safetyCheckSub => _p(
      'A few questions help us flag anything that may need prompt attention.',
      'Kuch sawaal hamein aisi cheezein pehchaanne mein madad karte hain jin par turant dhyan zaroori ho.');
  String get safetyUpdate => _p('Update', 'Update karein');
  String get safetyAllClear =>
      _p('No concerning symptoms reported', 'Koi chinta wala lakshan nahi');
  String get safetyReported => _p('Symptoms reported', 'Lakshan darj kiye');
  String get qWaterBroken => _p('Has your water broken?', 'Kya aapka paani toot gaya?');
  String get qBleeding => _p('Any bleeding?', 'Koi bleeding?');
  String get qMovementReduced =>
      _p('Reduced baby movement?', 'Baby ki movement kam?');
  String get qSeverePain => _p('Severe constant pain between contractions?',
      'Contractions ke beech tej lagataar dard?');
  String get optYes => _p('Yes', 'Haan');
  String get optNo => _p('No', 'Nahi');
  String get optNotSure => _p('Not sure', 'Pakka nahi');
  String get bleedNone => _p('None', 'Koi nahi');
  String get bleedLight => _p('Light spotting', 'Halki spotting');
  String get bleedHeavy => _p('Heavy', 'Tej');
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
  String get fatherMomentMinutes => _p('~3 min', '~3 min');
  String get startMoment => _p('Start Moment', 'Shuru Karein');

  // ---- Today | This Week toggle + Weekly Journey ---------------------------
  String get fatherTabToday => _p('Today', 'Aaj');
  String get fatherTabThisWeek => _p('This Week', 'Is Hafte');
  String get fatherWeeklyIntro => _p(
      "This week, through a father's eyes.",
      'Is hafte, ek pita ki nazar se.');
  String get fatherSecInsight => _p('Father Insight', 'Pita Ki Soch');
  String get fatherSecSupport =>
      _p('Supporting Your Partner', 'Partner Ka Saath');
  String get fatherSecConnect =>
      _p('Connecting With Your Baby', 'Baby Se Judaav');
  String get fatherSecMission => _p("This Week's Mission", 'Is Hafte Ka Mission');

  // ---- Can I? (Explore tab) ------------------------------------------------
  String get canITitle => _p('Can I?', 'Can I?');
  String get canISubtitle => _p(
      'Quick, trustworthy answers to everyday pregnancy questions.',
      'Pregnancy ke rozmarra sawaalon ke turant, bharosemand jawaab.');
  String get canISearchHint => _p(
      'Search food, drinks, medicines or activities',
      'Khaana, drinks, dawai ya activities search karein');
  String get canIPopularTitle => _p('Popular searches', 'Popular searches');
  String get canIBrowseTitle => _p('Browse by category', 'Category se dekhein');
  String get canICatEat => _p('Can I eat?', 'Kya main kha sakti hoon?');
  String get canICatDrink => _p('Can I drink?', 'Kya main pee sakti hoon?');
  String get canICatTake => _p('Can I take?', 'Kya main le sakti hoon?');
  String get canICatDo => _p('Can I do?', 'Kya main kar sakti hoon?');
  String canIDuringPregnancy(String name) =>
      _p('$name during pregnancy', 'Pregnancy mein: $name');
  String get canIWhy => _p('Why?', 'Kyun?');
  String get canITrimesterNotes => _p('Trimester notes', 'Trimester notes');
  String canITrimesterLabel(int i) => _p(
      const ['First trimester', 'Second trimester', 'Third trimester']
          [i.clamp(0, 2)],
      const ['Pehli trimester', 'Doosri trimester', 'Teesri trimester']
          [i.clamp(0, 2)]);
  String get canINowBadge => _p("You're here", 'Aap yahaan');
  String get canIIndianContext =>
      _p('In the Indian context', 'Indian context mein');
  String get canIRelated => _p('Related questions', 'Milte-julte sawaal');
  String get canIAskTitle =>
      _p('Still have a question?', 'Abhi bhi koi sawaal hai?');
  String get canIAskBody => _p('Ask Veda for guidance made for you.',
      'Apne liye banayi gayi guidance ke liye Ask Veda.');
  String get canIAskCta => _p('Ask Veda', 'Ask Veda');
  String get canIAskComingSoon => _p(
      'Ask Veda is coming soon — your personal AI guide.',
      'Ask Veda jald aa raha hai — aapka personal AI guide.');
  String get canISave => _p('Save', 'Save');
  String get canISavedBadge => _p('Saved', 'Saved');
  String get canISavedTitle => _p('Saved questions', 'Saved sawaal');
  String get canISavedEmpty => _p(
      'Nothing saved yet. Tap the bookmark on any answer to keep it here.',
      'Abhi kuch save nahi hua. Kisi bhi answer par bookmark dabakar yahaan rakhein.');
  String get canIDisclaimer => _p(
      "General guidance, not a substitute for your doctor's advice.",
      'Yeh general guidance hai, aapke doctor ki salah ka vikalp nahi.');
  String get canINoResults => _p('No match yet. Try another word — or ask Veda.',
      'Abhi koi match nahi. Doosra shabd try karein — ya Veda se poochein.');
  String canIVerdictLabel(String key) {
    switch (key) {
      case 'safe':
        return _p('Safe', 'Surakshit');
      case 'moderation':
        return _p('Safe in moderation', 'Seemit maatra mein theek');
      case 'depends':
        return _p('It depends', 'Yeh nirbhar karta hai');
      case 'avoid':
        return _p('Best avoided', 'Behtar hai na karein');
      case 'askDoctor':
        return _p('Ask your doctor', 'Apne doctor se poochein');
      default:
        return '';
    }
  }

  // ---- Understanding Your Report (Tools) -----------------------------------
  String get rTitle => _p('Understanding Your Report', 'Apni Report Samjhein');
  String get rSubtitle => _p(
      'Simple explanations for common pregnancy findings and conditions.',
      'Aam pregnancy findings aur conditions ke saral explanation.');
  String get rSearchHint => _p(
      'Search a report finding or condition', 'Koi finding ya condition search karein');
  String get rPopularTitle => _p('Popular topics', 'Popular topics');
  String get rAllTopics => _p('All topics', 'Sabhi topics');
  String get rSecMeans => _p('What does this mean?', 'Iska matlab kya hai?');
  String get rSecCommon => _p('How common is it?', 'Yeh kitna aam hai?');
  String get rSecNext =>
      _p('What usually happens next?', 'Aage aam taur par kya hota hai?');
  String get rSecWhen =>
      _p('When is it usually discussed?', 'Yeh aam taur par kab dekha jaata hai?');
  String get rTypicallyAround =>
      _p('Typically identified around', 'Aam taur par pata chalta hai');
  String rWeekRange(int? from, int? to) {
    if (from != null && to != null) return _p('Week $from–$to', 'Week $from–$to');
    if (from != null) return _p('From Week $from', 'Week $from se');
    if (to != null) return _p('Up to Week $to', 'Week $to tak');
    return '';
  }

  String get rSecQuestions => _p(
      'Questions you may want to ask your doctor',
      'Sawaal jo aap apne doctor se pooch sakti hain');
  String get rSecRemember => _p('Things to remember', 'Yaad rakhne ki baatein');
  String get rReassurance => _p(
      'Every pregnancy is unique. Your healthcare provider understands your specific situation and will guide you on the right path for you and your baby.',
      'Har pregnancy alag hoti hai. Aapke doctor aapki situation ko samajhte hain aur aapko aur aapke baby ke liye sahi raah dikhaayenge.');
  String get rAskTitle => _p('Still worried?', 'Abhi bhi chinta ho rahi hai?');
  String get rAskBody => _p('Need help understanding your situation? Ask Veda.',
      'Apni situation samajhne mein madad chahiye? Ask Veda.');
  String get rAskCta => _p('Ask Veda', 'Ask Veda');
  String get rAskComingSoon => _p(
      'Ask Veda is coming soon — your personal AI guide.',
      'Ask Veda jald aa raha hai — aapka personal AI guide.');

  // ---- Garbh Sanskar Journey (Tools) ---------------------------------------
  String get gsTitle => _p('Garbh Sanskar Journey', 'Garbh Sanskar Journey');
  String get gsSubtitle => _p(
      'A space for calm, connection and reflection during pregnancy.',
      'Pregnancy mein calm, judaav aur reflection ke liye ek jagah.');
  String get gsContinue => _p('Continue your practice', 'Apni practice jaari rakhein');
  String get gsContinueCta => _p('Continue', 'Jaari rakhein');
  String get gsWhatToday => _p('What would you like today?', 'Aaj aap kya karna chahengi?');
  String get gsShravan => _p('Shravan', 'Shravan');
  String get gsShravanTag => _p('Sacred Listening', 'Pavitra Shravan');
  String get gsSamvad => _p('Samvad', 'Samvad');
  String get gsSamvadTag => _p('Womb Connection', 'Garbh Se Judaav');
  String get gsVichara => _p('Vichara', 'Vichara');
  String get gsVicharaTag => _p('Positive Contemplation', 'Sakaratmak Vichar');
  String get gsKriya => _p('Kriya', 'Kriya');
  String get gsKriyaTag => _p('Breath & Grounding', 'Saans Aur Sthirta');
  String get gsYourJourney => _p('Your journey', 'Aapka safar');
  String get gsStatListening => _p('Listening', 'Shravan');
  String get gsStatReflections => _p('Reflections', 'Vichar');
  String get gsStatConnections => _p('Connections', 'Judaav');
  String get gsStatBreathing => _p('Breathing', 'Saans');
  String get gsFavorites => _p('Favorites', 'Pasandeeda');
  String get gsFavEmpty => _p(
      'Nothing saved yet. Tap the heart on anything you love.',
      'Abhi kuch save nahi hua. Jo pasand aaye uspar heart dabayein.');
  String get gsPlay => _p('Play', 'Chalayein');
  String get gsRead => _p('Read', 'Padhein');
  String get gsStartPractice => _p('Start practice', 'Practice shuru karein');
  String get gsTodaysConnection => _p("Today's connection", 'Aaj ka judaav');
  String get gsAnotherPrompt => _p('Another prompt', 'Doosra prompt');
  String get gsRecordVoice => _p('Record voice', 'Awaaz record karein');
  String get gsWriteMessage => _p('Write message', 'Sandesh likhein');
  String get gsSaveMemory => _p('Save to Memory Vault', 'Memory Vault mein save karein');
  String get gsMemorySaved => _p('Memory saved', 'Memory save ho gayi');
  String get gsMemorySavedBody =>
      _p('One day, your child may hear this.', 'Ek din, aapka bachcha ise sun sakta hai.');
  String get gsReflectMoment => _p('A moment to reflect', 'Ek pal thaharne ka');
  String gsMinutes(int m) => _p('$m min', '$m min');
  String gsMinRead(int m) => _p('$m minute read', '$m minute padhein');
  String get gsFinish => _p('Finish', 'Samaapt');
  String get gsWellDone => _p('Well done', 'Bahut achhe');
  String get gsWellDoneBody =>
      _p('Carry this calm with you.', 'Is shaanti ko apne saath le jaayein.');
  String get gsSampleAudio =>
      _p('A calming sample plays here — full audio coming soon.',
          'Yahaan ek calming sample bajta hai — poora audio jald aayega.');

  // ---- Community (Tools) ---------------------------------------------------
  String get cmTitle => _p('Community', 'Community');
  String get cmSearchHint => _p(
      'Search communities, topics or posts', 'Communities, topics ya posts search karein');
  String get cmJoinedSection => _p('Your communities', 'Aapki communities');
  String get cmRecommended => _p('Recommended for you', 'Aapke liye recommended');
  String get cmPulse => _p('Community Pulse', 'Community Pulse');
  String get cmFeed => _p('For you', 'Aapke liye');
  String get cmJoin => _p('Join', 'Join karein');
  String get cmJoinedBadge => _p('Joined', 'Joined');
  String get cmLeave => _p('Leave community', 'Community chhodein');
  String get cmMute => _p('Mute community', 'Community mute karein');
  String get cmUnmute => _p('Unmute community', 'Unmute karein');
  String cmMembers(int n) => _p('$n members', '$n members');
  String get cmCreatePost => _p('Create post', 'Post banayein');
  String get cmVote => _p('Vote', 'Vote');
  String get cmVoted => _p('Thanks for voting', 'Vote ke liye shukriya');
  String get cmViewDiscussion => _p('View discussion', 'Discussion dekhein');
  String get cmComments => _p('Comments', 'Comments');
  String get cmEmptyComments =>
      _p('Be the first to comment.', 'Sabse pehle comment karein.');
  String get cmAddComment => _p('Add a comment…', 'Comment likhein…');
  String get cmRelated => _p('Related discussions', 'Milti-julti discussions');
  String get cmSuggested => _p('Suggested communities', 'Suggested communities');
  String get cmAbout => _p('About', 'Iske baare mein');
  String get cmPosts => _p('Posts', 'Posts');
  String get cmPostTo => _p('Post to', 'Yahaan post karein');
  String get cmTypeLabel => _p('Type', 'Prakaar');
  String get cmSuggestedTags =>
      _p('Auto-detected topics', 'Auto-detect kiye gaye topics');

  // ---- Products ❤️ (Tools) -------------------------------------------------
  String get prTitle => _p('Products', 'Products');
  String get prTabRecommended => _p('Recommended', 'Recommended');
  String get prTabBrowse => _p('Browse all', 'Sabhi');
  String get prTabSaved => _p('Saved', 'Saved');
  String prRecommendedFor(int week) =>
      _p('Recommended for Week $week', 'Week $week ke liye recommended');
  String get prRecommendedSub => _p(
      'Selected because they are most relevant at your current stage.',
      'Aapke current stage ke liye sabse relevant cheezein.');
  String get prGuidance => _p('ParentVeda Guidance', 'ParentVeda Guidance');
  String get prLookFor => _p('Look for', 'Yeh dekhein');
  String get prAvoid => _p('Avoid', 'Inse bachein');
  String get prPicks => _p('ParentVeda Picks', 'ParentVeda Picks');
  String get prUsefulDuring => _p('Useful during', 'Kab kaam aata hai');
  String get prYouAreHere => _p('You are here', 'Aap yahaan');
  String get prWhenHelps => _p('When this helps', 'Yeh kab kaam aata hai');
  String prYouWeek(int week) => _p('You · Wk $week', 'Aap · Wk $week');
  String get prRelevantNow => _p('Useful for you now', 'Abhi aapke liye useful');
  String prComingUp(int week) =>
      _p('Useful from around Week $week', 'Lagbhag Week $week se useful');
  String prHelpsSentence(int from, String toLabel) {
    final en = toLabel == 'Postpartum' ? 'after birth' : 'birth';
    final hi = toLabel == 'Postpartum' ? 'janm ke baad tak' : 'janm tak';
    return _p('Recommended from Week $from through $en.',
        'Week $from se $hi recommended.');
  }
  String get prScore => _p('ParentVeda Score', 'ParentVeda Score');
  String get prBestFor => _p('Best for', 'Kiske liye behtar');
  String get prWhy => _p('Why ParentVeda recommends this',
      'ParentVeda ise kyun recommend karta hai');
  String get prConsider => _p('Things to consider', 'Dhyaan rakhne ki baatein');
  String get prBuyNow => _p('Buy now', 'Abhi khareedein');
  String get prCompare => _p('Compare', 'Compare');
  String prBrowseAllCount(int n) => _p('Browse all $n', 'Sabhi $n dekhein');
  String get prVerdict => _p('ParentVeda Verdict', 'ParentVeda Verdict');
  String get prReviewSummary => _p('What parents say', 'Parents kya kehte hain');
  String get prMostLoved => _p('Most loved', 'Sabse pasand');
  String get prPraise => _p('Most mentioned praise', 'Sabse zyada taareef');
  String get prDrawback => _p('Most mentioned drawback', 'Sabse zyada kami');
  String get prWouldBuyAgain => _p('Would buy again', 'Dobara khareedenge');
  String get prReviews => _p('Real parent reviews', 'Asli parent reviews');
  String get prUsedDuring => _p('Used during', 'Kab istemaal kiya');
  String get prLiked => _p('What I liked', 'Mujhe kya pasand aaya');
  String get prWatchOut => _p('Watch out for', 'Iska dhyaan rakhein');
  String get prRelated => _p('Related products', 'Milte-julte products');
  String get prSavedEmpty => _p(
      'Nothing saved yet. Tap the heart on any product to keep it here.',
      'Abhi kuch save nahi hua. Kisi bhi product par heart dabakar yahaan rakhein.');
  String get prComingSoon =>
      _p('Buying opens soon — saving works now ❤️', 'Buying jald — saving abhi chalta hai ❤️');
  String get prSearchHint => _p('Search products', 'Products search karein');
  String prBadge(String key) {
    switch (key) {
      case 'bestOverall':
        return _p('Best Overall', 'Best Overall');
      case 'bestBudget':
        return _p('Best Budget', 'Best Budget');
      case 'bestPremium':
        return _p('Best Premium', 'Best Premium');
      case 'sensitiveSkin':
        return _p('Best for Sensitive Skin', 'Sensitive Skin ke liye');
      case 'newborns':
        return _p('Best for Newborns', 'Newborns ke liye');
      default:
        return '';
    }
  }
  String get cmShareSomething =>
      _p('What would you like to share?', 'Aap kya share karna chahengi?');
  String get cmShare => _p('Share', 'Share karein');
  String get cmPosted => _p('Posted to your community ❤️', 'Aapki community mein post ho gaya ❤️');
  String get cmExpertBadge => _p('Expert', 'Expert');
  String get cmComingSoon => _p('Coming soon', 'Jald aa raha hai');
  String get cmRemindMe => _p('Remind me', 'Yaad dilayein');
  String cmPostType(String key) {
    switch (key) {
      case 'question':
        return _p('Question', 'Sawaal');
      case 'experience':
        return _p('Experience', 'Anubhav');
      case 'poll':
        return _p('Poll', 'Poll');
      case 'photo':
        return _p('Photo', 'Photo');
      case 'milestone':
        return _p('Milestone', 'Padaav');
      case 'expert':
        return _p('Expert', 'Expert');
      case 'parentVeda':
        return _p('ParentVeda', 'ParentVeda');
      default:
        return '';
    }
  }

  // ---- Read Next ❤️ (Home) -------------------------------------------------
  String get rnTitle => _p('Read Next', 'Read Next');
  String get rnSubtitle => _p('Handpicked reading for your stage of pregnancy.',
      'Aapki pregnancy stage ke liye chuni hui reading.');
  String get rnThisWeekPick => _p("This Week's Pick", 'Is Hafte Ki Pick');
  String get rnWhyNow => _p('Why this matters now', 'Yeh abhi kyun zaroori hai');
  String get rnReadNow => _p('Read now', 'Abhi padhein');
  String get rnRecommended => _p('Recommended for this week', 'Is hafte ke liye recommended');
  String get rnLookingAhead => _p('Looking ahead', 'Aage ki taiyaari');
  String rnComingUp(int week) => _p('Coming up around Week $week', 'Lagbhag Week $week ke aaspaas');
  String get rnBooks => _p('Books we love', 'Pasandeeda kitaabein');
  String get rnResearch => _p('Research simplified', 'Research aasaan bhaasha mein');
  String get rnExperts => _p('Expert recommendations', 'Expert ki salah');
  String get rnRecommendedBy => _p('Recommended by', 'Recommend kiya');
  String get rnWhyRecommend =>
      _p('Why ParentVeda recommends it', 'ParentVeda ise kyun recommend karta hai');
  String get rnSavedSection => _p('Saved for later', 'Baad ke liye saved');
  String get rnSavedEmpty => _p(
      'Nothing saved yet. Tap the heart on anything you want to read later.',
      'Abhi kuch save nahi hua. Jo baad mein padhna ho uspar heart dabayein.');
  String get rnSaveBadge => _p('Saved', 'Saved');
  String get rnMarkReading => _p('Mark as reading', 'Reading par lagayein');
  String get rnReadingBadge => _p('Reading', 'Reading');
  String get rnMarkDone => _p('Mark as completed', 'Completed par lagayein');
  String get rnCompletedBadge => _p('Completed', 'Completed');
  String get rnMoreReading => _p('More reading', 'Aur reading');
  String get rnKnowMore => _p('Know more', 'Aur jaanein');
  String get rnBuyNow => _p('Buy now', 'Abhi khareedein');
  String get rnBuyComingSoon =>
      _p('Buying opens soon — saving works now ❤️', 'Buying jald — saving abhi chalta hai ❤️');
  String get rnSearchHint => _p('Search reading', 'Reading search karein');
  String get rnNewResearch => _p('New research', 'Nayi research');

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
