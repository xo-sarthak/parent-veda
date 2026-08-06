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
LocalizedText _t(String en, [String? hi]) =>
    LocalizedText(en: en, hi: hi ?? en);

/// Popular-search chips on the Can I? home (emoji + label → entry id).
final List<({String emoji, String label, String id})> kCanIPopular = [
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
    aliases: ['papita', 'raw papaya', 'ripe papaya', 'कच्चा पपीता', 'पका पपीता'],
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
    aliases: ['cheese', 'cottage cheese', 'कॉटेज चीज़'],
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
    aliases: ['chaat', 'golgappa', 'pani puri', 'outside food', 'पानी पूरी', 'बाहर का खाना'],
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
    aliases: ['caffeine', 'espresso', 'filter coffee', 'फ़िल्टर कॉफ़ी'],
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
    aliases: ['chai', 'doodh tea', 'दूध वाली चाय'],
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
    aliases: ['herbal tea', 'हर्बल चाय'],
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
    aliases: ['nariyal pani', 'tender coconut', 'नारियल पानी', 'कच्चा नारियल'],
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
    aliases: ['cola', 'soda', 'cold drink', 'pepsi', 'coke', 'कोल्ड ड्रिंक'],
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
    aliases: ['crocin', 'dolo', 'dolo 650', 'fever', 'paracetamol', 'calpol', 'Dolo 650'],
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
    aliases: ['ibuprofen paracetamol', 'Ibuprofen Paracetamol'],
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
    aliases: ['folate', 'vitamin b9', 'Vitamin B9'],
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
    aliases: ['ferrous', 'haemoglobin', 'iron tablet', 'आयरन की गोली'],
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
    aliases: ['calcium tablet', 'कैल्शियम की गोली'],
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
    aliases: ['vitamin d3', 'cholecalciferol', 'Vitamin D3'],
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
    aliases: ['flight', 'flying', 'air travel', 'airplane', 'plane', 'हवाई यात्रा'],
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
    aliases: ['car travel', 'train', 'road trip', 'bus', 'कार से यात्रा', 'सड़क यात्रा'],
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
    aliases: ['prenatal yoga', 'pranayama', 'asana', 'exercise', 'गर्भावस्था का योग'],
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
    aliases: ['walk', 'morning walk', 'सुबह की सैर'],
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
    aliases: ['hair dye', 'dye', 'colour', 'mehndi', 'henna', 'बालों की डाई'],
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
    aliases: ['wax', 'threading', 'hair removal', 'बाल हटाना'],
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
    aliases: ['nail paint', 'manicure', 'pedicure', 'नेल पेंट'],
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
    aliases: ['intercourse', 'intimacy', 'sex during pregnancy', 'गर्भावस्था में संबंध'],
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
    aliases: ['sleep position', 'sleeping side', 'back sleeping', 'सोने का तरीक़ा', 'करवट लेकर सोना', 'पीठ के बल सोना'],
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
    aliases: ['odomos', 'all out', 'mosquito coil', 'repellent', 'All Out', 'मच्छर भगाने की कॉइल'],
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
    aliases: ['dentist', 'tooth', 'root canal', 'scaling', 'रूट कैनाल'],
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
    aliases: ['radiograph', 'scan', 'ct scan', 'CT scan'],
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
    aliases: ['steam', 'hot tub', 'jacuzzi', 'hot bath', 'हॉट टब', 'गरम पानी से नहाना'],
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
    aliases: ['lifting weights', 'heavy lifting', 'carrying', 'वज़न उठाना', 'भारी सामान उठाना'],
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
  CanIEntry(id: 'apple', name: LocalizedText(en: 'Apple', hi: 'सेब'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Apples are a great everyday fruit in pregnancy.', 'गर्भावस्था में सेब रोज़ का एक बढ़िया फल है।'), why: _t('Good fibre and vitamins that help digestion and energy. Wash well before eating.', 'अच्छा fibre और विटामिन, जो पाचन और ऊर्जा में मदद करते हैं। खाने से पहले अच्छी तरह धो लीजिए।'), aliases: ['seb', 'apple']),
  CanIEntry(id: 'orange', name: LocalizedText(en: 'Orange / Citrus', hi: 'संतरा / खट्टे फल'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Oranges and citrus fruits are a healthy choice.', 'संतरा और खट्टे फल एक सेहतमंद विकल्प हैं।'), why: _t('Rich in vitamin C and water, they support immunity and hydration.', 'इनमें Vitamin C और पानी भरपूर है, जो रोग-प्रतिरोधक क्षमता और शरीर में पानी बनाए रखने में मदद करते हैं।'), aliases: ['santra', 'citrus', 'mosambi']),
  CanIEntry(id: 'grapes', name: LocalizedText(en: 'Grapes', hi: 'अंगूर'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Grapes are fine in moderation, washed well.', 'अंगूर अच्छी तरह धोकर, सीमित मात्रा में ठीक हैं।'), why: _t('A good source of vitamins; rinse thoroughly and keep portions modest due to natural sugar.', 'विटामिन का अच्छा स्रोत; अच्छी तरह धोइए और क़ुदरती चीनी की वजह से मात्रा सीमित रखिए।'), aliases: ['angur']),
  CanIEntry(id: 'watermelon', name: LocalizedText(en: 'Watermelon', hi: 'तरबूज़'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Watermelon is hydrating and safe.', 'तरबूज़ सुरक्षित है और शरीर में पानी बनाए रखता है।'), why: _t('Mostly water with helpful minerals; great in heat. Eat it freshly cut at home, not pre-cut from outside.', 'ज़्यादातर पानी, साथ में काम के खनिज; गर्मी में बढ़िया। घर पर ताज़ा काटकर खाइए, बाहर का कटा हुआ नहीं।'), aliases: ['tarbooj']),
  CanIEntry(id: 'muskmelon', name: LocalizedText(en: 'Muskmelon', hi: 'ख़रबूज़ा'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Muskmelon is a safe, hydrating fruit.', 'ख़रबूज़ा एक सुरक्षित फल है जो शरीर में पानी बनाए रखता है।'), why: _t('Light and water-rich; wash the rind and eat it freshly cut at home.', 'हल्का और पानी से भरपूर; छिलका धोइए और घर पर ताज़ा काटकर खाइए।'), aliases: ['kharbooja']),
  CanIEntry(id: 'guava', name: LocalizedText(en: 'Guava', hi: 'अमरूद'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Guava is a nutritious, high-fibre fruit.', 'अमरूद एक पौष्टिक फल है जिसमें fibre ख़ूब है।'), why: _t('Rich in fibre and vitamin C; helps with constipation. Wash well.', 'इसमें fibre और Vitamin C भरपूर है; क़ब्ज़ में मदद करता है। अच्छी तरह धोइए।'), aliases: ['amrood']),
  CanIEntry(id: 'pomegranate', name: LocalizedText(en: 'Pomegranate', hi: 'अनार'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Pomegranate is a healthy choice in pregnancy.', 'गर्भावस्था में अनार एक सेहतमंद विकल्प है।'), why: _t('Full of iron-supporting nutrients and antioxidants; a gentle, nourishing fruit.', 'Iron में मदद करने वाले पोषक तत्वों और antioxidants से भरा; एक सौम्य, पोषक फल।'), aliases: ['anar']),
  CanIEntry(id: 'chikoo', name: LocalizedText(en: 'Chikoo (Sapota)', hi: 'चीकू'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Chikoo is fine in moderation.', 'चीकू सीमित मात्रा में ठीक है।'), why: _t('Sweet and energy-giving; enjoy in modest amounts as it is high in natural sugar.', 'मीठा और ऊर्जा देने वाला; क़ुदरती चीनी ज़्यादा है इसलिए थोड़ी मात्रा में खाइए।'), aliases: ['sapota', 'chiku']),
  CanIEntry(id: 'custard_apple', name: LocalizedText(en: 'Custard Apple', hi: 'शरीफ़ा'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Custard apple is fine in moderation.', 'शरीफ़ा सीमित मात्रा में ठीक है।'), why: _t('Nutritious and energy-rich; keep portions modest due to its sweetness.', 'पौष्टिक और ऊर्जा से भरपूर; मिठास की वजह से मात्रा सीमित रखिए।'), aliases: ['sitaphal', 'sharifa']),
  CanIEntry(id: 'litchi', name: LocalizedText(en: 'Litchi', hi: 'लीची'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Litchi is fine in small amounts.', 'लीची थोड़ी मात्रा में ठीक है।'), why: _t('Refreshing and sweet; eat ripe ones in moderation and not on an empty stomach.', 'ताज़गी भरी और मीठी; पकी हुई सीमित मात्रा में खाइए, ख़ाली पेट नहीं।'), aliases: ['lychee']),
  CanIEntry(id: 'jackfruit', name: LocalizedText(en: 'Jackfruit', hi: 'कटहल'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Ripe jackfruit is fine in moderation.', 'पका कटहल सीमित मात्रा में ठीक है।'), why: _t('Enjoy ripe jackfruit in modest amounts; there is no good reason to fear it in normal quantities.', 'पका कटहल थोड़ी मात्रा में खाइए; आम मात्रा में इससे डरने की कोई ख़ास वजह नहीं है।'), aliases: ['kathal']),
  CanIEntry(id: 'dates', name: LocalizedText(en: 'Dates', hi: 'खजूर'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Dates are a wonderful pregnancy snack.', 'खजूर गर्भावस्था का एक बेहतरीन स्नैक है।'), why: _t('Rich in iron and natural energy, and often suggested later in pregnancy. Enjoy a few a day.', 'इसमें Iron और क़ुदरती ऊर्जा भरपूर है, और गर्भावस्था के बाद के दौर में अक्सर सुझाया जाता है। रोज़ कुछ खाइए।'), aliases: ['khajoor']),
  CanIEntry(id: 'figs', name: LocalizedText(en: 'Figs', hi: 'अंजीर'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Figs are nutritious and safe.', 'अंजीर पौष्टिक और सुरक्षित है।'), why: _t('Good for fibre, calcium and iron, and helpful for digestion. Fresh or soaked dried figs both work.', 'fibre, Calcium और Iron के लिए अच्छा, और पाचन में मददगार। ताज़ा या भिगोया हुआ सूखा अंजीर, दोनों चलेंगे।'), aliases: ['anjeer']),
  CanIEntry(id: 'berries', name: LocalizedText(en: 'Berries', hi: 'बेरी'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Strawberries and berries are a healthy choice.', 'स्ट्रॉबेरी और बेरी एक सेहतमंद विकल्प हैं।'), why: _t('Rich in vitamin C and antioxidants; wash thoroughly before eating.', 'इनमें Vitamin C और antioxidants भरपूर हैं; खाने से पहले अच्छी तरह धोइए।'), aliases: ['strawberry', 'blueberry']),
  CanIEntry(id: 'kiwi', name: LocalizedText(en: 'Kiwi', hi: 'कीवी'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Kiwi is a safe, vitamin-rich fruit.', 'कीवी एक सुरक्षित फल है, विटामिन से भरपूर।'), why: _t('High in vitamin C and fibre, and gentle on digestion.', 'इसमें Vitamin C और fibre ज़्यादा हैं, और यह पाचन पर नरम है।'), aliases: ['kiwi']),
  CanIEntry(id: 'pear', name: LocalizedText(en: 'Pear', hi: 'नाशपाती'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Pears are a safe, gentle fruit.', 'नाशपाती एक सुरक्षित, सौम्य फल है।'), why: _t('Good fibre and hydration, and easy on the stomach. Wash well.', 'अच्छा fibre और पानी, और पेट पर आसान। अच्छी तरह धोइए।'), aliases: ['nashpati']),
  CanIEntry(id: 'dry_fruits', name: LocalizedText(en: 'Dry Fruits & Nuts', hi: 'सूखे मेवे'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Dried fruits and nuts are a great snack.', 'सूखे मेवे और नट्स एक बढ़िया स्नैक हैं।'), why: _t('Nutrient-dense energy with iron and good fats; keep portions sensible.', 'Iron और अच्छे fats के साथ पोषण से भरी ऊर्जा; मात्रा समझदारी से रखिए।'), aliases: ['mewa', 'dry fruits', 'सूखे मेवे']),
  CanIEntry(id: 'almonds', name: LocalizedText(en: 'Almonds', hi: 'बादाम'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Almonds are a healthy daily snack.', 'बादाम रोज़ का एक सेहतमंद स्नैक है।'), why: _t('Good fats, protein and vitamin E; a handful a day is lovely. Soaked almonds are easy to digest.', 'अच्छे fats, protein और Vitamin E; दिन में एक मुट्ठी बढ़िया है। भीगे बादाम आसानी से पच जाते हैं।'), aliases: ['badam']),
  CanIEntry(id: 'walnuts', name: LocalizedText(en: 'Walnuts', hi: 'अख़रोट'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Walnuts are nourishing in pregnancy.', 'गर्भावस्था में अख़रोट पोषण देता है।'), why: _t('A good source of omega-3 fats that support development; a few a day is plenty.', 'Omega-3 fats का अच्छा स्रोत, जो शिशु के विकास में मदद करते हैं; दिन में कुछ ही काफ़ी हैं।'), aliases: ['akhrot']),
  CanIEntry(id: 'cashews', name: LocalizedText(en: 'Cashews', hi: 'काजू'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Cashews are fine in moderation.', 'काजू सीमित मात्रा में ठीक हैं।'), why: _t('Tasty and nutritious; keep to a small handful as they are calorie-rich.', 'स्वादिष्ट और पौष्टिक; कैलोरी ज़्यादा है इसलिए एक छोटी मुट्ठी तक रखिए।'), aliases: ['kaju']),
  CanIEntry(id: 'peanuts', name: LocalizedText(en: 'Peanuts', hi: 'मूँगफली'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Peanuts are safe unless you are allergic.', 'मूँगफली सुरक्षित है, बशर्ते आपको allergy न हो।'), why: _t('A good plant protein; avoid only if you have a known peanut allergy.', 'एक अच्छा वनस्पति protein; सिर्फ़ तभी बचिए जब आपको मूँगफली से allergy होना पता हो।'), aliases: ['moongphali', 'groundnut']),
  CanIEntry(id: 'makhana', name: LocalizedText(en: 'Makhana', hi: 'मखाना'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Makhana (fox nuts) is a great light snack.', 'मखाना एक बढ़िया हल्का स्नैक है।'), why: _t('Low in fat and good for a roasted, guilt-free nibble.', 'इसमें fat कम है — भुना हुआ मखाना बिना किसी झिझक के खाया जा सकता है।'), aliases: ['fox nuts', 'lotus seeds', 'मखाना', 'कमलगट्टा']),
  CanIEntry(id: 'sabudana', name: LocalizedText(en: 'Sabudana', hi: 'साबूदाना'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Sabudana is safe and easy to digest.', 'साबूदाना सुरक्षित है और आसानी से पच जाता है।'), why: _t('A gentle source of energy, popular during fasts; cook it well.', 'ऊर्जा का एक सौम्य स्रोत, व्रत में ख़ूब चलता है; अच्छी तरह पकाइए।'), aliases: ['tapioca', 'sago']),
  CanIEntry(id: 'spinach', name: LocalizedText(en: 'Spinach & Greens', hi: 'पालक और हरी सब्ज़ियाँ'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Spinach and leafy greens are excellent.', 'पालक और हरी पत्तेदार सब्ज़ियाँ बहुत बढ़िया हैं।'), why: _t('Rich in iron and folate; wash very well and cook it. Great for pregnancy.', 'इनमें Iron और Folate भरपूर हैं; बहुत अच्छी तरह धोकर पकाइए। गर्भावस्था के लिए बढ़िया।'), aliases: ['palak', 'greens', 'saag']),
  CanIEntry(id: 'drumstick', name: LocalizedText(en: 'Drumstick (Moringa)', hi: 'सहजन (मोरिंगा)'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Drumstick is fine cooked in moderation.', 'सहजन पका हुआ, सीमित मात्रा में ठीक है।'), why: _t('Nutritious in cooked dishes like sambar; enjoy in normal food amounts.', 'सांभर जैसे पके व्यंजनों में पौष्टिक; आम खाने की मात्रा में खाइए।'), aliases: ['moringa', 'sahjan']),
  CanIEntry(id: 'brinjal', name: LocalizedText(en: 'Brinjal', hi: 'बैंगन'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Brinjal is safe, cooked well.', 'बैंगन अच्छी तरह पका हुआ सुरक्षित है।'), why: _t('A normal vegetable; cook it properly. There is no need to avoid it.', 'एक सामान्य सब्ज़ी; ठीक से पकाइए। इससे बचने की कोई ज़रूरत नहीं।'), aliases: ['baingan', 'eggplant']),
  CanIEntry(id: 'potato', name: LocalizedText(en: 'Potato', hi: 'आलू'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Potato is safe in pregnancy.', 'गर्भावस्था में आलू सुरक्षित है।'), why: _t('A staple carbohydrate; just balance it with vegetables and protein.', 'रोज़ का एक carbohydrate; बस इसे सब्ज़ियों और protein के साथ संतुलित रखिए।'), aliases: ['aloo']),
  CanIEntry(id: 'tomato', name: LocalizedText(en: 'Tomato', hi: 'टमाटर'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Tomatoes are safe and healthy.', 'टमाटर सुरक्षित और सेहतमंद है।'), why: _t('Rich in vitamins; wash well. Fine raw in salads made at home, or cooked.', 'विटामिन से भरपूर; अच्छी तरह धोइए। घर पर बने सलाद में कच्चा या पका, दोनों ठीक हैं।'), aliases: ['tamatar']),
  CanIEntry(id: 'carrot', name: LocalizedText(en: 'Carrot', hi: 'गाजर'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Carrots are a healthy, safe vegetable.', 'गाजर एक सेहतमंद, सुरक्षित सब्ज़ी है।'), why: _t('Good for vitamin A and fibre; wash and peel before eating raw.', 'Vitamin A और fibre के लिए अच्छी; कच्ची खाने से पहले धोकर छील लीजिए।'), aliases: ['gajar']),
  CanIEntry(id: 'beetroot', name: LocalizedText(en: 'Beetroot', hi: 'चुकंदर'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Beetroot is safe and nourishing.', 'चुकंदर सुरक्षित और पोषक है।'), why: _t('Supports iron levels and adds natural colour; wash well.', 'Iron के स्तर में मदद करता है और क़ुदरती रंग देता है; अच्छी तरह धोइए।'), aliases: ['chukandar']),
  CanIEntry(id: 'sprouts', name: LocalizedText(en: 'Sprouts', hi: 'अंकुरित अनाज'), category: CanICategory.eat, verdict: CanIVerdict.depends, short: _t('Sprouts are best eaten cooked, not raw.', 'अंकुरित अनाज पकाकर खाना बेहतर है, कच्चा नहीं।'), why: _t('Raw sprouts can carry bacteria; lightly steaming or cooking them makes them much safer.', 'कच्चे अंकुरित अनाज में bacteria हो सकते हैं; हल्की भाप देना या पकाना इन्हें कहीं ज़्यादा सुरक्षित बना देता है।'), aliases: ['moong sprouts', 'sprout', 'अंकुरित मूंग']),
  CanIEntry(id: 'raw_salad', name: LocalizedText(en: 'Raw Salad', hi: 'कच्चा सलाद'), category: CanICategory.eat, verdict: CanIVerdict.depends, short: _t('Salads are healthy if washed very well.', 'सलाद बहुत अच्छी तरह धुला हो तो सेहतमंद है।'), why: _t('Raw vegetables are good, but wash them thoroughly with clean water; outside salads are the main risk.', 'कच्ची सब्ज़ियाँ अच्छी हैं, पर उन्हें साफ़ पानी से अच्छी तरह धोइए; असली ख़तरा बाहर के सलाद से है।'), aliases: ['salad', 'raw vegetables', 'कच्ची सब्ज़ियाँ']),
  CanIEntry(id: 'mushroom', name: LocalizedText(en: 'Mushroom', hi: 'मशरूम'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Cooked mushrooms are safe.', 'पके मशरूम सुरक्षित हैं।'), why: _t('Common edible mushrooms are fine when cooked well; avoid wild or unfamiliar ones.', 'आम खाने वाले मशरूम अच्छी तरह पके हों तो ठीक हैं; जंगली या अनजाने मशरूम मत खाइए।'), aliases: ['mushroom']),
  CanIEntry(id: 'egg', name: LocalizedText(en: 'Egg', hi: 'अंडा'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Well-cooked eggs are a great protein.', 'अच्छी तरह पका अंडा protein का बढ़िया स्रोत है।'), why: _t('Cook until both white and yolk are firm; avoid runny or raw eggs.', 'सफ़ेदी और ज़र्दी दोनों जमने तक पकाइए; बहता हुआ या कच्चा अंडा मत खाइए।'), aliases: ['anda', 'eggs']),
  CanIEntry(id: 'chicken', name: LocalizedText(en: 'Chicken', hi: 'चिकन'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Well-cooked chicken is safe and nourishing.', 'अच्छी तरह पका चिकन सुरक्षित और पोषक है।'), why: _t('A good protein; cook it thoroughly until no pink remains.', 'एक अच्छा protein; इतना पकाइए कि कहीं गुलाबी न बचे।'), aliases: ['murga', 'chicken']),
  CanIEntry(id: 'mutton', name: LocalizedText(en: 'Mutton', hi: 'मटन'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Well-cooked mutton is fine in moderation.', 'अच्छी तरह पका मटन सीमित मात्रा में ठीक है।'), why: _t('A good iron source; cook it thoroughly and keep portions reasonable as it is heavy.', 'Iron का अच्छा स्रोत; अच्छी तरह पकाइए और भारी होने की वजह से मात्रा सीमित रखिए।'), aliases: ['red meat', 'mutton', 'लाल मीट']),
  CanIEntry(id: 'fish', name: LocalizedText(en: 'Fish', hi: 'मछली'), category: CanICategory.eat, verdict: CanIVerdict.depends, short: _t('Most cooked fish is healthy; limit high-mercury types.', 'ज़्यादातर पकी मछली सेहतमंद है; जिनमें Mercury ज़्यादा हो उन्हें सीमित रखिए।'), why: _t('Low-mercury fish like rohu are good for development; limit large fish such as king mackerel and shark.', 'रोहू जैसी कम Mercury वाली मछलियाँ शिशु के विकास के लिए अच्छी हैं; king mackerel और शार्क जैसी बड़ी मछलियाँ सीमित रखिए।'), aliases: ['machli']),
  CanIEntry(id: 'prawns', name: LocalizedText(en: 'Prawns', hi: 'झींगा'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Well-cooked prawns are safe.', 'अच्छी तरह पके झींगे सुरक्षित हैं।'), why: _t('Fully cooked prawns and shrimp are fine; avoid raw or undercooked seafood.', 'पूरी तरह पके झींगे ठीक हैं; कच्चा या अधपका seafood मत खाइए।'), aliases: ['shrimp', 'jhinga']),
  CanIEntry(id: 'high_mercury_fish', name: LocalizedText(en: 'High-Mercury Fish', hi: 'ज़्यादा Mercury वाली मछली'), category: CanICategory.eat, verdict: CanIVerdict.avoid, short: _t('Large high-mercury fish are best avoided.', 'ज़्यादा Mercury वाली बड़ी मछलियों से बचना बेहतर है।'), why: _t('Shark, swordfish and king mackerel can be high in mercury; choose smaller fish instead.', 'शार्क, swordfish और king mackerel में Mercury ज़्यादा हो सकता है; इनकी जगह छोटी मछलियाँ चुनिए।'), aliases: ['mercury fish', 'shark', 'swordfish', 'Mercury वाली मछली']),
  CanIEntry(id: 'dal', name: LocalizedText(en: 'Dal & Lentils', hi: 'दाल'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Dal and lentils are excellent in pregnancy.', 'गर्भावस्था में दाल बहुत बढ़िया है।'), why: _t('A staple plant protein with fibre and iron; eat freely.', 'fibre और Iron के साथ रोज़ का वनस्पति protein; बेझिझक खाइए।'), aliases: ['lentils', 'pulses']),
  CanIEntry(id: 'soya', name: LocalizedText(en: 'Soya', hi: 'सोया'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Soya is fine in moderation.', 'सोया सीमित मात्रा में ठीक है।'), why: _t('A useful protein in tofu, soya chunks or milk; keep to normal food amounts.', 'tofu, सोया चंक्स या सोया दूध में एक काम का protein; आम खाने की मात्रा तक रखिए।'), aliases: ['soy', 'soya chunks', 'सोया बड़ी']),
  CanIEntry(id: 'rajma_chana', name: LocalizedText(en: 'Rajma & Chana', hi: 'राजमा और चना'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Rajma and chana are healthy, protein-rich foods.', 'राजमा और चना सेहतमंद हैं, protein से भरपूर।'), why: _t('Beans and chickpeas give protein, fibre and iron; soak and cook well.', 'राजमा और छोले protein, fibre और Iron देते हैं; भिगोकर अच्छी तरह पकाइए।'), aliases: ['kidney beans', 'chickpeas', 'chole', 'राजमा']),
  CanIEntry(id: 'milk', name: LocalizedText(en: 'Milk', hi: 'दूध'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Pasteurised milk is great in pregnancy.', 'गर्भावस्था में pasteurised दूध बढ़िया है।'), why: _t('A good source of calcium and protein; choose pasteurised or boiled milk.', 'Calcium और protein का अच्छा स्रोत; pasteurised या उबला हुआ दूध चुनिए।'), aliases: ['doodh']),
  CanIEntry(id: 'cheese', name: LocalizedText(en: 'Cheese', hi: 'चीज़'), category: CanICategory.eat, verdict: CanIVerdict.depends, short: _t('Hard and pasteurised cheeses are fine; avoid soft unpasteurised ones.', 'सख़्त और pasteurised चीज़ ठीक हैं; बिना pasteurise किया soft cheese मत खाइए।'), why: _t('Cheddar and processed cheese are safe; avoid mould-ripened or unpasteurised soft cheeses.', 'Cheddar और processed cheese सुरक्षित हैं; फफूँद से पकाए गए या बिना pasteurise किए soft cheese मत खाइए।'), aliases: ['cheese']),
  CanIEntry(id: 'ghee', name: LocalizedText(en: 'Ghee & Butter', hi: 'घी और मक्खन'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Ghee and butter are fine in moderate amounts.', 'घी और मक्खन सीमित मात्रा में ठीक हैं।'), why: _t('Normal food fats that are fine in cooking; just keep the quantity sensible.', 'खाना पकाने में इस्तेमाल होने वाले आम fats, जो ठीक हैं; बस मात्रा समझदारी से रखिए।'), aliases: ['ghee', 'makkhan', 'butter']),
  CanIEntry(id: 'mawa_sweets', name: LocalizedText(en: 'Mithai (Mawa Sweets)', hi: 'मिठाई (मावा वाली)'), category: CanICategory.eat, verdict: CanIVerdict.depends, short: _t('Enjoy mithai from pasteurised mawa, in moderation.', 'pasteurised मावे की मिठाई सीमित मात्रा में खाइए।'), why: _t('Khoya sweets are fine occasionally if fresh and hygienic; the concern is adulteration, freshness and sugar.', 'खोये की मिठाई ताज़ा और साफ़ हो तो कभी-कभार ठीक है; चिंता मिलावट, ताज़गी और चीनी की है।'), aliases: ['mithai', 'khoya', 'barfi', 'sweets']),
  CanIEntry(id: 'oats', name: LocalizedText(en: 'Oats', hi: 'ओट्स'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Oats are a wonderful pregnancy breakfast.', 'ओट्स गर्भावस्था का एक बेहतरीन नाश्ता है।'), why: _t('High in fibre, they help digestion and keep you full; pair with milk and fruit.', 'इसमें fibre ज़्यादा है, यह पाचन में मदद करता है और पेट भरा रखता है; दूध और फल के साथ लीजिए।'), aliases: ['oats', 'oatmeal']),
  CanIEntry(id: 'poha', name: LocalizedText(en: 'Poha', hi: 'पोहा'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Poha is a light, safe meal.', 'पोहा एक हल्का, सुरक्षित खाना है।'), why: _t('Easy to digest and can be made iron-rich; a gentle everyday option.', 'आसानी से पचता है और इसे Iron से भरपूर बनाया जा सकता है; रोज़ का एक सौम्य विकल्प।'), aliases: ['poha']),
  CanIEntry(id: 'instant_noodles', name: LocalizedText(en: 'Instant Noodles', hi: 'इंस्टेंट नूडल्स'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Instant noodles are fine as an occasional treat.', 'इंस्टेंट नूडल्स कभी-कभार की ख़ुशी के तौर पर ठीक हैं।'), why: _t('Low in nutrition and high in salt; enjoy once in a while, ideally with added veg and egg.', 'पोषण कम और नमक ज़्यादा; कभी-कभार खाइए, हो सके तो सब्ज़ी और अंडा डालकर।'), aliases: ['maggi', 'noodles']),
  CanIEntry(id: 'fried_snacks', name: LocalizedText(en: 'Fried Snacks', hi: 'तले हुए स्नैक्स'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Samosa, pakora and the like are fine occasionally.', 'समोसा, पकौड़ा वग़ैरह कभी-कभार ठीक हैं।'), why: _t('Tasty but oily; enjoy now and then, ideally freshly made and hygienic.', 'स्वादिष्ट पर तैलीय; कभी-कभी खाइए, हो सके तो ताज़ा बना और साफ़-सुथरा।'), aliases: ['samosa', 'pakora', 'kachori', 'fried']),
  CanIEntry(id: 'maida', name: LocalizedText(en: 'Maida (Refined Flour)', hi: 'मैदा'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Foods made of maida are fine in moderation.', 'मैदे से बनी चीज़ें सीमित मात्रा में ठीक हैं।'), why: _t('Refined flour has little fibre; balance it with whole grains and vegetables.', 'मैदे में fibre कम होता है; इसे साबुत अनाज और सब्ज़ियों से संतुलित कीजिए।'), aliases: ['refined flour', 'white flour', 'मैदा', 'सफ़ेद आटा']),
  CanIEntry(id: 'pickle', name: LocalizedText(en: 'Pickle (Achar)', hi: 'अचार'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Pickle is fine in small amounts.', 'अचार थोड़ी मात्रा में ठीक है।'), why: _t('It adds flavour but is very high in salt and oil; a little is okay.', 'यह स्वाद देता है पर इसमें नमक और तेल बहुत ज़्यादा होता है; थोड़ा सा ठीक है।'), aliases: ['achar']),
  CanIEntry(id: 'saffron', name: LocalizedText(en: 'Saffron (Kesar)', hi: 'केसर'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('A few strands of saffron are fine.', 'केसर के कुछ रेशे ठीक हैं।'), why: _t('Saffron in milk in tiny culinary amounts is fine; there is no need for large quantities.', 'दूध में खाने भर की थोड़ी सी केसर ठीक है; ज़्यादा मात्रा की कोई ज़रूरत नहीं।'), aliases: ['kesar', 'saffron']),
  CanIEntry(id: 'turmeric_milk', name: LocalizedText(en: 'Turmeric / Haldi Doodh', hi: 'हल्दी / हल्दी वाला दूध'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Haldi doodh in normal amounts is comforting and safe.', 'आम मात्रा में हल्दी वाला दूध सुकून देता है और सुरक्षित है।'), why: _t('Turmeric in cooking and a cup of haldi milk is fine; avoid very large supplement doses.', 'खाने में हल्दी और एक कप हल्दी वाला दूध ठीक है; सप्लीमेंट की बहुत बड़ी ख़ुराक मत लीजिए।'), aliases: ['haldi', 'turmeric', 'golden milk', 'हल्दी वाला दूध']),
  CanIEntry(id: 'jaggery', name: LocalizedText(en: 'Jaggery (Gud)', hi: 'गुड़'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Jaggery is a fine natural sweetener in moderation.', 'गुड़ सीमित मात्रा में एक अच्छा क़ुदरती मीठा है।'), why: _t('Often preferred over white sugar and may support iron; still a sugar, so keep it moderate.', 'सफ़ेद चीनी से बेहतर माना जाता है और Iron में मदद कर सकता है; फिर भी है तो चीनी ही, इसलिए मात्रा सीमित रखिए।'), aliases: ['gud', 'gur']),
  CanIEntry(id: 'spices', name: LocalizedText(en: 'Spices & Herbs', hi: 'मसाले और जड़ी-बूटियाँ'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Everyday cooking spices and herbs are safe.', 'रोज़ के मसाले और जड़ी-बूटियाँ सुरक्षित हैं।'), why: _t('Normal culinary amounts of jeera, dhania, ajwain, hing and garlic are fine; only avoid very large medicinal doses.', 'जीरा, धनिया, अजवाइन, हींग और लहसुन खाने भर की आम मात्रा में ठीक हैं; सिर्फ़ दवा जैसी बहुत बड़ी ख़ुराक से बचिए।'), aliases: ['jeera', 'cumin', 'ajwain', 'hing', 'garlic', 'dhania', 'masala']),
  CanIEntry(id: 'salt', name: LocalizedText(en: 'Salt', hi: 'नमक'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Use normal amounts of salt; avoid excess.', 'नमक आम मात्रा में लीजिए; ज़्यादा मत कीजिए।'), why: _t('Some salt is needed, but high salt can worsen swelling and blood pressure; use iodised salt.', 'थोड़ा नमक ज़रूरी है, पर ज़्यादा नमक सूजन और blood pressure बढ़ा सकता है; iodised नमक इस्तेमाल कीजिए।'), aliases: ['namak', 'sodium']),
  CanIEntry(id: 'sugar', name: LocalizedText(en: 'Sugar', hi: 'चीनी'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Sugar is fine in moderation.', 'चीनी सीमित मात्रा में ठीक है।'), why: _t('Enjoy sweet things in modest amounts; too much adds empty calories and affects blood sugar.', 'मीठा थोड़ी मात्रा में खाइए; ज़्यादा होने पर सिर्फ़ ख़ाली कैलोरी बढ़ती है और blood sugar पर असर पड़ता है।'), aliases: ['cheeni', 'sugar']),
  CanIEntry(id: 'sushi', name: LocalizedText(en: 'Sushi (Raw Fish)', hi: 'सुशी (कच्ची मछली)'), category: CanICategory.eat, verdict: CanIVerdict.avoid, short: _t('Raw-fish sushi is best avoided.', 'कच्ची मछली वाली sushi से बचना बेहतर है।'), why: _t('Raw seafood can carry bacteria and parasites; cooked or vegetarian sushi is a safer choice.', 'कच्चे seafood में bacteria और परजीवी हो सकते हैं; पकी या शाकाहारी sushi ज़्यादा सुरक्षित विकल्प है।'), aliases: ['raw fish', 'sushi', 'कच्ची मछली']),
  CanIEntry(id: 'raw_meat', name: LocalizedText(en: 'Raw / Undercooked Meat', hi: 'कच्चा / अधपका माँस'), category: CanICategory.eat, verdict: CanIVerdict.avoid, short: _t('Raw or undercooked meat should be avoided.', 'कच्चा या अधपका माँस नहीं खाना चाहिए।'), why: _t('It can carry infections like toxoplasma; always cook meat thoroughly.', 'इसमें toxoplasma जैसे संक्रमण हो सकते हैं; माँस हमेशा अच्छी तरह पकाइए।'), aliases: ['undercooked meat', 'rare meat', 'अधपका माँस', 'कम पका माँस']),
  CanIEntry(id: 'deli_meat', name: LocalizedText(en: 'Cold Cuts / Deli Meat', hi: 'ठंडा कटा माँस / Deli meat'), category: CanICategory.eat, verdict: CanIVerdict.depends, short: _t('Heat cold cuts until steaming before eating.', 'cold cuts खाने से पहले भाप निकलने तक गरम कीजिए।'), why: _t('Ready-to-eat cold meats can carry listeria; heating them through makes them safer.', 'सीधे खाने वाले ठंडे माँस में listeria हो सकता है; अच्छी तरह गरम करने से यह ज़्यादा सुरक्षित हो जाता है।'), aliases: ['cold cuts', 'salami', 'ham', 'ठंडा कटा माँस']),
  CanIEntry(id: 'leftovers', name: LocalizedText(en: 'Leftover Food', hi: 'बचा हुआ खाना'), category: CanICategory.eat, verdict: CanIVerdict.depends, short: _t('Leftovers are fine if stored and reheated properly.', 'बचा हुआ खाना ठीक से रखा और गरम किया जाए तो ठीक है।'), why: _t('Refrigerate promptly and reheat until piping hot; avoid food that has been left out for long.', 'तुरंत फ़्रिज में रखिए और एकदम गरम होने तक दोबारा गरम कीजिए; देर तक बाहर रखा खाना मत खाइए।'), aliases: ['leftovers', 'stale food', 'बासी खाना']),
  CanIEntry(id: 'spicy_food', name: LocalizedText(en: 'Spicy Food', hi: 'तीखा खाना'), category: CanICategory.eat, verdict: CanIVerdict.safe, short: _t('Spicy food is fine if it agrees with you.', 'तीखा खाना आपको सूट करता हो तो ठीक है।'), why: _t('It will not harm the baby; it may worsen heartburn for some, so adjust to your comfort.', 'यह शिशु को नुक़सान नहीं पहुँचाएगा; कुछ लोगों की सीने की जलन बढ़ सकती है, इसलिए अपनी सुविधा से तय कीजिए।'), aliases: ['spicy', 'teekha']),
  CanIEntry(id: 'chyawanprash', name: LocalizedText(en: 'Chyawanprash', hi: 'च्यवनप्राश'), category: CanICategory.eat, verdict: CanIVerdict.moderation, short: _t('Chyawanprash is generally fine in small daily amounts.', 'च्यवनप्राश रोज़ थोड़ी मात्रा में आम तौर पर ठीक है।'), why: _t('A traditional tonic that is usually okay; check with your doctor if unsure about the ingredients.', 'एक पारंपरिक टॉनिक जो आम तौर पर ठीक रहता है; सामग्री को लेकर शक हो तो डॉक्टर से पूछ लीजिए।'), aliases: ['chyawanprash']),

  // ---- DRINK ----
  CanIEntry(id: 'milkshake', name: LocalizedText(en: 'Milkshake', hi: 'मिल्कशेक'), category: CanICategory.drink, verdict: CanIVerdict.moderation, short: _t('Homemade milkshakes are a nice, safe treat.', 'घर के बने मिल्कशेक एक अच्छी, सुरक्षित ख़ुशी हैं।'), why: _t('Made with pasteurised milk and fruit they are nourishing; go easy on added sugar.', 'pasteurised दूध और फल से बने हों तो पोषक हैं; ऊपर से चीनी कम रखिए।'), aliases: ['shake', 'milkshake']),
  CanIEntry(id: 'fresh_juice', name: LocalizedText(en: 'Fresh Juice', hi: 'ताज़ा जूस'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Freshly made juice at home is fine.', 'घर पर ताज़ा बना जूस ठीक है।'), why: _t('Drink it fresh and hygienically made; whole fruit is even better for the fibre.', 'ताज़ा और साफ़-सुथरा बना हुआ पीजिए; fibre के लिए साबुत फल और भी बेहतर है।'), aliases: ['juice', 'fresh juice', 'ताज़ा जूस']),
  CanIEntry(id: 'packaged_juice', name: LocalizedText(en: 'Packaged Juice', hi: 'पैकेट वाला जूस'), category: CanICategory.drink, verdict: CanIVerdict.moderation, short: _t('Packaged juices are okay occasionally.', 'पैकेट वाले जूस कभी-कभार ठीक हैं।'), why: _t('They are high in sugar and low in fibre; fresh fruit or fresh juice is better.', 'इनमें चीनी ज़्यादा और fibre कम होता है; ताज़ा फल या ताज़ा जूस बेहतर है।'), aliases: ['tetra pack juice', 'packaged juice', 'टेट्रा पैक जूस', 'पैकेट वाला जूस']),
  CanIEntry(id: 'lemon_water', name: LocalizedText(en: 'Lemon Water', hi: 'नींबू पानी'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Lemon water is safe and refreshing.', 'नींबू पानी सुरक्षित है और ताज़गी देता है।'), why: _t('Hydrating and can ease nausea; a lovely everyday drink.', 'शरीर में पानी बनाए रखता है और मतली कम कर सकता है; रोज़ का एक प्यारा पेय।'), aliases: ['nimbu pani', 'shikanji', 'नींबू पानी']),
  CanIEntry(id: 'sugarcane_juice', name: LocalizedText(en: 'Sugarcane Juice', hi: 'गन्ने का रस'), category: CanICategory.drink, verdict: CanIVerdict.depends, short: _t('Sugarcane juice is fine if hygienic and fresh.', 'गन्ने का रस साफ़ और ताज़ा हो तो ठीक है।'), why: _t('Refreshing and energy-giving; the concern is roadside hygiene, so prefer clean, fresh sources.', 'ताज़गी और ऊर्जा देता है; चिंता सड़क किनारे की सफ़ाई की है, इसलिए साफ़, ताज़ा जगह से लीजिए।'), aliases: ['ganne ka ras', 'गन्ने का रस']),
  CanIEntry(id: 'lassi', name: LocalizedText(en: 'Lassi', hi: 'लस्सी'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Lassi made from fresh curd is safe and cooling.', 'ताज़े दही की लस्सी सुरक्षित है और ठंडक देती है।'), why: _t('A probiotic, calcium-rich drink; sweet or salted, made hygienically.', 'Probiotics और Calcium से भरपूर पेय; मीठी हो या नमकीन, बस साफ़-सफ़ाई से बनी हो।'), aliases: ['lassi']),
  CanIEntry(id: 'energy_drinks', name: LocalizedText(en: 'Energy Drinks', hi: 'एनर्जी ड्रिंक'), category: CanICategory.drink, verdict: CanIVerdict.avoid, short: _t('Energy drinks are best avoided.', 'एनर्जी ड्रिंक से बचना बेहतर है।'), why: _t('They are high in caffeine and stimulants that are not recommended in pregnancy.', 'इनमें caffeine और उत्तेजक तत्व ज़्यादा होते हैं, जो गर्भावस्था में सुझाए नहीं जाते।'), aliases: ['red bull', 'energy drink', 'Red Bull', 'एनर्जी ड्रिंक']),
  CanIEntry(id: 'herbal_tea', name: LocalizedText(en: 'Herbal Tea', hi: 'हर्बल चाय'), category: CanICategory.drink, verdict: CanIVerdict.depends, short: _t('Check each herbal tea before drinking.', 'कोई भी herbal चाय पीने से पहले जाँच लीजिए।'), why: _t('Some herbs are not advised in pregnancy; ginger and mild ones are usually fine, but confirm the blend.', 'कुछ जड़ी-बूटियाँ गर्भावस्था में नहीं सुझाई जातीं; अदरक और हल्की चीज़ें आम तौर पर ठीक हैं, पर मिश्रण ज़रूर देख लीजिए।'), aliases: ['herbal tea', 'tulsi tea', 'हर्बल चाय', 'तुलसी की चाय']),
  CanIEntry(id: 'smoothie', name: LocalizedText(en: 'Smoothie', hi: 'स्मूदी'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Homemade fruit smoothies are nourishing.', 'घर की बनी फलों की स्मूदी पोषक होती है।'), why: _t('A great way to get fruit, curd and nuts; make them fresh and hygienic.', 'फल, दही और मेवे एक साथ लेने का बढ़िया तरीक़ा; ताज़ा और साफ़-सुथरा बनाइए।'), aliases: ['smoothie']),
  CanIEntry(id: 'kombucha', name: LocalizedText(en: 'Kombucha', hi: 'कोम्बुचा'), category: CanICategory.drink, verdict: CanIVerdict.avoid, short: _t('Kombucha is best avoided in pregnancy.', 'गर्भावस्था में Kombucha से बचना बेहतर है।'), why: _t('It is fermented, sometimes unpasteurised and slightly alcoholic, so it is safer to skip.', 'यह किण्वित होता है, कभी-कभी बिना pasteurise किया, और इसमें थोड़ी शराब भी होती है, इसलिए छोड़ देना ज़्यादा सुरक्षित है।'), aliases: ['kombucha']),
  CanIEntry(id: 'diet_soda', name: LocalizedText(en: 'Diet Soda', hi: 'डाइट सोडा'), category: CanICategory.drink, verdict: CanIVerdict.moderation, short: _t('Diet sodas are okay occasionally.', 'डाइट सोडा कभी-कभार ठीक है।'), why: _t('Artificial sweeteners are generally considered fine in small amounts, but these drinks add little value.', 'बनावटी मिठास थोड़ी मात्रा में आम तौर पर ठीक मानी जाती है, पर इन पेयों से फ़ायदा कुछ ख़ास नहीं।'), aliases: ['diet coke', 'zero soda', 'Diet Coke', 'ज़ीरो सोडा']),
  CanIEntry(id: 'aam_panna', name: LocalizedText(en: 'Aam Panna', hi: 'आम पना'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Aam panna is a safe, cooling summer drink.', 'आम पन्ना गर्मियों का एक सुरक्षित, ठंडक देने वाला पेय है।'), why: _t('Hydrating and good for the heat; make it fresh and hygienically.', 'शरीर में पानी बनाए रखता है और गर्मी में अच्छा है; ताज़ा और साफ़-सफ़ाई से बनाइए।'), aliases: ['aam panna', 'आम पना']),
  CanIEntry(id: 'badam_milk', name: LocalizedText(en: 'Badam Milk', hi: 'बादाम वाला दूध'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Badam milk is a nourishing, safe drink.', 'बादाम दूध एक पोषक, सुरक्षित पेय है।'), why: _t('Milk with almonds gives calcium and good fats; lovely warm or cold.', 'बादाम वाला दूध Calcium और अच्छे fats देता है; गरम हो या ठंडा, दोनों बढ़िया।'), aliases: ['almond milk', 'badam milk', 'बादाम का दूध', 'बादाम वाला दूध']),
  CanIEntry(id: 'decaf_coffee', name: LocalizedText(en: 'Decaf Coffee', hi: 'Decaf कॉफ़ी'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Decaf coffee is a good low-caffeine choice.', 'Decaf कॉफ़ी कम caffeine वाला एक अच्छा विकल्प है।'), why: _t('It has very little caffeine, so it is gentle; a nice swap if you miss coffee.', 'इसमें caffeine बहुत कम होता है, इसलिए यह नरम है; कॉफ़ी की याद आए तो एक अच्छा विकल्प।'), aliases: ['decaf']),
  CanIEntry(id: 'jaljeera', name: LocalizedText(en: 'Jaljeera', hi: 'जलजीरा'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('Jaljeera is safe and aids digestion.', 'जलजीरा सुरक्षित है और पाचन में मदद करता है।'), why: _t('A cumin-based drink that can settle the stomach; make it hygienically.', 'जीरे से बना पेय जो पेट को शांत कर सकता है; साफ़-सफ़ाई से बनाइए।'), aliases: ['jaljeera']),
  CanIEntry(id: 'ors', name: LocalizedText(en: 'ORS / Electrolytes', hi: 'ORS / Electrolytes'), category: CanICategory.drink, verdict: CanIVerdict.safe, short: _t('ORS and electrolyte drinks help when you are dehydrated.', 'शरीर में पानी की कमी हो तो ORS और electrolyte वाले पेय मदद करते हैं।'), why: _t('Useful in heat, vomiting or weakness; use standard ORS as directed.', 'गर्मी, उल्टी या कमज़ोरी में काम आते हैं; मानक ORS बताए तरीक़े से लीजिए।'), aliases: ['ors', 'electral', 'glucose water', 'ग्लूकोज़ का पानी']),

  // ---- TAKE (medicines / supplements) ----
  CanIEntry(id: 'aspirin', name: LocalizedText(en: 'Aspirin', hi: 'Aspirin'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Only take aspirin if your doctor prescribes it.', 'Aspirin सिर्फ़ तभी लीजिए जब आपके डॉक्टर लिखें।'), why: _t('Low-dose aspirin is sometimes prescribed in pregnancy, but it should never be self-started.', 'गर्भावस्था में कम ख़ुराक वाली Aspirin कभी-कभी दी जाती है, पर इसे कभी अपने आप शुरू नहीं करना चाहिए।'), aliases: ['aspirin', 'disprin', 'ecosprin']),
  CanIEntry(id: 'cetirizine', name: LocalizedText(en: 'Antihistamines (Cetirizine)', hi: 'Antihistamines (Cetirizine)'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Ask your doctor before taking allergy medicines.', 'allergy की दवा लेने से पहले अपने डॉक्टर से पूछिए।'), why: _t('Some antihistamines are used in pregnancy, but confirm the choice and dose with your doctor.', 'कुछ antihistamines गर्भावस्था में इस्तेमाल होते हैं, पर कौन सा और कितनी ख़ुराक, यह डॉक्टर से पक्का कर लीजिए।'), aliases: ['cetirizine', 'allergy', 'antihistamine', 'avil']),
  CanIEntry(id: 'antacids', name: LocalizedText(en: 'Antacids', hi: 'Antacids'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Most simple antacids are fine for heartburn.', 'सीने की जलन के लिए ज़्यादातर सादे antacids ठीक हैं।'), why: _t('Calcium or magnesium based antacids are commonly used; follow the label, and your doctor if you need them often.', 'Calcium या Magnesium वाले antacids आम तौर पर इस्तेमाल होते हैं; लेबल के हिसाब से लीजिए, और बार-बार ज़रूरत पड़े तो डॉक्टर से पूछिए।'), aliases: ['digene', 'eno', 'gelusil', 'acidity']),
  CanIEntry(id: 'pantoprazole', name: LocalizedText(en: 'Acidity Tablets (Pantoprazole)', hi: 'अम्लता की गोलियाँ (Pantoprazole)'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Acidity tablets like pantoprazole need your doctor okay.', 'Pantoprazole जैसी अम्लता की गोलियों के लिए डॉक्टर की हामी चाहिए।'), why: _t('These are sometimes used in pregnancy; take them on medical advice rather than on your own.', 'ये गर्भावस्था में कभी-कभी इस्तेमाल होती हैं; इन्हें अपने आप लेने के बजाय डॉक्टर की सलाह पर लीजिए।'), aliases: ['pan', 'omeprazole', 'pantoprazole', 'rabeprazole']),
  CanIEntry(id: 'vitamin_c', name: LocalizedText(en: 'Vitamin C', hi: 'Vitamin C'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Vitamin C from food or a prescribed dose is fine.', 'खाने से मिलने वाला Vitamin C या डॉक्टर की लिखी ख़ुराक ठीक है।'), why: _t('Helpful for immunity and iron absorption; avoid very high supplement doses unless advised.', 'रोग-प्रतिरोधक क्षमता और Iron सोखने में मददगार; सलाह न हो तो सप्लीमेंट की बहुत बड़ी ख़ुराक मत लीजिए।'), aliases: ['vitamin c', 'Vitamin C']),
  CanIEntry(id: 'multivitamin', name: LocalizedText(en: 'Prenatal Multivitamin', hi: 'Prenatal Multivitamin'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Prenatal multivitamins are usually recommended.', 'गर्भावस्था के multivitamins आम तौर पर सुझाए जाते हैं।'), why: _t('Take a pregnancy-specific multivitamin as advised; avoid stacking extra high-dose vitamins on top.', 'गर्भावस्था के लिए बना multivitamin सलाह के मुताबिक़ लीजिए; उसके ऊपर से और बड़ी ख़ुराक वाले विटामिन मत जोड़िए।'), aliases: ['multivitamin', 'prenatal vitamin', 'प्रेगनेंसी की विटामिन']),
  CanIEntry(id: 'omega3', name: LocalizedText(en: 'Omega-3 (DHA)', hi: 'Omega-3 (DHA)'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Omega-3 (DHA) supplements are commonly recommended.', 'Omega-3 (DHA) सप्लीमेंट आम तौर पर सुझाए जाते हैं।'), why: _t('They support brain and eye development; take a pregnancy-safe one as advised.', 'ये दिमाग़ और आँखों के विकास में मदद करते हैं; गर्भावस्था के लिए सुरक्षित वाला, सलाह के मुताबिक़ लीजिए।'), aliases: ['dha', 'fish oil', 'omega 3', 'मछली का तेल', 'Omega-3']),
  CanIEntry(id: 'b12', name: LocalizedText(en: 'Vitamin B12', hi: 'Vitamin B12'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Vitamin B12 is fine and often recommended.', 'Vitamin B12 ठीक है और अक्सर सुझाया जाता है।'), why: _t('Important for you and your baby, especially on a vegetarian diet; take it as advised.', 'आपके और आपके शिशु के लिए ज़रूरी, ख़ासकर शाकाहारी खाने पर; सलाह के मुताबिक़ लीजिए।'), aliases: ['b12', 'cobalamin']),
  CanIEntry(id: 'ondansetron', name: LocalizedText(en: 'Anti-Nausea (Ondansetron)', hi: 'मतली की दवा (Ondansetron)'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Anti-nausea medicines should be doctor-prescribed.', 'मतली की दवा डॉक्टर की लिखी हुई होनी चाहिए।'), why: _t('Medicines like ondansetron are used for severe vomiting, but only on medical advice.', 'Ondansetron जैसी दवाएँ तेज़ उल्टी में इस्तेमाल होती हैं, पर सिर्फ़ डॉक्टर की सलाह पर।'), aliases: ['ondansetron', 'emeset', 'vomiting tablet', 'उल्टी की गोली']),
  CanIEntry(id: 'doxylamine', name: LocalizedText(en: 'Morning-Sickness Tablet (Doxylamine)', hi: 'सुबह की मतली की गोली (Doxylamine)'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Doxylamine for morning sickness needs a prescription.', 'सुबह की मतली के लिए Doxylamine डॉक्टर की पर्ची से ही लेनी चाहिए।'), why: _t('A common, doctor-prescribed option for nausea, often with vitamin B6; use as directed.', 'मतली के लिए डॉक्टर की लिखी एक आम दवा, अक्सर Vitamin B6 के साथ; बताए तरीक़े से लीजिए।'), aliases: ['doxinate', 'doxylamine', 'morning sickness tablet', 'मतली की गोली']),
  CanIEntry(id: 'cough_syrup', name: LocalizedText(en: 'Cough Syrup', hi: 'खाँसी का सिरप'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Check with your doctor before any cough syrup.', 'कोई भी खाँसी का सिरप लेने से पहले अपने डॉक्टर से पूछिए।'), why: _t('Some contain ingredients best avoided in pregnancy; your doctor can suggest a safe one.', 'कुछ में ऐसी चीज़ें होती हैं जिनसे गर्भावस्था में बचना बेहतर है; आपके डॉक्टर एक सुरक्षित सिरप बता सकते हैं।'), aliases: ['cough syrup', 'benadryl', 'खाँसी का सिरप']),
  CanIEntry(id: 'lozenges', name: LocalizedText(en: 'Throat Lozenges', hi: 'गले की गोलियाँ'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Plain throat lozenges are generally fine.', 'सादी गले की गोलियाँ आम तौर पर ठीक हैं।'), why: _t('Simple menthol or honey-lemon lozenges are okay for a sore throat; avoid medicated ones without advice.', 'गले में ख़राश के लिए सादी menthol या शहद-नींबू वाली गोलियाँ ठीक हैं; बिना सलाह दवा वाली मत लीजिए।'), aliases: ['throat lozenge', 'strepsils', 'गले की गोली']),
  CanIEntry(id: 'vicks_balm', name: LocalizedText(en: 'Vicks / Balm', hi: 'Vicks / बाम'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Vicks and balms for external use are generally fine.', 'बाहर लगाने वाले Vicks और बाम आम तौर पर ठीक हैं।'), why: _t('Applied on the skin or used for steam they are usually okay; do not swallow them.', 'त्वचा पर लगाने या भाप लेने में आम तौर पर ठीक हैं; इन्हें निगलिए मत।'), aliases: ['vicks', 'balm', 'vaporub', 'zandu balm', 'Zandu Balm']),
  CanIEntry(id: 'laxative', name: LocalizedText(en: 'Laxatives', hi: 'क़ब्ज़ की दवा'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Try diet and fluids first; ask before laxatives.', 'पहले खाने और पानी से कोशिश कीजिए; जुलाब लेने से पहले पूछिए।'), why: _t('Fibre, water and isabgol help constipation; stronger laxatives need medical advice.', 'fibre, पानी और ईसबगोल क़ब्ज़ में मदद करते हैं; तेज़ जुलाब के लिए डॉक्टर की सलाह चाहिए।'), aliases: ['laxative', 'dulcolax', 'cremaffin']),
  CanIEntry(id: 'isabgol', name: LocalizedText(en: 'Isabgol (Psyllium)', hi: 'इसबगोल'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Isabgol is a safe option for constipation.', 'क़ब्ज़ के लिए ईसबगोल एक सुरक्षित विकल्प है।'), why: _t('A gentle fibre that eases constipation; take it with plenty of water.', 'एक सौम्य fibre जो क़ब्ज़ में राहत देता है; इसे ख़ूब पानी के साथ लीजिए।'), aliases: ['psyllium', 'isabgol', 'fibre']),
  CanIEntry(id: 'probiotics', name: LocalizedText(en: 'Probiotics', hi: 'Probiotics'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Probiotics are generally considered safe.', 'Probiotics आम तौर पर सुरक्षित माने जाते हैं।'), why: _t('Curd and probiotic supplements can help digestion; choose a reputable one.', 'दही और probiotic सप्लीमेंट पाचन में मदद कर सकते हैं; भरोसेमंद ब्रांड चुनिए।'), aliases: ['probiotic']),
  CanIEntry(id: 'ashwagandha', name: LocalizedText(en: 'Ashwagandha', hi: 'अश्वगंधा'), category: CanICategory.take, verdict: CanIVerdict.avoid, short: _t('Ashwagandha is best avoided in pregnancy.', 'गर्भावस्था में अश्वगंधा से बचना बेहतर है।'), why: _t('This herb is traditionally not recommended during pregnancy; skip it unless your doctor says otherwise.', 'यह जड़ी-बूटी परंपरागत रूप से गर्भावस्था में नहीं सुझाई जाती; जब तक आपके डॉक्टर न कहें, इसे छोड़ दीजिए।'), aliases: ['ashwagandha']),
  CanIEntry(id: 'ayurvedic_medicine', name: LocalizedText(en: 'Ayurvedic / Herbal Medicine', hi: 'आयुर्वेदिक / जड़ी-बूटी की दवा'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Check any ayurvedic or herbal medicine with your doctor.', 'कोई भी आयुर्वेदिक या जड़ी-बूटी की दवा अपने डॉक्टर से पूछकर लीजिए।'), why: _t('Natural does not always mean safe in pregnancy, and product quality varies; confirm first.', 'क़ुदरती होने का मतलब गर्भावस्था में हमेशा सुरक्षित नहीं होता, और उत्पादों की गुणवत्ता अलग-अलग होती है; पहले पक्का कर लीजिए।'), aliases: ['ayurvedic', 'herbal medicine', 'kadha', 'churan', 'जड़ी-बूटी की दवा']),
  CanIEntry(id: 'homeopathy', name: LocalizedText(en: 'Homeopathy', hi: 'होम्योपैथी'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Discuss homeopathic remedies with your doctor.', 'होम्योपैथी की दवाओं के बारे में अपने डॉक्टर से बात कीजिए।'), why: _t('If you use homeopathy, let your doctor know; do not stop prescribed medicines for it.', 'अगर आप होम्योपैथी लेती हैं तो डॉक्टर को बताइए; इसके लिए लिखी हुई दवाएँ बंद मत कीजिए।'), aliases: ['homeopathy']),
  CanIEntry(id: 'sleeping_pills', name: LocalizedText(en: 'Sleeping Pills', hi: 'नींद की गोलियाँ'), category: CanICategory.take, verdict: CanIVerdict.avoid, short: _t('Avoid sleeping pills unless prescribed.', 'नींद की गोलियाँ डॉक्टर की लिखी हुई न हों तो मत लीजिए।'), why: _t('Most sedatives are not recommended; speak to your doctor about safe ways to sleep better.', 'ज़्यादातर नींद की दवाएँ नहीं सुझाई जातीं; बेहतर नींद के सुरक्षित तरीक़ों के बारे में अपने डॉक्टर से बात कीजिए।'), aliases: ['sleeping pills', 'sedative', 'melatonin', 'नींद की गोलियाँ']),
  CanIEntry(id: 'diclofenac', name: LocalizedText(en: 'Diclofenac / Nimesulide', hi: 'Diclofenac / Nimesulide'), category: CanICategory.take, verdict: CanIVerdict.avoid, short: _t('These painkillers are generally avoided in pregnancy.', 'ये दर्द की दवाएँ गर्भावस्था में आम तौर पर नहीं ली जातीं।'), why: _t('They are anti-inflammatories usually not advised, especially later; paracetamol is preferred.', 'ये anti-inflammatory दवाएँ हैं जो आम तौर पर नहीं सुझाई जातीं, ख़ासकर बाद के दौर में; Paracetamol बेहतर माना जाता है।'), aliases: ['diclofenac', 'voveran', 'nimesulide']),
  CanIEntry(id: 'antifungal_cream', name: LocalizedText(en: 'Antifungal / Antiseptic Cream', hi: 'Antifungal / Antiseptic क्रीम'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Check skin creams like antifungals with your doctor.', 'antifungal जैसी त्वचा की क्रीम अपने डॉक्टर से पूछकर लगाइए।'), why: _t('Many topical creams are used in pregnancy, but confirm the specific one is suitable.', 'कई क्रीम गर्भावस्था में लगाई जाती हैं, पर जो आप लगा रही हैं वह ठीक है या नहीं, यह पक्का कर लीजिए।'), aliases: ['antifungal', 'candid', 'betadine', 'antiseptic']),
  CanIEntry(id: 'deworming', name: LocalizedText(en: 'Deworming Tablet', hi: 'पेट के कीड़ों की गोली'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Deworming should be timed and approved by your doctor.', 'पेट के कीड़ों की दवा कब लेनी है, यह आपके डॉक्टर तय करें और उनकी हामी हो।'), why: _t('Some deworming medicines are delayed in pregnancy; let your doctor decide the timing.', 'कुछ कीड़ों की दवाएँ गर्भावस्था में बाद के लिए टाल दी जाती हैं; समय आपके डॉक्टर तय करें।'), aliases: ['deworming', 'albendazole']),
  CanIEntry(id: 'thyroid_medicine', name: LocalizedText(en: 'Thyroid Medicine', hi: 'Thyroid की दवा'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Continue your thyroid medicine as prescribed.', 'अपनी thyroid की दवा जैसी लिखी है वैसी लेती रहिए।'), why: _t('Thyroid tablets are important and usually continued in pregnancy; your doctor will adjust the dose.', 'Thyroid की गोलियाँ ज़रूरी हैं और गर्भावस्था में आम तौर पर चलती रहती हैं; ख़ुराक आपके डॉक्टर ठीक कर देंगे।'), aliases: ['thyronorm', 'thyroid', 'eltroxin']),
  CanIEntry(id: 'bp_medicine', name: LocalizedText(en: 'Blood Pressure Medicine', hi: 'ब्लड प्रेशर की दवा'), category: CanICategory.take, verdict: CanIVerdict.askDoctor, short: _t('Never stop or change BP medicine on your own.', 'BP की दवा अपने आप कभी बंद मत कीजिए, न बदलिए।'), why: _t('Some BP medicines are switched in pregnancy; your doctor will choose a safe one and adjust it.', 'गर्भावस्था में BP की कुछ दवाएँ बदल दी जाती हैं; आपके डॉक्टर एक सुरक्षित दवा चुनकर उसे ठीक करेंगे।'), aliases: ['blood pressure medicine', 'bp tablet', 'ब्लड प्रेशर की दवा', 'BP की गोली']),
  CanIEntry(id: 'insulin', name: LocalizedText(en: 'Insulin', hi: 'Insulin'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Insulin is safe and often used in pregnancy.', 'Insulin सुरक्षित है और गर्भावस्था में अक्सर इस्तेमाल होता है।'), why: _t('It does not cross to the baby and is the usual treatment when needed; take it as prescribed.', 'यह शिशु तक नहीं पहुँचता और ज़रूरत पड़ने पर यही आम इलाज है; जैसा लिखा हो वैसे लीजिए।'), aliases: ['insulin']),
  CanIEntry(id: 'vaccines', name: LocalizedText(en: 'Vaccines (TT / Flu / COVID)', hi: 'टीके (TT / Flu / COVID)'), category: CanICategory.take, verdict: CanIVerdict.safe, short: _t('Recommended pregnancy vaccines are safe and protective.', 'गर्भावस्था में सुझाए गए टीके सुरक्षित हैं और बचाव करते हैं।'), why: _t('Tetanus (TT/Tdap), flu and COVID vaccination are advised in pregnancy; follow your doctor for timing.', 'गर्भावस्था में Tetanus (TT/Tdap), flu और COVID के टीके सुझाए जाते हैं; समय के लिए अपने डॉक्टर की सुनिए।'), aliases: ['tt', 'tdap', 'tetanus', 'flu shot', 'covid vaccine', 'vaccine', 'COVID का टीका']),

  // ---- DO (activities, beauty, lifestyle) ----
  CanIEntry(id: 'driving', name: LocalizedText(en: 'Driving', hi: 'गाड़ी चलाना'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Driving is fine while you are comfortable.', 'जब तक आप आराम से हैं, गाड़ी चलाना ठीक है।'), why: _t('Safe in an uncomplicated pregnancy; keep the seatbelt low under the bump and take breaks on long drives.', 'सामान्य गर्भावस्था में सुरक्षित है; seatbelt पेट के नीचे से रखिए और लंबी ड्राइव में बीच-बीच में रुकिए।'), aliases: ['driving', 'car']),
  CanIEntry(id: 'cycling', name: LocalizedText(en: 'Cycling', hi: 'साइकिल चलाना'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Gentle cycling is okay early on if you are used to it.', 'अगर आपकी आदत है तो शुरू के महीनों में हल्की साइकिलिंग ठीक है।'), why: _t('Balance changes as the bump grows, so many switch to a stationary bike later. Avoid busy traffic and falls.', 'पेट बढ़ने के साथ संतुलन बदलता है, इसलिए कई माँएँ बाद में स्थिर साइकिल पर चली जाती हैं। भीड़भाड़ वाले ट्रैफ़िक और गिरने से बचिए।'), aliases: ['cycling', 'bicycle']),
  CanIEntry(id: 'running', name: LocalizedText(en: 'Running / Jogging', hi: 'दौड़ना / जॉगिंग'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Light running is okay if you already run; listen to your body.', 'अगर आप पहले से दौड़ती हैं तो हल्की दौड़ ठीक है; अपने शरीर की सुनिए।'), why: _t('Continue gently if you are used to it; stop if you feel pain, dizziness or pressure, and stay hydrated.', 'आदत हो तो धीरे-धीरे जारी रखिए; दर्द, चक्कर या दबाव लगे तो रुक जाइए, और पानी पीती रहिए।'), aliases: ['running', 'jogging', 'jog']),
  CanIEntry(id: 'dancing', name: LocalizedText(en: 'Dancing', hi: 'नाचना'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Gentle dancing is a joyful, safe way to move.', 'हल्का नाचना हिलने-डुलने का एक ख़ुशनुमा, सुरक्षित तरीक़ा है।'), why: _t('Light dancing is great; avoid jumps, spins and falls, especially later on.', 'हल्का नाचना बढ़िया है; कूदने, घूमने और गिरने से बचिए, ख़ासकर बाद के महीनों में।'), aliases: ['dance', 'garba']),
  CanIEntry(id: 'household_chores', name: LocalizedText(en: 'Household Chores', hi: 'घर के काम'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Normal household work is fine; avoid strain.', 'घर का आम काम ठीक है; ज़ोर मत लगाइए।'), why: _t('Everyday chores are good light activity; avoid heavy lifting, strong chemicals and standing on stools.', 'रोज़ के काम हल्की कसरत जैसे अच्छे हैं; भारी सामान उठाने, तेज़ केमिकल और स्टूल पर चढ़ने से बचिए।'), aliases: ['housework', 'chores', 'cleaning']),
  CanIEntry(id: 'climbing_stairs', name: LocalizedText(en: 'Climbing Stairs', hi: 'सीढ़ियाँ चढ़ना'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Climbing stairs is safe; just go steadily.', 'सीढ़ियाँ चढ़ना सुरक्षित है; बस आराम से चढ़िए।'), why: _t('Use the railing and take your time; there is no need to avoid stairs in a normal pregnancy.', 'रेलिंग पकड़िए और जल्दबाज़ी मत कीजिए; सामान्य गर्भावस्था में सीढ़ियों से बचने की कोई ज़रूरत नहीं।'), aliases: ['stairs', 'steps']),
  CanIEntry(id: 'standing_long', name: LocalizedText(en: 'Standing Long Hours', hi: 'लंबे समय खड़े रहना'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Long standing is okay but take regular breaks.', 'देर तक खड़े रहना ठीक है पर बीच-बीच में आराम कीजिए।'), why: _t('Standing for hours can cause swelling and back ache; sit, move and put your feet up when you can.', 'घंटों खड़े रहने से सूजन और कमर दर्द हो सकता है; जब मौक़ा मिले बैठिए, थोड़ा चलिए और पैर ऊपर रखिए।'), aliases: ['standing']),
  CanIEntry(id: 'amusement_rides', name: LocalizedText(en: 'Amusement Rides', hi: 'मेले के झूले'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Skip roller coasters and jerky rides.', 'रोलर कोस्टर और झटके वाली राइड्स छोड़ दीजिए।'), why: _t('Sudden jolts and forces are best avoided; gentle rides without big drops are a safer choice.', 'अचानक लगने वाले झटकों से बचना बेहतर है; बिना बड़ी गिरावट वाली हल्की राइड्स ज़्यादा सुरक्षित विकल्प हैं।'), aliases: ['roller coaster', 'rides', 'रोलर कोस्टर']),
  CanIEntry(id: 'trekking', name: LocalizedText(en: 'Trekking / Hiking', hi: 'ट्रेकिंग / पहाड़ी चढ़ाई'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Easy treks are okay; avoid high altitude and rough trails.', 'आसान ट्रेक ठीक हैं; ज़्यादा ऊँचाई और ऊबड़-खाबड़ रास्तों से बचिए।'), why: _t('Gentle walks in nature are lovely; avoid steep, slippery routes, high altitude and exhaustion.', 'क़ुदरत के बीच हल्की सैर बहुत अच्छी है; खड़ी चढ़ाई, फिसलन भरे रास्ते, ज़्यादा ऊँचाई और थकान से बचिए।'), aliases: ['trekking', 'hiking']),
  CanIEntry(id: 'gym', name: LocalizedText(en: 'Gym Workouts', hi: 'जिम की कसरत'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Continue gentle gym workouts with guidance.', 'किसी की देखरेख में हल्की जिम कसरत जारी रखिए।'), why: _t('Light strength and cardio are fine if you are used to them; avoid heavy weights, lying flat later, and overheating.', 'आदत हो तो हल्की strength और cardio ठीक हैं; भारी वज़न, बाद के महीनों में पीठ के बल लेटने, और ज़्यादा गरम होने से बचिए।'), aliases: ['gym', 'workout', 'exercise']),
  CanIEntry(id: 'keratin', name: LocalizedText(en: 'Keratin / Straightening', hi: 'Keratin / बाल सीधे करना'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Skip keratin and chemical straightening for now.', 'फ़िलहाल keratin और केमिकल स्ट्रेटनिंग छोड़ दीजिए।'), why: _t('These treatments can contain strong chemicals like formaldehyde; many prefer to wait until after pregnancy.', 'इन ट्रीटमेंट में formaldehyde जैसे तेज़ केमिकल हो सकते हैं; कई माँएँ गर्भावस्था के बाद तक रुकना पसंद करती हैं।'), aliases: ['keratin', 'smoothening', 'rebonding']),
  CanIEntry(id: 'facial', name: LocalizedText(en: 'Facial / Clean-up', hi: 'फ़ेशियल / क्लीन-अप'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('A gentle facial is fine; skip strong treatments.', 'हल्का फ़ेशियल ठीक है; तेज़ ट्रीटमेंट छोड़ दीजिए।'), why: _t('Basic facials are relaxing; avoid harsh peels, strong actives and electrical treatments without advice.', 'साधारण फ़ेशियल सुकून देते हैं; बिना सलाह कड़े peel, तेज़ actives और बिजली वाले ट्रीटमेंट से बचिए।'), aliases: ['facial', 'clean up', 'hair spa', 'क्लीन-अप', 'हेयर स्पा']),
  CanIEntry(id: 'chemical_peel', name: LocalizedText(en: 'Chemical Peel', hi: 'केमिकल पील'), category: CanICategory.doActivity, verdict: CanIVerdict.askDoctor, short: _t('Check chemical peels with your doctor or dermatologist.', 'केमिकल peel अपने डॉक्टर या dermatologist से पूछकर कराइए।'), why: _t('Mild peels may be okay, but stronger acids are often postponed; confirm first.', 'हल्के peel ठीक हो सकते हैं, पर तेज़ acids अक्सर बाद के लिए टाल दिए जाते हैं; पहले पक्का कर लीजिए।'), aliases: ['peel', 'chemical peel', 'केमिकल पील']),
  CanIEntry(id: 'botox_fillers', name: LocalizedText(en: 'Botox / Fillers', hi: 'Botox / Fillers'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Botox and fillers are best avoided in pregnancy.', 'गर्भावस्था में Botox और fillers से बचना बेहतर है।'), why: _t('They are elective with limited safety data, so most advise waiting until afterwards.', 'ये ज़रूरी नहीं हैं और इनकी सुरक्षा पर जानकारी कम है, इसलिए ज़्यादातर लोग बाद तक रुकने की सलाह देते हैं।'), aliases: ['botox', 'fillers', 'dermal filler', 'डर्मल फिलर']),
  CanIEntry(id: 'laser_hair', name: LocalizedText(en: 'Laser Hair Removal', hi: 'लेज़र से बाल हटाना'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Many postpone laser hair removal.', 'कई माँएँ laser hair removal टाल देती हैं।'), why: _t('It is not known to be harmful, but skin is more sensitive and it is elective, so waiting is common.', 'यह नुक़सानदेह नहीं माना जाता, पर त्वचा ज़्यादा संवेदनशील रहती है और यह ज़रूरी भी नहीं, इसलिए रुक जाना आम है।'), aliases: ['laser']),
  CanIEntry(id: 'pedicure', name: LocalizedText(en: 'Pedicure / Manicure', hi: 'पेडीक्योर / मैनीक्योर'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('A pedicure or manicure is a lovely, safe treat.', 'पेडिक्योर या मैनिक्योर एक प्यारी, सुरक्षित ख़ुशी है।'), why: _t('Enjoy it; choose a clean salon and a gentle calf massage rather than strong pressure points.', 'ज़रूर कराइए; साफ़ सैलून चुनिए और पिंडलियों की हल्की मालिश कराइए, तेज़ प्रेशर पॉइंट नहीं।'), aliases: ['pedicure', 'manicure']),
  CanIEntry(id: 'makeup', name: LocalizedText(en: 'Makeup', hi: 'मेकअप'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Everyday makeup is fine.', 'रोज़ का मेकअप ठीक है।'), why: _t('Normal cosmetics are safe; remove them before bed and patch-test new products as skin can be sensitive.', 'आम कॉस्मेटिक सुरक्षित हैं; सोने से पहले हटा दीजिए और नई चीज़ पहले थोड़ी सी लगाकर देखिए, क्योंकि त्वचा संवेदनशील हो सकती है।'), aliases: ['makeup', 'cosmetics']),
  CanIEntry(id: 'sunscreen', name: LocalizedText(en: 'Sunscreen', hi: 'सनस्क्रीन'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Sunscreen is safe and a good idea.', 'Sunscreen सुरक्षित है और लगाना अच्छी बात है।'), why: _t('It protects skin that can pigment more easily now; mineral sunscreens are a gentle choice.', 'अभी त्वचा पर आसानी से रंगत आ जाती है, यह उससे बचाता है; mineral sunscreen एक सौम्य विकल्प है।'), aliases: ['sunscreen', 'spf']),
  CanIEntry(id: 'retinol', name: LocalizedText(en: 'Retinol Creams', hi: 'Retinol क्रीम'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Avoid retinol and strong vitamin-A creams.', 'Retinol और तेज़ Vitamin A वाली क्रीम मत लगाइए।'), why: _t('Topical retinoids are usually advised against in pregnancy; switch to gentler skincare.', 'गर्भावस्था में लगाने वाले retinoids आम तौर पर मना किए जाते हैं; नरम skincare पर आ जाइए।'), aliases: ['retinol', 'retinoid', 'anti aging cream', 'एंटी एजिंग क्रीम']),
  CanIEntry(id: 'perfume', name: LocalizedText(en: 'Perfume / Deodorant', hi: 'परफ़्यूम / डियोड्रेंट'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Perfume is fine; strong scents may trigger nausea.', 'परफ़्यूम ठीक है; तेज़ ख़ुशबू से मतली हो सकती है।'), why: _t('It is safe to wear; you may just find heavy fragrances bothersome early on.', 'लगाना सुरक्षित है; बस शुरुआती महीनों में भारी ख़ुशबू परेशान कर सकती है।'), aliases: ['perfume', 'deodorant']),
  CanIEntry(id: 'hair_oil', name: LocalizedText(en: 'Hair Oiling (Champi)', hi: 'बालों में तेल (चंपी)'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Oiling your hair is safe and soothing.', 'बालों में तेल लगाना सुरक्षित है और सुकून देता है।'), why: _t('A traditional, relaxing routine; a gentle champi is perfectly fine.', 'एक पारंपरिक, आराम देने वाली आदत; हल्की चंपी बिलकुल ठीक है।'), aliases: ['champi', 'hair oil', 'बालों का तेल']),
  CanIEntry(id: 'tattoo', name: LocalizedText(en: 'Tattoo / Piercing', hi: 'टैटू / पियर्सिंग'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Many postpone new tattoos and piercings.', 'कई माँएँ नया टैटू और पियर्सिंग टाल देती हैं।'), why: _t('The main concern is infection risk and unknowns; most prefer to wait until after pregnancy.', 'मुख्य चिंता संक्रमण के ख़तरे और अनजानी बातों की है; ज़्यादातर लोग गर्भावस्था के बाद तक रुकना पसंद करते हैं।'), aliases: ['tattoo', 'piercing']),
  CanIEntry(id: 'gel_nails', name: LocalizedText(en: 'Gel / Acrylic Nails', hi: 'जेल / एक्रिलिक नाख़ून'), category: CanICategory.doActivity, verdict: CanIVerdict.moderation, short: _t('Gel or acrylic nails are okay occasionally.', 'जेल या एक्रिलिक नेल्स कभी-कभार ठीक हैं।'), why: _t('Generally low risk; ensure a ventilated salon, and note nails may be checked during labour.', 'ख़तरा आम तौर पर कम है; सैलून हवादार हो, और ध्यान रखिए कि प्रसव के दौरान नाख़ून देखे जा सकते हैं।'), aliases: ['gel nails', 'acrylic', 'जेल नाख़ून']),
  CanIEntry(id: 'smoking', name: LocalizedText(en: 'Smoking', hi: 'धूम्रपान'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Smoking should be avoided completely.', 'धूम्रपान से पूरी तरह बचना चाहिए।'), why: _t('It reduces oxygen and nutrients to your baby; stopping at any point helps. Ask for support if you need it.', 'यह आपके शिशु तक पहुँचने वाली oxygen और पोषण कम कर देता है; किसी भी वक़्त छोड़ना फ़ायदा करता है। मदद चाहिए तो ज़रूर माँगिए।'), aliases: ['smoking', 'cigarette']),
  CanIEntry(id: 'secondhand_smoke', name: LocalizedText(en: 'Secondhand Smoke', hi: 'दूसरों का धुआँ'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Avoid secondhand smoke as much as you can.', 'दूसरों के धुएँ से जितना हो सके बचिए।'), why: _t('Breathing in others smoke is also harmful; ask people not to smoke around you.', 'दूसरों का धुआँ साँस में जाना भी नुक़सानदेह है; लोगों से कहिए कि आपके आसपास धूम्रपान न करें।'), aliases: ['passive smoking', 'secondhand smoke', 'दूसरों का धुआँ', 'सिगरेट का धुआँ']),
  CanIEntry(id: 'vaping', name: LocalizedText(en: 'Vaping', hi: 'वेपिंग'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Vaping and e-cigarettes are best avoided.', 'Vaping और e-cigarettes से बचना बेहतर है।'), why: _t('They still contain nicotine and other substances that are not safe for the baby.', 'इनमें भी nicotine और दूसरी चीज़ें होती हैं जो शिशु के लिए सुरक्षित नहीं हैं।'), aliases: ['vape', 'e cigarette', 'ई-सिगरेट']),
  CanIEntry(id: 'hot_water_bath', name: LocalizedText(en: 'Very Hot Bath', hi: 'बहुत गरम पानी से नहाना'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Warm baths are lovely; very hot water is not advised.', 'गुनगुने पानी से नहाना बहुत अच्छा है; बहुत गरम पानी की सलाह नहीं दी जाती।'), why: _t('Avoid very hot baths that raise your body temperature; keep the water comfortably warm.', 'बहुत गरम पानी से मत नहाइए जो शरीर का तापमान बढ़ा दे; पानी बस आराम भर गुनगुना रखिए।'), aliases: ['hot bath', 'hot water', 'गरम पानी से नहाना', 'गरम पानी']),
  CanIEntry(id: 'ac_use', name: LocalizedText(en: 'Air Conditioning', hi: 'एयर कंडीशनिंग'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Air conditioning is completely fine.', 'एयर कंडीशनिंग बिलकुल ठीक है।'), why: _t('Staying cool and comfortable is good; just avoid sitting directly in a cold draught for long.', 'ठंडा और आरामदेह रहना अच्छा है; बस देर तक सीधे ठंडी हवा के सामने मत बैठिए।'), aliases: ['ac', 'air conditioner', 'एसी']),
  CanIEntry(id: 'incense', name: LocalizedText(en: 'Incense (Agarbatti)', hi: 'अगरबत्ती'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Use agarbatti and dhoop in a ventilated space.', 'अगरबत्ती और धूप हवादार जगह में जलाइए।'), why: _t('Occasional use is fine; avoid breathing heavy smoke in a closed room for long periods.', 'कभी-कभार जलाना ठीक है; बंद कमरे में देर तक गाढ़ा धुआँ साँस में लेने से बचिए।'), aliases: ['agarbatti', 'dhoop', 'incense']),
  CanIEntry(id: 'cleaning_chemicals', name: LocalizedText(en: 'Strong Cleaning Chemicals', hi: 'तेज़ सफ़ाई के रसायन'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Use strong cleaners with care and ventilation.', 'तेज़ सफ़ाई वाले केमिकल संभलकर और हवादार जगह में इस्तेमाल कीजिए।'), why: _t('Wear gloves, open windows and do not mix chemicals; switch to milder products where you can.', 'दस्ताने पहनिए, खिड़कियाँ खोलिए और केमिकल आपस में मत मिलाइए; जहाँ हो सके हल्के उत्पादों पर आ जाइए।'), aliases: ['bleach', 'phenyl', 'cleaning chemicals', 'सफ़ाई के केमिकल']),
  CanIEntry(id: 'paint_fumes', name: LocalizedText(en: 'Paint Fumes', hi: 'पेंट का धुआँ'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Avoid heavy paint fumes; ventilate well.', 'पेंट की तेज़ गंध से बचिए; हवा आने-जाने दीजिए।'), why: _t('Brief exposure is unlikely to harm, but avoid painting projects and strong solvent fumes in closed rooms.', 'थोड़ी देर के लिए सामने आना शायद नुक़सान न करे, पर बंद कमरों में पेंट का काम और तेज़ solvent की गंध से बचिए।'), aliases: ['paint', 'fumes', 'solvent']),
  CanIEntry(id: 'pesticides', name: LocalizedText(en: 'Pesticides / Sprays', hi: 'कीटनाशक / स्प्रे'), category: CanICategory.doActivity, verdict: CanIVerdict.avoid, short: _t('Avoid pesticides and strong sprays.', 'कीटनाशकों और तेज़ स्प्रे से बचिए।'), why: _t('Keep away from spraying and treated areas; choose safer pest control and ventilate well.', 'छिड़काव और छिड़काव की गई जगहों से दूर रहिए; ज़्यादा सुरक्षित pest control चुनिए और हवा आने-जाने दीजिए।'), aliases: ['pesticide', 'spray']),
  CanIEntry(id: 'pet_cats', name: LocalizedText(en: 'Cats / Litter', hi: 'बिल्ली / उसकी गंदगी'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('You can keep your cat; avoid the litter box.', 'आप अपनी बिल्ली रख सकती हैं; बस litter box से दूर रहिए।'), why: _t('The concern is toxoplasma from cat faeces, so let someone else clean the litter and wash your hands well.', 'चिंता बिल्ली की गंदगी से होने वाले toxoplasma की है, इसलिए litter कोई और साफ़ करे और आप हाथ अच्छी तरह धोइए।'), aliases: ['cat', 'kitten', 'litter']),
  CanIEntry(id: 'pet_dogs', name: LocalizedText(en: 'Dogs / Pets', hi: 'कुत्ते / पालतू जानवर'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Keeping dogs and pets is absolutely fine.', 'कुत्ते और दूसरे पालतू जानवर रखना बिलकुल ठीक है।'), why: _t('Pets are wonderful company; just wash your hands and keep their vaccinations and hygiene up to date.', 'पालतू जानवर बहुत अच्छा साथ देते हैं; बस हाथ धोती रहिए और उनके टीके तथा सफ़ाई का ध्यान रखिए।'), aliases: ['dog', 'pet']),
  CanIEntry(id: 'gardening', name: LocalizedText(en: 'Gardening', hi: 'बाग़वानी'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Gardening is fine; wear gloves and wash up.', 'बाग़बानी ठीक है; दस्ताने पहनिए और बाद में हाथ धो लीजिए।'), why: _t('Soil can carry toxoplasma, so wear gloves and wash your hands well afterwards.', 'मिट्टी में toxoplasma हो सकता है, इसलिए दस्ताने पहनिए और बाद में हाथ अच्छी तरह धोइए।'), aliases: ['gardening', 'soil']),
  CanIEntry(id: 'public_transport', name: LocalizedText(en: 'Public Transport', hi: 'सार्वजनिक परिवहन'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Buses, trains and the metro are fine to use.', 'बस, ट्रेन और मेट्रो से चलना ठीक है।'), why: _t('Travel as usual; ask for a seat, hold the supports carefully and avoid the most crowded rush hours if you can.', 'आम दिनों की तरह सफ़र कीजिए; सीट माँग लीजिए, सहारा संभलकर पकड़िए और हो सके तो सबसे ज़्यादा भीड़ वाले समय से बचिए।'), aliases: ['bus', 'metro', 'train', 'public transport', 'पब्लिक ट्रांसपोर्ट']),
  CanIEntry(id: 'crowded_places', name: LocalizedText(en: 'Crowded Places', hi: 'भीड़ भरी जगहें'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Crowded places are okay; protect against infection.', 'भीड़ वाली जगहें ठीक हैं; बस संक्रमण से बचाव कीजिए।'), why: _t('No special harm, but it is wise to keep distance during illness seasons and wash your hands often.', 'कोई ख़ास नुक़सान नहीं, पर बीमारी के मौसम में दूरी रखना और बार-बार हाथ धोना समझदारी है।'), aliases: ['crowd', 'festival', 'mela']),
  CanIEntry(id: 'high_heels', name: LocalizedText(en: 'High Heels', hi: 'ऊँची एड़ी'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Low, stable shoes are safer than high heels.', 'नीची, मज़बूत चप्पल-जूते ऊँची हील से ज़्यादा सुरक्षित हैं।'), why: _t('Balance and posture change in pregnancy; flats or small heels reduce the risk of falls and back ache.', 'गर्भावस्था में संतुलन और शरीर का ढंग बदल जाता है; फ़्लैट या छोटी हील गिरने और कमर दर्द का ख़तरा कम करती हैं।'), aliases: ['heels', 'high heels', 'हाई हील']),
  CanIEntry(id: 'tight_clothes', name: LocalizedText(en: 'Tight Clothes', hi: 'तंग कपड़े'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Choose comfortable, loose clothing.', 'आरामदेह, ढीले कपड़े चुनिए।'), why: _t('Very tight clothing can be uncomfortable and restrict circulation; soft, roomy fits feel better.', 'बहुत कसे कपड़े तकलीफ़ देते हैं और ख़ून के बहाव में रुकावट डाल सकते हैं; नरम, खुले कपड़े ज़्यादा अच्छे लगते हैं।'), aliases: ['tight clothes', 'टाइट कपड़े']),
  CanIEntry(id: 'massage', name: LocalizedText(en: 'Massage', hi: 'मालिश'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Gentle massage is fine; choose a prenatal therapist.', 'हल्की मालिश ठीक है; गर्भावस्था की मालिश जानने वाले से कराइए।'), why: _t('Relaxing for back and legs; avoid strong abdominal pressure and go to someone experienced with pregnancy.', 'कमर और पैरों के लिए आराम देने वाली; पेट पर तेज़ दबाव मत पड़ने दीजिए और किसी ऐसे व्यक्ति के पास जाइए जिसे गर्भावस्था का अनुभव हो।'), aliases: ['massage', 'body massage', 'prenatal massage', 'बॉडी मसाज', 'प्रेगनेंसी मसाज']),
  CanIEntry(id: 'spa', name: LocalizedText(en: 'Spa / Sauna', hi: 'स्पा / Sauna'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Enjoy gentle spa treatments; skip heat therapies.', 'हल्के स्पा ट्रीटमेंट ज़रूर लीजिए; गर्मी वाली थेरेपी छोड़ दीजिए।'), why: _t('Relaxing massages and facials are fine; avoid saunas, steam rooms and hot tubs that overheat you.', 'आराम देने वाली मालिश और फ़ेशियल ठीक हैं; sauna, steam room और hot tub से बचिए जो शरीर को ज़्यादा गरम कर दें।'), aliases: ['spa', 'sauna', 'steam']),
  CanIEntry(id: 'meditation', name: LocalizedText(en: 'Meditation', hi: 'ध्यान'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Meditation is wonderful in pregnancy.', 'गर्भावस्था में ध्यान बहुत अच्छा है।'), why: _t('It eases stress and helps sleep and connection with your baby; practise as often as you like.', 'यह तनाव कम करता है और नींद तथा शिशु से जुड़ाव में मदद करता है; जितनी बार चाहें कीजिए।'), aliases: ['meditation', 'mindfulness', 'pranayam']),
  CanIEntry(id: 'mobile_phone', name: LocalizedText(en: 'Mobile / Microwave', hi: 'मोबाइल / माइक्रोवेव'), category: CanICategory.doActivity, verdict: CanIVerdict.safe, short: _t('Using your phone and microwave is safe.', 'फ़ोन और माइक्रोवेव इस्तेमाल करना सुरक्षित है।'), why: _t('There is no evidence everyday phone use or microwaves harm the baby; just take breaks for your neck and eyes.', 'ऐसा कोई सबूत नहीं कि रोज़ फ़ोन चलाने या माइक्रोवेव से शिशु को नुक़सान होता है; बस गर्दन और आँखों के लिए बीच-बीच में आराम कीजिए।'), aliases: ['mobile', 'phone', 'radiation', 'microwave']),
  CanIEntry(id: 'stress', name: LocalizedText(en: 'Stress', hi: 'तनाव'), category: CanICategory.doActivity, verdict: CanIVerdict.depends, short: _t('Some stress is normal; ongoing stress is worth easing.', 'थोड़ा तनाव सामान्य है; लगातार बना रहने वाला तनाव कम करना ज़रूरी है।'), why: _t('Occasional worry is natural; if you feel constantly anxious, rest, talk to someone and tell your doctor.', 'कभी-कभी चिंता होना क़ुदरती है; अगर आप लगातार बेचैन महसूस करती हैं तो आराम कीजिए, किसी से बात कीजिए और अपने डॉक्टर को बताइए।'), aliases: ['stress', 'anxiety', 'tension']),
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
