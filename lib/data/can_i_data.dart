// =============================================================================
//  Can I?™  - curated seed database
// -----------------------------------------------------------------------------
//  A hand-picked set of the most common, well-established questions (covering
//  all six "popular searches" + a spread across Eat / Drink / Take / Do). This
//  is GENERAL educational guidance, written carefully and conservatively - it is
//  not a medical review, and every answer defers to the mother's own doctor.
//
//  English-first: every entry carries en + hi (today hi mirrors en) so Hindi can
//  be authored later without touching any screen. The schema scales to the full
//  250-item list unchanged.
// =============================================================================

import '../localization/app_language.dart';
import '../models/can_i_entry.dart';

/// Compact bilingual helper for the expanded library (English-first; hi mirrors
/// en until Hindi is authored).
LocalizedText _t(String s) => LocalizedText(en: s, hi: s);

/// Popular-search chips on the Can I? home (emoji + label → entry id).
const List<({String emoji, String label, String id})> kCanIPopular = [
  (emoji: '🍍', label: 'Pineapple', id: 'pineapple'),
  (emoji: '☕', label: 'Coffee', id: 'coffee'),
  (emoji: '💊', label: 'Crocin', id: 'paracetamol'),
  (emoji: '✈️', label: 'Flight travel', id: 'flight_travel'),
  (emoji: '🎨', label: 'Hair colour', id: 'hair_color'),
  (emoji: '❤️', label: 'Sex', id: 'sex'),
];

final List<CanIEntry> kCanIEntries = [
  // ===========================================================================
  //  EAT
  // ===========================================================================
  CanIEntry(
    id: 'papaya',
    name: LocalizedText(en: 'Papaya', hi: 'पपीता'),
    category: CanICategory.eat,
    verdict: CanIVerdict.depends,
    short: LocalizedText(
      en: 'Ripe papaya in small amounts is generally considered fine. Raw or unripe papaya is usually advised against.',
      hi: 'पका पपीता थोड़ी मात्रा में आम तौर पर ठीक माना जाता है। कच्चा या अधपका पपीता आम तौर पर मना किया जाता है।',
    ),
    why: LocalizedText(
      en: 'Fully ripe papaya is a nutritious fruit. Unripe or semi-ripe papaya contains more latex (papain), which is traditionally avoided in pregnancy. The riper it is, the gentler it is.',
      hi: 'पूरी तरह पका पपीता एक पौष्टिक फल है। कच्चे या अधपके पपीते में ज़्यादा latex (papain) होता है, जिससे गर्भावस्था में परंपरागत रूप से बचा जाता है। जितना पका होगा, उतना नरम रहेगा।',
    ),
    t1: LocalizedText(
      en: 'Many mothers prefer to be extra cautious in the first trimester and skip raw papaya entirely.',
      hi: 'कई माँएँ पहली तिमाही में ज़्यादा एहतियात बरतना पसंद करती हैं और कच्चा पपीता बिलकुल छोड़ देती हैं।',
    ),
    indian: LocalizedText(
      en: 'Raw papaya turns up in salads and some sabzis - that is the form to be careful with. Ripe, sweet papaya as fruit is the safer choice.',
      hi: 'कच्चा पपीता सलाद और कुछ सब्ज़ियों में आता है — यही वह रूप है जिससे सावधान रहना है। पका, मीठा पपीता फल के रूप में ज़्यादा सुरक्षित विकल्प है।',
    ),
    related: ['pineapple', 'mango', 'street_food'],
    aliases: ['papita', 'raw papaya', 'ripe papaya'],
  ),
  CanIEntry(
    id: 'pineapple',
    name: LocalizedText(en: 'Pineapple', hi: 'अनानास'),
    category: CanICategory.eat,
    verdict: CanIVerdict.moderation,
    short: LocalizedText(
      en: 'Pineapple in normal food amounts is generally fine. Only very large quantities are best avoided.',
      hi: 'आम खाने की मात्रा में अनानास आम तौर पर ठीक है। सिर्फ़ बहुत ज़्यादा मात्रा से बचना बेहतर है।',
    ),
    why: LocalizedText(
      en: 'Pineapple contains an enzyme called bromelain, but the amount in a normal serving is tiny. You would need to eat a lot for it to matter, so everyday portions are considered okay.',
      hi: 'अनानास में bromelain नाम का एक एंज़ाइम होता है, पर एक सामान्य हिस्से में इसकी मात्रा बहुत कम होती है। मायने रखने के लिए आपको बहुत ज़्यादा खाना पड़ेगा, इसलिए रोज़ की मात्रा ठीक मानी जाती है।',
    ),
    indian: LocalizedText(
      en: 'A few slices or a glass of fresh juice is fine. Skip the giant bowl-a-day habit.',
      hi: 'कुछ टुकड़े या एक गिलास ताज़ा जूस ठीक है। रोज़ एक बड़ा कटोरा भर खाने की आदत छोड़ दीजिए।',
    ),
    related: ['papaya', 'mango', 'banana'],
    aliases: ['ananas'],
  ),
  CanIEntry(
    id: 'mango',
    name: LocalizedText(en: 'Mango', hi: 'आम'),
    category: CanICategory.eat,
    verdict: CanIVerdict.moderation,
    short: LocalizedText(
      en: 'Mango is a nutritious fruit and fine in moderation.',
      hi: 'आम एक पौष्टिक फल है और सीमित मात्रा में ठीक है।',
    ),
    why: LocalizedText(
      en: 'Mango is rich in vitamins A and C and folate. It is also high in natural sugar, so keep portions reasonable - especially if your doctor is watching your blood sugar.',
      hi: 'आम में Vitamin A और C तथा Folate भरपूर होते हैं। इसमें क़ुदरती चीनी भी ज़्यादा होती है, इसलिए मात्रा सीमित रखिए — ख़ासकर अगर आपके डॉक्टर आपकी blood sugar पर नज़र रख रहे हैं।',
    ),
    indian: LocalizedText(
      en: 'Wash well and enjoy in season. If you have (or are at risk of) gestational diabetes, ask your doctor about quantity.',
      hi: 'अच्छी तरह धोकर मौसम में खाइए। अगर आपको gestational diabetes है (या ख़तरा है), तो मात्रा के बारे में डॉक्टर से पूछिए।',
    ),
    related: ['pineapple', 'banana', 'papaya'],
    aliases: ['aam'],
  ),
  CanIEntry(
    id: 'banana',
    name: LocalizedText(en: 'Banana', hi: 'केला'),
    category: CanICategory.eat,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Bananas are a great, easy pregnancy snack.',
      hi: 'केला गर्भावस्था का एक बढ़िया, आसान स्नैक है।',
    ),
    why: LocalizedText(
      en: 'They give quick energy and potassium, can settle early-pregnancy nausea, and help with constipation. A simple, reliable choice.',
      hi: 'यह तुरंत ऊर्जा और Potassium देता है, शुरुआती गर्भावस्था की मतली शांत कर सकता है, और क़ब्ज़ में मदद करता है। एक सरल, भरोसेमंद विकल्प।',
    ),
    related: ['mango', 'curd', 'pineapple'],
    aliases: ['kela'],
  ),
  CanIEntry(
    id: 'paneer',
    name: LocalizedText(en: 'Paneer', hi: 'पनीर'),
    category: CanICategory.eat,
    verdict: CanIVerdict.depends,
    short: LocalizedText(
      en: 'Paneer made from pasteurised milk and eaten fresh or cooked is fine. Avoid unpasteurised soft cheese.',
      hi: 'Pasteurised दूध से बना पनीर, ताज़ा या पका हुआ खाया जाए तो ठीक है। बिना pasteurise किया soft cheese मत खाइए।',
    ),
    why: LocalizedText(
      en: 'The concern with some soft cheeses is listeria, a bacteria that can grow in unpasteurised dairy. Paneer from pasteurised milk - cooked or freshly made - sidesteps that.',
      hi: 'कुछ soft cheese के साथ चिंता listeria की होती है, एक bacteria जो बिना pasteurise किए दूध में पनप सकता है। Pasteurised दूध का पनीर — पका हुआ या ताज़ा बना — इससे बच जाता है।',
    ),
    indian: LocalizedText(
      en: 'Branded and most home-made paneer uses pasteurised milk. When in doubt, cook it (paneer bhurji, palak paneer) rather than eating it raw.',
      hi: 'ब्रांडेड और ज़्यादातर घर का पनीर pasteurised दूध से बनता है। शक हो तो इसे कच्चा खाने के बजाय पका लीजिए (पनीर भुर्जी, पालक पनीर)।',
    ),
    related: ['curd', 'milk', 'street_food'],
    aliases: ['cheese', 'cottage cheese'],
  ),
  CanIEntry(
    id: 'curd',
    name: LocalizedText(en: 'Curd / Yoghurt', hi: 'दही'),
    category: CanICategory.eat,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Curd is safe and good for you in pregnancy.',
      hi: 'दही गर्भावस्था में सुरक्षित है और आपके लिए अच्छा है।',
    ),
    why: LocalizedText(
      en: 'Made from pasteurised milk, it is a good source of calcium and protein, and the probiotics can help digestion. Set curd at home or use packaged dahi.',
      hi: 'Pasteurised दूध से बना, यह Calcium और प्रोटीन का अच्छा स्रोत है, और इसके probiotics पाचन में मदद कर सकते हैं। घर पर दही जमाइए या पैकेट वाला दही लीजिए।',
    ),
    related: ['paneer', 'milk', 'banana'],
    aliases: ['dahi', 'yogurt', 'yoghurt'],
  ),
  CanIEntry(
    id: 'chocolate',
    name: LocalizedText(en: 'Chocolate', hi: 'चॉकलेट'),
    category: CanICategory.eat,
    verdict: CanIVerdict.moderation,
    short: LocalizedText(
      en: 'Chocolate is fine to enjoy in moderation.',
      hi: 'चॉकलेट सीमित मात्रा में खाना ठीक है।',
    ),
    why: LocalizedText(
      en: 'Chocolate contains a little caffeine, so it counts towards your daily caffeine total. A few squares are a lovely treat - just keep the overall amount sensible.',
      hi: 'चॉकलेट में थोड़ा caffeine होता है, इसलिए यह आपके रोज़ के caffeine में गिना जाता है। कुछ टुकड़े एक प्यारी ख़ुशी हैं — बस कुल मात्रा समझदारी से रखिए।',
    ),
    related: ['coffee', 'ice_cream', 'tea'],
    aliases: ['cocoa'],
  ),
  CanIEntry(
    id: 'street_food',
    name: LocalizedText(en: 'Street Food', hi: 'स्ट्रीट फ़ूड'),
    category: CanICategory.eat,
    verdict: CanIVerdict.depends,
    short: LocalizedText(
      en: 'It depends entirely on hygiene and freshness - the risk is contamination, not the dish itself.',
      hi: 'यह पूरी तरह साफ़-सफ़ाई और ताज़गी पर निर्भर करता है — ख़तरा दूषित होने का है, ख़ुद व्यंजन का नहीं।',
    ),
    why: LocalizedText(
      en: 'Pregnancy lowers your resistance to food-borne infections. Hot, freshly-cooked food from a busy, clean stall is far safer than anything sitting out, raw, or rinsed in tap water.',
      hi: 'गर्भावस्था खाने से होने वाले संक्रमणों के प्रति आपकी प्रतिरोधक क्षमता कम कर देती है। किसी व्यस्त, साफ़ ठेले से गरम, ताज़ा बना खाना उस चीज़ से कहीं ज़्यादा सुरक्षित है जो खुली रखी हो, कच्ची हो, या नल के पानी में धुली हो।',
    ),
    indian: LocalizedText(
      en: 'The usual culprits are golgappa/pani-puri water, cut fruit, and chutneys made with unfiltered water. Piping-hot tikki or dosa, freshly made, is lower risk.',
      hi: 'आम तौर पर गड़बड़ गोलगप्पे/पानी-पूरी के पानी, कटे फल, और बिना छने पानी की चटनी से होती है। एकदम गरम, ताज़ा बनी टिक्की या डोसा में ख़तरा कम है।',
    ),
    related: ['papaya', 'paneer', 'water'],
    aliases: ['chaat', 'golgappa', 'pani puri', 'outside food'],
  ),
  CanIEntry(
    id: 'honey',
    name: LocalizedText(en: 'Honey', hi: 'शहद'),
    category: CanICategory.eat,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Honey is fine for you during pregnancy.',
      hi: 'गर्भावस्था में आपके लिए शहद ठीक है।',
    ),
    why: LocalizedText(
      en: 'The well-known honey caution is for babies under one year, not for mothers. As an adult, your gut handles it normally. (Still mind the sugar.)',
      hi: 'शहद को लेकर जो जानी-मानी चेतावनी है वह एक साल से छोटे शिशुओं के लिए है, माँओं के लिए नहीं। एक वयस्क के तौर पर आपका पेट इसे सामान्य रूप से पचाता है। (फिर भी चीनी का ध्यान रखिए।)',
    ),
    related: ['chocolate', 'tea', 'ginger'],
    aliases: ['shahad'],
  ),
  CanIEntry(
    id: 'ginger',
    name: LocalizedText(en: 'Ginger', hi: 'अदरक'),
    category: CanICategory.eat,
    verdict: CanIVerdict.moderation,
    short: LocalizedText(
      en: 'Ginger in food and tea amounts is fine and can ease nausea.',
      hi: 'खाने और चाय जितनी मात्रा में अदरक ठीक है और मतली कम कर सकता है।',
    ),
    why: LocalizedText(
      en: 'Ginger is one of the better-studied natural remedies for morning sickness. Cooking-and-tea quantities are considered safe; very large supplement doses are not needed.',
      hi: 'सुबह की मतली के लिए अदरक उन क़ुदरती उपायों में है जिन पर सबसे ज़्यादा अध्ययन हुआ है। खाने और चाय की मात्रा सुरक्षित मानी जाती है; सप्लीमेंट की बहुत बड़ी ख़ुराक की ज़रूरत नहीं।',
    ),
    indian: LocalizedText(
      en: 'Adrak in chai or a little ginger-honey water is a gentle, traditional way to settle queasiness.',
      hi: 'चाय में अदरक या थोड़ा अदरक-शहद का पानी जी मिचलाना शांत करने का एक सौम्य, पारंपरिक तरीक़ा है।',
    ),
    related: ['honey', 'tea', 'banana'],
    aliases: ['adrak'],
  ),

  // ===========================================================================
  //  DRINK
  // ===========================================================================
  CanIEntry(
    id: 'coffee',
    name: LocalizedText(en: 'Coffee', hi: 'कॉफ़ी'),
    category: CanICategory.drink,
    verdict: CanIVerdict.moderation,
    short: LocalizedText(
      en: 'Up to about one cup a day (under ~200mg caffeine) is generally considered okay.',
      hi: 'दिन में लगभग एक कप तक (~200mg caffeine से कम) आम तौर पर ठीक माना जाता है।',
    ),
    why: LocalizedText(
      en: 'The usual guidance is to keep total caffeine under roughly 200mg a day. Remember it adds up across coffee, tea, cola and chocolate - not coffee alone.',
      hi: 'आम सलाह है कि कुल caffeine दिन में लगभग 200mg से कम रखें। याद रखिए यह कॉफ़ी, चाय, कोला और चॉकलेट सब मिलाकर जुड़ता है — सिर्फ़ कॉफ़ी नहीं।',
    ),
    t1: LocalizedText(
      en: 'Many mothers naturally go off coffee in the first trimester - listen to that.',
      hi: 'कई माँओं का पहली तिमाही में अपने आप कॉफ़ी से मन हट जाता है — उसे सुनिए।',
    ),
    indian: LocalizedText(
      en: 'A strong South-Indian filter coffee can be higher in caffeine than you think - one a day is a reasonable ceiling.',
      hi: 'एक तेज़ दक्षिण-भारतीय फ़िल्टर कॉफ़ी में आपकी सोच से ज़्यादा caffeine हो सकता है — दिन में एक ठीक हद है।',
    ),
    related: ['tea', 'green_tea', 'soft_drinks'],
    aliases: ['caffeine', 'espresso', 'filter coffee'],
  ),
  CanIEntry(
    id: 'tea',
    name: LocalizedText(en: 'Tea / Chai', hi: 'चाय'),
    category: CanICategory.drink,
    verdict: CanIVerdict.moderation,
    short: LocalizedText(
      en: 'Regular tea in moderation is fine - just mind the caffeine total.',
      hi: 'सामान्य चाय सीमित मात्रा में ठीक है — बस कुल caffeine का ध्यान रखिए।',
    ),
    why: LocalizedText(
      en: 'Tea has less caffeine than coffee but still counts towards your ~200mg daily limit. Two to three cups of normal chai is generally considered reasonable.',
      hi: 'चाय में कॉफ़ी से कम caffeine होता है पर यह भी आपकी ~200mg की रोज़ की सीमा में गिना जाता है। दो से तीन कप सामान्य चाय आम तौर पर ठीक मानी जाती है।',
    ),
    indian: LocalizedText(
      en: 'Doodh-wali chai counts too. Some herbal teas are not recommended in pregnancy, so check before switching to a new one.',
      hi: 'दूध वाली चाय भी गिनी जाती है। कुछ herbal चाय गर्भावस्था में सुझाई नहीं जातीं, इसलिए कोई नई चाय शुरू करने से पहले जाँच लीजिए।',
    ),
    related: ['coffee', 'green_tea', 'ginger'],
    aliases: ['chai', 'doodh tea'],
  ),
  CanIEntry(
    id: 'green_tea',
    name: LocalizedText(en: 'Green Tea', hi: 'ग्रीन टी'),
    category: CanICategory.drink,
    verdict: CanIVerdict.moderation,
    short: LocalizedText(
      en: 'One to two cups a day is usually fine; just do not overdo it.',
      hi: 'दिन में एक-दो कप आम तौर पर ठीक है; बस ज़्यादा मत कीजिए।',
    ),
    why: LocalizedText(
      en: 'Green tea has caffeine and, in large amounts, can interfere with how your body uses folate (important early in pregnancy). A cup or two is fine; gallons are not.',
      hi: 'ग्रीन टी में caffeine होता है और बड़ी मात्रा में यह इस बात में दख़ल दे सकती है कि आपका शरीर Folate कैसे इस्तेमाल करता है (जो शुरुआती गर्भावस्था में ज़रूरी है)। एक-दो कप ठीक हैं; बहुत ज़्यादा नहीं।',
    ),
    related: ['tea', 'coffee', 'folic_acid'],
    aliases: ['herbal tea'],
  ),
  CanIEntry(
    id: 'coconut_water',
    name: LocalizedText(en: 'Coconut Water', hi: 'नारियल पानी'),
    category: CanICategory.drink,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Coconut water is a great, hydrating choice.',
      hi: 'नारियल पानी एक बढ़िया विकल्प है जो शरीर में पानी बनाए रखता है।',
    ),
    why: LocalizedText(
      en: 'It is mostly water with natural electrolytes, so it helps with hydration and can be soothing if you feel queasy. Fresh is best.',
      hi: 'यह ज़्यादातर पानी है जिसमें क़ुदरती Electrolytes होते हैं, इसलिए यह शरीर में पानी बनाए रखने में मदद करता है और जी मिचलाने पर सुकून दे सकता है। ताज़ा सबसे अच्छा है।',
    ),
    indian: LocalizedText(
      en: 'Nariyal paani is widely recommended - drink it fresh from a tender coconut rather than a sugary packaged version.',
      hi: 'नारियल पानी की सलाह हर जगह दी जाती है — इसे ताज़े कच्चे नारियल से पीजिए, मीठे पैकेट वाले के बजाय।',
    ),
    related: ['water', 'buttermilk', 'soft_drinks'],
    aliases: ['nariyal pani', 'tender coconut'],
  ),
  CanIEntry(
    id: 'buttermilk',
    name: LocalizedText(en: 'Buttermilk', hi: 'छाछ'),
    category: CanICategory.drink,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Buttermilk is safe, cooling and good for digestion.',
      hi: 'छाछ सुरक्षित है, ठंडक देती है और पाचन के लिए अच्छी है।',
    ),
    why: LocalizedText(
      en: 'Made from curd, it offers calcium and probiotics, helps with acidity, and keeps you hydrated. A light, gut-friendly option.',
      hi: 'दही से बनी, यह Calcium और probiotics देती है, अम्लता में मदद करती है, और शरीर में पानी बनाए रखती है। एक हल्का, पेट के अनुकूल विकल्प।',
    ),
    indian: LocalizedText(
      en: 'Chaas with a little jeera and pudina is a great everyday drink, especially in summer.',
      hi: 'थोड़े जीरे और पुदीने वाली छाछ रोज़ का एक बढ़िया पेय है, ख़ासकर गर्मियों में।',
    ),
    related: ['curd', 'coconut_water', 'water'],
    aliases: ['chaas', 'chaach', 'lassi'],
  ),
  CanIEntry(
    id: 'alcohol',
    name: LocalizedText(en: 'Alcohol', hi: 'शराब'),
    category: CanICategory.drink,
    verdict: CanIVerdict.avoid,
    short: LocalizedText(
      en: 'No amount of alcohol is considered safe during pregnancy.',
      hi: 'गर्भावस्था में शराब की कोई भी मात्रा सुरक्षित नहीं मानी जाती।',
    ),
    why: LocalizedText(
      en: 'Alcohol crosses the placenta to your baby, and no safe level or safe time has been established. The clear, simple advice is to avoid it completely.',
      hi: 'शराब placenta पार करके आपके शिशु तक पहुँचती है, और कोई सुरक्षित मात्रा या सुरक्षित समय तय नहीं हुआ है। साफ़, सरल सलाह है कि इससे पूरी तरह बचिए।',
    ),
    related: ['coffee', 'soft_drinks'],
    aliases: ['wine', 'beer', 'sharab', 'drinking'],
  ),
  CanIEntry(
    id: 'soft_drinks',
    name: LocalizedText(en: 'Soft Drinks / Soda', hi: 'कोल्ड ड्रिंक / सोडा'),
    category: CanICategory.drink,
    verdict: CanIVerdict.moderation,
    short: LocalizedText(
      en: 'An occasional one is okay, but they are high in sugar and caffeine.',
      hi: 'कभी-कभार एक ठीक है, पर इनमें चीनी और caffeine ज़्यादा होते हैं।',
    ),
    why: LocalizedText(
      en: 'Colas add caffeine to your daily total and most soft drinks are very sugary with little benefit. Fine as a once-in-a-while treat, not an everyday drink.',
      hi: 'कोला आपके रोज़ के caffeine में जुड़ता है और ज़्यादातर कोल्ड ड्रिंक बहुत मीठे होते हैं और उनसे फ़ायदा कम। कभी-कभार की ख़ुशी के तौर पर ठीक, रोज़ के पेय के तौर पर नहीं।',
    ),
    related: ['coffee', 'coconut_water', 'water'],
    aliases: ['cola', 'soda', 'cold drink', 'pepsi', 'coke'],
  ),
  CanIEntry(
    id: 'water',
    name: LocalizedText(en: 'Water (how much)', hi: 'पानी (कितना)'),
    category: CanICategory.drink,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Drink plenty - staying well hydrated is one of the simplest good habits.',
      hi: 'ख़ूब पीजिए — शरीर में पानी बनाए रखना सबसे आसान अच्छी आदतों में से एक है।',
    ),
    why: LocalizedText(
      en: 'Aim for roughly 8–10 glasses a day (more in heat or if active). Good hydration helps with constipation, swelling and those common Braxton-Hicks tightenings.',
      hi: 'दिन में लगभग 8–10 गिलास का लक्ष्य रखिए (गर्मी में या ज़्यादा सक्रिय हों तो और)। अच्छी मात्रा में पानी क़ब्ज़, सूजन और आम Braxton Hicks कसाव में मदद करता है।',
    ),
    related: ['coconut_water', 'buttermilk', 'street_food'],
    aliases: ['hydration', 'pani'],
  ),

  // ===========================================================================
  //  TAKE (medicines / supplements)
  // ===========================================================================
  CanIEntry(
    id: 'paracetamol',
    name: LocalizedText(en: 'Paracetamol (Crocin / Dolo)', hi: 'Paracetamol (Crocin / Dolo)'),
    category: CanICategory.take,
    verdict: CanIVerdict.moderation,
    short: LocalizedText(
      en: 'Paracetamol is generally considered the preferred choice for fever or pain - lowest dose that helps, for the shortest time.',
      hi: 'बुख़ार या दर्द के लिए Paracetamol आम तौर पर पसंदीदा विकल्प माना जाता है — जो काम करे वह सबसे कम ख़ुराक, सबसे कम समय के लिए।',
    ),
    why: LocalizedText(
      en: 'It is the most widely used pain/fever medicine in pregnancy and is usually preferred over alternatives. Still, use it only when needed and let your doctor know if you are taking it often.',
      hi: 'गर्भावस्था में यह सबसे ज़्यादा इस्तेमाल होने वाली दर्द/बुख़ार की दवा है और आम तौर पर दूसरों से बेहतर मानी जाती है। फिर भी, इसे सिर्फ़ ज़रूरत पर लीजिए और अगर आप इसे बार-बार ले रही हैं तो डॉक्टर को बताइए।',
    ),
    related: ['ibuprofen', 'combiflam', 'antibiotics'],
    aliases: ['crocin', 'dolo', 'dolo 650', 'fever', 'paracetamol', 'calpol'],
  ),
  CanIEntry(
    id: 'ibuprofen',
    name: LocalizedText(en: 'Ibuprofen', hi: 'Ibuprofen'),
    category: CanICategory.take,
    verdict: CanIVerdict.avoid,
    short: LocalizedText(
      en: 'Generally avoided in pregnancy - especially in the third trimester. Ask your doctor first.',
      hi: 'गर्भावस्था में आम तौर पर इससे बचा जाता है — ख़ासकर तीसरी तिमाही में। पहले अपने डॉक्टर से पूछिए।',
    ),
    why: LocalizedText(
      en: 'Ibuprofen is an anti-inflammatory (NSAID) that is usually not recommended in pregnancy, particularly later on. Paracetamol is normally suggested instead.',
      hi: 'Ibuprofen एक anti-inflammatory (NSAID) है जो गर्भावस्था में आम तौर पर नहीं सुझाई जाती, ख़ासकर बाद के दौर में। इसकी जगह आम तौर पर Paracetamol सुझाया जाता है।',
    ),
    t3: LocalizedText(
      en: 'In the third trimester it is best avoided altogether - it can affect the baby. Do not take it without your doctor.',
      hi: 'तीसरी तिमाही में इससे पूरी तरह बचना बेहतर है — यह शिशु पर असर डाल सकती है। अपने डॉक्टर के बिना इसे मत लीजिए।',
    ),
    related: ['paracetamol', 'combiflam', 'aspirin'],
    aliases: ['brufen', 'advil', 'nsaid'],
  ),
  CanIEntry(
    id: 'combiflam',
    name: LocalizedText(en: 'Combiflam', hi: 'Combiflam'),
    category: CanICategory.take,
    verdict: CanIVerdict.askDoctor,
    short: LocalizedText(
      en: 'Best not taken on your own - it contains ibuprofen. Check with your doctor.',
      hi: 'अपने आप न लेना बेहतर है — इसमें Ibuprofen है। अपने डॉक्टर से पूछिए।',
    ),
    why: LocalizedText(
      en: 'Combiflam combines paracetamol with ibuprofen, and the ibuprofen part is the one usually avoided in pregnancy. For fever or pain, plain paracetamol is the safer default.',
      hi: 'Combiflam में Paracetamol के साथ Ibuprofen मिला होता है, और Ibuprofen वाला हिस्सा ही वह है जिससे गर्भावस्था में आम तौर पर बचा जाता है। बुख़ार या दर्द के लिए सादा Paracetamol ज़्यादा सुरक्षित विकल्प है।',
    ),
    related: ['ibuprofen', 'paracetamol', 'aspirin'],
    aliases: ['ibuprofen paracetamol'],
  ),
  CanIEntry(
    id: 'antibiotics',
    name: LocalizedText(en: 'Antibiotics', hi: 'Antibiotics'),
    category: CanICategory.take,
    verdict: CanIVerdict.askDoctor,
    short: LocalizedText(
      en: 'Some are safe in pregnancy and some are not - only take antibiotics your doctor prescribes.',
      hi: 'कुछ गर्भावस्था में सुरक्षित हैं और कुछ नहीं — सिर्फ़ वही antibiotics लीजिए जो आपके डॉक्टर लिखें।',
    ),
    why: LocalizedText(
      en: 'It depends entirely on which antibiotic. Several are used safely in pregnancy; a few are avoided. This is one to never self-prescribe or reuse from an old strip.',
      hi: 'यह पूरी तरह इस पर निर्भर करता है कि कौन सा antibiotic है। कई गर्भावस्था में सुरक्षित रूप से इस्तेमाल होते हैं; कुछ से बचा जाता है। यह वह चीज़ है जिसे कभी ख़ुद से न लें और न पुरानी पत्ती से दोबारा इस्तेमाल करें।',
    ),
    related: ['paracetamol', 'combiflam'],
    aliases: ['amoxicillin', 'azithromycin', 'augmentin', 'antibiotic'],
  ),
  CanIEntry(
    id: 'folic_acid',
    name: LocalizedText(en: 'Folic Acid', hi: 'Folic Acid'),
    category: CanICategory.take,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Folic acid is recommended in pregnancy - take it as your doctor advises.',
      hi: 'गर्भावस्था में Folic acid सुझाया जाता है — इसे अपने डॉक्टर की सलाह के मुताबिक़ लीजिए।',
    ),
    why: LocalizedText(
      en: 'It supports your baby\'s early brain and spine development, which is why it is advised from before conception through early pregnancy. It is one of the few things actively encouraged.',
      hi: 'यह आपके शिशु के शुरुआती दिमाग़ और रीढ़ के विकास में मदद करता है, इसीलिए इसे गर्भधारण से पहले से शुरुआती गर्भावस्था तक लेने की सलाह दी जाती है। यह उन कुछ चीज़ों में है जिन्हें सक्रिय रूप से प्रोत्साहित किया जाता है।',
    ),
    t1: LocalizedText(
      en: 'Most important in the first trimester (and ideally before) - do not skip it.',
      hi: 'पहली तिमाही में (और आदर्श रूप से उससे भी पहले) सबसे ज़रूरी — इसे मत छोड़िए।',
    ),
    related: ['iron', 'calcium', 'vitamin_d'],
    aliases: ['folate', 'vitamin b9'],
  ),
  CanIEntry(
    id: 'iron',
    name: LocalizedText(en: 'Iron Supplements', hi: 'Iron सप्लीमेंट'),
    category: CanICategory.take,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Iron is commonly recommended - take the dose your doctor prescribes.',
      hi: 'Iron आम तौर पर सुझाया जाता है — वही ख़ुराक लीजिए जो आपके डॉक्टर लिखें।',
    ),
    why: LocalizedText(
      en: 'Your blood volume rises in pregnancy, so iron needs go up and many mothers are advised supplements. It can cause constipation - fluids and fibre help.',
      hi: 'गर्भावस्था में आपका blood volume बढ़ता है, इसलिए Iron की ज़रूरत बढ़ जाती है और कई माँओं को सप्लीमेंट की सलाह दी जाती है। इससे क़ब्ज़ हो सकती है — पानी और fibre मदद करते हैं।',
    ),
    related: ['folic_acid', 'calcium', 'vitamin_d'],
    aliases: ['ferrous', 'haemoglobin', 'iron tablet'],
  ),
  CanIEntry(
    id: 'calcium',
    name: LocalizedText(en: 'Calcium Supplements', hi: 'Calcium सप्लीमेंट'),
    category: CanICategory.take,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Calcium is commonly recommended in pregnancy; follow your doctor\'s advice.',
      hi: 'गर्भावस्था में Calcium आम तौर पर सुझाया जाता है; अपने डॉक्टर की सलाह मानिए।',
    ),
    why: LocalizedText(
      en: 'It supports your baby\'s bones and teeth and protects your own stores. It is usually taken at a different time of day from iron, since they compete for absorption.',
      hi: 'यह आपके शिशु की हड्डियों और दाँतों को सहारा देता है और आपके अपने भंडार की रक्षा करता है। इसे आम तौर पर Iron से अलग समय पर लिया जाता है, क्योंकि दोनों सोखे जाने के लिए आपस में होड़ करते हैं।',
    ),
    related: ['iron', 'folic_acid', 'vitamin_d'],
    aliases: ['calcium tablet'],
  ),
  CanIEntry(
    id: 'vitamin_d',
    name: LocalizedText(en: 'Vitamin D', hi: 'Vitamin D'),
    category: CanICategory.take,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Vitamin D is commonly recommended; take the dose your doctor sets.',
      hi: 'Vitamin D आम तौर पर सुझाया जाता है; वही ख़ुराक लीजिए जो आपके डॉक्टर तय करें।',
    ),
    why: LocalizedText(
      en: 'It helps your body absorb calcium and supports bone health for you and your baby. Many people are mildly deficient, so it is often prescribed.',
      hi: 'यह आपके शरीर को Calcium सोखने में मदद करता है और आपकी व शिशु की हड्डियों की सेहत सँभालता है। बहुत से लोगों में इसकी हल्की कमी होती है, इसलिए यह अक्सर लिखा जाता है।',
    ),
    related: ['calcium', 'folic_acid', 'iron'],
    aliases: ['vitamin d3', 'cholecalciferol'],
  ),

  // ===========================================================================
  //  DO (activities / beauty / lifestyle)
  // ===========================================================================
  CanIEntry(
    id: 'flight_travel',
    name: LocalizedText(en: 'Flight Travel', hi: 'हवाई यात्रा'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.depends,
    short: LocalizedText(
      en: 'Air travel is generally fine in an uncomplicated pregnancy - usually most comfortable in the second trimester.',
      hi: 'बिना किसी उलझन वाली गर्भावस्था में हवाई यात्रा आम तौर पर ठीक है — आम तौर पर दूसरी तिमाही में सबसे आरामदेह।',
    ),
    why: LocalizedText(
      en: 'Flying does not harm a low-risk pregnancy. On long flights, walk and stretch, keep hydrated, and wear your seatbelt low under the bump. Always clear travel with your doctor first.',
      hi: 'उड़ान कम जोखिम वाली गर्भावस्था को नुक़सान नहीं पहुँचाती। लंबी उड़ानों में चलिए और शरीर खोलिए, पानी पीती रहिए, और सीट-बेल्ट बंप के नीचे नीची बाँधिए। यात्रा की मंज़ूरी हमेशा पहले अपने डॉक्टर से ले लीजिए।',
    ),
    t2: LocalizedText(
      en: 'Usually the easiest window to travel - nausea has eased and the bump is still manageable.',
      hi: 'आम तौर पर यात्रा के लिए सबसे आसान दौर — मतली कम हो चुकी होती है और बंप अभी सँभालने लायक़ होता है।',
    ),
    t3: LocalizedText(
      en: 'Many airlines restrict travel after about 36 weeks and may ask for a doctor\'s note - check before booking.',
      hi: 'कई एयरलाइंस लगभग 36 हफ़्ते के बाद यात्रा पर रोक लगाती हैं और डॉक्टर का पत्र माँग सकती हैं — बुकिंग से पहले जाँच लीजिए।',
    ),
    related: ['long_travel', 'walking', 'water'],
    aliases: ['flight', 'flying', 'air travel', 'airplane', 'plane'],
  ),
  CanIEntry(
    id: 'long_travel',
    name: LocalizedText(en: 'Long Road / Train Travel', hi: 'लंबी सड़क / रेल यात्रा'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.depends,
    short: LocalizedText(
      en: 'Usually fine - break the journey often to move, stretch and use the toilet.',
      hi: 'आम तौर पर ठीक — सफ़र बीच-बीच में तोड़िए ताकि चल सकें, शरीर खोल सकें और शौचालय जा सकें।',
    ),
    why: LocalizedText(
      en: 'Sitting for hours can make legs swell and feel stiff. Stop every couple of hours, walk a little, stay hydrated, and keep the seatbelt below the bump. Avoid very bumpy roads late in pregnancy.',
      hi: 'घंटों बैठे रहने से पैरों में सूजन और अकड़न आ सकती है। हर दो घंटे में रुकिए, थोड़ा चलिए, पानी पीती रहिए, और सीट-बेल्ट बंप के नीचे रखिए। गर्भावस्था के बाद के दौर में बहुत ऊबड़-खाबड़ रास्तों से बचिए।',
    ),
    related: ['flight_travel', 'walking', 'water'],
    aliases: ['car travel', 'train', 'road trip', 'bus'],
  ),
  CanIEntry(
    id: 'yoga',
    name: LocalizedText(en: 'Yoga', hi: 'योग'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Gentle prenatal yoga is wonderful; avoid intense poses, deep twists and lying flat on your back later on.',
      hi: 'सौम्य prenatal योग बहुत अच्छा है; तेज़ आसन, गहरे मरोड़ और बाद के दौर में पीठ के बल सीधा लेटने से बचिए।',
    ),
    why: LocalizedText(
      en: 'Yoga helps with flexibility, breathing and calm, and can ease back pain. Choose a prenatal class or teacher, skip strong abdominal and twisting poses, and never push into discomfort.',
      hi: 'योग लचीलेपन, साँस और शांति में मदद करता है, और कमर दर्द कम कर सकता है। कोई prenatal क्लास या शिक्षक चुनिए, पेट पर ज़ोर डालने वाले और मरोड़ वाले आसन छोड़िए, और कभी तकलीफ़ की हद तक मत जाइए।',
    ),
    related: ['walking', 'swimming', 'sleeping_back'],
    aliases: ['prenatal yoga', 'pranayama', 'asana', 'exercise'],
  ),
  CanIEntry(
    id: 'swimming',
    name: LocalizedText(en: 'Swimming', hi: 'तैराकी'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Swimming is one of the best pregnancy exercises.',
      hi: 'तैराकी गर्भावस्था के सबसे अच्छे व्यायामों में से एक है।',
    ),
    why: LocalizedText(
      en: 'The water takes the weight off your joints and back while giving a gentle full-body workout. Avoid diving, very hot pools, and slippery edges.',
      hi: 'पानी आपके जोड़ों और कमर से वज़न हटा देता है और साथ ही पूरे शरीर की सौम्य कसरत देता है। गोता लगाने, बहुत गरम पूल और फिसलन भरे किनारों से बचिए।',
    ),
    related: ['walking', 'yoga'],
    aliases: ['pool', 'swim'],
  ),
  CanIEntry(
    id: 'walking',
    name: LocalizedText(en: 'Walking', hi: 'चलना'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Walking is safe and encouraged throughout pregnancy.',
      hi: 'चलना पूरी गर्भावस्था में सुरक्षित है और इसे प्रोत्साहित किया जाता है।',
    ),
    why: LocalizedText(
      en: 'It is gentle cardio that helps your mood, sleep, digestion and stamina for labour - with almost no downside. Comfortable shoes and a steady pace are all you need.',
      hi: 'यह एक सौम्य cardio है जो आपके मन, नींद, पाचन और प्रसव के लिए दमख़म में मदद करता है — और इसका लगभग कोई नुक़सान नहीं। बस आरामदायक जूते और एक स्थिर रफ़्तार चाहिए।',
    ),
    related: ['yoga', 'swimming', 'lifting'],
    aliases: ['walk', 'morning walk'],
  ),
  CanIEntry(
    id: 'hair_color',
    name: LocalizedText(en: 'Hair Colour / Dye', hi: 'बालों का रंग / डाई'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.depends,
    short: LocalizedText(
      en: 'Generally considered low-risk, especially from the second trimester. Many prefer ammonia-free dyes or highlights.',
      hi: 'आम तौर पर कम जोखिम वाला माना जाता है, ख़ासकर दूसरी तिमाही से। कई लोग ammonia-रहित डाई या highlights पसंद करते हैं।',
    ),
    why: LocalizedText(
      en: 'Very little dye is absorbed through the scalp, so the risk is considered small. To be extra cautious, some wait past the first trimester, choose gentler formulas, and keep the room ventilated.',
      hi: 'सिर की त्वचा से बहुत कम डाई सोखी जाती है, इसलिए जोखिम कम माना जाता है। ज़्यादा एहतियात के लिए कुछ लोग पहली तिमाही बीतने का इंतज़ार करते हैं, हल्के फ़ॉर्मूले चुनते हैं, और कमरे में हवा आने-जाने का इंतज़ाम रखते हैं।',
    ),
    t1: LocalizedText(
      en: 'Many mothers choose to wait until after the first trimester, just for peace of mind.',
      hi: 'कई माँएँ सिर्फ़ मन की शांति के लिए पहली तिमाही बीतने तक इंतज़ार करना चुनती हैं।',
    ),
    indian: LocalizedText(
      en: 'Natural henna (mehndi) is a popular, gentler alternative for colour - patch-test first, and avoid "black henna" which can contain harsh chemicals.',
      hi: 'क़ुदरती मेहंदी रंग के लिए एक लोकप्रिय, हल्का विकल्प है — पहले थोड़ी सी लगाकर देख लीजिए, और "काली मेहंदी" से बचिए जिसमें कड़े रसायन हो सकते हैं।',
    ),
    related: ['waxing', 'keratin', 'nail_polish'],
    aliases: ['hair dye', 'dye', 'colour', 'mehndi', 'henna'],
  ),
  CanIEntry(
    id: 'waxing',
    name: LocalizedText(en: 'Waxing', hi: 'वैक्सिंग'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Waxing is generally fine - your skin may just be more sensitive now.',
      hi: 'वैक्सिंग आम तौर पर ठीक है — बस अभी आपकी त्वचा ज़्यादा नाज़ुक हो सकती है।',
    ),
    why: LocalizedText(
      en: 'There is no harm to the baby. Hormones can make skin more sensitive and prone to redness, so patch-test new products and tell your salon you are pregnant.',
      hi: 'शिशु को कोई नुक़सान नहीं। हार्मोन त्वचा को ज़्यादा नाज़ुक और लाल पड़ने वाला बना सकते हैं, इसलिए नए उत्पाद पहले थोड़े से आज़माइए और सैलून को बता दीजिए कि आप गर्भवती हैं।',
    ),
    related: ['hair_color', 'nail_polish'],
    aliases: ['wax', 'threading', 'hair removal'],
  ),
  CanIEntry(
    id: 'nail_polish',
    name: LocalizedText(en: 'Nail Polish', hi: 'नेल पॉलिश'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Occasional use is fine; just paint your nails in a ventilated room.',
      hi: 'कभी-कभार इस्तेमाल ठीक है; बस नाख़ून हवादार कमरे में रँगिए।',
    ),
    why: LocalizedText(
      en: 'The exposure from painting your nails is tiny. Keep the window open or a fan on so you are not breathing fumes, and you are good to go.',
      hi: 'नाख़ून रँगने से मिलने वाला असर बहुत कम है। खिड़की खुली रखिए या पंखा चला लीजिए ताकि आप धुआँ न लें, बस इतना काफ़ी है।',
    ),
    related: ['hair_color', 'waxing'],
    aliases: ['nail paint', 'manicure', 'pedicure'],
  ),
  CanIEntry(
    id: 'sex',
    name: LocalizedText(en: 'Sex During Pregnancy', hi: 'गर्भावस्था में संबंध'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Sex is safe in a normal, uncomplicated pregnancy.',
      hi: 'सामान्य, बिना उलझन वाली गर्भावस्था में संबंध सुरक्षित हैं।',
    ),
    why: LocalizedText(
      en: 'Your baby is well protected by the womb and fluid, so intimacy will not harm them. Comfort changes as the bump grows - adjust as needed.',
      hi: 'आपका शिशु बच्चेदानी और तरल से अच्छी तरह सुरक्षित है, इसलिए नज़दीकी उसे नुक़सान नहीं पहुँचाएगी। बंप बढ़ने के साथ आराम बदलता है — ज़रूरत के मुताबिक़ बदलाव कर लीजिए।',
    ),
    indian: LocalizedText(
      en: 'It is a common worry but a normal, healthy part of pregnancy. Your doctor may advise against it only in specific situations (such as bleeding or placenta previa).',
      hi: 'यह एक आम चिंता है पर गर्भावस्था का सामान्य, स्वस्थ हिस्सा है। आपके डॉक्टर सिर्फ़ ख़ास स्थितियों में मना कर सकते हैं (जैसे ब्लीडिंग या placenta previa)।',
    ),
    related: ['walking', 'sleeping_back'],
    aliases: ['intercourse', 'intimacy', 'sex during pregnancy'],
  ),
  CanIEntry(
    id: 'sleeping_back',
    name: LocalizedText(en: 'Sleeping On Your Back', hi: 'पीठ के बल सोना'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.depends,
    short: LocalizedText(
      en: 'Fine early on. From the second and third trimester, side-sleeping (preferably left) is usually advised.',
      hi: 'शुरू में ठीक है। दूसरी और तीसरी तिमाही से करवट (बेहतर हो बाईं) लेकर सोने की सलाह दी जाती है।',
    ),
    why: LocalizedText(
      en: 'As the womb grows heavier, lying flat on your back can press on a large vein and make you feel dizzy. Sleeping on your side keeps blood flowing comfortably to you and the baby.',
      hi: 'जैसे-जैसे बच्चेदानी भारी होती है, पीठ के बल सीधा लेटना एक बड़ी नस पर दबाव डाल सकता है और चक्कर जैसा लग सकता है। करवट लेकर सोने से आप तक और शिशु तक ख़ून आराम से बहता रहता है।',
    ),
    t2: LocalizedText(
      en: 'A good time to get used to side-sleeping - tuck a pillow behind your back and between your knees.',
      hi: 'करवट लेकर सोने की आदत डालने का अच्छा समय — पीठ के पीछे और घुटनों के बीच तकिया लगा लीजिए।',
    ),
    t3: LocalizedText(
      en: 'Prefer the left side. If you wake up on your back, just turn over - no need to panic.',
      hi: 'बाईं करवट बेहतर है। अगर पीठ के बल जाग जाएँ, तो बस पलट जाइए — घबराने की ज़रूरत नहीं।',
    ),
    related: ['yoga', 'sex', 'lifting'],
    aliases: ['sleep position', 'sleeping side', 'back sleeping'],
  ),
  CanIEntry(
    id: 'mosquito_repellent',
    name: LocalizedText(en: 'Mosquito Repellent', hi: 'मच्छर भगाने वाली चीज़ें'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.depends,
    short: LocalizedText(
      en: 'Use them - mosquito-borne illness is the bigger risk - but prefer gentler options and good ventilation.',
      hi: 'इनका इस्तेमाल कीजिए — मच्छर से होने वाली बीमारी बड़ा ख़तरा है — पर हल्के विकल्प और अच्छी हवा को प्राथमिकता दीजिए।',
    ),
    why: LocalizedText(
      en: 'Dengue, malaria and chikungunya are genuinely risky in pregnancy, so protection matters. Creams and roll-ons used as directed are considered fine; air out the room if you use liquid vaporisers or coils.',
      hi: 'डेंगू, मलेरिया और चिकनगुनिया गर्भावस्था में सचमुच जोखिम भरे हैं, इसलिए बचाव ज़रूरी है। क्रीम और roll-on निर्देश के मुताबिक़ इस्तेमाल करना ठीक माना जाता है; अगर आप liquid vaporiser या coil इस्तेमाल करती हैं तो कमरे में हवा आने-जाने दीजिए।',
    ),
    indian: LocalizedText(
      en: 'Especially important in the monsoon. Prefer creams/patches and nets over breathing in coil or All-Out fumes in a closed room.',
      hi: 'बारिश के मौसम में ख़ासकर ज़रूरी। बंद कमरे में coil या All-Out का धुआँ लेने के बजाय क्रीम/पैच और मच्छरदानी बेहतर हैं।',
    ),
    related: ['dental', 'xray'],
    aliases: ['odomos', 'all out', 'mosquito coil', 'repellent'],
  ),
  CanIEntry(
    id: 'dental',
    name: LocalizedText(en: 'Dental Treatment', hi: 'दाँतों का इलाज'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.safe,
    short: LocalizedText(
      en: 'Routine dental care is safe and important - just tell your dentist you are pregnant.',
      hi: 'दाँतों की सामान्य देखभाल सुरक्षित और ज़रूरी है — बस अपने dentist को बता दीजिए कि आप गर्भवती हैं।',
    ),
    why: LocalizedText(
      en: 'Gums often become tender and bleed in pregnancy, so cleanings and necessary treatment matter. Most procedures are fine; dental X-rays use a shield and a tiny, focused dose.',
      hi: 'गर्भावस्था में मसूड़े अक्सर नाज़ुक हो जाते हैं और ख़ून आता है, इसलिए सफ़ाई और ज़रूरी इलाज मायने रखते हैं। ज़्यादातर प्रक्रियाएँ ठीक हैं; dental X-ray में ढाल इस्तेमाल होती है और ख़ुराक बहुत कम व एक जगह केंद्रित होती है।',
    ),
    t2: LocalizedText(
      en: 'The most comfortable window for any planned dental work.',
      hi: 'किसी भी तय दंत-चिकित्सा के लिए सबसे आरामदेह दौर।',
    ),
    related: ['xray', 'paracetamol', 'antibiotics'],
    aliases: ['dentist', 'tooth', 'root canal', 'scaling'],
  ),
  CanIEntry(
    id: 'xray',
    name: LocalizedText(en: 'X-Ray', hi: 'X-Ray'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.askDoctor,
    short: LocalizedText(
      en: 'Avoid routine X-rays. If one is medically needed, your doctor will shield you and keep it minimal.',
      hi: 'सामान्य X-ray से बचिए। अगर मेडिकल रूप से ज़रूरी हो, तो आपके डॉक्टर ढाल लगाएँगे और इसे कम से कम रखेंगे।',
    ),
    why: LocalizedText(
      en: 'Elective imaging is usually postponed during pregnancy. When an X-ray is genuinely needed (say after an injury), the dose is small and your abdomen is shielded - always tell the team you are pregnant.',
      hi: 'गर्भावस्था में मर्ज़ी से करवाई जाने वाली इमेजिंग आम तौर पर टाल दी जाती है। जब X-ray सचमुच ज़रूरी हो (जैसे चोट के बाद), तो ख़ुराक कम होती है और आपके पेट पर ढाल लगाई जाती है — टीम को हमेशा बता दीजिए कि आप गर्भवती हैं।',
    ),
    related: ['dental', 'mosquito_repellent'],
    aliases: ['radiograph', 'scan', 'ct scan'],
  ),
  CanIEntry(
    id: 'sauna',
    name: LocalizedText(en: 'Sauna / Hot Tub', hi: 'Sauna / गरम पानी का टब'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.avoid,
    short: LocalizedText(
      en: 'Best avoided - getting overheated is not recommended in pregnancy.',
      hi: 'बचना बेहतर है — गर्भावस्था में शरीर का ज़्यादा गरम होना ठीक नहीं माना जाता।',
    ),
    why: LocalizedText(
      en: 'Saunas, steam rooms and hot tubs can raise your core temperature too much, especially early on. A warm (not hot) bath or shower is the comfortable, safe alternative.',
      hi: 'Sauna, steam room और गरम टब आपके शरीर का तापमान बहुत बढ़ा सकते हैं, ख़ासकर शुरुआती दौर में। गुनगुने (गरम नहीं) पानी से नहाना आरामदेह और सुरक्षित विकल्प है।',
    ),
    related: ['swimming', 'walking'],
    aliases: ['steam', 'hot tub', 'jacuzzi', 'hot bath'],
  ),
  CanIEntry(
    id: 'lifting',
    name: LocalizedText(en: 'Lifting Heavy Things', hi: 'भारी सामान उठाना'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.depends,
    short: LocalizedText(
      en: 'Light lifting is fine; avoid straining and very heavy loads.',
      hi: 'हल्का उठाना ठीक है; ज़ोर लगाने और बहुत भारी बोझ से बचिए।',
    ),
    why: LocalizedText(
      en: 'Pregnancy hormones loosen your ligaments and your balance shifts, so heavy or awkward lifting risks your back more than the baby. Bend at the knees, hold things close, and ask for help with the heavy stuff.',
      hi: 'गर्भावस्था के हार्मोन आपके जोड़ों के बंधन ढीले कर देते हैं और संतुलन बदल जाता है, इसलिए भारी या टेढ़ा उठाना शिशु से ज़्यादा आपकी कमर के लिए ख़तरा है। घुटनों से झुकिए, चीज़ें शरीर के पास रखिए, और भारी सामान के लिए मदद माँगिए।',
    ),
    t3: LocalizedText(
      en: 'Take extra care now - your centre of gravity is well forward and strain is easier.',
      hi: 'अभी ज़्यादा ध्यान रखिए — आपके शरीर का संतुलन काफ़ी आगे की ओर है और ज़ोर पड़ना आसान है।',
    ),
    related: ['walking', 'yoga', 'sleeping_back'],
    aliases: ['lifting weights', 'heavy lifting', 'carrying'],
  ),
  CanIEntry(
    id: 'fasting',
    name: LocalizedText(en: 'Fasting', hi: 'व्रत'),
    category: CanICategory.doActivity,
    verdict: CanIVerdict.askDoctor,
    short: LocalizedText(
      en: 'Talk to your doctor before fasting - whether it is okay depends on your health and stage.',
      hi: 'व्रत रखने से पहले अपने डॉक्टर से बात कीजिए — यह ठीक है या नहीं, यह आपकी सेहत और चरण पर निर्भर करता है।',
    ),
    why: LocalizedText(
      en: 'Steady nutrition and hydration matter a lot in pregnancy. Some shorter or partial fasts may be okay for some mothers; long or strict fasts are often advised against. It is very individual.',
      hi: 'गर्भावस्था में लगातार पोषण और पानी बहुत मायने रखते हैं। कुछ माँओं के लिए छोटे या आंशिक व्रत ठीक हो सकते हैं; लंबे या सख़्त व्रत से अक्सर मना किया जाता है। यह बहुत हद तक हर व्यक्ति पर निर्भर है।',
    ),
    indian: LocalizedText(
      en: 'For festival vrats, many mothers keep a fruit-and-milk (phalahar) fast rather than a nirjala one - but please confirm with your doctor first.',
      hi: 'त्योहारों के व्रत में कई माँएँ निर्जला के बजाय फलाहार रखती हैं — पर कृपया पहले अपने डॉक्टर से पुष्टि कर लीजिए।',
    ),
    related: ['water', 'street_food'],
    aliases: ['vrat', 'upvas', 'roza', 'navratri'],
  ),

  // ==========================================================================
  //  EXPANDED LIBRARY (toward the ~250-item set). Concise general guidance,
  //  English-first, PENDING MEDICAL REVIEW. Tone matches the curated set.
  // ==========================================================================

  // ---- EAT ----
  CanIEntry(id: 'apple', name: LocalizedText(en: 'Apple', hi: 'सेब'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Apples are a great everyday fruit in pregnancy.'), why: _t('Good fibre and vitamins that help digestion and energy. Wash well before eating.'), aliases: ['seb', 'apple']),
  CanIEntry(id: 'orange', name: LocalizedText(en: 'Orange / Citrus', hi: 'संतरा / खट्टे फल'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Oranges and citrus fruits are a healthy choice.'), why: _t('Rich in vitamin C and water, they support immunity and hydration.'), aliases: ['santra', 'citrus', 'mosambi']),
  CanIEntry(id: 'grapes', name: LocalizedText(en: 'Grapes', hi: 'अंगूर'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Grapes are fine in moderation, washed well.'), why: _t('A good source of vitamins; rinse thoroughly and keep portions modest due to natural sugar.'), aliases: ['angur']),
  CanIEntry(id: 'watermelon', name: LocalizedText(en: 'Watermelon', hi: 'तरबूज़'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Watermelon is hydrating and safe.'), why: _t('Mostly water with helpful minerals; great in heat. Eat it freshly cut at home, not pre-cut from outside.'), aliases: ['tarbooj']),
  CanIEntry(id: 'muskmelon', name: LocalizedText(en: 'Muskmelon', hi: 'ख़रबूज़ा'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Muskmelon is a safe, hydrating fruit.'), why: _t('Light and water-rich; wash the rind and eat it freshly cut at home.'), aliases: ['kharbooja']),
  CanIEntry(id: 'guava', name: LocalizedText(en: 'Guava', hi: 'अमरूद'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Guava is a nutritious, high-fibre fruit.'), why: _t('Rich in fibre and vitamin C; helps with constipation. Wash well.'), aliases: ['amrood']),
  CanIEntry(id: 'pomegranate', name: LocalizedText(en: 'Pomegranate', hi: 'अनार'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Pomegranate is a healthy choice in pregnancy.'), why: _t('Full of iron-supporting nutrients and antioxidants; a gentle, nourishing fruit.'), aliases: ['anar']),
  CanIEntry(id: 'chikoo', name: LocalizedText(en: 'Chikoo (Sapota)', hi: 'चीकू'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Chikoo is fine in moderation.'), why: _t('Sweet and energy-giving; enjoy in modest amounts as it is high in natural sugar.'), aliases: ['sapota', 'chiku']),
  CanIEntry(id: 'custard_apple', name: LocalizedText(en: 'Custard Apple', hi: 'शरीफ़ा'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Custard apple is fine in moderation.'), why: _t('Nutritious and energy-rich; keep portions modest due to its sweetness.'), aliases: ['sitaphal', 'sharifa']),
  CanIEntry(id: 'litchi', name: LocalizedText(en: 'Litchi', hi: 'लीची'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Litchi is fine in small amounts.'), why: _t('Refreshing and sweet; eat ripe ones in moderation and not on an empty stomach.'), aliases: ['lychee']),
  CanIEntry(id: 'jackfruit', name: LocalizedText(en: 'Jackfruit', hi: 'कटहल'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Ripe jackfruit is fine in moderation.'), why: _t('Enjoy ripe jackfruit in modest amounts; there is no good reason to fear it in normal quantities.'), aliases: ['kathal']),
  CanIEntry(id: 'dates', name: LocalizedText(en: 'Dates', hi: 'खजूर'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Dates are a wonderful pregnancy snack.'), why: _t('Rich in iron and natural energy, and often suggested later in pregnancy. Enjoy a few a day.'), aliases: ['khajoor']),
  CanIEntry(id: 'figs', name: LocalizedText(en: 'Figs', hi: 'अंजीर'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Figs are nutritious and safe.'), why: _t('Good for fibre, calcium and iron, and helpful for digestion. Fresh or soaked dried figs both work.'), aliases: ['anjeer']),
  CanIEntry(id: 'berries', name: LocalizedText(en: 'Berries', hi: 'बेरी'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Strawberries and berries are a healthy choice.'), why: _t('Rich in vitamin C and antioxidants; wash thoroughly before eating.'), aliases: ['strawberry', 'blueberry']),
  CanIEntry(id: 'kiwi', name: LocalizedText(en: 'Kiwi', hi: 'कीवी'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Kiwi is a safe, vitamin-rich fruit.'), why: _t('High in vitamin C and fibre, and gentle on digestion.'), aliases: ['kiwi']),
  CanIEntry(id: 'pear', name: LocalizedText(en: 'Pear', hi: 'नाशपाती'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Pears are a safe, gentle fruit.'), why: _t('Good fibre and hydration, and easy on the stomach. Wash well.'), aliases: ['nashpati']),
  CanIEntry(id: 'dry_fruits', name: LocalizedText(en: 'Dry Fruits & Nuts', hi: 'सूखे मेवे'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Dried fruits and nuts are a great snack.'), why: _t('Nutrient-dense energy with iron and good fats; keep portions sensible.'), aliases: ['mewa', 'dry fruits']),
  CanIEntry(id: 'almonds', name: LocalizedText(en: 'Almonds', hi: 'बादाम'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Almonds are a healthy daily snack.'), why: _t('Good fats, protein and vitamin E; a handful a day is lovely. Soaked almonds are easy to digest.'), aliases: ['badam']),
  CanIEntry(id: 'walnuts', name: LocalizedText(en: 'Walnuts', hi: 'अख़रोट'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Walnuts are nourishing in pregnancy.'), why: _t('A good source of omega-3 fats that support development; a few a day is plenty.'), aliases: ['akhrot']),
  CanIEntry(id: 'cashews', name: LocalizedText(en: 'Cashews', hi: 'काजू'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Cashews are fine in moderation.'), why: _t('Tasty and nutritious; keep to a small handful as they are calorie-rich.'), aliases: ['kaju']),
  CanIEntry(id: 'peanuts', name: LocalizedText(en: 'Peanuts', hi: 'मूँगफली'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Peanuts are safe unless you are allergic.'), why: _t('A good plant protein; avoid only if you have a known peanut allergy.'), aliases: ['moongphali', 'groundnut']),
  CanIEntry(id: 'makhana', name: LocalizedText(en: 'Makhana', hi: 'मखाना'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Makhana (fox nuts) is a great light snack.'), why: _t('Low in fat and good for a roasted, guilt-free nibble.'), aliases: ['fox nuts', 'lotus seeds']),
  CanIEntry(id: 'sabudana', name: LocalizedText(en: 'Sabudana', hi: 'साबूदाना'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Sabudana is safe and easy to digest.'), why: _t('A gentle source of energy, popular during fasts; cook it well.'), aliases: ['tapioca', 'sago']),
  CanIEntry(id: 'spinach', name: LocalizedText(en: 'Spinach & Greens', hi: 'पालक और हरी सब्ज़ियाँ'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Spinach and leafy greens are excellent.'), why: _t('Rich in iron and folate; wash very well and cook it. Great for pregnancy.'), aliases: ['palak', 'greens', 'saag']),
  CanIEntry(id: 'drumstick', name: LocalizedText(en: 'Drumstick (Moringa)', hi: 'सहजन (मोरिंगा)'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Drumstick is fine cooked in moderation.'), why: _t('Nutritious in cooked dishes like sambar; enjoy in normal food amounts.'), aliases: ['moringa', 'sahjan']),
  CanIEntry(id: 'brinjal', name: LocalizedText(en: 'Brinjal', hi: 'बैंगन'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Brinjal is safe, cooked well.'), why: _t('A normal vegetable; cook it properly. There is no need to avoid it.'), aliases: ['baingan', 'eggplant']),
  CanIEntry(id: 'potato', name: LocalizedText(en: 'Potato', hi: 'आलू'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Potato is safe in pregnancy.'), why: _t('A staple carbohydrate; just balance it with vegetables and protein.'), aliases: ['aloo']),
  CanIEntry(id: 'tomato', name: LocalizedText(en: 'Tomato', hi: 'टमाटर'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Tomatoes are safe and healthy.'), why: _t('Rich in vitamins; wash well. Fine raw in salads made at home, or cooked.'), aliases: ['tamatar']),
  CanIEntry(id: 'carrot', name: LocalizedText(en: 'Carrot', hi: 'गाजर'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Carrots are a healthy, safe vegetable.'), why: _t('Good for vitamin A and fibre; wash and peel before eating raw.'), aliases: ['gajar']),
  CanIEntry(id: 'beetroot', name: LocalizedText(en: 'Beetroot', hi: 'चुकंदर'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Beetroot is safe and nourishing.'), why: _t('Supports iron levels and adds natural colour; wash well.'), aliases: ['chukandar']),
  CanIEntry(id: 'sprouts', name: LocalizedText(en: 'Sprouts', hi: 'अंकुरित अनाज'), category: CanICategory.eat, verdict: CanIVerdict.depends, short: _t('Sprouts are best eaten cooked, not raw.'), why: _t('Raw sprouts can carry bacteria; lightly steaming or cooking them makes them much safer.'), aliases: ['moong sprouts', 'sprout']),
  CanIEntry(id: 'raw_salad', name: LocalizedText(en: 'Raw Salad', hi: 'कच्चा सलाद'), category: CanICategory.eat, verdict: CanIVerdict.depends, short: _t('Salads are healthy if washed very well.'), why: _t('Raw vegetables are good, but wash them thoroughly with clean water; outside salads are the main risk.'), aliases: ['salad', 'raw vegetables']),
  CanIEntry(id: 'mushroom', name: LocalizedText(en: 'Mushroom', hi: 'मशरूम'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Cooked mushrooms are safe.'), why: _t('Common edible mushrooms are fine when cooked well; avoid wild or unfamiliar ones.'), aliases: ['mushroom']),
  CanIEntry(id: 'egg', name: LocalizedText(en: 'Egg', hi: 'अंडा'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Well-cooked eggs are a great protein.'), why: _t('Cook until both white and yolk are firm; avoid runny or raw eggs.'), aliases: ['anda', 'eggs']),
  CanIEntry(id: 'chicken', name: LocalizedText(en: 'Chicken', hi: 'चिकन'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Well-cooked chicken is safe and nourishing.'), why: _t('A good protein; cook it thoroughly until no pink remains.'), aliases: ['murga', 'chicken']),
  CanIEntry(id: 'mutton', name: LocalizedText(en: 'Mutton', hi: 'मटन'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Well-cooked mutton is fine in moderation.'), why: _t('A good iron source; cook it thoroughly and keep portions reasonable as it is heavy.'), aliases: ['red meat', 'mutton']),
  CanIEntry(id: 'fish', name: LocalizedText(en: 'Fish', hi: 'मछली'), category: CanICategory.eat, verdict: CanIVerdict.depends, short: _t('Most cooked fish is healthy; limit high-mercury types.'), why: _t('Low-mercury fish like rohu are good for development; limit large fish such as king mackerel and shark.'), aliases: ['machli']),
  CanIEntry(id: 'prawns', name: LocalizedText(en: 'Prawns', hi: 'झींगा'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Well-cooked prawns are safe.'), why: _t('Fully cooked prawns and shrimp are fine; avoid raw or undercooked seafood.'), aliases: ['shrimp', 'jhinga']),
  CanIEntry(id: 'high_mercury_fish', name: LocalizedText(en: 'High-Mercury Fish', hi: 'ज़्यादा Mercury वाली मछली'), category: CanICategory.eat, verdict: CanIVerdict.avoid, short: _t('Large high-mercury fish are best avoided.'), why: _t('Shark, swordfish and king mackerel can be high in mercury; choose smaller fish instead.'), aliases: ['mercury fish', 'shark', 'swordfish']),
  CanIEntry(id: 'dal', name: LocalizedText(en: 'Dal & Lentils', hi: 'दाल'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Dal and lentils are excellent in pregnancy.'), why: _t('A staple plant protein with fibre and iron; eat freely.'), aliases: ['lentils', 'pulses']),
  CanIEntry(id: 'soya', name: LocalizedText(en: 'Soya', hi: 'सोया'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Soya is fine in moderation.'), why: _t('A useful protein in tofu, soya chunks or milk; keep to normal food amounts.'), aliases: ['soy', 'soya chunks']),
  CanIEntry(id: 'rajma_chana', name: LocalizedText(en: 'Rajma & Chana', hi: 'राजमा और चना'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Rajma and chana are healthy, protein-rich foods.'), why: _t('Beans and chickpeas give protein, fibre and iron; soak and cook well.'), aliases: ['kidney beans', 'chickpeas', 'chole']),
  CanIEntry(id: 'milk', name: LocalizedText(en: 'Milk', hi: 'दूध'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Pasteurised milk is great in pregnancy.'), why: _t('A good source of calcium and protein; choose pasteurised or boiled milk.'), aliases: ['doodh']),
  CanIEntry(id: 'cheese', name: LocalizedText(en: 'Cheese', hi: 'चीज़'), category: CanICategory.eat, verdict: CanIVerdict.depends, short: _t('Hard and pasteurised cheeses are fine; avoid soft unpasteurised ones.'), why: _t('Cheddar and processed cheese are safe; avoid mould-ripened or unpasteurised soft cheeses.'), aliases: ['cheese']),
  CanIEntry(id: 'ghee', name: LocalizedText(en: 'Ghee & Butter', hi: 'घी और मक्खन'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Ghee and butter are fine in moderate amounts.'), why: _t('Normal food fats that are fine in cooking; just keep the quantity sensible.'), aliases: ['ghee', 'makkhan', 'butter']),
  CanIEntry(id: 'mawa_sweets', name: LocalizedText(en: 'Mithai (Mawa Sweets)', hi: 'मिठाई (मावा वाली)'), category: CanICategory.eat, verdict: CanIVerdict.depends, short: _t('Enjoy mithai from pasteurised mawa, in moderation.'), why: _t('Khoya sweets are fine occasionally if fresh and hygienic; the concern is adulteration, freshness and sugar.'), aliases: ['mithai', 'khoya', 'barfi', 'sweets']),
  CanIEntry(id: 'oats', name: LocalizedText(en: 'Oats', hi: 'ओट्स'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Oats are a wonderful pregnancy breakfast.'), why: _t('High in fibre, they help digestion and keep you full; pair with milk and fruit.'), aliases: ['oats', 'oatmeal']),
  CanIEntry(id: 'poha', name: LocalizedText(en: 'Poha', hi: 'पोहा'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Poha is a light, safe meal.'), why: _t('Easy to digest and can be made iron-rich; a gentle everyday option.'), aliases: ['poha']),
  CanIEntry(id: 'instant_noodles', name: LocalizedText(en: 'Instant Noodles', hi: 'इंस्टेंट नूडल्स'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Instant noodles are fine as an occasional treat.'), why: _t('Low in nutrition and high in salt; enjoy once in a while, ideally with added veg and egg.'), aliases: ['maggi', 'noodles']),
  CanIEntry(id: 'fried_snacks', name: LocalizedText(en: 'Fried Snacks', hi: 'तले हुए स्नैक्स'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Samosa, pakora and the like are fine occasionally.'), why: _t('Tasty but oily; enjoy now and then, ideally freshly made and hygienic.'), aliases: ['samosa', 'pakora', 'kachori', 'fried']),
  CanIEntry(id: 'maida', name: LocalizedText(en: 'Maida (Refined Flour)', hi: 'मैदा'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Foods made of maida are fine in moderation.'), why: _t('Refined flour has little fibre; balance it with whole grains and vegetables.'), aliases: ['refined flour', 'white flour']),
  CanIEntry(id: 'pickle', name: LocalizedText(en: 'Pickle (Achar)', hi: 'अचार'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Pickle is fine in small amounts.'), why: _t('It adds flavour but is very high in salt and oil; a little is okay.'), aliases: ['achar']),
  CanIEntry(id: 'saffron', name: LocalizedText(en: 'Saffron (Kesar)', hi: 'केसर'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('A few strands of saffron are fine.'), why: _t('Saffron in milk in tiny culinary amounts is fine; there is no need for large quantities.'), aliases: ['kesar', 'saffron']),
  CanIEntry(id: 'turmeric_milk', name: LocalizedText(en: 'Turmeric / Haldi Doodh', hi: 'हल्दी / हल्दी वाला दूध'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Haldi doodh in normal amounts is comforting and safe.'), why: _t('Turmeric in cooking and a cup of haldi milk is fine; avoid very large supplement doses.'), aliases: ['haldi', 'turmeric', 'golden milk']),
  CanIEntry(id: 'jaggery', name: LocalizedText(en: 'Jaggery (Gud)', hi: 'गुड़'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Jaggery is a fine natural sweetener in moderation.'), why: _t('Often preferred over white sugar and may support iron; still a sugar, so keep it moderate.'), aliases: ['gud', 'gur']),
  CanIEntry(id: 'spices', name: LocalizedText(en: 'Spices & Herbs', hi: 'मसाले और जड़ी-बूटियाँ'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Everyday cooking spices and herbs are safe.'), why: _t('Normal culinary amounts of jeera, dhania, ajwain, hing and garlic are fine; only avoid very large medicinal doses.'), aliases: ['jeera', 'cumin', 'ajwain', 'hing', 'garlic', 'dhania', 'masala']),
  CanIEntry(id: 'salt', name: LocalizedText(en: 'Salt', hi: 'नमक'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Use normal amounts of salt; avoid excess.'), why: _t('Some salt is needed, but high salt can worsen swelling and blood pressure; use iodised salt.'), aliases: ['namak', 'sodium']),
  CanIEntry(id: 'sugar', name: LocalizedText(en: 'Sugar', hi: 'चीनी'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Sugar is fine in moderation.'), why: _t('Enjoy sweet things in modest amounts; too much adds empty calories and affects blood sugar.'), aliases: ['cheeni', 'sugar']),
  CanIEntry(id: 'sushi', name: LocalizedText(en: 'Sushi (Raw Fish)', hi: 'सुशी (कच्ची मछली)'), category: CanICategory.eat, verdict: CanIVerdict.avoid, short: _t('Raw-fish sushi is best avoided.'), why: _t('Raw seafood can carry bacteria and parasites; cooked or vegetarian sushi is a safer choice.'), aliases: ['raw fish', 'sushi']),
  CanIEntry(id: 'raw_meat', name: LocalizedText(en: 'Raw / Undercooked Meat', hi: 'कच्चा / अधपका माँस'), category: CanICategory.eat, verdict: CanIVerdict.avoid, short: _t('Raw or undercooked meat should be avoided.'), why: _t('It can carry infections like toxoplasma; always cook meat thoroughly.'), aliases: ['undercooked meat', 'rare meat']),
  CanIEntry(id: 'deli_meat', name: LocalizedText(en: 'Cold Cuts / Deli Meat', hi: 'ठंडा कटा माँस / Deli meat'), category: CanICategory.eat, verdict: CanIVerdict.depends, short: _t('Heat cold cuts until steaming before eating.'), why: _t('Ready-to-eat cold meats can carry listeria; heating them through makes them safer.'), aliases: ['cold cuts', 'salami', 'ham']),
  CanIEntry(id: 'leftovers', name: LocalizedText(en: 'Leftover Food', hi: 'बचा हुआ खाना'), category: CanICategory.eat, verdict: CanIVerdict.depends, short: _t('Leftovers are fine if stored and reheated properly.'), why: _t('Refrigerate promptly and reheat until piping hot; avoid food that has been left out for long.'), aliases: ['leftovers', 'stale food']),
  CanIEntry(id: 'spicy_food', name: LocalizedText(en: 'Spicy Food', hi: 'तीखा खाना'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Spicy food is fine if it agrees with you.'), why: _t('It will not harm the baby; it may worsen heartburn for some, so adjust to your comfort.'), aliases: ['spicy', 'teekha']),
  CanIEntry(id: 'chyawanprash', name: LocalizedText(en: 'Chyawanprash', hi: 'च्यवनप्राश'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Chyawanprash is generally fine in small daily amounts.'), why: _t('A traditional tonic that is usually okay; check with your doctor if unsure about the ingredients.'), aliases: ['chyawanprash']),

  // ---- DRINK ----
  CanIEntry(id: 'milkshake', name: LocalizedText(en: 'Milkshake', hi: 'मिल्कशेक'), category: CanICategory.drink, verdict: CanIVerdict.moderation, short: _t('Homemade milkshakes are a nice, safe treat.'), why: _t('Made with pasteurised milk and fruit they are nourishing; go easy on added sugar.'), aliases: ['shake', 'milkshake']),
  CanIEntry(id: 'fresh_juice', name: LocalizedText(en: 'Fresh Juice', hi: 'ताज़ा जूस'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Freshly made juice at home is fine.'), why: _t('Drink it fresh and hygienically made; whole fruit is even better for the fibre.'), aliases: ['juice', 'fresh juice']),
  CanIEntry(id: 'packaged_juice', name: LocalizedText(en: 'Packaged Juice', hi: 'पैकेट वाला जूस'), category: CanICategory.drink, verdict: CanIVerdict.moderation, short: _t('Packaged juices are okay occasionally.'), why: _t('They are high in sugar and low in fibre; fresh fruit or fresh juice is better.'), aliases: ['tetra pack juice', 'packaged juice']),
  CanIEntry(id: 'lemon_water', name: LocalizedText(en: 'Lemon Water', hi: 'नींबू पानी'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Lemon water is safe and refreshing.'), why: _t('Hydrating and can ease nausea; a lovely everyday drink.'), aliases: ['nimbu pani', 'shikanji']),
  CanIEntry(id: 'sugarcane_juice', name: LocalizedText(en: 'Sugarcane Juice', hi: 'गन्ने का रस'), category: CanICategory.drink, verdict: CanIVerdict.depends, short: _t('Sugarcane juice is fine if hygienic and fresh.'), why: _t('Refreshing and energy-giving; the concern is roadside hygiene, so prefer clean, fresh sources.'), aliases: ['ganne ka ras']),
  CanIEntry(id: 'lassi', name: LocalizedText(en: 'Lassi', hi: 'लस्सी'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Lassi made from fresh curd is safe and cooling.'), why: _t('A probiotic, calcium-rich drink; sweet or salted, made hygienically.'), aliases: ['lassi']),
  CanIEntry(id: 'energy_drinks', name: LocalizedText(en: 'Energy Drinks', hi: 'एनर्जी ड्रिंक'), category: CanICategory.drink, verdict: CanIVerdict.avoid, short: _t('Energy drinks are best avoided.'), why: _t('They are high in caffeine and stimulants that are not recommended in pregnancy.'), aliases: ['red bull', 'energy drink']),
  CanIEntry(id: 'herbal_tea', name: LocalizedText(en: 'Herbal Tea', hi: 'हर्बल चाय'), category: CanICategory.drink, verdict: CanIVerdict.depends, short: _t('Check each herbal tea before drinking.'), why: _t('Some herbs are not advised in pregnancy; ginger and mild ones are usually fine, but confirm the blend.'), aliases: ['herbal tea', 'tulsi tea']),
  CanIEntry(id: 'smoothie', name: LocalizedText(en: 'Smoothie', hi: 'स्मूदी'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Homemade fruit smoothies are nourishing.'), why: _t('A great way to get fruit, curd and nuts; make them fresh and hygienic.'), aliases: ['smoothie']),
  CanIEntry(id: 'kombucha', name: LocalizedText(en: 'Kombucha', hi: 'कोम्बुचा'), category: CanICategory.drink, verdict: CanIVerdict.avoid, short: _t('Kombucha is best avoided in pregnancy.'), why: _t('It is fermented, sometimes unpasteurised and slightly alcoholic, so it is safer to skip.'), aliases: ['kombucha']),
  CanIEntry(id: 'diet_soda', name: LocalizedText(en: 'Diet Soda', hi: 'डाइट सोडा'), category: CanICategory.drink, verdict: CanIVerdict.moderation, short: _t('Diet sodas are okay occasionally.'), why: _t('Artificial sweeteners are generally considered fine in small amounts, but these drinks add little value.'), aliases: ['diet coke', 'zero soda']),
  CanIEntry(id: 'aam_panna', name: LocalizedText(en: 'Aam Panna', hi: 'आम पना'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Aam panna is a safe, cooling summer drink.'), why: _t('Hydrating and good for the heat; make it fresh and hygienically.'), aliases: ['aam panna']),
  CanIEntry(id: 'badam_milk', name: LocalizedText(en: 'Badam Milk', hi: 'बादाम वाला दूध'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Badam milk is a nourishing, safe drink.'), why: _t('Milk with almonds gives calcium and good fats; lovely warm or cold.'), aliases: ['almond milk', 'badam milk']),
  CanIEntry(id: 'decaf_coffee', name: LocalizedText(en: 'Decaf Coffee', hi: 'Decaf कॉफ़ी'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Decaf coffee is a good low-caffeine choice.'), why: _t('It has very little caffeine, so it is gentle; a nice swap if you miss coffee.'), aliases: ['decaf']),
  CanIEntry(id: 'jaljeera', name: LocalizedText(en: 'Jaljeera', hi: 'जलजीरा'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Jaljeera is safe and aids digestion.'), why: _t('A cumin-based drink that can settle the stomach; make it hygienically.'), aliases: ['jaljeera']),
  CanIEntry(id: 'ors', name: LocalizedText(en: 'ORS / Electrolytes', hi: 'ORS / Electrolytes'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('ORS and electrolyte drinks help when you are dehydrated.'), why: _t('Useful in heat, vomiting or weakness; use standard ORS as directed.'), aliases: ['ors', 'electral', 'glucose water']),

  // ---- TAKE (medicines / supplements) ----
  CanIEntry(id: 'aspirin', name: LocalizedText(en: 'Aspirin', hi: 'Aspirin'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Only take aspirin if your doctor prescribes it.'), why: _t('Low-dose aspirin is sometimes prescribed in pregnancy, but it should never be self-started.'), aliases: ['aspirin', 'disprin', 'ecosprin']),
  CanIEntry(id: 'cetirizine', name: LocalizedText(en: 'Antihistamines (Cetirizine)', hi: 'Antihistamines (Cetirizine)'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Ask your doctor before taking allergy medicines.'), why: _t('Some antihistamines are used in pregnancy, but confirm the choice and dose with your doctor.'), aliases: ['cetirizine', 'allergy', 'antihistamine', 'avil']),
  CanIEntry(id: 'antacids', name: LocalizedText(en: 'Antacids', hi: 'Antacids'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Most simple antacids are fine for heartburn.'), why: _t('Calcium or magnesium based antacids are commonly used; follow the label, and your doctor if you need them often.'), aliases: ['digene', 'eno', 'gelusil', 'acidity']),
  CanIEntry(id: 'pantoprazole', name: LocalizedText(en: 'Acidity Tablets (Pantoprazole)', hi: 'अम्लता की गोलियाँ (Pantoprazole)'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Acidity tablets like pantoprazole need your doctor okay.'), why: _t('These are sometimes used in pregnancy; take them on medical advice rather than on your own.'), aliases: ['pan', 'omeprazole', 'pantoprazole', 'rabeprazole']),
  CanIEntry(id: 'vitamin_c', name: LocalizedText(en: 'Vitamin C', hi: 'Vitamin C'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Vitamin C from food or a prescribed dose is fine.'), why: _t('Helpful for immunity and iron absorption; avoid very high supplement doses unless advised.'), aliases: ['vitamin c']),
  CanIEntry(id: 'multivitamin', name: LocalizedText(en: 'Prenatal Multivitamin', hi: 'Prenatal Multivitamin'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Prenatal multivitamins are usually recommended.'), why: _t('Take a pregnancy-specific multivitamin as advised; avoid stacking extra high-dose vitamins on top.'), aliases: ['multivitamin', 'prenatal vitamin']),
  CanIEntry(id: 'omega3', name: LocalizedText(en: 'Omega-3 (DHA)', hi: 'Omega-3 (DHA)'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Omega-3 (DHA) supplements are commonly recommended.'), why: _t('They support brain and eye development; take a pregnancy-safe one as advised.'), aliases: ['dha', 'fish oil', 'omega 3']),
  CanIEntry(id: 'b12', name: LocalizedText(en: 'Vitamin B12', hi: 'Vitamin B12'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Vitamin B12 is fine and often recommended.'), why: _t('Important for you and your baby, especially on a vegetarian diet; take it as advised.'), aliases: ['b12', 'cobalamin']),
  CanIEntry(id: 'ondansetron', name: LocalizedText(en: 'Anti-Nausea (Ondansetron)', hi: 'मतली की दवा (Ondansetron)'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Anti-nausea medicines should be doctor-prescribed.'), why: _t('Medicines like ondansetron are used for severe vomiting, but only on medical advice.'), aliases: ['ondansetron', 'emeset', 'vomiting tablet']),
  CanIEntry(id: 'doxylamine', name: LocalizedText(en: 'Morning-Sickness Tablet (Doxylamine)', hi: 'सुबह की मतली की गोली (Doxylamine)'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Doxylamine for morning sickness needs a prescription.'), why: _t('A common, doctor-prescribed option for nausea, often with vitamin B6; use as directed.'), aliases: ['doxinate', 'doxylamine', 'morning sickness tablet']),
  CanIEntry(id: 'cough_syrup', name: LocalizedText(en: 'Cough Syrup', hi: 'खाँसी का सिरप'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Check with your doctor before any cough syrup.'), why: _t('Some contain ingredients best avoided in pregnancy; your doctor can suggest a safe one.'), aliases: ['cough syrup', 'benadryl']),
  CanIEntry(id: 'lozenges', name: LocalizedText(en: 'Throat Lozenges', hi: 'गले की गोलियाँ'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Plain throat lozenges are generally fine.'), why: _t('Simple menthol or honey-lemon lozenges are okay for a sore throat; avoid medicated ones without advice.'), aliases: ['throat lozenge', 'strepsils']),
  CanIEntry(id: 'vicks_balm', name: LocalizedText(en: 'Vicks / Balm', hi: 'Vicks / बाम'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Vicks and balms for external use are generally fine.'), why: _t('Applied on the skin or used for steam they are usually okay; do not swallow them.'), aliases: ['vicks', 'balm', 'vaporub', 'zandu balm']),
  CanIEntry(id: 'laxative', name: LocalizedText(en: 'Laxatives', hi: 'क़ब्ज़ की दवा'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Try diet and fluids first; ask before laxatives.'), why: _t('Fibre, water and isabgol help constipation; stronger laxatives need medical advice.'), aliases: ['laxative', 'dulcolax', 'cremaffin']),
  CanIEntry(id: 'isabgol', name: LocalizedText(en: 'Isabgol (Psyllium)', hi: 'इसबगोल'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Isabgol is a safe option for constipation.'), why: _t('A gentle fibre that eases constipation; take it with plenty of water.'), aliases: ['psyllium', 'isabgol', 'fibre']),
  CanIEntry(id: 'probiotics', name: LocalizedText(en: 'Probiotics', hi: 'Probiotics'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Probiotics are generally considered safe.'), why: _t('Curd and probiotic supplements can help digestion; choose a reputable one.'), aliases: ['probiotic']),
  CanIEntry(id: 'ashwagandha', name: LocalizedText(en: 'Ashwagandha', hi: 'अश्वगंधा'), category: CanICategory.take, verdict: CanIVerdict.avoid, short: _t('Ashwagandha is best avoided in pregnancy.'), why: _t('This herb is traditionally not recommended during pregnancy; skip it unless your doctor says otherwise.'), aliases: ['ashwagandha']),
  CanIEntry(id: 'ayurvedic_medicine', name: LocalizedText(en: 'Ayurvedic / Herbal Medicine', hi: 'आयुर्वेदिक / जड़ी-बूटी की दवा'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Check any ayurvedic or herbal medicine with your doctor.'), why: _t('Natural does not always mean safe in pregnancy, and product quality varies; confirm first.'), aliases: ['ayurvedic', 'herbal medicine', 'kadha', 'churan']),
  CanIEntry(id: 'homeopathy', name: LocalizedText(en: 'Homeopathy', hi: 'होम्योपैथी'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Discuss homeopathic remedies with your doctor.'), why: _t('If you use homeopathy, let your doctor know; do not stop prescribed medicines for it.'), aliases: ['homeopathy']),
  CanIEntry(id: 'sleeping_pills', name: LocalizedText(en: 'Sleeping Pills', hi: 'नींद की गोलियाँ'), category: CanICategory.take, verdict: CanIVerdict.avoid, short: _t('Avoid sleeping pills unless prescribed.'), why: _t('Most sedatives are not recommended; speak to your doctor about safe ways to sleep better.'), aliases: ['sleeping pills', 'sedative', 'melatonin']),
  CanIEntry(id: 'diclofenac', name: LocalizedText(en: 'Diclofenac / Nimesulide', hi: 'Diclofenac / Nimesulide'), category: CanICategory.take, verdict: CanIVerdict.avoid, short: _t('These painkillers are generally avoided in pregnancy.'), why: _t('They are anti-inflammatories usually not advised, especially later; paracetamol is preferred.'), aliases: ['diclofenac', 'voveran', 'nimesulide']),
  CanIEntry(id: 'antifungal_cream', name: LocalizedText(en: 'Antifungal / Antiseptic Cream', hi: 'Antifungal / Antiseptic क्रीम'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Check skin creams like antifungals with your doctor.'), why: _t('Many topical creams are used in pregnancy, but confirm the specific one is suitable.'), aliases: ['antifungal', 'candid', 'betadine', 'antiseptic']),
  CanIEntry(id: 'deworming', name: LocalizedText(en: 'Deworming Tablet', hi: 'पेट के कीड़ों की गोली'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Deworming should be timed and approved by your doctor.'), why: _t('Some deworming medicines are delayed in pregnancy; let your doctor decide the timing.'), aliases: ['deworming', 'albendazole']),
  CanIEntry(id: 'thyroid_medicine', name: LocalizedText(en: 'Thyroid Medicine', hi: 'Thyroid की दवा'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Continue your thyroid medicine as prescribed.'), why: _t('Thyroid tablets are important and usually continued in pregnancy; your doctor will adjust the dose.'), aliases: ['thyronorm', 'thyroid', 'eltroxin']),
  CanIEntry(id: 'bp_medicine', name: LocalizedText(en: 'Blood Pressure Medicine', hi: 'ब्लड प्रेशर की दवा'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Never stop or change BP medicine on your own.'), why: _t('Some BP medicines are switched in pregnancy; your doctor will choose a safe one and adjust it.'), aliases: ['blood pressure medicine', 'bp tablet']),
  CanIEntry(id: 'insulin', name: LocalizedText(en: 'Insulin', hi: 'Insulin'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Insulin is safe and often used in pregnancy.'), why: _t('It does not cross to the baby and is the usual treatment when needed; take it as prescribed.'), aliases: ['insulin']),
  CanIEntry(id: 'vaccines', name: LocalizedText(en: 'Vaccines (TT / Flu / COVID)', hi: 'टीके (TT / Flu / COVID)'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Recommended pregnancy vaccines are safe and protective.'), why: _t('Tetanus (TT/Tdap), flu and COVID vaccination are advised in pregnancy; follow your doctor for timing.'), aliases: ['tt', 'tdap', 'tetanus', 'flu shot', 'covid vaccine', 'vaccine']),

  // ---- DO (activities, beauty, lifestyle) ----
  CanIEntry(id: 'driving', name: LocalizedText(en: 'Driving', hi: 'गाड़ी चलाना'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Driving is fine while you are comfortable.'), why: _t('Safe in an uncomplicated pregnancy; keep the seatbelt low under the bump and take breaks on long drives.'), aliases: ['driving', 'car']),
  CanIEntry(id: 'cycling', name: LocalizedText(en: 'Cycling', hi: 'साइकिल चलाना'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Gentle cycling is okay early on if you are used to it.'), why: _t('Balance changes as the bump grows, so many switch to a stationary bike later. Avoid busy traffic and falls.'), aliases: ['cycling', 'bicycle']),
  CanIEntry(id: 'running', name: LocalizedText(en: 'Running / Jogging', hi: 'दौड़ना / जॉगिंग'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Light running is okay if you already run; listen to your body.'), why: _t('Continue gently if you are used to it; stop if you feel pain, dizziness or pressure, and stay hydrated.'), aliases: ['running', 'jogging', 'jog']),
  CanIEntry(id: 'dancing', name: LocalizedText(en: 'Dancing', hi: 'नाचना'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Gentle dancing is a joyful, safe way to move.'), why: _t('Light dancing is great; avoid jumps, spins and falls, especially later on.'), aliases: ['dance', 'garba']),
  CanIEntry(id: 'household_chores', name: LocalizedText(en: 'Household Chores', hi: 'घर के काम'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Normal household work is fine; avoid strain.'), why: _t('Everyday chores are good light activity; avoid heavy lifting, strong chemicals and standing on stools.'), aliases: ['housework', 'chores', 'cleaning']),
  CanIEntry(id: 'climbing_stairs', name: LocalizedText(en: 'Climbing Stairs', hi: 'सीढ़ियाँ चढ़ना'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Climbing stairs is safe; just go steadily.'), why: _t('Use the railing and take your time; there is no need to avoid stairs in a normal pregnancy.'), aliases: ['stairs', 'steps']),
  CanIEntry(id: 'standing_long', name: LocalizedText(en: 'Standing Long Hours', hi: 'लंबे समय खड़े रहना'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Long standing is okay but take regular breaks.'), why: _t('Standing for hours can cause swelling and back ache; sit, move and put your feet up when you can.'), aliases: ['standing']),
  CanIEntry(id: 'amusement_rides', name: LocalizedText(en: 'Amusement Rides', hi: 'मेले के झूले'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Skip roller coasters and jerky rides.'), why: _t('Sudden jolts and forces are best avoided; gentle rides without big drops are a safer choice.'), aliases: ['roller coaster', 'rides']),
  CanIEntry(id: 'trekking', name: LocalizedText(en: 'Trekking / Hiking', hi: 'ट्रेकिंग / पहाड़ी चढ़ाई'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Easy treks are okay; avoid high altitude and rough trails.'), why: _t('Gentle walks in nature are lovely; avoid steep, slippery routes, high altitude and exhaustion.'), aliases: ['trekking', 'hiking']),
  CanIEntry(id: 'gym', name: LocalizedText(en: 'Gym Workouts', hi: 'जिम की कसरत'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Continue gentle gym workouts with guidance.'), why: _t('Light strength and cardio are fine if you are used to them; avoid heavy weights, lying flat later, and overheating.'), aliases: ['gym', 'workout', 'exercise']),
  CanIEntry(id: 'keratin', name: LocalizedText(en: 'Keratin / Straightening', hi: 'Keratin / बाल सीधे करना'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Skip keratin and chemical straightening for now.'), why: _t('These treatments can contain strong chemicals like formaldehyde; many prefer to wait until after pregnancy.'), aliases: ['keratin', 'smoothening', 'rebonding']),
  CanIEntry(id: 'facial', name: LocalizedText(en: 'Facial / Clean-up', hi: 'फ़ेशियल / क्लीन-अप'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('A gentle facial is fine; skip strong treatments.'), why: _t('Basic facials are relaxing; avoid harsh peels, strong actives and electrical treatments without advice.'), aliases: ['facial', 'clean up', 'hair spa']),
  CanIEntry(id: 'chemical_peel', name: LocalizedText(en: 'Chemical Peel', hi: 'केमिकल पील'), category: CanICategory.doActivity, verdict: CanIVerdict.askDoctor, short: _t('Check chemical peels with your doctor or dermatologist.'), why: _t('Mild peels may be okay, but stronger acids are often postponed; confirm first.'), aliases: ['peel', 'chemical peel']),
  CanIEntry(id: 'botox_fillers', name: LocalizedText(en: 'Botox / Fillers', hi: 'Botox / Fillers'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Botox and fillers are best avoided in pregnancy.'), why: _t('They are elective with limited safety data, so most advise waiting until afterwards.'), aliases: ['botox', 'fillers', 'dermal filler']),
  CanIEntry(id: 'laser_hair', name: LocalizedText(en: 'Laser Hair Removal', hi: 'लेज़र से बाल हटाना'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Many postpone laser hair removal.'), why: _t('It is not known to be harmful, but skin is more sensitive and it is elective, so waiting is common.'), aliases: ['laser']),
  CanIEntry(id: 'pedicure', name: LocalizedText(en: 'Pedicure / Manicure', hi: 'पेडीक्योर / मैनीक्योर'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('A pedicure or manicure is a lovely, safe treat.'), why: _t('Enjoy it; choose a clean salon and a gentle calf massage rather than strong pressure points.'), aliases: ['pedicure', 'manicure']),
  CanIEntry(id: 'makeup', name: LocalizedText(en: 'Makeup', hi: 'मेकअप'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Everyday makeup is fine.'), why: _t('Normal cosmetics are safe; remove them before bed and patch-test new products as skin can be sensitive.'), aliases: ['makeup', 'cosmetics']),
  CanIEntry(id: 'sunscreen', name: LocalizedText(en: 'Sunscreen', hi: 'सनस्क्रीन'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Sunscreen is safe and a good idea.'), why: _t('It protects skin that can pigment more easily now; mineral sunscreens are a gentle choice.'), aliases: ['sunscreen', 'spf']),
  CanIEntry(id: 'retinol', name: LocalizedText(en: 'Retinol Creams', hi: 'Retinol क्रीम'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Avoid retinol and strong vitamin-A creams.'), why: _t('Topical retinoids are usually advised against in pregnancy; switch to gentler skincare.'), aliases: ['retinol', 'retinoid', 'anti aging cream']),
  CanIEntry(id: 'perfume', name: LocalizedText(en: 'Perfume / Deodorant', hi: 'परफ़्यूम / डियोड्रेंट'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Perfume is fine; strong scents may trigger nausea.'), why: _t('It is safe to wear; you may just find heavy fragrances bothersome early on.'), aliases: ['perfume', 'deodorant']),
  CanIEntry(id: 'hair_oil', name: LocalizedText(en: 'Hair Oiling (Champi)', hi: 'बालों में तेल (चंपी)'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Oiling your hair is safe and soothing.'), why: _t('A traditional, relaxing routine; a gentle champi is perfectly fine.'), aliases: ['champi', 'hair oil']),
  CanIEntry(id: 'tattoo', name: LocalizedText(en: 'Tattoo / Piercing', hi: 'टैटू / पियर्सिंग'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Many postpone new tattoos and piercings.'), why: _t('The main concern is infection risk and unknowns; most prefer to wait until after pregnancy.'), aliases: ['tattoo', 'piercing']),
  CanIEntry(id: 'gel_nails', name: LocalizedText(en: 'Gel / Acrylic Nails', hi: 'जेल / एक्रिलिक नाख़ून'), category: CanICategory.doActivity, verdict: CanIVerdict.moderation, short: _t('Gel or acrylic nails are okay occasionally.'), why: _t('Generally low risk; ensure a ventilated salon, and note nails may be checked during labour.'), aliases: ['gel nails', 'acrylic']),
  CanIEntry(id: 'smoking', name: LocalizedText(en: 'Smoking', hi: 'धूम्रपान'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Smoking should be avoided completely.'), why: _t('It reduces oxygen and nutrients to your baby; stopping at any point helps. Ask for support if you need it.'), aliases: ['smoking', 'cigarette']),
  CanIEntry(id: 'secondhand_smoke', name: LocalizedText(en: 'Secondhand Smoke', hi: 'दूसरों का धुआँ'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Avoid secondhand smoke as much as you can.'), why: _t('Breathing in others smoke is also harmful; ask people not to smoke around you.'), aliases: ['passive smoking', 'secondhand smoke']),
  CanIEntry(id: 'vaping', name: LocalizedText(en: 'Vaping', hi: 'वेपिंग'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Vaping and e-cigarettes are best avoided.'), why: _t('They still contain nicotine and other substances that are not safe for the baby.'), aliases: ['vape', 'e cigarette']),
  CanIEntry(id: 'hot_water_bath', name: LocalizedText(en: 'Very Hot Bath', hi: 'बहुत गरम पानी से नहाना'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Warm baths are lovely; very hot water is not advised.'), why: _t('Avoid very hot baths that raise your body temperature; keep the water comfortably warm.'), aliases: ['hot bath', 'hot water']),
  CanIEntry(id: 'ac_use', name: LocalizedText(en: 'Air Conditioning', hi: 'एयर कंडीशनिंग'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Air conditioning is completely fine.'), why: _t('Staying cool and comfortable is good; just avoid sitting directly in a cold draught for long.'), aliases: ['ac', 'air conditioner']),
  CanIEntry(id: 'incense', name: LocalizedText(en: 'Incense (Agarbatti)', hi: 'अगरबत्ती'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Use agarbatti and dhoop in a ventilated space.'), why: _t('Occasional use is fine; avoid breathing heavy smoke in a closed room for long periods.'), aliases: ['agarbatti', 'dhoop', 'incense']),
  CanIEntry(id: 'cleaning_chemicals', name: LocalizedText(en: 'Strong Cleaning Chemicals', hi: 'तेज़ सफ़ाई के रसायन'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Use strong cleaners with care and ventilation.'), why: _t('Wear gloves, open windows and do not mix chemicals; switch to milder products where you can.'), aliases: ['bleach', 'phenyl', 'cleaning chemicals']),
  CanIEntry(id: 'paint_fumes', name: LocalizedText(en: 'Paint Fumes', hi: 'पेंट का धुआँ'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Avoid heavy paint fumes; ventilate well.'), why: _t('Brief exposure is unlikely to harm, but avoid painting projects and strong solvent fumes in closed rooms.'), aliases: ['paint', 'fumes', 'solvent']),
  CanIEntry(id: 'pesticides', name: LocalizedText(en: 'Pesticides / Sprays', hi: 'कीटनाशक / स्प्रे'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Avoid pesticides and strong sprays.'), why: _t('Keep away from spraying and treated areas; choose safer pest control and ventilate well.'), aliases: ['pesticide', 'spray']),
  CanIEntry(id: 'pet_cats', name: LocalizedText(en: 'Cats / Litter', hi: 'बिल्ली / उसकी गंदगी'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('You can keep your cat; avoid the litter box.'), why: _t('The concern is toxoplasma from cat faeces, so let someone else clean the litter and wash your hands well.'), aliases: ['cat', 'kitten', 'litter']),
  CanIEntry(id: 'pet_dogs', name: LocalizedText(en: 'Dogs / Pets', hi: 'कुत्ते / पालतू जानवर'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Keeping dogs and pets is absolutely fine.'), why: _t('Pets are wonderful company; just wash your hands and keep their vaccinations and hygiene up to date.'), aliases: ['dog', 'pet']),
  CanIEntry(id: 'gardening', name: LocalizedText(en: 'Gardening', hi: 'बाग़वानी'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Gardening is fine; wear gloves and wash up.'), why: _t('Soil can carry toxoplasma, so wear gloves and wash your hands well afterwards.'), aliases: ['gardening', 'soil']),
  CanIEntry(id: 'public_transport', name: LocalizedText(en: 'Public Transport', hi: 'सार्वजनिक परिवहन'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Buses, trains and the metro are fine to use.'), why: _t('Travel as usual; ask for a seat, hold the supports carefully and avoid the most crowded rush hours if you can.'), aliases: ['bus', 'metro', 'train', 'public transport']),
  CanIEntry(id: 'crowded_places', name: LocalizedText(en: 'Crowded Places', hi: 'भीड़ भरी जगहें'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Crowded places are okay; protect against infection.'), why: _t('No special harm, but it is wise to keep distance during illness seasons and wash your hands often.'), aliases: ['crowd', 'festival', 'mela']),
  CanIEntry(id: 'high_heels', name: LocalizedText(en: 'High Heels', hi: 'ऊँची एड़ी'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Low, stable shoes are safer than high heels.'), why: _t('Balance and posture change in pregnancy; flats or small heels reduce the risk of falls and back ache.'), aliases: ['heels', 'high heels']),
  CanIEntry(id: 'tight_clothes', name: LocalizedText(en: 'Tight Clothes', hi: 'तंग कपड़े'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Choose comfortable, loose clothing.'), why: _t('Very tight clothing can be uncomfortable and restrict circulation; soft, roomy fits feel better.'), aliases: ['tight clothes']),
  CanIEntry(id: 'massage', name: LocalizedText(en: 'Massage', hi: 'मालिश'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Gentle massage is fine; choose a prenatal therapist.'), why: _t('Relaxing for back and legs; avoid strong abdominal pressure and go to someone experienced with pregnancy.'), aliases: ['massage', 'body massage', 'prenatal massage']),
  CanIEntry(id: 'spa', name: LocalizedText(en: 'Spa / Sauna', hi: 'स्पा / Sauna'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Enjoy gentle spa treatments; skip heat therapies.'), why: _t('Relaxing massages and facials are fine; avoid saunas, steam rooms and hot tubs that overheat you.'), aliases: ['spa', 'sauna', 'steam']),
  CanIEntry(id: 'meditation', name: LocalizedText(en: 'Meditation', hi: 'ध्यान'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Meditation is wonderful in pregnancy.'), why: _t('It eases stress and helps sleep and connection with your baby; practise as often as you like.'), aliases: ['meditation', 'mindfulness', 'pranayam']),
  CanIEntry(id: 'mobile_phone', name: LocalizedText(en: 'Mobile / Microwave', hi: 'मोबाइल / माइक्रोवेव'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Using your phone and microwave is safe.'), why: _t('There is no evidence everyday phone use or microwaves harm the baby; just take breaks for your neck and eyes.'), aliases: ['mobile', 'phone', 'radiation', 'microwave']),
  CanIEntry(id: 'stress', name: LocalizedText(en: 'Stress', hi: 'तनाव'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Some stress is normal; ongoing stress is worth easing.'), why: _t('Occasional worry is natural; if you feel constantly anxious, rest, talk to someone and tell your doctor.'), aliases: ['stress', 'anxiety', 'tension']),
];

// ---------------------------------------------------------------------------
//  Lookup helpers
// ---------------------------------------------------------------------------

CanIEntry? canIById(String id) {
  for (final e in kCanIEntries) {
    if (e.id == id) return e;
  }
  return null;
}

List<CanIEntry> canIByCategory(CanICategory c) =>
    kCanIEntries.where((e) => e.category == c).toList();

/// Prefix-first search across name + aliases. Returns prefix matches before
/// looser "contains" matches, each group alphabetical.
List<CanIEntry> canISearch(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  final prefix = <CanIEntry>[];
  final contains = <CanIEntry>[];
  for (final e in kCanIEntries) {
    final terms = <String>[e.name.en.toLowerCase(), ...e.aliases.map((a) => a.toLowerCase())];
    if (terms.any((t) => t.startsWith(q))) {
      prefix.add(e);
    } else if (terms.any((t) => t.contains(q))) {
      contains.add(e);
    }
  }
  int byName(CanIEntry a, CanIEntry b) =>
      a.name.en.toLowerCase().compareTo(b.name.en.toLowerCase());
  prefix.sort(byName);
  contains.sort(byName);
  return [...prefix, ...contains];
}
