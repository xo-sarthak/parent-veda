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

  // ---- Direction B "Warm Nest" Home (hero, rituals, quick row, splash) ------
  String weekDayLine(int week, int day) =>
      _p('Week $week, Day $day', 'Hafta $week, Din $day');
  String babyIsSize(String fruit) =>
      _p('Your baby is $fruit', 'Aapka baby $fruit jitna');
  String momentDone(int done, int total) =>
      _p('$done of $total done', '$total mein se $done poore');
  String get ritualGrow => _p('Grow', 'Grow');
  String get ritualRead => _p('Read', 'Padhein');
  String get ritualTalk => _p('Talk', 'Baat');
  String get ritualSanskar => _p('Sanskar', 'Sanskar');
  String get ritualForYou => _p('For you', 'Aapke liye');
  String get quickKicks => _p('Kicks', 'Kicks');
  String quickKicksValue(int n) => _p('$n today', 'aaj $n');
  String get quickWater => _p('Water', 'Paani');
  String quickWaterValue(int n) => _p('$n glasses', '$n glass');
  String get splashTagline => _p('Nurturing wisdom', 'Nurturing wisdom');
  String get splashFooter =>
      _p('Your calm companion 💜', 'Aapka shaant saathi 💜');

  // ===========================================================================
  //  MY JOURNAL — the mother's pregnancy memory timeline
  // ===========================================================================
  String get jrTitle => _p('My Journal', 'My Journal');
  String get jrSubtitle =>
      _p('Your pregnancy story, one day at a time',
          'Aapki pregnancy ki kahani, ek-ek din');
  String get jrFilterAll => _p('All', 'Sab');
  String get jrFilterMemories => _p('Memories', 'Yaadein');
  String get jrFilterPhotos => _p('Photos', 'Photos');
  String get jrTakePhoto => _p('Take a photo', 'Photo kheenchein');
  String get jrChooseGallery => _p('Choose from gallery', 'Gallery se chunein');
  String get jrFilterMilestones => _p('Milestones', 'Padaav');
  String get jrFilterHealth => _p('Health', 'Sehat');
  String get jrFilterScans => _p('Scans', 'Scans');
  String get jrFilterBaby => _p('Baby', 'Baby');
  String get jrEmptyTitle => _p('Your pregnancy story begins here.',
      'Aapki pregnancy ki kahani yahin se shuru hoti hai.');
  String get jrEmptyBody => _p(
      'Capture a memory, a photo, or a note for your baby — it all gathers here.',
      'Ek yaad, ek photo, ya baby ke liye ek note save karein — sab yahin jama hoga.');
  String get jrCreateFirst => _p('Create First Memory', 'Pehli Yaad Banayein');
  String get jrCreateMemory => _p('Create Memory', 'Yaad Banayein');
  String get jrWriteMemory => _p('Write Memory', 'Yaad Likhein');
  String get jrAddPhoto => _p('Add Photo', 'Photo Add Karein');
  String get jrRecordVoice =>
      _p('Record Voice Note', 'Voice Note Record Karein');
  String get jrNoteForBaby => _p('Note for Baby', 'Baby Ke Liye Note');
  String get jrVoiceSoon =>
      _p('Voice memories are coming soon 💜', 'Voice memories jaldi aa rahi hain 💜');
  String get jrSearchHint =>
      _p('Search your journal', 'Apni journal mein search karein');
  String get jrExport => _p('Export', 'Export');
  String get jrExportSoon => _p(
      'Your printable memory book is coming soon 💜',
      'Aapki printable memory book jaldi aa rahi hai 💜');
  String get jrMemoryHint => _p('Write your memory…', 'Apni yaad likhein…');
  String get jrNoteForBabyHint =>
      _p('Write to your baby…', 'Apne baby ko likhein…');
  String get jrCaptionHint =>
      _p('Add a caption (optional)', 'Caption add karein (optional)');
  String get jrSaveMemory => _p('Save', 'Save karein');
  String get jrSavedMemory =>
      _p('Saved to your journal 💜', 'Aapki journal mein save ho gaya 💜');
  // Daily "My Journal" section + create flows
  String get jcMyJournal => _p('My Journal', 'Meri Journal');
  String get jcViewTimeline =>
      _p('View My Journal Timeline', 'Meri Journal Timeline dekhein');
  String get jcCustom => _p('Custom', 'Custom');
  String get jcCustomTagHint =>
      _p('Tag (e.g. Cravings, A dream)', 'Tag (jaise Cravings)');
  String get jcCustomBodyHint => _p(
      'Write anything you want to remember…', 'Jo yaad rakhna ho likhein…');
  String get jcRecordTitle =>
      _p('Record a voice note', 'Voice note record karein');
  String get jcTapToRecord =>
      _p('Tap the mic to start', 'Shuru karne ke liye mic tap karein');
  String get jcRecording =>
      _p('Recording… tap to stop', 'Record ho raha hai… rokne ke liye tap karein');
  String get jcRecordAnother =>
      _p('Tap to record another', 'Ek aur record karne ke liye tap karein');
  String get jcMicNeeded => _p('Microphone permission is needed to record.',
      'Record karne ke liye microphone permission chahiye.');
  // "Entry saved" confirmation snackbars.
  String get jcSavedMemory => _p('Memory saved 💜', 'Yaad save ho gayi 💜');
  String get jcSavedNote =>
      _p('Note for baby saved 💜', 'Baby ke liye note save ho gaya 💜');
  String get jcSavedPhoto =>
      _p('Photo added to your journal', 'Photo aapke journal mein add ho gayi');
  String get jcSavedVoice =>
      _p('Voice note saved', 'Voice note save ho gaya');
  String get jcUpdated => _p('Entry updated', 'Entry update ho gayi');
  // Speech-to-text mic button.
  String get micTap => _p('Tap to dictate', 'Bolkar likhne ke liye tap karein');
  String get micListening => _p('Listening…', 'Sun raha hai…');
  String get micDenied => _p('Microphone/speech permission is needed to dictate.',
      'Bolkar likhne ke liye microphone/speech permission chahiye.');
  String get jcVoiceNote => _p('Voice note', 'Voice note');
  String get jrDeleteEntryQ =>
      _p('Delete this entry?', 'Yeh entry delete karein?');
  String get jrNothingHere => _p(
      'Nothing here yet — add your first one with the button below.',
      'Abhi yahan kuch nahi — neeche button se apni pehli add karein.');
  String jrWeekLabel(int w) => _p('Week $w', 'Hafta $w');
  // Journal views (grouped list + flip-through booklet).
  String get jrListView => _p('List view', 'List view');
  String get jrBookletView => _p('Booklet', 'Booklet');
  String get jrGroupBy => _p('Group by', 'Group by');
  String get jrByMonth => _p('Month', 'Mahina');
  String get jrByWeek => _p('Week', 'Hafta');
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
      ? _p('My Pregnancy Journal', 'My Pregnancy Journal')
      : _p("$name's Pregnancy Journal", "$name ka Pregnancy Journal");
  String jrCoverWeeks(int a, int b) => _p('Weeks $a–$b', 'Hafte $a–$b');
  String get jrCoverHint =>
      _p('Swipe to flip through', 'Palatne ke liye swipe karein');
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
          'Aaj kis baat ne aapko muskuraaya?',
          'Abhi aap sabse zyada kis baat ke liye excited hain?',
          'Aaj ke baare mein aap apne baby ko kya bataana chahengi?',
          'Is hafte kis baat ne aapko hairaan kiya?',
          'Apne baby ke liye ek message likhein.',
          'Aaj aap kis baat ke liye shukrguzaar hain?',
        ];
  // Auto-entry titles.
  String jrWeekDone(int w) => _p('Week $w completed', 'Hafta $w poora hua');
  String get jrFirstTriDone =>
      _p('First trimester complete', 'Pehli trimester poori');
  String get jrSecondTriDone =>
      _p('Second trimester complete', 'Doosri trimester poori');
  String get jrThirdTriStart =>
      _p('Third trimester started', 'Teesri trimester shuru');
  String get jrHalfway => _p('Halfway there', 'Aadha safar poora');
  String get jrViability =>
      _p('Viability milestone reached', 'Viability padaav tak pahunche');
  String get jrFullTerm => _p('Full term reached', 'Full term tak pahunche');
  String get jrWeightLogged => _p('Weight logged', 'Wazan note hua');
  String get jrKickSession => _p('Kick session logged', 'Kick session note hua');
  String get jrFirstKick => _p('First kick recorded', 'Pehli kick record hui');
  String jrMovementsCount(int n) =>
      _p(n == 1 ? '1 movement' : '$n movements',
          n == 1 ? '1 movement' : '$n movements');
  // "Where your journal fills from" info sheet + per-filter empty states.
  String get jrInfoTitle =>
      _p('Where your journal fills from', 'Aapki journal kahan se bharti hai');
  String get jrInfoIntro => _p(
      'Some entries you add yourself; others appear automatically as you use the app.',
      'Kuch entries aap khud add karti hain; kuch app use karte hue apne aap aa jaati hain.');
  String get jrSrcMemories =>
      _p('Memories — written by you.', 'Yaadein — aap likhti hain.');
  String get jrSrcBaby => _p(
      'Notes for baby — written by you, in their own space.',
      'Baby ke liye notes — aap likhti hain, unki apni jagah.');
  String get jrSrcPhotos => _p('Photos — added by you from your gallery.',
      'Photos — aap apni gallery se add karti hain.');
  String get jrSrcMilestones => _p('Milestones — automatic, from your due date.',
      'Padaav — apne aap, aapki due date se.');
  String get jrSrcHealth => _p(
      'Weight, kicks & symptoms — from your trackers and Symptoms Companion.',
      'Wazan, kicks aur symptoms — aapke trackers aur Symptoms Companion se.');
  String get jrSrcScans => _p(
      'Scans & reports — appear once uploads are available (coming soon).',
      'Scans aur reports — upload available hone par aayenge (jaldi aa raha hai).');
  String get jrEmptyMemories => _p(
      'Your memories will gather here. Tap Create Memory to write your first.',
      'Aapki yaadein yahan jama hongi. Pehli likhne ke liye Create Memory dabaayein.');
  String get jrEmptyPhotos => _p(
      'Your photos will gather here. Add one with Create Memory.',
      'Aapki photos yahan jama hongi. Create Memory se ek add karein.');
  String get jrEmptyMilestones => _p(
      'Milestones appear here automatically as your pregnancy grows 💜',
      'Padaav yahan apne aap aate hain jaise aapki pregnancy aage badhti hai 💜');
  String get jrEmptyHealth => _p(
      'Your weight and kick logs gather here automatically from the trackers.',
      'Aapke wazan aur kick logs yahan apne aap trackers se aate hain.');
  String get jrEmptyScans => _p(
      'Scans & reports will appear here once uploads are available — coming soon 💜',
      'Scans aur reports yahan upload available hone par aayenge — jaldi aa raha hai 💜');
  String get jrEmptyBaby => _p(
      'Your notes for baby will gather here. Write your first with Create Memory.',
      'Baby ke liye aapke notes yahan jama honge. Pehla Create Memory se likhein.');

  // ===========================================================================
  //  MY CALENDAR — the pregnancy command center
  // ===========================================================================
  String get tabCalendar => _p('Calendar', 'Calendar');
  String get calTitle => _p('My Calendar', 'My Calendar');
  String get calTabTimeline => _p('Timeline', 'Timeline');
  String get calTabCalendar => _p('Calendar', 'Calendar');
  String get calTabUpcoming => _p('Upcoming', 'Aage');
  String calDaysTogether(int n) => _p('$n Days Together', '$n Din Saath');
  String get calFilterAll => _p('All', 'Sab');
  String get calFilterMilestones => _p('Milestones', 'Padaav');
  String get calFilterMedical => _p('Medical', 'Medical');
  String get calFilterJournal => _p('Journal', 'Journal');
  String get calFilterPersonal => _p('Personal', 'Niji');
  String get calFilterParentveda => _p('ParentVeda', 'ParentVeda');
  String get calSearchHint => _p('Search events', 'Events search karein');
  String get calThisWeek => _p('This week', 'Is hafte');
  String get calNext2Weeks => _p('Next 2 weeks', 'Agle 2 hafte');
  String get calThisMonth => _p('This month', 'Is mahine');
  String get calLater => _p('Later', 'Baad mein');
  String get calTimelineEmpty => _p(
      'Your journey will appear here as it unfolds.',
      'Aapka safar yahan dikhega jaise woh aage badhega.');
  String get calUpcomingEmpty => _p(
      'Nothing scheduled ahead right now.', 'Abhi aage kuch tay nahi hai.');
  String get calNoEventsDay => _p('Nothing on this day.', 'Is din kuch nahi.');
  String get calAddPersonal =>
      _p('Add personal event', 'Niji event add karein');
  String get calEventTitleHint => _p('Event name', 'Event ka naam');
  String get calEventNoteHint => _p('Note (optional)', 'Note (optional)');
  String get calStatusCompleted => _p('Completed', 'Poora');
  String get calStatusUpcoming => _p('Upcoming', 'Aane wala');
  String calOpenWeek(int n) => _p('Open Week $n', 'Hafta $n kholein');
  String get calOpenJournal => _p('Open Journal', 'Journal kholein');
  String calInDays(int n) => n <= 0
      ? _p('Today', 'Aaj')
      : (n == 1 ? _p('Tomorrow', 'Kal') : _p('In $n days', '$n din mein'));
  String calMonthYear(DateTime d) =>
      '${_months[(d.month - 1).clamp(0, 11)]} ${d.year}';
  List<String> get calWeekdayLetters =>
      const ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  // ===========================================================================
  //  MY BUMP JOURNEY — the visual pregnancy timeline
  // ===========================================================================
  String get bumpTitle => _p('My Bump Journey', 'My Bump Journey');
  String get bumpSubtitle =>
      _p('Your bump, week by week', 'Aapka bump, hafte-dar-hafte');
  String get bumpEmptyTitle => _p('Your bump journey begins here.',
      'Aapka bump safar yahin se shuru hota hai.');
  String get bumpEmptyBody =>
      _p('Capture your first memory ❤', 'Apni pehli yaad kaid karein ❤');
  String get bumpAddFirst => _p('Add First Photo', 'Pehli Photo Add Karein');
  String get bumpAddPhoto => _p('Add Photo', 'Photo Add Karein');
  String get bumpTakePhoto => _p('Take Photo', 'Photo Kheechein');
  String get bumpUpload => _p('Upload Photo', 'Photo Upload Karein');
  String bumpPhotosAdded(int n) => _p('$n Photos Added', '$n Photos Add Hui');
  String get bumpThenNow => _p('Then & Now', 'Pehle & Ab');
  String get bumpThen => _p('Then', 'Pehle');
  String get bumpNow => _p('Now', 'Ab');
  String bumpCaptureThisWeek(int w) => _p(
      'Week $w — would you like to capture this week?',
      'Hafta $w — is hafte ko kaid karna chahengi?');
  String get bumpFilterAll => _p('All', 'Sab');
  String get bumpFilterT1 => _p('Trimester 1', 'Trimester 1');
  String get bumpFilterT2 => _p('Trimester 2', 'Trimester 2');
  String get bumpFilterT3 => _p('Trimester 3', 'Trimester 3');
  String get bumpFilterCaptioned => _p('With captions', 'Caption ke saath');
  String get bumpFilterFavorites => _p('Favorites', 'Pasandeeda');
  String get bumpNothingForFilter =>
      _p('No photos here yet.', 'Yahan abhi koi photo nahi.');
  String get bumpExportSoon => _p('Your bump memory book is coming soon ❤',
      'Aapki bump memory book jaldi aa rahi hai ❤');
  String get bumpSaved => _p('Saved to your bump journey ❤',
      'Aapke bump safar mein save ho gaya ❤');
  String bumpJournalTitle(int w) =>
      _p('Bump photo · Week $w', 'Bump photo · Hafta $w');
  String get bumpEditCaption => _p('Edit caption', 'Caption edit karein');
  List<String> get bumpCaptionSuggestions => _e
      ? const [
          'Today I felt stronger.',
          'Halfway there ❤',
          'Baby is growing beautifully.',
          'Feeling excited.',
          'Our journey continues.',
        ]
      : const [
          'Aaj main aur mazboot mehsoos kar rahi hoon.',
          'Aadha safar poora ❤',
          'Baby khoobsurati se badh raha hai.',
          'Bahut excited feel ho raha hai.',
          'Hamara safar jaari hai.',
        ];

  // ===========================================================================
  //  DAILY MEDICATION & SUPPLEMENTS
  // ===========================================================================
  String get medTitle =>
      _p('Medication & Supplements', 'Medication & Supplements');
  String get medTodayNourishment =>
      _p("Today's Nourishment ❤", 'Aaj Ka Poshan ❤');
  String medProgress(int done, int total) =>
      _p('$done of $total completed today', '$total mein se $done aaj poore');
  String get medTaken => _p('Taken', 'Le liya');
  String get medTakenDone => _p('Taken ✓', 'Le liya ✓');
  String medLogged(String name) => _p('$name logged ❤', '$name log ho gaya ❤');
  String get medAddNew => _p('Add New', 'Naya Add Karein');
  String get medSetupTitle => _p(
      "Let's set up your supplements ❤", 'Aaiye aapke supplements set karein ❤');
  String get medSetupBody => _p(
      'Which supplements has your doctor recommended?',
      'Aapke doctor ne kaunse supplements recommend kiye hain?');
  String get medAddCustom =>
      _p('Add custom medication', 'Custom medication add karein');
  String get medTabDaily => _p('Daily', 'Rozaana');
  String get medTabWeekly => _p('Weekly', 'Saptaahik');
  String get medWeekOverview => _p('Week overview', 'Hafte ka overview');
  String medDaysOf7(int n) => _p('$n/7 days', '$n/7 din');
  String medConsistency(int n) => _p(
      'You recorded your supplements on $n of the last 30 days.',
      'Aapne pichhle 30 dinon mein se $n din apne supplements record kiye.');
  String get medName => _p('Name', 'Naam');
  String get medDose => _p('Dose', 'Khuraak');
  String get medTime => _p(
      'Time (e.g. 8 PM, after breakfast)', 'Samay (jaise 8 PM, nashte ke baad)');
  String get medFrequency => _p(
      'Frequency (e.g. once daily)', 'Kitni baar (jaise rozaana ek baar)');
  String get medNotes => _p('Notes (optional)', 'Notes (optional)');
  String get medAddTitle => _p('Add medication', 'Medication add karein');
  String get medDeleteQ =>
      _p('Remove this from your list?', 'Ise apni list se hataayein?');
  String get medDisclaimer => _p('Tracking only — always follow your doctor.',
      'Sirf tracking — hamesha apne doctor ki salah maanein.');
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
            'Pregnancy mein sehatmand blood banane mein madad karta hai.');
      case 'calcium':
        return _p("Supports your baby's bone development.",
            'Aapke baby ki haddiyon ke vikas mein madad karta hai.');
      case 'folicAcid':
        return _p("Supports your baby's early development.",
            'Aapke baby ke shuruaati vikas mein madad karta hai.');
      case 'vitaminD':
        return _p('Supports calcium absorption and immunity.',
            'Calcium absorption aur immunity mein madad karta hai.');
      case 'dha':
        return _p("Supports your baby's brain and eye development.",
            'Aapke baby ke dimaag aur aankhon ke vikas mein madad karta hai.');
      case 'multivitamin':
        return _p('A daily blend of key pregnancy nutrients.',
            'Pregnancy ke zaroori nutrients ka rozaana mishran.');
      default:
        return '';
    }
  }

  // ---- Tools hub + Home Garbh ----------------------------------------------
  String get toolCanI => _p('Can I?', 'Can I?');
  String get toolsSupportNote => _p(
      'Supportive, never clinical — always check with your doctor.',
      'Sahaayak, kabhi clinical nahi — hamesha apne doctor se poochein.');
  String get homeGarbhSubtitle =>
      _p('Five gentle daily rituals', 'Paanch pyaari rozaana rituals');

  // ===========================================================================
  //  WATCH & LEARN — contextual videos
  // ===========================================================================
  String get vidTodaysVideo => _p("Today's Video ❤", 'Aaj Ka Video ❤');
  String get vidWhyNow =>
      _p('Why this matters now', 'Yeh abhi kyun maayne rakhta hai');
  String get vidWatch => _p('Watch', 'Dekhein');
  String get vidSave => _p('Save', 'Save');
  String get vidSaved => _p('Saved', 'Saved');
  String get vidMoreVideos => _p('More videos', 'Aur videos');
  String get vidComingSoon => _p('This video is on its way — coming soon ❤',
      'Yeh video jald aa raha hai — coming soon ❤');
  String get vidScreenTitle => _p('Watch & Learn', 'Watch & Learn');
  String get vidSecRecommended =>
      _p('Recommended for this week', 'Is hafte ke liye');
  String get vidSecSkill => _p('Learn a skill', 'Ek skill seekhein');
  String get vidSecExpert => _p('Expert explains', 'Expert samjhaate hain');
  String get vidSecBirth => _p('Birth preparation', 'Janm ki taiyaari');
  String get vidSecNewborn => _p('Newborn preparation', 'Newborn ki taiyaari');
  String get vidSecSaved => _p('Saved videos', 'Save kiye videos');
  String get savedVaultTitle => _p('Saved', 'Saved');
  String get savedVaultSubtitle => _p(
      'Your bookmarked videos, in one place.',
      'Aapke bookmark kiye videos, ek jagah.');
  // Saved hub (Profile › Saved).
  String get savedHubSubtitle => _p(
      'Your saved reads, videos & read-to-baby, all here.',
      'Aapke saved reads, videos & read-to-baby, sab yahan.');
  String get shTitle => _p('Saved', 'Saved');
  String get shReadToBaby => _p('Saved read-to-baby', 'Saved read-to-baby');
  String get shReads => _p('Saved reads', 'Saved reads');
  String get shWatch => _p('Watch & Learn', 'Watch & Learn');
  String get shRead => _p('Read more', 'Aur padhein');
  String get shEmpty => _p(
      "Nothing saved yet. Tap the bookmark on a read, a video or a read-to-baby piece and it'll show up here.",
      'Abhi kuch save nahi hua. Kisi read, video ya read-to-baby piece par bookmark dabayein — woh yahan dikhega.');
  String get rtbSave => _p('Save', 'Save karein');

  // ===========================================================================
  //  SYMPTOMS COMPANION
  // ===========================================================================
  String get symTitle => _p('Symptoms Companion ❤', 'Symptoms Companion ❤');
  String get symToolTitle => _p('Symptoms', 'Lakshan');
  String get symSearchHint => _p(
      'What are you experiencing today?', 'Aaj aap kya mehsoos kar rahi hain?');
  String symCommonNow(int week) =>
      _p('Common around Week $week', 'Hafta $week ke aas-paas aam');
  String get symBrowse => _p('Browse by category', 'Category se dekhein');
  String get symAll => _p('All symptoms', 'Saare lakshan');
  String get symHowCommon => _p('How common is it?', 'Yeh kitna aam hai?');
  String get symWhy => _p('Why it happens', 'Yeh kyun hota hai');
  String get symWhatHelps => _p('What may help', 'Kya madad kar sakta hai');
  String get symWhenDoctor =>
      _p('When to contact your doctor', 'Doctor se kab sampark karein');
  String get symLog => _p('Log this symptom', 'Yeh symptom log karein');
  String symLogged(String name) => _p('Logged: $name', '$name log hua');
  String get symSeverity => _p('How strong is it?', 'Kitna tez hai?');
  String get symMild => _p('Mild', 'Halka');
  String get symModerate => _p('Moderate', 'Madhyam');
  String get symSevere => _p('Severe', 'Tej');
  String get symAddToJournal =>
      _p('Add to my journal', 'Meri journal mein add karein');
  String get symUrgentTitle => _p('When to seek care', 'Kab turant care lein');
  String get symUrgentBody => _p(
      'These are signs to contact your doctor or maternity unit.',
      'Ye sanket hain jab doctor ya maternity unit se sampark karein.');
  String symInsight(String name, int n) => _p(
      "You've noted $name $n times this week.",
      'Aapne is hafte $name $n baar note kiya.');
  String symJournalText(String name) =>
      _p('You noted $name today.', 'Aapne aaj $name note kiya.');
  String get symNoResults =>
      _p('No matches — try another word.', 'Koi match nahi — doosra shabd try karein.');
  String get symDisclaimer => _p(
      'For understanding, not diagnosis — your doctor is always the best guide.',
      'Samajhne ke liye, nidaan nahi — aapka doctor hamesha sabse achhi salah dete hain.');
  String get symCatDigestive => _p('Digestive', 'Pachan');
  String get symCatPhysical => _p('Physical', 'Sharirik');
  String get symCatSleep => _p('Sleep', 'Neend');
  String get symCatEmotional => _p('Emotional', 'Bhaavnaayein');
  String get symCatCirculation => _p('Circulation', 'Circulation');
  String get symCatMovement => _p('Baby movement', 'Baby movement');
  String get symCatLabour => _p('Labour signs', 'Labour ke sanket');
  String get symCatUrgent => _p('Urgent', 'Urgent');

  // ===========================================================================
  //  SCANS & APPOINTMENTS — care roadmap
  // ===========================================================================
  String get calFilterAppointments => _p('Appointments', 'Appointments');
  String get calChildbirth => _p('Birth', 'Janm');
  String get calAddNote => _p('Add Note', 'Note jodein');
  String get calNoNotesDay =>
      _p('No notes for this day yet.', 'Is din ke liye abhi koi note nahi.');
  String get calWeeksUpper => _p('WEEKS', 'HAFTE');
  // Selected-day panel + colour-code legend.
  String get calOnThisDay => _p('On this day', 'Is din');
  String get calLegendTitle =>
      _p('What the dots mean', 'In dots ka matlab');
  String calTrimesterTag(int t) => switch (t) {
        1 => _p('1st tri', '1st tri'),
        2 => _p('2nd tri', '2nd tri'),
        _ => _p('3rd tri', '3rd tri'),
      };
  String calTrimesterStart(int t) => switch (t) {
        1 => _p('1st trimester begins', '1st trimester shuru'),
        2 => _p('2nd trimester begins', '2nd trimester shuru'),
        _ => _p('3rd trimester begins', '3rd trimester shuru'),
      };
  String get calMeanMilestone =>
      _p('A pregnancy milestone', 'Pregnancy ka ek milestone');
  String get calMeanMedical =>
      _p('A scan, test or vaccination', 'Scan, test ya vaccination');
  String get calMeanAppointment =>
      _p('A doctor appointment', 'Doctor appointment');
  String get calMeanJournal => _p(
      'A memory, photo or log you saved', 'Aapki saved memory, photo ya log');
  String get calMeanPersonal =>
      _p('A personal note you added', 'Aapka jodaa hua note');
  String get calMeanParentveda => _p(
      'A ParentVeda unlock or "days together"',
      'ParentVeda unlock ya "saath ke din"');
  String get calMeanWeekStart =>
      _p('The start of a pregnancy week', 'Pregnancy hafte ki shuruaat');
  String get calMeanTrimester =>
      _p('A new trimester begins', 'Naya trimester shuru');
  String get calMeanBirth => _p('Your due date', 'Aapki due date');
  String get calLegendWeekStart => _p('Week start', 'Hafte ki shuruaat');
  String get calLegendTrimester => _p('Trimester start', 'Trimester shuru');
  String get calLegendBirth => _p('Due date', 'Due date');
  String get scnTitle => _p('Scans & Appointments ❤', 'Scans & Appointments ❤');
  // Daily-home "Scans & appointments" card (the due-now list + view-all).
  String get scnDailyTitle => _p('Scans & appointments', 'Scans & appointments');
  String get scnAlreadyDone => _p('Already done', 'Pehle se ho gaya');
  String get scnViewAll => _p('View all scans', 'Sabhi scans dekhein');
  String get scnToolTitle => _p('Scans & Care', 'Scans & Care');
  String get scnTabUpcoming => _p('Upcoming', 'Aage');
  String get scnTabCompleted => _p('Completed', 'Poore');
  String get scnTabRoadmap => _p('Care roadmap', 'Care roadmap');
  String get scnNextUp => _p('NEXT UP', 'AGLA');
  String get scnLearnMore => _p('Learn more', 'Aur jaanein');
  String get scnMarkDone => _p('Mark completed', 'Poora mark karein');
  String get scnMarkedDone => _p('Completed ✓', 'Poora ✓');
  String get scnImportantNote => _p(
      'Every pregnancy is unique — your doctor will guide you based on your situation.',
      'Har pregnancy alag hai — aapke doctor aapki situation ke hisaab se salah denge.');
  // Scan guide — "what is this scan" + "how to interpret the report".
  String get scnWhatIs => _p('What is this scan?', 'Yeh scan kya hai?');
  String get scnHowToInterpret =>
      _p('How to interpret the report', 'Report kaise samjhein');
  String get scnInterpretSub => _p('Understand the terms on your report',
      'Apni report ke terms samjhein');
  String get scnInterpretHeading =>
      _p('Reading your report', 'Apni report padhna');
  String get scnInterpretDisclaimerTitle =>
      _p('Not for medical diagnosis', 'Medical diagnosis ke liye nahi');
  String get scnInterpretDisclaimer => _p(
      'This explains common terms to help you understand YOUR report and ask better questions. It is general information — NOT a diagnosis or medical advice, and ParentVeda is not a medical service. Always rely on your doctor or sonographer to interpret your actual results.',
      'Yeh aam terms samjhata hai taaki aap APNI report samjhein aur behtar sawaal pooch sakein. Yeh saamaanya jaankari hai — koi diagnosis ya medical salah NAHI, aur ParentVeda koi medical service nahi. Apne result samajhne ke liye hamesha apne doctor ya sonographer par bharosa karein.');
  String get scnUpToDate => _p("You're up to date — nothing due right now ❤",
      'Aap up to date hain — abhi kuch due nahi ❤');
  String get scnNoCompleted => _p(
      'Scans you mark completed will gather here.',
      'Jo scans aap poore mark karengi woh yahan jama honge.');
  String get scnDelivery => _p('Delivery', 'Delivery');
  String get scnAppts => _p('Your appointments', 'Aapke appointments');
  String get scnAddAppt => _p('Add appointment', 'Appointment add karein');
  String get scnApptTitle => _p('Title', 'Title');
  String get scnApptTime => _p('Time (optional)', 'Samay (optional)');
  String get scnApptLocation => _p('Location (optional)', 'Jagah (optional)');
  String get scnApptDoctor => _p('Doctor (optional)', 'Doctor (optional)');
  String get scnTypeDoctor => _p('Doctor visit', 'Doctor visit');
  String get scnTypeScan => _p('Scan', 'Scan');
  String get scnTypeTest => _p('Test', 'Test');
  String get scnTypeVaccination => _p('Vaccination', 'Vaccination');
  String get scnTypeCustom => _p('Custom', 'Custom');
  String scnCompletedJournal(String name) =>
      _p('$name — completed', '$name — poora');

  // ===========================================================================
  //  DUE DATE CALCULATOR
  // ===========================================================================
  String get ddcTitle => _p('Due Date Calculator', 'Due Date Calculator');
  String get ddcToolTitle => _p('Due Date', 'Due Date');
  String get ddcHeader => _p('When is my baby due?', 'Mera baby kab due hai?');
  String get ddcSub => _p(
      'Calculate your due date, timeline and upcoming milestones.',
      'Apni due date, timeline aur aane wale padaav nikaalein.');
  String get ddcMethod =>
      _p('How would you like to calculate?', 'Aap kaise calculate karna chahengi?');
  String get ddcLmp => _p('Last period (LMP)', 'Pichhla period (LMP)');
  String get ddcConception => _p('Conception date', 'Conception ki tareekh');
  String get ddcIvf => _p('IVF transfer', 'IVF transfer');
  String get ddcUltrasound => _p('Ultrasound dating', 'Ultrasound dating');
  String get ddcKnown =>
      _p('I know my due date', 'Mujhe meri due date pata hai');
  String get ddcLmpDate => _p('First day of your last period',
      'Aapke pichhle period ka pehla din');
  String get ddcCycle => _p('Cycle length', 'Cycle ki lambai');
  String get ddcDays => _p('days', 'din');
  String get ddcDaysLabel => _p('Days', 'Din');
  String get ddcConceptionDate =>
      _p('Conception date', 'Conception ki tareekh');
  String get ddcTransferDate =>
      _p('Embryo transfer date', 'Embryo transfer ki tareekh');
  String get ddcEmbryoDay => _p('Embryo age', 'Embryo ki umar');
  String get ddcDay3 => _p('Day 3', 'Day 3');
  String get ddcDay5 => _p('Day 5', 'Day 5');
  String get ddcScanDate => _p('Date of ultrasound', 'Ultrasound ki tareekh');
  String get ddcGa => _p('Gestational age at scan', 'Scan par gestational age');
  String get ddcKnownDate => _p('Your due date', 'Aapki due date');
  String get ddcPickDate => _p('Pick a date', 'Tareekh chunein');
  String get ddcCalculate =>
      _p('Calculate My Due Date', 'Meri Due Date Nikaalein');
  String get ddcResultLead => _p(
      'Your baby is expected around', 'Aapka baby aane waala hai lagbhag');
  String get ddcTimeline => _p('Your timeline', 'Aapki timeline');
  String get ddcMilestones =>
      _p('Key milestones ahead', 'Aage ke khaas padaav');
  String get ddcTrimesters =>
      _p('Trimester breakdown', 'Trimester breakdown');
  String get ddcConceptionTitle =>
      _p('Conception & months', 'Conception aur mahine');
  String get ddcConceptionAround =>
      _p('Estimated conception around', 'Anumaanit conception lagbhag');
  String get ddcMonths => _p('Month by month', 'Mahine-dar-mahine');
  String get ddcMsHeartbeat => _p('Heartbeat', 'Dhadkan');
  String get ddcMsNt => _p('NT Scan', 'NT Scan');
  String get ddcMsAnomaly => _p('Anomaly Scan', 'Anomaly Scan');
  String get ddcMsViability => _p('Viability', 'Viability');
  String get ddcMsThirdTri => _p('Third Trimester', 'Teesri Trimester');
  String get ddcMsFullTerm => _p('Full Term', 'Full Term');
  String get ddcMsDue => _p('Due Date', 'Due Date');
  String get ddcReady => _p('Your pregnancy journey is ready 💜',
      'Aapki pregnancy journey taiyaar hai 💜');
  String get ddcBenWeekly => _p('Weekly development', 'Saptaahik vikas');
  String get ddcBenDaily => _p('Daily guidance', 'Rozaana margdarshan');
  String get ddcBenScans => _p('Scan reminders', 'Scan reminders');
  String get ddcBenGarbh => _p('Garbh Sanskar', 'Garbh Sanskar');
  String get ddcBenSymptoms => _p('Symptom support', 'Symptom support');
  String get ddcBenBag => _p('Hospital bag', 'Hospital bag');
  String get ddcStart => _p('Start My Pregnancy Journey',
      'Meri Pregnancy Journey Shuru Karein');
  String get ddcStarted =>
      _p('Your journey is set 💜', 'Aapki journey set ho gayi 💜');
  String get ddcRecalculate => _p('Recalculate', 'Dobara nikaalein');

  // ===========================================================================
  //  ASK VEDA — companion (preview)
  // ===========================================================================
  String get vedaTitle => _p('Ask Veda', 'Ask Veda');
  String get vedaToolTitle => _p('Ask Veda', 'Ask Veda');
  String get vedaTagline => _p('Your pregnancy & parenting companion',
      'Aapki pregnancy aur parenting saathi');
  String get vedaComingSoon => _p('Coming soon', 'Jaldi aa raha hai');
  String get vedaBeta => _p('Beta', 'Beta');
  String get vedaWelcome => _p(
      "Hello 💜 I'm Veda. Ask me about a food, a symptom or your week, and I'll share what we know — drawn from ParentVeda's guidance. I'm still learning, and I'll get better as we grow.",
      'Namaste 💜 Main Veda hoon. Mujhse kisi food, lakshan ya apne hafte ke baare mein poochein — main ParentVeda ki jaankari se jo pata hai woh bataungi. Main abhi seekh rahi hoon, aur aage aur behtar hoti jaungi.');
  String get vedaHint => _p('Ask AskVeda', 'Ask AskVeda');
  String get vedaTrySomething => _p('Try asking', 'Yeh poochein');
  String get vedaReply => _p(
      "I'm almost ready 💜 Veda is launching soon — I'll answer this with your week, scans and journal in mind. I'll let you know the moment I'm here.",
      'Main lagbhag taiyaar hoon 💜 Veda jald aa rahi hai — main is sawaal ka jawaab aapke hafte, scans aur journal ke saath doongi. Aate hi aapko bata doongi.');
  String get vedaVoice => _p('Voice', 'Voice');
  String get vedaVoiceSoon =>
      _p('Voice questions are coming soon 💜', 'Voice sawaal jaldi aa rahe hain 💜');
  String get vedaImage => _p('Photo', 'Photo');
  String get vedaImageSoon => _p(
      'Photo questions (rashes, reports, labels) are coming soon 💜',
      'Photo sawaal (rashes, reports, labels) jaldi aa rahe hain 💜');
  // Offline "answer from our own content" (Can I? + Symptoms).
  String get vedaDisclaimer => _p(
      'This is general guidance from what I know — please confirm anything important with your doctor. 💜',
      'Yeh meri jaankari se general guidance hai — kuch bhi important ho to apne doctor se zaroor confirm karein. 💜');
  String get vedaNoMatch => _p(
      "I don't have a confident answer on that yet — I'm still learning. Try asking about a food (\"Can I eat papaya?\"), a symptom, or use the Can I? tool. I'll answer more as ParentVeda grows. 💜",
      "Iska pakka jawaab abhi mere paas nahi hai — main abhi seekh rahi hoon. Kisi food (\"Kya main papaya kha sakti hoon?\"), lakshan ke baare mein poochein, ya Can I? tool use karein. ParentVeda badhne ke saath main aur jawaab dungi. 💜");
  String get vedaFromYourApp =>
      _p('From your ParentVeda', 'Aapke ParentVeda se');
  // Structured showcase result-page section headers.
  String get vedaWhatMeans =>
      _p('What this means for you', 'Aapke liye iska matlab');
  String get vedaNextActions =>
      _p('Recommended next actions', 'Recommended agle kadam');
  String get vedaPvContent => _p('From ParentVeda', 'ParentVeda se');
  String get vedaCommunityInsights =>
      _p('Community insights', 'Community insights');
  String get vedaProductsHdr => _p('Products', 'Products');
  String get vedaServices => _p('Services', 'Services');
  String get vedaUrgentBanner => _p(
      'Please act now — contact your maternity unit',
      'Please abhi act karein — apni maternity unit se contact karein');
  // Stage-wise suggested questions (the Ask Veda home, before you type).
  String get vedaSuggestHeader =>
      _p("What's on your mind?", 'Kya poochna chahti hain?');
  String get vedaSuggestSub => _p(
      'Tap a question, or type your own below.',
      'Koi sawaal tap karein, ya neeche apna likhein.');
  String get vedaStageSoon =>
      _p('As your journey grows', 'Jaise aapka safar badhega');
  String get vedaShuffle => _p('Shuffle questions', 'Naye sawaal');
  // Ask Veda structured result page (the "Ask Veda Results" design).
  String get vedaAnswerLabel => _p('Veda Answer', 'Veda ka jawab');
  String get vedaWhenChecked =>
      _p('When to get checked', 'Kab doctor ko dikhayein');
  String get vedaMoreInfo => _p('More information', 'Aur jaankari');
  // Retrieval-path 7-section answer: personalization default, default actions,
  // community social-proof, and content-TYPE labels for Section 4.
  String get vedaMeansDefault => _p(
      "Here's what ParentVeda's guidance suggests for where you are right now.",
      'ParentVeda ki guidance aapki abhi ki sthiti ke liye yeh sujhaati hai.');
  String get vedaActionExplore => _p(
      'Explore the related ParentVeda content below.',
      'Neeche di gayi ParentVeda content dekhein.');
  String get vedaActionTrack => _p(
      'Note how you\'re feeling and track it over the next few days.',
      'Aap kaisa mehsoos kar rahi hain, note karein aur agle kuch din track karein.');
  String get vedaActionDoctor => _p(
      'If it persists or worries you, check with your doctor.',
      'Agar yeh bana rahe ya chinta ho, to apne doctor se baat karein.');
  String vedaCommunitySocial(int n) => _p(
      'Other ParentVeda mothers have asked about this too.',
      'ParentVeda ki doosri mummies ne bhi iske baare mein poocha hai.');
  String get vedaTypeCanI => _p('Can-I guide', 'Can-I guide');
  String get vedaTypeSymptom => _p('Symptom guide', 'Lakshan guide');
  String get vedaTypeWeekly => _p('Weekly journey', 'Weekly journey');
  String get vedaTypeRead => _p('Read', 'Read');
  String get vedaTypeTip => _p('Trimester tip', 'Trimester tip');
  String get vedaTypeReflection => _p('Reflection', 'Reflection');
  String get vedaTypeReadBaby => _p('Read to baby', 'Read to baby');
  String get vedaTypeGarbh => _p('Garbh Sanskar', 'Garbh Sanskar');
  String get vedaTypeBody => _p('Body changes', 'Body changes');
  String get vedaTypeTool => _p('Tool', 'Tool');
  String get vedaTypeProduct => _p('Product', 'Product');
  String get vedaTypeCommunity => _p('Community', 'Community');
  String get vedaTypeScan => _p('Scan guide', 'Scan guide');
  String get vedaTalkExpert => _p('Talk to an expert', 'Expert se baat karein');
  String get vedaProductsHint =>
      _p('Suggested for your question', 'Aapke sawaal ke hisaab se');
  String get vedaBook => _p('Book', 'Book');
  String get vedaCall => _p('Call', 'Call');
  String get vedaVerdictSafe => _p('Generally safe ✅', 'Aam taur par safe ✅');
  String get vedaVerdictModeration =>
      _p('Fine in moderation ⚖️', 'Seemit maatra mein theek ⚖️');
  String get vedaVerdictDepends => _p('It depends 🤔', 'Yeh nirbhar karta hai 🤔');
  String get vedaVerdictAvoid => _p('Best avoided 🚫', 'Behtar hai bachein 🚫');
  String get vedaVerdictAskDoctor =>
      _p('Ask your doctor 🩺', 'Apne doctor se poochein 🩺');
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
          'Kya main papaya kha sakti hoon?',
          'Kya coffee safe hai?',
          'Kya abhi kamar dard normal hai?',
          'Acidity kam kaise karein?',
          'Behtar neend kaise aaye?',
          'Kya main pineapple kha sakti hoon?',
        ];

  // ===========================================================================
  //  WEEK'S TO GO (weekly header)
  // ===========================================================================
  String weeksToGo(int n) => _p(n == 1 ? '1 week to go' : '$n weeks to go',
      n == 1 ? '1 hafta baaki' : '$n hafte baaki');
  String get weeksToGoNow => _p('Any day now 💜', 'Kabhi bhi 💜');
  String get flowDaily => _p('Daily', 'Rozaana');
  String get flowWeekly => _p('Weekly', 'Saptaahik');
  String get snapThisWeek => _p('This week', 'Is hafte');
  String get snapOpenWeek => _p('View week', 'Week dekhein');
  String get sizeWord => _p('Size', 'Size');
  String get wkVideoEyebrow => _p('Watch this week', 'Is hafte dekhein');
  // The weekly video is labelled by the week it covers (replaces "Watch this
  // week"), so it reads as that week's video.
  String wkPregnancyWeek(int n) =>
      _p('Pregnancy Week $n', 'Pregnancy Week $n');
  String get wkVideoSoon =>
      _p('Playback coming soon 💜', 'Playback jaldi aa raha hai 💜');
  String get ttEyebrow => _p('Trimester tips', 'Trimester tips');
  String ttTitle(int week) => _p('Tips for week $week', 'Hafta $week ke tips');
  String get journeyTrailKicker =>
      _p('Your trail to birth', 'Janm tak ka safar');
  String gsKicker(int week) =>
      _p('Garbh Sanskar · Week $week', 'Garbh Sanskar · Hafta $week');
  String get gsFiveRituals =>
      _p('Five gentle rituals', 'Paanch komal rituals');

  // Week 20 "ParentVeda Journey" overview accordions (design preview)
  String get ovBaby => _p('Baby', 'Baby');
  String get ovBabySub =>
      _p("What I'm doing this week", 'Is hafte main kya kar raha hoon');
  String get ovMother => _p('Mother', 'Maa');
  String get ovMotherSub =>
      _p("How you're feeling", 'Aap kaisa mehsoos kar rahi hain');
  String get ovHealth => _p('Health', 'Sehat');
  String get ovHealthSub => _p("This week's care", 'Is hafte ki dekhbhaal');
  String get ovVideoWhy => _p('Why this matters', 'Yeh kyun zaroori hai');
  String get msEyebrow => _p('Milestones', 'Padaav');
  String get msTitle => _p("Baby's journey", 'Baby ka safar');
  String get msThisWeek => _p('This week', 'Is hafte');

  // ===========================================================================
  //  WEEK FLOW (V2 — week 20 vertical-flow preview)
  // ===========================================================================
  String get wfClassic => _p('Classic', 'Classic');
  String get wfNew => _p('New', 'New');
  String get weeklyBackToDaily => _p('Daily', 'Daily');
  // Global search (Home search icon).
  String get searchHint =>
      _p('Search ParentVeda…', 'ParentVeda mein search karein…');
  String get searchEmptyHint => _p(
      'Search products, reads, foods, symptoms and tools.',
      'Products, reads, foods, lakshan aur tools search karein.');
  String get searchNoResults =>
      _p('No results for', 'Koi result nahi mila');
  String get searchTools => _p('Tools & sections', 'Tools aur sections');
  String get searchProducts => _p('Products', 'Products');
  String get searchReads => _p('Reads', 'Reads');
  String get searchCanI => _p('Can I?', 'Can I?');
  String get searchSymptoms => _p('Symptoms', 'Lakshan');
  String get navProducts => _p('Products', 'Products');
  String get wfBabySection => _p('About your baby', 'Aapke baby ke baare mein');
  String get wfMotherSection => _p('For you, mum', 'Aapke liye, maa');
  String get wfNextSection => _p("What's next", 'Aage kya');
  String get wfNextBrief => _p(
      'Scans, appointments and milestones coming up around now.',
      'Aane wale scans, appointments aur padaav.');
  String get wfVideosSection => _p("This week's videos", 'Is hafte ke videos');
  String get wfArticlesSection => _p("This week's reads", 'Is hafte ke reads');
  String get wfPartnerSection =>
      _p('Share with your partner', 'Partner ke saath share karein');
  String get wfTapExplore =>
      _p('Tap to explore', 'Dekhne ke liye tap karein');
  String get wfBabyScience => _p('Baby Science', 'Baby Science');
  String get wfSwipeHint =>
      _p('Swipe for Baby Science', 'Baby Science ke liye swipe karein');
  String get wfBabyMilestones =>
      _p('Milestones around now', 'Abhi ke aas-paas ke padaav');
  String get wfMotherThisWeek => _p('Mother this week', 'Maa is hafte');
  // Combined Mother page (the "for you, mum" read + "mother this week" merged).
  String get wfYouThisWeek => _p('You this week', 'Aap is hafte');
  // Organic "daily moment" nudge woven into the weekly flow.
  String get wfDailyBridgeKicker =>
      _p('DON\'T MISS', 'CHHOOT NA JAAYE');
  String get wfDailyBridgeTitle =>
      _p('Your daily moment is waiting', 'Aapka daily moment intezaar mein hai');
  String get wfDailyBridgeBody => _p(
      "Today's reads, Garbh Sanskar and a journal prompt are ready for you on Home.",
      'Aaj ke reads, Garbh Sanskar aur ek journal prompt Home par taiyaar hain.');
  String get wfDailyBridgeCta => _p('Go to today', 'Aaj par jaayein');
  // Mother health page — three toggles on one page.
  String get wfTabSymptoms => _p('Symptoms', 'Symptoms');
  String get wfTabDiet => _p('Diet', 'Diet');
  String get wfTabActions => _p('Actions', 'Actions');
  // Inline media-placeholder tags woven into the reads.
  String get wfMediaVideo => _p('VIDEO', 'VIDEO');
  String get wfMediaPhoto => _p('PHOTO', 'PHOTO');
  String get wfHealthThisWeek => _p('Health this week', 'Sehat is hafte');
  String get wfEatThisWeek =>
      _p('What to eat this week', 'Is hafte kya khaayein');
  String get wfDoThisWeek => _p('What to do this week', 'Is hafte kya karein');
  String get wfSwipeMore =>
      _p('Swipe for more', 'Aur dekhne ke liye swipe karein');
  String get wfHealthIntro => _p(
      'Common, normal things you may notice now — tap any to understand it and what helps.',
      'Aam, normal baatein jo aap abhi mehsoos kar sakti hain — kisi ko bhi samajhne ke liye tap karein.');
  String get wfTapToRead => _p('Read about it', 'Iske baare mein padhein');
  String get wfMilestonesTitle =>
      _p('Upcoming milestones', 'Aane wale padaav');
  String get wfScansTitle =>
      _p('Scans & appointments', 'Scans & appointments');
  String get wfNextIntro => _p(
      "Here's what's coming up in your journey — the milestones your baby will reach, and the scans worth keeping on your radar. A little glimpse ahead helps you feel prepared and calm.",
      'Aage aapke safar mein kya aane wala hai — baby ke padaav aur dhyaan rakhne layak scans. Thodi jhalak aage ki, taaki aap taiyar aur shaant mehsoos karein.');
  String get wfNextRadar => _p('On your radar', 'Aapke radar par');
  // What's-next tab labels (single page, no swipe) + the "for you" forward look.
  String get wfNextTabScans => _p('Scans', 'Scans');
  String get wfNextTabYou => _p('For you', 'Aapke liye');
  String get wfNextTabMilestones => _p('Milestones', 'Padaav');
  String get wfNextMotherIntro => _p(
      'A gentle look at how you may feel in the weeks just ahead — your body changing, step by step.',
      'Aane wale hafton mein aap kaisa mehsoos kar sakti hain — aapka shareer dheere-dheere badalta hua, ek halki jhalak.');
  String get wfBodyLabel => _p('Your body', 'Aapka shareer');
  String get wfFeelLabel => _p('How you may feel', 'Kaisa lag sakta hai');
  String get wfGotIt => _p('Got it', 'Samajh gaya');
  String get wfTipsTitle => _p('Trimester tips', 'Trimester tips');
  String wfTrimesterLabel(int t) => _p('Trimester $t', 'Trimester $t');
  String wfWeeksToGo(int n) => _p('$n weeks to go', '$n hafte baaki');
  String wfPercentThere(int pct) => _p('$pct% there', '$pct% poora');

  // Garbh tool + Products (daily carousel)
  String get garbhToolTitle => _p('Garbh Sanskar', 'Garbh Sanskar');
  // Spiritual Reading (a gentle, neutral, surface-level testing feature).
  String get sprToolTitle => _p('Spiritual Reading', 'Spiritual Reading');
  String get sprTitle => _p('Spiritual Reading', 'Spiritual Reading');
  String get sprDisclaimer => _p(
      'A gentle, surface-level look at how a few traditions approach pregnancy and motherhood — shared for comfort and curiosity, with respect for all beliefs. Not religious instruction.',
      'Kuch paramparaayein pregnancy aur maatritva ko kaise dekhti hain, uski ek halki si jhalak — sukoon aur jaankari ke liye, sabhi vishwaason ke sammaan ke saath. Yeh koi dharmik nirdesh nahi hai.');
  String get sprFootnote => _p(
      'Shared respectfully for comfort and reflection — not as religious advice. Every family’s beliefs are their own.',
      'Sukoon aur soch ke liye sammaan ke saath saajha kiya gaya — dharmik salah ke taur par nahi. Har parivaar ke vishwaas unke apne hain.');
  String sprViewAll(int n) =>
      _p('View all $n readings', 'Sabhi $n readings dekhein');
  String get prodSectionTitle => _p(
      "Today's product recommendation", 'Aaj ki product recommendation');
  String get prodSeeAll => _p('See all', 'Sab dekhein');
  // Weekly snapshot + Today's journey (Home segregation).
  String get snapshotTitle => _p('Weekly snapshot', 'Weekly snapshot');
  String get todaysJourney => _p("Today's journey", 'Aaj ka safar');
  String weeksLeftShort(int n) => _p('$n wks to go', '$n hafte baaki');
  String get medManageCta => _p('Manage', 'Manage karein');
  String get prodSeeNow => _p('See now', 'Dekhein');
  String get wfTabThisWeek => _p('This week', 'Is hafte');
  String get wfTabHealth => _p('Health', 'Sehat');
  String get wfTabEat => _p('Eat', 'Khaayein');
  String get wfTabDo => _p('To-do', 'Karein');
  String get wfTabScans => _p('Scans', 'Scans');
  String get wfTabMilestones => _p('Milestones', 'Padaav');
  String get wfAvoid => _p('What to avoid', 'Kya na khaayein');
  String get wfDisclaimer => _p(
      'This is for understanding, not diagnosis — your doctor is always the best guide.',
      'Yeh samajhne ke liye hai, nidaan nahi — aapka doctor hamesha sabse achhi salah dete hain.');
  String get wfPartnerCta =>
      _p('Share update on WhatsApp', 'WhatsApp par update share karein');
  String get wfPartnerBlurb => _p(
      'Send your partner a crisp summary of this week — baby, you, scans and how they can help.',
      'Apne partner ko is hafte ka saaf summary bhejein — baby, aap, scans aur woh kaise madad kar sakte hain.');
  String wfPartnerHeader(int week) =>
      _p('Our pregnancy · Week $week', 'Hamari pregnancy · Hafta $week');
  String get wfPartnerScans =>
      _p('Check upcoming scans together in the app.',
          'App mein aane wale scans saath dekhein.');
  String get wfPartnerHelp =>
      _p('How you can help', 'Aap kaise madad kar sakte hain');
  String get wfPartnerScansHeader =>
      _p('Scans & appointments coming up:', 'Aane wale scans & appointments:');
  String get wfPartnerSignoff => _p(
      "You're in this together 💜", 'Aap dono is safar mein saath hain 💜');

  // ---- Module eyebrows -----------------------------------------------------
  String get growEyebrow =>
      _p('Daily parenting tip', 'Rozaana parenting tip');
  String get readEyebrow => _p('Read To Your Baby', 'Apne Baby Ko Sunaayein');
  String get medDailyTitle => _p(
      'Daily medication and supplements', 'Rozaana dawai aur supplements');
  String get medHomeSubtitle => _p("Track today's medicines & supplements",
      'Aaj ki dawaiyan & supplements track karein');
  String get medTrackCta => _p('Track today', 'Aaj track karein');
  String get talkEyebrow => _p('Talk To Your Baby', 'Apne Baby Se Baat Karein');
  String get momentForYouEyebrow => _p('A Moment For You', 'Aapke Liye Ek Pal');
  String get movementEyebrow =>
      _p('Baby Movement Check-In', 'Baby Movement Check-In');

  // ---- Shared CTAs / labels ------------------------------------------------
  String get readMore => _p('Read More', 'Aur Padhein');
  String get readCta => _p('Read', 'Padhein');
  String get listenCta => _p('Listen', 'Sunein');
  // Read-to-your-baby customizable feed.
  String get rtbCustomize => _p('Customize', 'Customize karein');
  String get rtbCustomizeTitle =>
      _p('Customize this feed', 'Yeh feed customize karein');
  String get rtbCustomizeSub => _p('Choose what your daily read draws from.',
      'Chunein ki aapki rozaana read kahan se aaye.');
  String get rtbSpeaking => _p('Speaking cards', 'Speaking cards');
  String get rtbStories => _p("Children's stories", 'Bachchon ki kahaniyan');
  String get rtbSpiritual => _p('Spiritual reading', 'Spiritual reading');
  String get rtbRhymes => _p('Rhymes & lullabies', 'Rhymes & lullabies');
  String get rtbAffirmations =>
      _p('Affirmations & blessings', 'Affirmations & aashirwad');
  String get rtbPickReligions =>
      _p('Pick traditions', 'Paramparaayein chunein');
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
  // Direction B (Warm Nest) floating tab bar:
  String get tabToday => _p('Today', 'Aaj');
  String get tabJourney => _p('Journey', 'Safar');
  String get tabPrepare => _p('Prepare', 'Taiyari');
  String get tabSanskar => _p('Sanskar', 'Sanskar');
  String get tabRead => _p('Read', 'Padhein');
  String get tabCommunity => _p('Community', 'Community');

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
  String get profileSignOut => _p('Sign out', 'Sign out');
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
  String get journeyHerePill => _p("You're here", 'Aap yahan');
  String get journeyWelcome => _p('Welcome', 'Swagat');
  String get journeyStart => _p('Start', 'Shuruaat');
  String get journeyBirth => _p('Birth', 'Birth');
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
  // Journey-map milestone dates ("jm*").
  String jmShortDate(DateTime d) =>
      '${d.day} ${_months[(d.month - 1).clamp(0, 11)].substring(0, 3)}';
  String get jmEditDate => _p('Edit date', 'Tareekh badlein');
  String get jmWhenHappened => _p('When did this happen?', 'Ye kab hua tha?');
  String jmHappenedOn(String date) => _p('Happened on $date', '$date ko hua');
  String get jmEditedHint => _p('edited by you', 'aapne set kiya');
  // Appointment-style milestones (scans/visits the clinic schedules).
  String get jmSetAppointment =>
      _p('Set appointment date', 'Appointment ki tareekh set karein');
  String get jmEditAppointment =>
      _p('Edit appointment date', 'Appointment ki tareekh badlein');
  String jmAppointmentOn(String date) =>
      _p('Appointment · $date', 'Appointment · $date');
  // Late-joiner "catch up" — set real dates for moments already behind you.
  String get jmCatchUpTitle => _p('Joined along the way?', 'Beech mein judi?');
  String get jmCatchUpBody => _p(
      'Set when these moments actually happened, so this map is truly yours.',
      'Set karein ki ye pal asal mein kab hue, taaki yeh map sach mein aapka ho.');
  String get jmCatchUpCta => _p('Catch up', 'Catch up karein');
  String get jmCatchUpSheet =>
      _p('When did these happen?', 'Ye kab hue the?');
  String get jmSetWhen => _p('Set date', 'Tareekh set karein');
  String get jmAllCaughtUp =>
      _p("You're all caught up ❤️", 'Aap sab set hain ❤️');
  // Overdue (past the due date) — calm, reassuring.
  String get jmOverdueTitle => _p('Past your due date', 'Due date nikal gayi');
  String jmOverdueBody(int days) => _p(
      '$days ${days == 1 ? 'day' : 'days'} past your due date — your baby will come when ready 💛',
      '$days din due date ke baad — aapka baby taiyaar hone par aayega 💛');
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
  // "What are Kegels & how to do them" — for a first-timer.
  String get kegelHowTitle =>
      _p('What is a Kegel & how to do it', 'Kegel kya hai & kaise karein');
  String get kegelHowBody => _p(
      'A Kegel is simply squeezing and lifting your pelvic-floor muscles — the same ones you would use to stop yourself passing urine or wind — then fully relaxing them. To find them, imagine gently stopping that flow (just to locate the muscle, not as a habit). Squeeze and hold for a few seconds, then relax for the same time. Keep breathing normally, and try not to tighten your tummy, thighs or buttocks. A Care Session below guides the hold-and-relax timing for you.',
      'Kegel yaani apni pelvic-floor muscles ko kasna aur upar uthana — wahi jo aap urine ya gas rokne ke liye use karti hain — phir poori tarah dheela chhodna. Inhe dhoondhne ke liye, halke se us flow ko rokne ki kalpana karein (sirf muscle pehchaanne ke liye, aadat ke roop mein nahi). Kuch second kasein aur rokein, phir utni hi der dheela chhodein. Saans normal rakhein, aur pet, jaangh ya kulhe na kasein. Neeche di Care Session aapke liye hold-and-relax ka timing guide karti hai.');
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

  // --- Simplified hospital bag (v2): the joyful, tap-only experience ---------
  String get hb2MyBag => _p('My Hospital Bag', 'Mera Hospital Bag');
  String get hb2FillingUp =>
      _p('Your bag is filling up 💛', 'Aapka bag bhar raha hai 💛');
  String get hb2ReadyBanner => _p('Your bag is ready for baby! 🎉',
      'Aapka bag baby ke liye taiyaar hai! 🎉');
  String get hb2HeroEmpty =>
      _p("Let's pack for the big day", 'Bade din ke liye pack karein');
  String hb2DaysToGo(int n) => _p('$n days to go', '$n din baaki');
  String hb2ReadyPct(int n) => _p('$n% ready', '$n% taiyaar');
  String get hb2AddItems => _p('Add items', 'Items add karein');
  String get hb2EmptyTitle =>
      _p("Let's start your bag 🎒", 'Apna bag shuru karein 🎒');
  String get hb2EmptySub => _p(
      "Add the things you'd love to have for the big day.",
      'Bade din ke liye jo cheezein chahiye, unhe add karein.');
  String get hb2GroupVeda =>
      _p('Buy from ParentVeda', 'ParentVeda se khareedein');
  String get hb2GroupElse =>
      _p('Buy elsewhere', 'Kahin aur se khareedein');
  String get hb2GroupHave => _p('Already have', 'Pehle se hai');
  String get hb2GroupNeeded =>
      _p('Where will you get these?', 'Ye kahan se laaengi?');
  String hb2Buy(int price) => _p('Buy ₹$price', '₹$price mein lein');
  String get hb2ToBuy => _p('To buy', 'Lena hai');
  String get hb2Bought => _p('Bought', 'Le liya');
  String get hb2Pack => _p('Pack', 'Pack karein');
  String get hb2Packed => _p('Packed', 'Pack ho gaya');
  String get hb2ChooseSource =>
      _p('Where will you get this?', 'Ye kahan se laaengi?');
  String get hb2SrcVeda =>
      _p('Buy from ParentVeda', 'ParentVeda se khareedein');
  String get hb2SrcElse => _p('Buy elsewhere', 'Kahin aur se khareedein');
  String get hb2SrcHave => _p('I already have it', 'Ye mere paas hai');
  String get hb2Remove => _p('Remove from bag', 'Bag se hatayein');
  String get hb2LinkOptional =>
      _p('Paste a link (optional)', 'Link daalein (optional)');
  String get hb2Save => _p('Save', 'Save karein');
  String hb2PackedCheer(int i) {
    const en = [
      'One less thing to worry about 💛',
      'Your bag is getting ready ✨',
      'Lovely — packed! 🎒',
      "You're doing so well, mama 💛",
    ];
    const hi = [
      'Ek chinta kam 💛',
      'Aapka bag taiyaar ho raha hai ✨',
      'Bahut khoob — pack ho gaya! 🎒',
      'Aap bahut achha kar rahi hain, mama 💛',
    ];
    final n = i % en.length;
    return _p(en[n], hi[n]);
  }

  String get hb2AddTitle => _p('Add to my bag', 'Mere bag mein add karein');
  String get hb2Done => _p('Done', 'Done');
  String get hb2Search => _p('Search items…', 'Items dhoondein…');
  String get hb2MumsAlsoPacked => _p(
      'Mums like you also packed', 'Aap jaisi mummies ne ye bhi packing kiya');
  String get hb2SocialProof =>
      _p('9 in 10 mums pack this', '10 mein 9 mummies ye packing karti hain');
  String get hb2Add => _p('Add', 'Add');
  String get hb2CatLabour => _p('For labour', 'Labour ke liye');
  String get hb2CatAfter => _p('After delivery', 'Delivery ke baad');
  String get hb2CatBaby => _p('For baby', 'Baby ke liye');
  String get hb2CatPartner => _p('For partner', 'Partner ke liye');
  String get hb2CatDocs => _p('Documents', 'Documents');
  String get hb2CatComfort => _p('Comfort', 'Aaram ke liye');
  String get hb2CatCustom => _p('My own', 'Mere apne');
  String get hb2ShareTitle => _p('Share my bag', 'Mera bag share karein');
  String get hb2ShareToBuy => _p('Still to buy', 'Abhi lena hai');
  String hb2SharePacked(int a, int b) =>
      _p('Packed: $a of $b 💛', 'Pack hua: $b mein se $a 💛');
  String get hb2RemindMe => _p('Remind me to prep', 'Mujhe yaad dilayein');
  String get hb2RemindOff => _p('Turn off reminder', 'Reminder band karein');
  String get hb2ReminderTitle =>
      _p('Your hospital bag 💛', 'Aapka hospital bag 💛');
  String get hb2ReminderBody => _p(
      'A few minutes to add or pack something today?',
      'Aaj kuch add ya pack karne ke liye kuch minute?');
  String get hb2ReminderSet => _p("Reminder set — I'll nudge you daily 💛",
      'Reminder set — main roz yaad dilaungi 💛');
  String get hb2ReminderOff =>
      _p('Reminder turned off', 'Reminder band ho gaya');
  String get hb2KeepsakeTitle =>
      _p("Baby's bag is ready! 💛", 'Baby ka bag taiyaar hai! 💛');
  String hb2KeepsakeSub(String date) =>
      _p('Packed on $date', '$date ko packed');
  String get hb2KeepsakeShare => _p('Share the moment', 'Ye pal share karein');
  String hb2KeepsakeShareText(String date) => _p(
      'Our hospital bag is all packed and ready for baby 💛 ($date) — ParentVeda',
      'Hamara hospital bag baby ke liye taiyaar hai 💛 ($date) — ParentVeda');
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

  // ===== Hospital Bag V2 (toggle-able redesign) =============================
  String get hb2vClassic => _p('Classic', 'Classic');
  String get hb2vNew => _p('New', 'Naya');
  // Onboarding
  String get hb2v2Title => _p('Build your hospital bag', 'Apna hospital bag taiyaar karein');
  String get hb2v2Sub => _p(
      "Let's prepare for one of the most special days of your life. You don't need to finish today — we'll build it together over the coming weeks.",
      "Aapki zindagi ke sabse khaas din ki taiyaari karein. Aaj poora karna zaroori nahi — hum ise aane wale hafton mein saath milkar banayenge.");
  String get hb2v2StartCta => _p('Start preparing', 'Taiyaari shuru karein');
  String get hb2v2DeliveryQ =>
      _p('How are you planning to deliver?', 'Aap delivery kaise plan kar rahi hain?');
  // Plain-language stages
  String get hb2v2StageDecision => _p('Needs your decision', 'Aapka faisla chahiye');
  String get hb2v2StagePlanning => _p('Planning to buy', 'Khareedne ka plan');
  String get hb2v2StageHome => _p('Ready at home', 'Ghar par taiyaar');
  String get hb2v2StagePacked => _p('Packed', 'Pack ho gaya');
  String get hb2v2StageLater => _p('Maybe later', 'Shaayad baad mein');
  // Home
  String get hb2v2Attention => _p('Needs your attention', 'Aapke dhyaan ki zaroorat');
  String get hb2v2AllSorted => _p("You're all caught up 💛", 'Sab sambhal liya 💛');
  String get hb2v2Categories => _p('Your bag, by area', 'Aapka bag, hisson mein');
  String get hb2v2Shopping => _p('Shopping', 'Shopping');
  String get hb2v2Packing => _p('Packing', 'Packing');
  String hb2v2DaysToGo(int n) => _p('$n days to go', '$n din baaki');
  String get hb2v2HeroReady => _p('Your bag is almost ready 💛', 'Aapka bag lagbhag taiyaar 💛');
  String get hb2v2HeroBuilding => _p('Building your bag, gently', 'Aapka bag, aaraam se ban raha hai');
  // Action sheet
  String hb2v2WhatDo(String item) => _p('$item — what would you like to do?',
      '$item — aap kya karna chahengi?');
  String get hb2v2ChooseOne => _p('Help me choose one', 'Ek chunne mein madad karein');
  String get hb2v2HaveOne => _p('I already have one', 'Mere paas pehle se hai');
  String get hb2v2BuyElse => _p("I'll buy elsewhere", 'Main kahin aur se loongi');
  String get hb2v2Later => _p("I'll decide later", 'Baad mein decide karoongi');
  String get hb2v2NotNeed => _p("I don't think I need this", 'Mujhe shaayad iski zaroorat nahi');
  // Product experience
  String get hb2v2PvPick => _p('ParentVeda pick', 'ParentVeda ki pasand');
  String get hb2v2WhyRec => _p('Why ParentVeda recommends this', 'ParentVeda yeh kyun suggest karta hai');
  String get hb2v2Consider => _p('Things to consider', 'Dhyaan dene ki baatein');
  String get hb2v2BuyingGuide => _p('Buying guide', 'Khareedne ki guide');
  String get hb2v2BuyingGuideBody => _p(
      'Look for soft, breathable fabric and an easy fit. One or two is usually enough to start — you can always add more later.',
      'Naram, saans lene wala kapda aur aaramdaayak fit dekhein. Shuru mein ek-do kaafi hote hain — baad mein aur le sakti hain.');
  String get hb2v2Reviews => _p('Real parent reviews', 'Asli parent reviews');
  String get hb2v2ReviewsSoon => _p('Reviews from ParentVeda parents are coming soon.',
      'ParentVeda parents ke reviews jaldi aa rahe hain.');
  String get hb2v2Compare => _p('Compare options', 'Options compare karein');
  String get hb2v2SeeAll => _p('See all options', 'Sabhi options dekhein');
  String get hb2v2Selected => _p('Selected', 'Chuna gaya');
  String get hb2v2ChooseThis => _p('Choose this', 'Yeh chunein');
  String get hb2v2BuyOnPv => _p('Buy from ParentVeda', 'ParentVeda se khareedein');
  // Buy elsewhere
  String get hb2v2WhereBuy => _p('Where will you buy it?', 'Aap ise kahaan se lengi?');
  String get hb2v2SkipForNow => _p('Skip for now', 'Abhi chhod dein');
  String get hb2v2AddDetails => _p('Add price / link / note (optional)',
      'Daam / link / note jodein (optional)');
  // Maybe later
  String get hb2v2MaybeLaterTitle => _p('Maybe later', 'Shaayad baad mein');
  String get hb2v2RestoreItem => _p('Add back to bag', 'Bag mein wapas jodein');
  // Packing
  String get hb2v2TimeToPack => _p('Time to pack your bag', 'Bag pack karne ka samay');
  String get hb2v2InBag => _p('In my hospital bag', 'Mere hospital bag mein');
  String get hb2v2PackThis => _p('Pack this', 'Ise pack karein');
  // Custom
  String get hb2v2AddOwn => _p('Add my own item', 'Apni cheez jodein');
  String get hb2v2ItemName => _p('Item name', 'Cheez ka naam');
  String get hb2v2NotesOptional => _p('Notes (optional)', 'Note (optional)');
  String get hb2v2RemoveItem => _p('Remove item', 'Cheez hatayein');
  // Shopping summary
  String get hb2v2SummaryTitle => _p('Shopping summary', 'Shopping summary');
  String get hb2v2SecFromPv => _p('Buying from ParentVeda', 'ParentVeda se khareed rahi hain');
  String get hb2v2SecElse => _p('Buying elsewhere', 'Kahin aur se');
  String get hb2v2SecHome => _p('Already at home', 'Ghar par pehle se');
  String get hb2v2SecWaiting => _p('Waiting to buy', 'Khareedna baaki');
  String get hb2v2SecPacked => _p('Packed', 'Pack ho gaya');
  String get hb2v2PvSpend => _p('ParentVeda spend', 'ParentVeda kharcha');
  String get hb2v2ExtSpend => _p('External spend', 'Baahar ka kharcha');
  String get hb2v2TotalSpend => _p('Total planned', 'Kul planned');
  String get hb2v2SummaryCta => _p('Shopping summary', 'Shopping summary');
  // Mark bought (elsewhere)
  String get hb2v2MarkBought => _p('Mark as bought', 'Khareeda mark karein');
  String get hb2v2Bought => _p('Bought', 'Khareed liya');
  String get hbMarkFavourite =>
      _p('Add to favourites', 'Favourites mein jodein');
  String get hbFavourites => _p('Favourites', 'Favourites');
  String hbTapToExpand(int n) => _p('$n items', '$n cheezein');
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
  // Affiliate split (also-available-elsewhere — mirrors the product checklist).
  String get hbAlsoElsewhere =>
      _p('Also available elsewhere', 'Kahin aur bhi uplabdh');
  String get hbAffiliateNote => _p(
      'Opens the store in your browser. ParentVeda may earn a small commission.',
      'Store aapke browser mein khulega. ParentVeda ko chhota commission mil sakta hai.');
  String hbBuyOn(String store) => _p('Buy on $store', '$store par khareedein');
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
      case 'fav':
        return _p('Favourites', 'Favourites');
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
  // "What is this" explainer — what a contraction is + true vs false (Braxton
  // Hicks) + how to time one. So a first-time user understands the tool.
  String get ctAboutTitle =>
      _p('Understanding contractions', 'Contractions ko samajhna');
  String get ctAboutBody => _p(
      'A contraction is your womb tightening and then relaxing. Not every tightening is labour. "Braxton Hicks" (practice) contractions are common and usually harmless — they tend to be irregular, do not get stronger or closer together, and often ease when you rest, change position or drink water. True labour contractions tend to get longer, stronger and closer together over time, and do not fade. To time one: tap when it starts, and again when it ends.',
      'Contraction yaani aapki kokh ka kasna aur phir dheela hona. Har kasaav labour nahi hota. "Braxton Hicks" (practice) contractions aam aur aksar harmless hote hain — ye anymit hote hain, na tej hote hain na paas-paas aate hain, aur aaram karne, position badalne ya paani peene par aksar kam ho jaate hain. Asli labour contractions samay ke saath lambe, tej aur paas-paas hote jaate hain, aur kam nahi hote. Time karne ke liye: shuru hone par tap karein, aur khatm hone par phir tap karein.');
  // The not-a-medical-app disclaimer (kept clearly visible).
  String get ctDisclaimerTitle =>
      _p('A timer, not a diagnosis', 'Ek timer, diagnosis nahi');
  String get ctDisclaimerBody => _p(
      'ParentVeda is not a medical or diagnostic service. This tool only records your contractions and shows the pattern — it cannot confirm that you are in labour, or rule it out. Only your doctor or midwife can. If anything feels off, contact them, even if the pattern here looks calm.',
      'ParentVeda koi medical ya diagnostic service nahi hai. Yeh tool sirf aapke contractions record karke pattern dikhata hai — yeh na labour confirm kar sakta hai, na inkaar. Sirf aapki doctor ya midwife hi yeh keh sakti hain. Agar kuch theek na lage, to unse sampark karein — chahe yahan pattern shaant hi kyun na dikhe.');
  // Universal "always consult" line shown under every (non-urgent) assessment.
  String get ctAlwaysConsult => _p(
      'Timing cannot confirm or rule out labour. If you are unsure, or something does not feel right, contact your doctor or midwife — even now.',
      'Timing se labour na confirm ho sakta hai na inkaar. Agar pakka nahi, ya kuch theek na lage, to abhi apni doctor ya midwife se sampark karein.');

  // ---- Reminders (customizable local notifications) ------------------------
  String get rmdTitle => _p('Reminders', 'Reminders');
  String get rmdToolSub =>
      _p('Gentle nudges, your way', 'Aapke tareeke se halki yaad');
  String get rmdEmpty => _p('No reminders yet', 'Abhi koi reminder nahi');
  String get rmdEmptySub => _p(
      'Add a gentle nudge for anything — a Kegel session, your vitamin, reading to baby, or your own.',
      'Kisi bhi cheez ke liye halki yaad jodein — Kegel session, vitamin, baby ko padhna, ya apni khud ki.');
  String get rmdAdd => _p('Add reminder', 'Reminder jodein');
  String get rmdRemindMe => _p('Remind me', 'Mujhe yaad dilaayein');
  String get rmdNew => _p('New reminder', 'Naya reminder');
  String get rmdEditTitle => _p('Edit reminder', 'Reminder badlein');
  String get rmdWhatLabel => _p('What should we remind you about?',
      'Hum aapko kis cheez ki yaad dilaayein?');
  String get rmdWhatHint =>
      _p('e.g. Time for your Kegels', 'jaise Kegel ka samay');
  String get rmdSuggestions => _p('Quick ideas', 'Jaldi ideas');
  String get rmdTime => _p('Time', 'Samay');
  String get rmdRepeat => _p('Repeat', 'Dohraayein');
  String get rmdOnce => _p('Once', 'Ek baar');
  String get rmdDaily => _p('Daily', 'Rozana');
  String get rmdWeekly => _p('Weekly', 'Saptahik');
  String get rmdOnDay => _p('On', 'Din');
  String get rmdSave => _p('Save reminder', 'Reminder save karein');
  String get rmdDelete => _p('Delete reminder', 'Reminder hataayein');
  String get rmdSaved => _p('Reminder saved 💜', 'Reminder save ho gaya 💜');
  String get rmdRemoved => _p('Reminder removed', 'Reminder hata diya');
  String get rmdScheduleNote => _p('We\'ll nudge you at the time you set.',
      'Aapke set kiye samay par hum yaad dilaayenge.');
  // Extended repeat labels (used by medication reminders).
  String get rmdFortnightly => _p('Fortnightly', 'Har 2 hafte');
  String get rmdMonthly => _p('Monthly', 'Har maheene');
  String get rmdCustomDays => _p('Specific days', 'Chuni hui din');
  // --- Medication reminders (Daily Medication card; never tied to a medicine) -
  String get mrTitle => _p('My reminders', 'Mere reminder');
  String get mrAdd => _p('Add reminder', 'Reminder jodein');
  String get mrNew => _p('Add a reminder', 'Reminder jodein');
  String get mrEdit => _p('Edit reminder', 'Reminder badlein');
  String get mrFreq => _p('How often?', 'Kitni baar?');
  String get mrFreqOnce => _p('Once a day', 'Din mein ek baar');
  String get mrFreqTwice => _p('Twice a day', 'Din mein do baar');
  String get mrFreqThrice => _p('Thrice a day', 'Din mein teen baar');
  String get mrFreqWeekly => _p('Weekly', 'Har hafte');
  String get mrFreqFortnightly => _p('Fortnightly', 'Har 2 hafte');
  String get mrFreqMonthly => _p('Monthly', 'Har maheene');
  String get mrFreqCustom => _p('Custom', 'Custom');
  String get mrTimes => _p('At these times', 'In samay par');
  String mrTimeN(int n) => _p('Time $n', 'Samay $n');
  String get mrDayOfMonth => _p('Day of month', 'Maheene ka din');
  String get mrOnDays => _p('On these days', 'In dino par');
  String get mrNote => _p('Note (what should it say?)', 'Note (kya likhein?)');
  String get mrNoteHint =>
      _p('e.g. Iron tablet after lunch', 'jaise: lunch ke baad iron tablet');
  String get mrDefaultTitle =>
      _p('Medication reminder 💊', 'Dawai reminder 💊');
  String get mrSave => _p('Save reminder', 'Reminder save karein');
  String get mrDelete => _p('Delete', 'Hataayein');
  String get mrEmpty => _p('No reminders yet — tap the bell to add one.',
      'Abhi koi reminder nahi — bell dabaakar jodein.');
  String get mrSaved => _p('Reminder set 💜', 'Reminder set ho gaya 💜');
  String mrTimesPerDay(int n) => _p('$n× daily', 'Rozana $n baar');
  String rmdWeekdayShort(int wd) {
    const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const hi = ['Som', 'Mang', 'Budh', 'Guru', 'Shukra', 'Shani', 'Ravi'];
    final i = (wd - 1).clamp(0, 6);
    return _p(en[i], hi[i]);
  }

  // Suggested reminder presets.
  String get rmdSugKegel => _p('Time for your Kegels 🌸', 'Kegel ka samay 🌸');
  String get rmdSugVitamin =>
      _p('Take your prenatal vitamin 💊', 'Apna prenatal vitamin lein 💊');
  String get rmdSugRead =>
      _p('Read to your baby 📖', 'Apne baby ko padhein 📖');
  String get rmdSugWater => _p('Sip some water 💧', 'Thoda paani piyein 💧');
  String get rmdSugCalm =>
      _p('A calm moment for you 🕊️', 'Aapke liye ek shaant pal 🕊️');

  // ---- Trimester chart (Home) ----------------------------------------------
  String get tcTitle => _p('Trimester chart', 'Trimester chart');
  String get tcTrimester => _p('Trimester', 'Trimester');
  String get tcMonth => _p('Month', 'Mahina');
  String get tcWeek => _p('Week', 'Hafta');
  String tcDueDate(String date) => _p('Due Date: $date', 'Due Date: $date');
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
            'Your contractions are frequent, longer, and fairly regular — a pattern often seen in active labour. Even so, strong contractions can sometimes be a false alarm, so this is NOT a confirmation. Please contact your healthcare provider, or follow your birth plan.',
            'Aapke contractions baar-baar, lambe aur kaafi niyamit hain — aisa pattern aksar active labour mein dikhta hai. Phir bhi, tej contractions kabhi-kabhi false alarm bhi ho sakte hain, isliye yeh pakka NAHI hai. Kripya apne doctor se sampark karein, ya apne birth plan ko follow karein.');
      case 'likely':
        return _p(
            'A steady, labour-like pattern seems to be forming. It might be early labour, or it might still settle — timing alone cannot tell for sure. Consider contacting your healthcare provider for guidance.',
            'Ek niyamit, labour-jaisa pattern banta dikh raha hai. Yeh shuruaati labour ho sakta hai, ya abhi shaant bhi pad sakta hai — sirf timing se pakka nahi kaha ja sakta. Margdarshan ke liye apne doctor se sampark karne par vichaar karein.');
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
  // Tools Garbh Sanskar = a calm LIBRARY (no "today" framing). Intro + tiles.
  String get gsAboutBody => _p(
      'Garbh Sanskar is the gentle, age-old practice of nurturing your bond and your baby\'s growth through sound, positive thoughts, loving connection and mindful movement during pregnancy.',
      'Garbh Sanskar pregnancy ke dauraan dhwani, sakaratmak vichaaron, pyaar bhare judaav aur mindful movement se aapke rishte aur baby ke vikas ko poshit karne ki saumya, praacheen practice hai.');
  String get gsAboutMeaning => _p(
      'A calm space to explore — pick whatever feels right for you today.',
      'Ek shaant jagah jise explore karein — aaj jo aapko theek lage wo chunein.');
  String get gsShravanDesc => _p(
      'Calming ragas, tones and sounds for you and your baby.',
      'Aapke aur baby ke liye shaant ragas, sur aur dhwaniyan.');
  String get gsVicharaDesc => _p(
      'Sacred insights, gentle brain games and uplifting reads.',
      'Pavitra insights, halke brain games aur uplifting reads.');
  String get gsSamvadDesc => _p(
      'Speaking cards to read aloud — your voice, for your baby.',
      'Padhne ke liye speaking cards — aapki awaaz, aapke baby ke liye.');
  String get gsKriyaDesc => _p(
      'Gentle, safe prenatal movement and breathing practices.',
      'Saumya, surakshit prenatal movement aur saans ki practices.');
  String get gsBrowseAll =>
      _p('Browse the full collection.', 'Poora sangrah dekhein.');
  String get gsSamvadAffirm => _p('Affirmations', 'Affirmations');
  String get gsSamvadScripts =>
      _p('Read-aloud stories', 'Padhkar sunane wali kahaniyan');
  String get gsSamvadVisualize => _p('Visualizations', 'Visualizations');
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

  // ---- Garbh Sanskar v2.0 (daily ritual) ----------------------------------
  String get gsAhara => _p('Ahara', 'Ahara');
  String get gsAharaTag => _p('Nourishment', 'Poshan');
  String gsDayOfWeek(int day, int week) =>
      _p('Day $day of Week $week', 'Week $week ka Din $day');
  String get gsBabySize => _p('Baby size', 'Baby ka size');
  String get gsTodaysProgress => _p("Today's progress", 'Aaj ki pragati');
  String gsRitualsDone(int done, int goal) =>
      _p('$done / $goal rituals completed', '$done / $goal rituals poore');
  String gsDayStreak(int n) => _p('$n day streak', '$n din ki streak');
  String get gsTodaysRituals => _p("Today's rituals", 'Aaj ke rituals');
  String get gsVicharaTodo => _p('A reflection, a puzzle, or an uplifting read',
      'Ek vichaar, ek puzzle, ya ek prernadayi read');
  String gsDailyGoalLine(int goal) =>
      _p('Goal: $goal / $goal each day', 'Lakshya: roz $goal / $goal');
  String get gsAllDone =>
      _p('All 5 rituals complete — beautiful 💛', 'Saare 5 rituals poore — bahut sundar 💛');
  String get gsWhatToDo => _p('What to do', 'Kya karna hai');
  String get gsWhyMatters => _p('Why it matters', 'Yeh kyun zaroori hai');
  String get gsStart => _p('Start', 'Shuru karein');
  String get gsMarkDone => _p('Mark complete', 'Poora hua');
  String get gsCompletedToday => _p('Completed today', 'Aaj poora hua');
  String get gsTodaysSession => _p("Today's listening session", 'Aaj ka listening session');
  String get gsWhyToday =>
      _p('Why this is recommended today', 'Yeh aaj kyun recommend kiya');
  String get gsTabSacred => _p('Sacred Insights', 'Pavitra Vichar');
  String get gsTabBrain => _p('Brain Fitness', 'Brain Fitness');
  String get gsTabUplifting => _p('Uplifting Vibrations', 'Uplifting Vibrations');
  String get gsSamvadTabAffirm =>
      _p('Affirmations & Blessings', 'Affirmations & Aashirwad');
  String get gsSamvadTabStories => _p('Stories & Fables', 'Kahaniyaan & Fables');
  String get gsSamvadTabMantras => _p('Mantras & Lullabies', 'Mantra & Lories');
  String get gsSamvadTabSpiritual =>
      _p('Spiritual Reading', 'Aadhyaatmik Paath');
  String get gsMeaning => _p('What it means', 'Iska matlab');
  String get gsLesson => _p('Life lesson', 'Jeevan ka sabak');
  String get gsReadAloud => _p('Read aloud', 'Padh kar sunaayein');
  String get gsTodaysPractice => _p("Today's practice", 'Aaj ka abhyaas');
  String get gsSafetyNotes => _p('Safety notes', 'Suraksha note');
  String get gsTodaysNutrition => _p("Today's nutrition", 'Aaj ka poshan');
  String get gsRecipe => _p('Recommended recipe', 'Recommended recipe');
  String get gsFoodSwap => _p('Food swap', 'Food swap');
  String get gsLifestyleHabit => _p('Lifestyle habit', 'Lifestyle habit');
  String get gsLearnMore => _p('Learn more', 'Aur jaanein');
  String get gsLearnMoreSoon =>
      _p('Ask Veda is coming soon — your personal AI guide.',
          'Ask Veda jald aa raha hai — aapka personal AI guide.');
  String get gsRelatedDiscussions =>
      _p('Mothers are also discussing', 'Maaayein ispar baat kar rahi hain');
  String get gsPuzzleSoon =>
      _p('This puzzle opens soon — counts as done for today ❤️',
          'Yeh puzzle jald — aaj ke liye poora maana jaayega ❤️');
  // Vichara brain games — shared chrome.
  String get gsGameDone =>
      _p('Well done — a calm few minutes 🌿', 'Shabaash — kuch shaant pal 🌿');
  String get gsPlayAgain => _p('Play again', 'Phir se khelein');
  String get gsGameClose => _p('Done', 'Ho gaya');
  String get gsWordSearchHow => _p(
      'Tap the first and last letter of a hidden word.',
      'Chhupe shabd ke pehle aur aakhri akshar par tap karein.');
  String gsWordsFound(int a, int b) =>
      _p('$a of $b found', '$b mein se $a mile');
  String get gsSudokuHow => _p(
      'Fill 1–4 so every row, column and box has no repeats.',
      'Aise bharein ki har row, column aur box mein 1–4 dohraayein nahi.');
  String get gsLogicHow =>
      _p('Pick the answer that fits.', 'Sahi jawaab chunein.');
  String get gsLogicNudge =>
      _p('Not quite — try another 🌸', 'Bilkul nahi — doosra try karein 🌸');
  String gsLogicProgress(int a, int b) => _p('$a of $b', '$b mein se $a');
  String get gsMemoryHow => _p('Flip two cards to find the matching pairs.',
      'Do cards palatein aur jodi milayein.');

  // ---- Community (Tools) ---------------------------------------------------
  String get cmTitle => _p('Community', 'Community');
  String get cmSearchHint => _p(
      'Search communities, topics or posts', 'Communities, topics ya posts search karein');
  String get cmJoinedSection => _p('Your communities', 'Aapki communities');
  String get cmRecommended => _p('Recommended for you', 'Aapke liye recommended');
  String get cmRecommendedEmpty => _p(
      "You've joined every community 🎉 — they're all up in 'Your communities'.",
      "Aapne saari communities join kar li 🎉 — wo sab 'Aapki communities' mein hain.");
  String get cmPulse => _p('Community Pulse', 'Community Pulse');
  String get cmFeed => _p('For you', 'Aapke liye');
  String get cmWalkingTogether => _p('Walking together', 'Saath chalte hain');
  String get cmMyActivity => _p('My Activity', 'Meri Activity');
  String get cmMyBookmarks => _p('My Bookmarks', 'Mere Bookmarks');
  String get cmActPosts => _p('Your posts', 'Aapki posts');
  String get cmActLiked => _p('Liked', 'Pasand kiye');
  String get cmActCommented => _p('Commented', 'Comment kiye');
  String get cmActUpvoted => _p('Endorsed', 'Endorse kiye');
  String get cmActEmpty => _p(
      'Your posts, likes and comments will appear here.',
      'Aapki posts, likes aur comments yahan dikhenge.');
  String get cmBookmarksEmpty => _p(
      'Posts you bookmark will be saved here.',
      'Jo posts aap bookmark karengi woh yahan save honge.');
  String get cmJoin => _p('Join', 'Join karein');
  String get cmJoinedBadge => _p('Joined', 'Joined');
  String get cmLeave => _p('Leave community', 'Community chhodein');
  String get cmMute => _p('Mute community', 'Community mute karein');
  String get cmUnmute => _p('Unmute community', 'Unmute karein');
  // Twitter-style post card + ⋯ menu + profiles.
  String get cmInCommunity => _p('in', 'in');
  String get cmReposted => _p('Reposted ✓', 'Repost ho gaya ✓');
  String get cmRepostUndone => _p('Repost removed', 'Repost hata diya');
  String get cmShared => _p('Sharing… (preview)', 'Share ho raha hai… (preview)');
  String get cmFollow => _p('Follow', 'Follow');
  String get cmUnfollow => _p('Unfollow', 'Unfollow');
  String get cmFollowingState => _p('Following', 'Following');
  String get cmFollowedToast =>
      _p('Following — their posts show in Following',
          'Follow kiya — unke posts Following mein dikhenge');
  String get cmUnfollowedToast => _p('Unfollowed', 'Unfollow kiya');
  String get cmNotInterested => _p('Not interested', 'Interested nahi');
  String get cmNotInterestedDone =>
      _p("Got it — we'll show fewer like this",
          'Theek hai — aise posts kam dikhayenge');
  String get cmMuteUser => _p('Mute', 'Mute');
  String get cmMutedToast => _p('Muted', 'Mute kiya');
  String get cmBlock => _p('Block', 'Block');
  String get cmBlockedToast => _p('Blocked', 'Block kiya');
  String get cmReport => _p('Report post', 'Post report karein');
  String get cmReportedToast =>
      _p('Reported — thank you', 'Report kiya — shukriya');
  String get cmYourFeed => _p('Your feed', 'Aapka feed');
  String get cmFollowingEmpty =>
      _p('Your Following feed is empty', 'Following feed abhi khaali hai');
  String get cmFollowingEmptySub => _p(
      'Join communities or follow experts to see their posts here.',
      'Communities join karein ya experts ko follow karein — unke posts yahan dikhenge.');
  String get cmExpertBio => _p(
      'Verified expert on ParentVeda. Here to support mothers through pregnancy, birth and the early days with gentle, evidence-based guidance. 💜',
      'ParentVeda par verified expert. Pregnancy, birth aur shuruaati dino mein maaon ka saath dene ke liye — gentle, evidence-based guidance ke saath. 💜');
  String get cmMember => _p('Member', 'Member');
  String get cmPostsCount => _p('Posts', 'Posts');
  String get cmFollowers => _p('Followers', 'Followers');
  String get cmFollowingCount => _p('Following', 'Following');
  String get cmNoPostsYet => _p('No posts yet', 'Abhi koi post nahi');
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
  // ---- Product Checklist (tool) --------------------------------------------
  String get pclTitle => _p('Product Checklist', 'Product Checklist');
  String get pclIntro => _p(
      'Build your own checklists from our products — add what you want, note when you need it, and tick things off as you get them.',
      'Hamare products se apni khud ki checklist banayein — jo chahiye add karein, kab chahiye likhein, aur milte hi tick karein.');
  String get pclYourLists => _p('Your checklists', 'Aapki checklists');
  String get pclNewChecklist => _p('New checklist', 'Nayi checklist');
  String get pclNamePrompt =>
      _p('Name your checklist', 'Checklist ko naam dein');
  String get pclRename => _p('Rename', 'Naam badlein');
  String get pclDelete => _p('Delete', 'Delete');
  String get pclDeleteConfirm =>
      _p('Delete this checklist?', 'Yeh checklist delete karein?');
  String get pclDeleted => _p('Checklist deleted', 'Checklist delete ho gayi');
  String get pclCurated => _p('Curated starters', 'Curated starters');
  String get pclCuratedSub => _p('Ready-made lists you can make your own.',
      'Banayi-banayi lists, jinhe aap apna bana sakti hain.');
  String get pclAdopt =>
      _p('Add to my checklists', 'Meri checklists mein add karein');
  String get pclAddProducts => _p('Add products', 'Products add karein');
  String get pclAdd => _p('Add', 'Add');
  String get pclAdded => _p('Added', 'Added');
  String pclAddedTo(String name) =>
      _p('Added to $name', '$name mein add ho gaya');
  String get pclAddToChecklist =>
      _p('Add to checklist', 'Checklist mein add karein');
  String pclGotChip(int got, int total) => _p('$got/$total', '$got/$total');
  String pclGotOf(int got, int total) =>
      _p('$got of $total ticked', '$total mein se $got ticked');
  String get pclSaveList => _p('Save list', 'List save karein');
  String get pclSavedSnack => _p('Checklist saved ✓', 'Checklist save ho gayi ✓');
  String get pclAddRemaining =>
      _p('Add remaining to cart', 'Baaki cart mein daalein');
  String get pclGotPromptTitle => _p('Already got this?', 'Yeh mil gaya?');
  String get pclGotPromptBody => _p(
      "Mark it as something you already have — it won't be added to your cart.",
      'Ise aapke paas mojood maan lein — yeh cart mein nahi jaayega.');
  String get pclGotPromptYes => _p('Yes, got it', 'Haan, mil gaya');
  String get pclGotPromptNo => _p('Not yet', 'Abhi nahi');
  String get pclAffiliate => _p('Affiliate', 'Affiliate');
  String get pclCustomTag => _p('Yours', 'Aapka');
  String get pclBoughtTag => _p('Bought ✓', 'Le liya ✓');
  String get pclOpenLink => _p('Open link', 'Link kholein');
  String get pclAddOwn => _p('Add your own product', 'Apna product add karein');
  String get pclCustomName => _p('Product name', 'Product ka naam');
  String get pclCustomLink => _p('Link (optional)', 'Link (optional)');
  String get pclCustomPrice => _p('Price (optional)', 'Daam (optional)');
  String get pclCustomNote =>
      _p('When / note (optional)', 'Kab / note (optional)');
  String pclCustomAdded(String name) =>
      _p('Added "$name" to your list', '"$name" list mein add ho gaya');
  String pclItemsCount(int n) => _p('$n items', '$n cheezein');
  String pclListSummary(int total, int got) => total == 0
      ? _p('No products yet', 'Abhi koi product nahi')
      : _p('$total items · $got/$total got', '$total cheezein · $got/$total mila');
  String get pclNotePrompt =>
      _p('When do you need it?', 'Yeh kab chahiye?');
  String get pclAddWhen => _p('Add when', 'Kab chahiye, likhein');
  String get pclEditNote => _p('Edit note', 'Note edit karein');
  String get pclRemove => _p('Remove', 'Hatayein');
  String get pclEmpty => _p(
      'No checklists yet. Create one and add the products you love.',
      'Abhi koi checklist nahi. Ek banayein aur apne pasand ke products add karein.');
  String get pclEmptyItems => _p(
      'No products yet. Add some from our catalogue.',
      'Abhi koi product nahi. Hamare catalogue se kuch add karein.');
  String get pclSearchHint => _p('Search products', 'Products search karein');
  String get pclNoResults => _p('No products found', 'Koi product nahi mila');
  String get pclSave => _p('Save', 'Save');
  String get pclCancel => _p('Cancel', 'Cancel');

  // ---- Shopping cart (preview, no real payment) ----------------------------
  String get cartProductsTitle => _p('Cart', 'Cart');
  String get cartHospitalTitle =>
      _p('Hospital Bag Cart', 'Hospital Bag Cart');
  String get cartAddToCart => _p('Add to cart', 'Cart mein add karein');
  String get cartAddAllToCart =>
      _p('Add all to cart', 'Sab cart mein add karein');
  String get cartBuyNow => _p('Buy now', 'Abhi khareedein');
  String get cartCheckout => _p('Checkout', 'Checkout');
  String get cartPlaceOrder => _p('Place order', 'Order place karein');
  String get cartSubtotal => _p('Subtotal', 'Subtotal');
  String get cartDelivery => _p('Delivery', 'Delivery');
  String get cartFree => _p('Free', 'Free');
  String get cartTotal => _p('Total', 'Total');
  String get cartEach => _p('each', 'each');
  String cartItems(int n) => _p('$n item${n == 1 ? '' : 's'}',
      '$n cheez${n == 1 ? '' : 'ein'}');
  String get cartSize => _p('Size', 'Size');
  String get cartColor => _p('Colour', 'Colour');
  String get cartChooseSize => _p('Choose a size', 'Size chunein');
  String get cartEmpty => _p('Your cart is empty', 'Aapka cart khaali hai');
  String get cartEmptyHint => _p(
      'Add products and they will show up here.',
      'Products add karein, woh yahan dikhenge.');
  String get cartAddedToCart => _p('Added to cart', 'Cart mein add ho gaya');
  String cartAddedN(int n) => _p('$n added to cart',
      '$n cart mein add ho gaye');
  String get cartAllInCart =>
      _p('Already in your cart', 'Pehle se aapke cart mein hai');
  String get cartViewCart => _p('View cart', 'Cart dekhein');
  String get cartOrderSummary => _p('Order summary', 'Order summary');
  String get cartDeliverTo => _p('Deliver to', 'Yahan bhejein');
  String get cartDeliverToValue =>
      _p('Home · Add address', 'Ghar · Address add karein');
  String get cartChange => _p('Change', 'Badlein');
  String get cartPaymentMethod => _p('Payment method', 'Payment method');
  String get cartComingSoonTag => _p('Coming soon', 'Jald aa raha hai');
  String get cartOrderPlaced => _p('Order placed', 'Order ho gaya');
  String get cartOrderPlacedSub => _p(
      'This is a preview — no payment was taken. We will let you know the moment checkout goes live. 💜',
      'Yeh ek preview hai — koi payment nahi liya gaya. Checkout live hote hi aapko bata denge. 💜');
  String get cartContinueShopping =>
      _p('Continue shopping', 'Shopping jaari rakhein');

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
  String get prAffiliate => _p('Affiliate', 'Affiliate');
  String get prBuyOnAmazon => _p('Buy on Amazon', 'Amazon par khareedein');
  String get prAffiliateNote => _p('Sold on Amazon — opens externally.',
      'Amazon par milta hai — bahar khulta hai.');
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
  String get cmPostAsDoctor => _p('Post as doctor', 'Doctor ban kar post karein');
  String get cmPostedAsDoctor => _p('Posted as a verified doctor 🩺', 'Verified doctor ke roop mein post ho gaya 🩺');
  String get cmPostingAsDoctor => _p('Posting as a verified doctor', 'Verified doctor ke roop mein post');
  String get cmExpertBadge => _p('Expert', 'Expert');
  String get cmComingSoon => _p('Coming soon', 'Jald aa raha hai');
  String get cmRemindMe => _p('Remind me', 'Yaad dilayein');
  // ---- Community Pro: trust-building expert endorsement layer ---------------
  String get cmSubtitle => _p(
      'A circle of mothers, walking the same path as you.',
      'Maaon ka ek circle, jo aapke saath usi raah par chal rahi hain.');
  String get cmFollowing => _p('Following', 'Follow kiye');
  String cmNew(int n) => _p('$n new', '$n naye');
  String get cmEndorsed => _p('Verified expert backs this experience',
      'Verified expert is anubhav ko samarthan dete hain');
  String get cmExpertLiked => _p('Liked', 'Pasand');
  String get cmVerifiedExpert => _p('Verified expert', 'Verified expert');
  // Expert-endorsement credibility count + "who verified" sheet.
  String cmPlusExperts(int n) =>
      _p('+$n other experts', '+$n aur experts');
  String get cmExpertsWhoVerified =>
      _p('Verified by these experts', 'In experts ne verify kiya');
  String cmAndMoreExperts(int n) =>
      _p('…and $n more verified experts', '…aur $n verified experts');
  // Doctor (test) mode + endorse flow.
  String get cmDoctorMode => _p('Doctor mode', 'Doctor mode');
  String get cmDoctorBanner => _p(
      "You're viewing as a verified doctor · test mode",
      'Aap ek verified doctor ke roop mein dekh rahe hain · test mode');
  String get cmDoctorOn =>
      _p('Doctor mode on — test', 'Doctor mode on — test');
  String get cmDoctorOff => _p('Doctor mode off', 'Doctor mode off');
  String get cmEndorseThis => _p('Verify this', 'Verify karein');
  String get cmYouVerified => _p('You verified this', 'Aapne verify kiya');
  String get cmExit => _p('Exit', 'Exit');
  // Subtle "verified by an expert" hint (replaces the old full-width banner).
  String cmVerifiedBy(String name) =>
      _p('Verified by $name', '$name ne verify kiya');
  String cmVerifiedByPlus(String name, int n) => _p(
      'Verified by $name +$n experts', '$name +$n experts ne verify kiya');
  // Request-an-expert-to-verify flow (composer toggle, pending tag, expert filter).
  String get cmAskVerifyTitle =>
      _p('Ask an expert to verify this', 'Expert se verify karne ko kahein');
  String get cmAskVerifySub => _p(
      'A verified expert can review and confirm your post.',
      'Ek verified expert aapke post ko dekh kar confirm kar sakte hain.');
  String get cmPendingVerify =>
      _p('Awaiting expert verification', 'Expert verification ka intezaar');
  String get cmNeedsVerify => _p('Needs verification', 'Verification chahiye');
  String get cmNoVerifyRequests => _p(
      'No posts are waiting for verification right now.',
      'Abhi koi post verification ke liye nahi hai.');
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
        return _p('Mental health', 'Mental health');
      default:
        return _p('Any doctor', 'Koi bhi doctor');
    }
  }

  String get cmChooseSpecialty =>
      _p('Which expert should we ask?', 'Kis expert se poochein?');
  String cmAwaitingSpecialty(String specialty) => _p(
      'Awaiting $specialty verification', '$specialty verification ka intezaar');
  String get cmCommentToVerify =>
      _p('Comment to verify this post', 'Verify karne ke liye comment karein');
  String get cmShareVia => _p('via ParentVeda Community', 'ParentVeda Community se');
  // Composer — write & add photos to a community.
  String get cmAddPhotos => _p('Add photos', 'Photos jodein');
  String get cmCamera => _p('Camera', 'Camera');
  String get cmWritePrompt => _p('Share something with this group…',
      'Is group ke saath kuch share karein…');
  // Community Pulse cards (Community Pro design).
  String get cmPulse1Tag => _p('YOU ARE NOT ALONE', 'AAP AKELI NAHI HAIN');
  String get cmPulse1Text => _p('127 mothers are also due in November 2026.',
      '127 mummies bhi November 2026 mein due hain.');
  String get cmPulse1Foot =>
      _p('+124 mamas online right now', '+124 mummies abhi online');
  String get cmPulse2Tag => _p('TRENDING TODAY', 'AAJ TRENDING');
  String get cmPulse2Text => _p('34 mamas are sharing their week-18 wins.',
      '34 mummies apni week-18 ki jeet share kar rahi hain.');
  String get cmPulse2Foot => _p('#Week18 · updated 2h ago',
      '#Week18 · 2 ghante pehle update');
  String get cmPulse3Tag => _p('EXPERT LIVE', 'EXPERT LIVE');
  String get cmPulse3Text => _p('Dr. Meera is hosting a latch & feeding Q&A.',
      'Dr. Meera latch & feeding Q&A le rahi hain.');
  String get cmPulse3Foot => _p('Today · 6:00 PM · Tap to set a reminder',
      'Aaj · 6:00 PM · Reminder set karne ke liye tap karein');
  String get cmPulse4Tag => _p('A GENTLE REMINDER', 'EK PYAARA REMINDER');
  String get cmPulse4Text => _p('You grew a whole heartbeat this month. 💜',
      'Is mahine aapne ek poori dhadkan badhayi. 💜');
  String get cmPulse4Foot => _p('Tap to log how you are feeling today',
      'Aaj kaisa lag raha hai, log karne ke liye tap karein');
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

  // ---- Daily Reads (Home — above Read Next) --------------------------------
  String get drTitle => _p('Daily Reads', 'Daily Reads');
  String get drArticles => _p('Articles', 'Lekh');
  String get drBooks => _p('Books', 'Kitaabein');
  String get drSeeAll => _p('See all', 'Sabhi dekhein');

  // ---- Read recommendations ❤️ (formerly "Read Next" / "Library") ----------
  String get rnTitle =>
      _p('Read recommendations', 'Read recommendations');
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
