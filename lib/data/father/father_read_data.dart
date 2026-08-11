// =============================================================================
//  Father Read slots - "Read recommendations" tailored for the dad
// -----------------------------------------------------------------------------
//  The mother's daily reads come from kReadItems (read_next_data.dart). These
//  are the FATHER slots for the same Read-recommendations layer: week-aware
//  reads written for the dad - about her, the baby, and how to support - so the
//  Father Daily "Daily read" card surfaces real, relevant content instead of a
//  placeholder. Re-voiced from the mother set (third-person about her) plus a
//  few dad-specific pieces. English only, matching the Father screen.
//
//  Mirrors the mother "Learn V2" reader: each item can carry whyThisMatters +
//  researchSimplified (+ optional myth/fact) shown as styled blocks in the
//  father Slate reader. Types span article / research / book so the Reads tab
//  can group them as Articles · Research Summaries · Book Summaries.
// =============================================================================

import '../../models/read_item.dart';
import '../../localization/app_language.dart';

/// English-only, awaiting translation. Same shape as a translated pair so
/// the shared model can widen, but deliberately NOT `_t(x, x)`: an
/// identical pair reads as finished work to anything counting pairs.
/// `grep -c '_en('` is the size of what is left here.
///
/// UNUSED AS OF 2026-08-11 — every marker in this file has been translated, and
/// that is exactly why it stays. It is the marker for the NEXT English-only
/// string somebody adds, and deleting it would leave them reaching for
/// `_t(x, x)`, which is the form that once let can_i_data be reported finished
/// with 302 strings still English. `tool/hindi_audit.py` greps for this name.
// ignore: unused_element
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

LocalizedText _t(String en, String hi) => LocalizedText(en: en, hi: hi);

/// Identical in both languages BY NATURE - a book title, an author, a brand.
///
/// The counterpart to `_en()` above and the reason both exist: they produce the
/// SAME LocalizedText, so only the name records which kind of "no Hindi here"
/// this is. `_en()` is a debt; this is a finished decision. Collapsing them
/// would make `grep -c '_en('` stop being the size of what is left.
LocalizedText _same(String s) => LocalizedText(en: s, hi: s);

final List<ReadItem> kFatherReadItems = [
  ReadItem(
    id: 'f_baby_hears',
    title: _t('What Your Baby Can Hear at 20 Weeks', '20 हफ़्ते पर आपका शिशु क्या सुनता है'),
    type: ReadType.article,
    weekStart: 18,
    weekEnd: 24,
    priority: 'high',
    reason: _t('Your voice carries especially well now - here is why reading aloud matters.', 'आपकी आवाज़ अभी ख़ास तौर पर अच्छी तरह पहुँचती है — इसीलिए पढ़कर सुनाना मायने रखता है।'),
    readingTime: _t('3 min', '3 मिनट'),
    category: _t('Bonding', 'जुड़ाव'),
    emoji: '👂',
    body: _t('Around now the tiny bones of your baby\'s inner ear finish forming, and sound begins to reach them. Your voice - lower and slower than hers - carries especially well through the body.\n\n'
        'Reading a few lines aloud each day is not sentimental; it is how your baby starts to know you before they ever see you. The rhythm matters more than the words.\n\n'
        'A minute is plenty. Pick a short story, sit close to her bump, and let your voice rise and fall.', 'इन्हीं दिनों शिशु के भीतरी कान की नन्ही हड्डियाँ बनकर पूरी होती हैं, और आवाज़ उन तक पहुँचने लगती है। आपकी आवाज़ — उनकी आवाज़ से भारी और धीमी — शरीर के भीतर से ख़ास तौर पर अच्छी तरह पहुँचती है।\n\n'
        'रोज़ दो-चार पंक्तियाँ पढ़कर सुनाना कोई भावुक सी बात नहीं है; इसी तरह शिशु आपको देखने से पहले ही आपको जानने लगते हैं। शब्दों से ज़्यादा मायने लय रखती है।\n\n'
        'एक मिनट भी काफ़ी है। कोई छोटी सी कहानी चुनिए, उनके बंप के पास बैठिए, और अपनी आवाज़ को चढ़ने-उतरने दीजिए।'),
    whyThisMatters: _t('Your baby learning your voice now is not a nice-to-have - it lays the first thread of attachment. Newborns turn toward voices they heard in the womb, and a father\'s lower pitch is one of the easiest for them to pick out. The minutes you spend reading aloud quietly build a recognition that pays off the day they are born.', 'शिशु का अभी आपकी आवाज़ पहचानने लगना ऐसी चीज़ नहीं जो हो तो अच्छी, न हो तो चले — यहीं से लगाव का पहला धागा बँधता है। नवजात उन आवाज़ों की ओर मुड़ते हैं जो उन्होंने पेट के भीतर सुनी थीं, और पिता की भारी आवाज़ उनके लिए पहचानना सबसे आसान आवाज़ों में से एक है। पढ़कर सुनाने में लगाए आपके ये चंद मिनट चुपचाप एक पहचान बनाते रहते हैं, जो जन्म के दिन काम आती है।'),
    researchSimplified: _t('Newborns calm to voices and rhymes they heard repeatedly before birth, and can tell their parents\' voices apart within days. Low-frequency sound travels through tissue better than high sound, so your voice reaches the womb clearly. In short: repetition plus your natural pitch equals a baby who already knows you.', 'जन्म से पहले बार-बार सुनी आवाज़ों और तुकबंदियों से नवजात शांत हो जाते हैं, और कुछ ही दिनों में अपने माँ-बाप की आवाज़ें अलग-अलग पहचानने लगते हैं। कम frequency वाली आवाज़ ऊँची आवाज़ के मुक़ाबले शरीर के भीतर से बेहतर गुज़रती है, इसलिए आपकी आवाज़ गर्भ तक साफ़ पहुँचती है। कुल मिलाकर: दोहराव और आपकी अपनी भारी आवाज़ — इन्हीं दोनों से शिशु जन्म से पहले ही आपको जानने लगता है।'),
    myth: _t('The baby cannot really hear me through the bump yet.', 'बंप के पार शिशु मुझे अभी सच में सुन नहीं सकता।'),
    fact: _t('By around 20 weeks the inner ear is working and low sounds - like your voice - reach your baby clearly.', 'क़रीब 20 हफ़्ते तक भीतरी कान काम करने लगता है और कम आवाज़ें — जैसे आपकी — शिशु तक साफ़ पहुँचती हैं।'),
  ),
  ReadItem(
    id: 'f_halfway',
    title: _t("She's Halfway - What's Changing for Her", 'वे आधे रास्ते पर हैं — उनके लिए क्या बदल रहा है'),
    type: ReadType.article,
    weekStart: 18,
    weekEnd: 22,
    priority: 'high',
    reason: _t('Around week 20 she reaches the halfway point - here is how to show up.', 'हफ़्ता 20 के आसपास वे आधे रास्ते पर पहुँचती हैं — आप कैसे साथ दे सकते हैं।'),
    readingTime: _t('4 min', '4 मिनट'),
    category: _t('Supporting Her', 'उनका साथ'),
    emoji: '🌗',
    body: _t('Around week 20 she reaches the halfway mark - a real milestone. Many mothers feel more energetic now, the bump becomes visible, and the first kicks often arrive.\n\n'
        'What she needs from you is presence, not fixes. Her body is doing enormous work, and a little practical help - a chore taken off her plate, an early night - lands bigger than grand gestures.\n\n'
        'It is also a lovely window to connect with the baby together: your voice is clear to them now, so read or talk to the bump while she rests.', 'हफ़्ता 20 के आसपास वे आधे रास्ते पर पहुँच जाती हैं — यह सचमुच एक पड़ाव है। कई माँओं को अब ज़्यादा ताक़त महसूस होती है, बंप दिखने लगता है, और पहली लातें अक्सर इसी दौर में आती हैं।\n\nउन्हें आपसे साथ चाहिए, हल नहीं। उनका शरीर बहुत बड़ा काम कर रहा है, और थोड़ी सी असली मदद — कोई काम अपने ज़िम्मे ले लेना, जल्दी सुला देना — बड़े-बड़े इशारों से कहीं ज़्यादा मायने रखती है।\n\nयह शिशु से साथ मिलकर जुड़ने का भी अच्छा मौक़ा है: आपकी आवाज़ अब उन तक साफ़ पहुँचती है, तो जब वे आराम कर रही हों, बंप से बात कीजिए या पढ़कर सुनाइए।'),
    whyThisMatters: _t('The halfway point is when pregnancy starts to feel real for many dads too. Knowing what is shifting for her - energy, body, the first kicks - lets you offer the specific, practical support that actually lands, instead of guessing.', 'आधा रास्ता वह जगह है जहाँ कई पिताओं के लिए भी गर्भावस्था असली लगने लगती है। उनके लिए क्या बदल रहा है — ताक़त, शरीर, पहली लातें — यह जानने से आप अंदाज़ा लगाने के बजाय वह ठोस, काम की मदद कर पाते हैं जो सच में असर करती है।'),
    researchSimplified: _t('Around the mid-point many women report an energy rebound as early fatigue eases. Partner support is consistently linked to lower stress and better wellbeing in pregnancy, and practical help (chores, rest) reduces her load more than reassurance alone.', 'बीच के दौर में कई महिलाएँ बताती हैं कि शुरुआती थकान कम होते ही ताक़त लौट आती है। साथी का सहारा लगातार कम तनाव और बेहतर सेहत से जुड़ा पाया गया है, और असली मदद (घर के काम, आराम) अकेले तसल्ली देने से ज़्यादा उनका बोझ घटाती है।'),
  ),
  ReadItem(
    id: 'f_anomaly_scan',
    title: _t('The 20-Week Scan - How to Be There for Her', '20 हफ़्ते का scan — उनके साथ कैसे खड़े रहें'),
    type: ReadType.article,
    weekStart: 18,
    weekEnd: 22,
    priority: 'high',
    reason: _t('The detailed anatomy scan is around now - your presence matters.', 'विस्तृत anatomy scan इन्हीं दिनों है — आपका साथ मायने रखता है।'),
    readingTime: _t('4 min', '4 मिनट'),
    category: _t('Supporting Her', 'उनका साथ'),
    emoji: '🔍',
    body: _t('The anomaly scan, usually around weeks 18–22, is a detailed look at how your baby is developing - heart, brain, spine, limbs and organs. It takes longer than earlier scans.\n\n'
        'You can usually go with her, and your presence matters more than you think - these appointments can carry quiet anxiety. Write down any questions beforehand so neither of you forgets them in the moment.\n\n'
        'Most findings are reassuring. If anything needs a closer look, the doctor will guide the next steps calmly - your job is simply to be steady beside her.', 'Anomaly scan, आम तौर पर 18–22 हफ़्ते के बीच, इस बात की बारीक जाँच है कि आपका शिशु कैसे बन रहा है — दिल, दिमाग़, रीढ़, हाथ-पैर और बाक़ी अंग। इसमें पिछले scan से ज़्यादा वक़्त लगता है।\n\nआप आम तौर पर उनके साथ जा सकते हैं, और आपका वहाँ होना आपके सोचने से कहीं ज़्यादा मायने रखता है — इन मुलाक़ातों में एक चुपचाप घबराहट रहती है। सवाल पहले से लिख लीजिए, ताकि मौक़े पर दोनों में से कोई भूल न जाए।\n\nज़्यादातर नतीजे तसल्ली देने वाले होते हैं। अगर किसी चीज़ को और क़रीब से देखने की ज़रूरत हुई, तो डॉक्टर शांति से आगे के क़दम बताएँगे — आपका काम बस उनके पास ठहरे हुए खड़े रहना है।'),
    whyThisMatters: _t('Scan days carry quiet anxiety even when everything is fine. Being there - steady, prepared, unhurried - is one of the clearest ways to show up. It also means you hear the same information she does, so you can talk it through together afterwards.', 'Scan वाले दिन एक चुपचाप घबराहट लिए आते हैं, तब भी जब सब ठीक हो। वहाँ होना — ठहरे हुए, तैयार, बिना जल्दबाज़ी के — साथ देने के सबसे साफ़ तरीक़ों में से एक है। इससे आप वही बात सुनते हैं जो वे सुनती हैं, तो बाद में दोनों मिलकर उस पर बात कर सकते हैं।'),
    researchSimplified: _t('The anomaly scan checks the baby\'s anatomy in detail; the large majority come back reassuring. Partner presence at antenatal appointments is associated with lower maternal anxiety, and writing questions down beforehand improves how much couples remember and understand.', 'Anomaly scan में शिशु के शरीर की बनावट बारीकी से देखी जाती है; ज़्यादातर मामलों में इसके नतीजे तसल्ली देने वाले होते हैं। गर्भावस्था की जाँच वाली मुलाक़ातों में साथी का मौजूद रहना माँ की कम घबराहट से जुड़ा पाया गया है, और सवाल पहले से लिखकर ले जाने से दोनों को ज़्यादा याद रहता है और बात ज़्यादा समझ में आती है।'),
  ),
  ReadItem(
    id: 'f_back_ache',
    title: _t('Why Her Back Aches Now - and What Helps', 'अब उनकी कमर क्यों दुखती है — और क्या मदद करता है'),
    type: ReadType.article,
    weekStart: 16,
    weekEnd: 30,
    priority: 'medium',
    reason: _t('Her centre of gravity is shifting - small, specific help lands big.', 'उनके शरीर का संतुलन आगे खिसक रहा है — छोटी, ठोस मदद बड़ा असर करती है।'),
    readingTime: _t('3 min', '3 मिनट'),
    category: _t('Supporting Her', 'उनका साथ'),
    emoji: '🤰',
    body: _t('As the bump grows, her centre of gravity shifts forward and her lower back takes the strain. By evening, it often aches.\n\n'
        'Small, specific help works best: offer a five-minute back rub, take the heavy lifting off her, and encourage her to rest on her side with a pillow for support.\n\n'
        'You do not need to solve it - just notice it before she has to ask. That noticing is its own kind of care.', 'बंप बढ़ने के साथ उनके शरीर का संतुलन आगे की ओर खिसकता है और सारा ज़ोर कमर के निचले हिस्से पर आ जाता है। शाम तक अक्सर वहीं दर्द होने लगता है।\n\nछोटी, ठोस मदद सबसे काम आती है: पाँच मिनट कमर सहला दीजिए, भारी सामान उठाने का काम अपने ज़िम्मे ले लीजिए, और उन्हें तकिये के सहारे करवट लेकर आराम करने को कहिए।\n\nआपको इसे ठीक नहीं करना है — बस उनके कहने से पहले नज़र पड़ जाना काफ़ी है। यही नज़र अपने आप में देखभाल है।'),
    whyThisMatters: _t('Back ache is one of the most common, most under-noticed strains of pregnancy. Spotting it before she has to ask turns "help" into care - and small, specific actions beat grand gestures every time.', 'कमर दर्द गर्भावस्था की सबसे आम और सबसे कम ध्यान में आने वाली तकलीफ़ों में से एक है। उनके कहने से पहले इसे भाँप लेना "मदद" को देखभाल बना देता है — और छोटे, ठोस काम हर बार बड़े-बड़े इशारों से आगे रहते हैं।'),
    researchSimplified: _t('As the uterus grows, the centre of gravity shifts forward and the lower-back muscles work harder, which is why aching peaks by evening. Side-lying with a support pillow and gentle counter-pressure (a short massage) are commonly recommended, low-risk ways to ease it.', 'बच्चेदानी बढ़ने के साथ शरीर का संतुलन आगे खिसकता है और कमर के निचले हिस्से की मांसपेशियों को ज़्यादा मेहनत करनी पड़ती है — इसीलिए दर्द शाम तक सबसे ज़्यादा होता है। तकिये के सहारे करवट लेकर लेटना और हल्का दबाव देना (छोटी मालिश) इसे कम करने के आम, कम जोखिम वाले तरीक़े माने जाते हैं।'),
  ),
  ReadItem(
    id: 'f_first_kicks',
    title: _t('Feeling the First Kicks Together', 'पहली लातें साथ में महसूस करना'),
    type: ReadType.article,
    weekStart: 18,
    weekEnd: 26,
    priority: 'medium',
    reason: _t('The first movements often arrive now - a moment to share.', 'पहली हलचल अक्सर इन्हीं दिनों आती है — यह पल साथ बाँटने लायक़ है।'),
    readingTime: _t('2 min', '2 मिनट'),
    category: _t('Bonding', 'जुड़ाव'),
    emoji: '👣',
    body: _t('Around now, the first flutters and kicks often arrive. At first they are faint - easy to miss - but they grow stronger over the coming weeks.\n\n'
        'Ask her to tell you when she feels one, and rest your hand gently on her bump. It may take patience; babies often go quiet when they sense a new pressure, then start again.\n\n'
        'The first time you feel that little nudge against your palm is a moment you will remember. Do not rush it - just be there for it.', 'इन्हीं दिनों पहली फड़कन और लातें अक्सर आ जाती हैं। शुरू में वे इतनी हल्की होती हैं कि छूट जाएँ — पर आने वाले हफ़्तों में मज़बूत होती जाती हैं।\n\nउनसे कहिए कि जब महसूस हो तो बताएँ, और अपना हाथ हल्के से उनके बंप पर रख दीजिए। सब्र लग सकता है; नया दबाव भाँपते ही शिशु अक्सर शांत हो जाते हैं, फिर दोबारा शुरू करते हैं।\n\nहथेली पर पहली बार वह नन्हा धक्का महसूस करना ऐसा पल है जो आपको याद रह जाएगा। इसमें जल्दी मत कीजिए — बस उसके लिए मौजूद रहिए।'),
    whyThisMatters: _t('Feeling the first kick is often the moment a dad\'s bond becomes physical. Sharing it - hand on the bump, waiting together - turns a private sensation into something you both hold.', 'पहली लात महसूस होना अक्सर वही पल होता है जब पिता का जुड़ाव छूकर महसूस होने लगता है। उसे साथ में बाँटना — बंप पर हाथ रखे, साथ मिलकर इंतज़ार करते हुए — एक ऐसे एहसास को, जो अब तक सिर्फ़ उनका था, आप दोनों का बना देता है।'),
    researchSimplified: _t('First movements (quickening) are usually felt by the mother before they are strong enough to feel from outside; external kicks tend to become palpable a few weeks later. Babies often still when they sense new pressure, then resume - so patience, not force, is the trick.', 'पहली हलचल (quickening) आम तौर पर माँ को तब महसूस होती है जब वह बाहर से महसूस होने लायक़ मज़बूत नहीं होती; बाहर से लातें कुछ हफ़्ते बाद हाथ पर लगने लगती हैं। नया दबाव भाँपते ही शिशु अक्सर ठहर जाते हैं, फिर शुरू कर देते हैं — इसलिए ज़ोर नहीं, सब्र ही तरकीब है।'),
  ),

  // ---- Research Summaries -------------------------------------------------
  ReadItem(
    id: 'f_res_voice',
    title: _t('The Science of Talking to the Bump', 'बंप से बात करने के पीछे का विज्ञान'),
    type: ReadType.research,
    weekStart: 16,
    weekEnd: 40,
    priority: 'medium',
    reason: _t('What the evidence actually says about prenatal bonding through sound.', 'आवाज़ से जन्म-पूर्व जुड़ाव पर सबूत असल में क्या कहते हैं।'),
    readingTime: _t('4 min', '4 मिनट'),
    category: _t('Research', 'शोध'),
    emoji: '🔬',
    body: _t('Prenatal hearing is one of the better-studied parts of fetal development, and the findings are surprisingly practical for dads.\n\n'
        'From the second trimester, the auditory system is wired enough to register sound, and low-frequency voices carry best through the abdominal wall. Repeated exposure to a melody or passage before birth shows up afterwards as recognition - newborns settle to what is familiar.\n\n'
        'The takeaway is simple: a short daily habit beats a rare grand gesture. Same story, same time, your voice.', 'जन्म से पहले सुनने की ताक़त, भ्रूण के विकास के सबसे अच्छी तरह पढ़े गए हिस्सों में से एक है, और उसके नतीजे पिताओं के लिए हैरान करने वाली हद तक काम के हैं।\n\nदूसरी तिमाही से सुनने का तंत्र इतना जुड़ चुका होता है कि आवाज़ दर्ज कर सके, और कम frequency वाली आवाज़ें पेट की दीवार से सबसे अच्छी तरह गुज़रती हैं। जन्म से पहले किसी धुन या पंक्ति को बार-बार सुनाना, जन्म के बाद पहचान बनकर दिखता है — जो जाना-पहचाना हो, नवजात उससे शांत होते हैं।\n\nनिचोड़ सीधा है: रोज़ की एक छोटी आदत, कभी-कभार के बड़े इशारे से बेहतर है। वही कहानी, वही वक़्त, आपकी आवाज़।'),
    whyThisMatters: _t('It reframes "talking to the bump" from something that feels awkward into something with a real, measurable payoff - a head start on the bond and on soothing your newborn.', '"बंप से बात करना" जो अटपटा लगता है, यह उसे एक असली, नापी जा सकने वाली कमाई में बदल देता है — लगाव में और नवजात को चुप कराने में, दोनों में एक शुरुआती बढ़त।'),
    researchSimplified: _t('Fetal heart-rate and newborn-behaviour studies consistently show recognition of pre-birth sounds. Low frequencies penetrate best, and repetition is the active ingredient. Practically: pick one short thing and repeat it daily.', 'भ्रूण की धड़कन और नवजात के व्यवहार पर हुए अध्ययन लगातार दिखाते हैं कि जन्म से पहले सुनी आवाज़ें पहचानी जाती हैं। कम frequency सबसे अच्छी तरह भीतर पहुँचती है, और असली असर दोहराव का होता है। व्यवहार में: कोई एक छोटी चीज़ चुनिए और उसे रोज़ दोहराइए।'),
  ),
  ReadItem(
    id: 'f_res_dads',
    title: _t('What the Research Says About Dads in Pregnancy', 'गर्भावस्था में पिता पर शोध क्या कहता है'),
    type: ReadType.research,
    weekStart: 12,
    weekEnd: 40,
    priority: 'medium',
    reason: _t('Involved partners measurably change how pregnancy goes for her.', 'साथ देने वाला साथी उनकी गर्भावस्था को नापी जा सकने वाली हद तक बदल देता है।'),
    readingTime: _t('5 min', '5 मिनट'),
    category: _t('Research', 'शोध'),
    emoji: '📊',
    body: _t('A father\'s involvement is not just sentimental - it correlates with concrete outcomes for mother and baby.\n\n'
        'Reviews link supportive partners to lower maternal stress, better antenatal-care attendance, and improved wellbeing. Some studies even associate strong partner support with healthier birth outcomes, likely through reduced stress and better self-care.\n\n'
        'The mechanism is ordinary: presence at appointments, sharing the mental load, and steady emotional support. None of it requires expertise - just showing up.', 'पिता का साथ देना सिर्फ़ भावुक सी बात नहीं है — इसका माँ और शिशु दोनों के ठोस नतीजों से नाता दिखता है।\n\n'
        'कई अध्ययनों को मिलाकर देखा गया है कि साथ देने वाला साथी हो तो माँ का तनाव कम रहता है, जाँच वाली मुलाक़ातें ज़्यादा नियम से होती हैं, और सेहत बेहतर रहती है। कुछ अध्ययनों में तो मज़बूत साथ का नाता जन्म के बेहतर नतीजों से भी जुड़ा मिला है — शायद कम तनाव और अपनी बेहतर देखभाल के रास्ते।\n\n'
        'तरीक़ा बहुत मामूली सा है: जाँच के वक़्त साथ होना, दिमाग़ पर पड़ा बोझ बाँटना, और लगातार भावनात्मक सहारा देना। इसमें किसी विशेषज्ञता की ज़रूरत नहीं — बस मौजूद रहने की।'),
    whyThisMatters: _t('If you have ever wondered whether your involvement really moves the needle, the evidence says it does - and it tells you where to spend your effort.', 'अगर आपने कभी सोचा हो कि आपके साथ देने से सच में कोई फ़र्क़ पड़ता है या नहीं, तो सबूत कहते हैं कि पड़ता है — और यह भी बताते हैं कि मेहनत कहाँ लगानी है।'),
    researchSimplified: _t('Across studies, partner support tracks with lower stress, better care engagement and wellbeing. The effective inputs are practical and emotional support plus appointment attendance - not grand gestures.', 'अलग-अलग अध्ययनों में साथी का सहारा कम तनाव, बेहतर देखभाल और बेहतर सेहत के साथ चलता दिखता है। असर करने वाली चीज़ें हैं — व्यावहारिक और भावनात्मक सहारा, और मुलाक़ातों में साथ जाना; बड़े-बड़े इशारे नहीं।'),
  ),

  // ---- Book Summaries -----------------------------------------------------
  ReadItem(
    id: 'f_book_handbook',
    title: _same("We're Pregnant! The First-Time Dad's Pregnancy Handbook"),
    type: ReadType.book,
    weekStart: 4,
    weekEnd: 40,
    priority: 'medium',
    reason: _t('A week-by-week, no-jargon field guide written dad-to-dad.', 'हफ़्ता-दर-हफ़्ता चलने वाली, बिना भारी शब्दों की गाइड — एक पिता से दूसरे पिता के लिए।'),
    readingTime: _t('Book · 5 min summary', 'किताब · 5 मिनट का सार'),
    category: _t('Book Summary', 'किताब का सार'),
    emoji: '📗',
    author: 'Adrian Kulp',
    rating: 4.6,
    ratingCount: 4200,
    why: _t('Warm, funny and practical - it treats the dad as a real participant, not a bystander, with concrete things to do each week.', 'गर्मजोशी भरी, मज़ेदार और काम की — यह पिता को असली हिस्सेदार मानती है, तमाशबीन नहीं, और हर हफ़्ते के लिए ठोस काम बताती है।'),
    body: _t('A week-by-week companion that walks a first-time father from positive test to delivery room. Each stage pairs what is happening for her and the baby with a short, doable list of ways to help.\n\n'
        'The tone is plain and reassuring - no medical jargon, no guilt - and it is honest about the parts nobody warns you about. Think of it as a field guide you dip into a few minutes at a time.\n\n'
        'Best used alongside her appointments: read the matching week, then show up prepared.', 'हफ़्ता-दर-हफ़्ता चलने वाली किताब, जो पहली बार पिता बन रहे आदमी को positive test से delivery room तक ले जाती है। हर पड़ाव पर बताती है कि उनके और शिशु के साथ क्या हो रहा है, और साथ में मदद करने के छोटे, कर सकने लायक़ तरीक़े गिनाती है।\n\nलहजा सीधा और तसल्ली देने वाला है — कोई डॉक्टरी भारी शब्द नहीं, कोई अपराधबोध नहीं — और यह उन हिस्सों पर भी ईमानदार है जिनके बारे में कोई पहले से नहीं बताता। इसे ऐसी गाइड समझिए जिसे आप कुछ-कुछ मिनट के लिए खोलते रहें।\n\nसबसे अच्छा तब है जब आप इसे उनकी जाँच-मुलाक़ातों के साथ पढ़ें: उस हफ़्ते वाला हिस्सा पढ़िए, फिर तैयार होकर पहुँचिए।'),
    buyUrl: '',
  ),
  ReadItem(
    id: 'f_book_dude',
    title: _same("Dude, You're Gonna Be a Dad!"),
    type: ReadType.book,
    weekStart: 4,
    weekEnd: 40,
    priority: 'medium',
    reason: _t('A quick, encouraging primer for the newly-terrified dad-to-be.', 'अभी-अभी घबराए, होने वाले पिता के लिए एक तेज़, हौसला देने वाली शुरुआत।'),
    readingTime: _t('Book · 4 min summary', 'किताब · 4 मिनट का सार'),
    category: _t('Book Summary', 'किताब का सार'),
    emoji: '📘',
    author: 'John Pfeiffer',
    rating: 4.5,
    ratingCount: 3100,
    why: _t('Short, blunt and encouraging - good for the dad who wants the essentials without a 300-page textbook.', 'छोटी, सीधी और हौसला देने वाली — उस पिता के लिए अच्छी जो 300 पन्नों की किताब के बिना ज़रूरी बातें जान लेना चाहता है।'),
    body: _t('A fast, confidence-building read that covers the essentials: what she is going through, what the appointments mean, how to prepare practically and financially, and how to be useful in the delivery room.\n\n'
        'It leans on humour to take the edge off the fear, then gets specific about what to actually do. Ideal for a dad who wants to feel ready without wading through jargon.\n\n'
        'Read the summary here, then keep the book handy for the trimester you are in.', 'तेज़ी से पढ़ी जाने वाली, भरोसा बढ़ाने वाली किताब जो ज़रूरी बातें बताती है: उन पर क्या बीत रहा है, जाँच-मुलाक़ातों का मतलब क्या है, व्यावहारिक और पैसों के लिहाज़ से कैसे तैयार हों, और delivery room में कैसे काम आएँ।\n\nयह डर की धार कम करने के लिए हँसी का सहारा लेती है, फिर साफ़-साफ़ बताती है कि करना क्या है। उस पिता के लिए बढ़िया जो भारी शब्दों में उलझे बिना तैयार महसूस करना चाहता है।\n\nसार यहीं पढ़िए, और किताब को अपनी मौजूदा तिमाही के लिए पास रखिए।'),
    buyUrl: '',
  ),
];

int _rank(ReadItem r) => r.isHigh ? 0 : 1;

/// Only the article-type father reads (the daily card + the ARTICLES list use
/// these; research/book items surface in their own Reads-tab sections).
List<ReadItem> get kFatherArticles =>
    kFatherReadItems.where((r) => r.type == ReadType.article).toList();

List<ReadItem> fatherReadsByType(ReadType type) =>
    kFatherReadItems.where((r) => r.type == type).toList();

/// The single father read pick for [week] (week-relevant, high-priority first;
/// falls back to the first item so the card always has something).
ReadItem fatherReadForWeek(int week) {
  final relevant = kFatherArticles.where((r) => r.relevantAt(week)).toList()
    ..sort((a, b) => _rank(a).compareTo(_rank(b)));
  return relevant.isNotEmpty ? relevant.first : kFatherArticles.first;
}

/// [count] father read picks for [week], rotating by [day] so it refreshes.
List<ReadItem> fatherDailyReads(int week, int day, {int count = 3}) {
  final relevant = kFatherArticles.where((r) => r.relevantAt(week)).toList()
    ..sort((a, b) => _rank(a).compareTo(_rank(b)));
  final pool = <ReadItem>[...relevant];
  if (pool.length < count) {
    pool.addAll(kFatherArticles.where((r) => !pool.contains(r)));
  }
  if (pool.isEmpty) return const [];
  final n = pool.length;
  final start = day % n;
  return List.generate(count.clamp(0, n), (i) => pool[(start + i) % n]);
}
