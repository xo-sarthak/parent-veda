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
      _p('Create your keepsake booklet', 'Apni yaadon ki kitaab banayein');
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
}
