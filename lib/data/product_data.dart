// =============================================================================
//  ParentVeda Products ❤️ - seed data (decision-engine prototype)
// -----------------------------------------------------------------------------
//  Pregnancy-stage-aware categories, each with a guidance card and 3 scored
//  ParentVeda Picks (Best Overall / Budget / Premium / etc.) carrying the
//  reasons-to-buy + things-to-consider. Prices and scores are illustrative,
//  pending real expert + parent data. English-first.
// =============================================================================

import '../models/product_models.dart';
import '../localization/app_language.dart';

LocalizedText _t(String en, String hi) => LocalizedText(en: en, hi: hi);

final List<ProductCategory> kProductCategories = [
  ProductCategory(
    id: 'pregnancy_pillow',
    name: _t('Pregnancy Pillow', 'गर्भावस्था का तकिया'),
    emoji: '🛏️',
    guidance: _t('A good pregnancy pillow supports your bump, back and knees at the same time.', 'एक अच्छा गर्भावस्था तकिया आपके पेट, पीठ और घुटनों — तीनों को एक साथ सहारा देता है।'),
    lookFor: [_t('Full-body support', 'पूरे शरीर को सहारा'), _t('Washable cover', 'धोने लायक़ कवर'), _t('Holds its shape over time', 'समय के साथ अपना आकार बनाए रखता है')],
    avoid: [_t('Pillows that flatten quickly', 'जल्दी बैठ जाने वाले तकिए'), _t('Very bulky designs for a small bed', 'छोटे बिस्तर के लिए बहुत भारी-भरकम डिज़ाइन')],
    fromWeek: 16,
    toLabel: _t('Birth', 'जन्म'),
    totalCount: 18,
  ),
  ProductCategory(
    id: 'stretch_care',
    name: _t('Stretch Mark Care', 'Stretch mark की देखभाल'),
    emoji: '🧴',
    guidance: _t('Daily moisturising keeps skin supple as your bump grows - consistency matters more than the brand.', 'पेट बढ़ने के साथ रोज़ moisturiser लगाते रहने से त्वचा मुलायम बनी रहती है — brand से ज़्यादा मायने रखती है नियमितता।'),
    lookFor: [_t('Deeply moisturising', 'गहराई तक नमी देने वाला'), _t('Fragrance-free', 'बिना ख़ुशबू वाला'), _t('Non-sticky finish', 'चिपचिपा नहीं')],
    avoid: [_t('Strong fragrances', 'तेज़ ख़ुशबू'), _t('Retinol-based creams', 'Retinol वाली creams')],
    fromWeek: 12,
    toLabel: _t('Birth', 'जन्म'),
    totalCount: 14,
  ),
  ProductCategory(
    id: 'maternity_wear',
    name: _t('Maternity Wear', 'गर्भावस्था के कपड़े'),
    emoji: '👗',
    guidance: _t('Look for room to grow and soft, breathable fabric you can keep wearing past delivery.', 'ऐसा देखें जिसमें बढ़ने की जगह हो और कपड़ा नरम व साँस लेने वाला हो, जिसे आप प्रसव के बाद भी पहनती रह सकें।'),
    lookFor: [_t('Stretchable over-bump fit', 'पेट के ऊपर तक खिंचने वाला fit'), _t('Breathable cotton', 'साँस लेने वाला सूती'), _t('Nursing-friendly', 'दूध पिलाने में आसान')],
    avoid: [_t('Tight elastic waistbands', 'कसी हुई इलास्टिक कमरबंद'), _t('Synthetic-only fabric', 'सिर्फ़ synthetic कपड़ा')],
    fromWeek: 14,
    toLabel: _t('Birth', 'जन्म'),
    totalCount: 22,
  ),
  ProductCategory(
    id: 'belly_band',
    name: _t('Belly Support Band', 'पेट को सहारा देने वाला बैंड'),
    emoji: '🤰',
    guidance: _t('A support band can ease back and bump strain later on - fit and adjustability matter most.', 'सहारा देने वाला बैंड आगे चलकर पीठ और पेट का ज़ोर कम कर सकता है — सबसे ज़्यादा मायने रखते हैं सही fit और उसे कसने-ढीला करने की सुविधा।'),
    lookFor: [_t('Adjustable gentle support', 'कसा-ढीला होने वाला हल्का सहारा'), _t('Breathable material', 'साँस लेने वाला कपड़ा'), _t('Eases back strain', 'पीठ का ज़ोर कम करता है')],
    avoid: [_t('Bands that are too tight', 'बहुत कसे बैंड'), _t('Non-breathable nylon', 'साँस न लेने वाला nylon')],
    fromWeek: 20,
    toLabel: _t('Birth', 'जन्म'),
    totalCount: 9,
  ),
  ProductCategory(
    id: 'compression_socks',
    name: _t('Compression Socks', 'Compression मोज़े'),
    emoji: '🧦',
    guidance: _t('Compression socks help with swelling and tired legs - graduated compression is the key feature.', 'Compression मोज़े सूजन और थकी टाँगों में मदद करते हैं — सबसे अहम बात है ऊपर से नीचे घटता compression।'),
    lookFor: [_t('Graduated compression', 'ऊपर से नीचे घटता compression'), _t('Breathable knit', 'साँस लेने वाली बुनाई'), _t('Easy to pull on', 'पहनने में आसान')],
    avoid: [_t('Very tight tops', 'बहुत कसा ऊपरी हिस्सा'), _t('Rough seams', 'खुरदुरी सिलाई')],
    fromWeek: 20,
    toLabel: _t('Birth', 'जन्म'),
    totalCount: 7,
  ),
  ProductCategory(
    id: 'nursing_bra',
    name: _t('Nursing Bra', 'दूध पिलाने वाली Bra'),
    emoji: '👚',
    guidance: _t('Comfort and easy one-hand opening matter most - get sized later in pregnancy.', 'सबसे ज़्यादा मायने रखता है आराम और एक हाथ से आसानी से खुल जाना — नाप गर्भावस्था के बाद के दिनों में लें।'),
    lookFor: [_t('Soft wireless support', 'बिना wire वाला नरम सहारा'), _t('Easy clip-down', 'आसानी से खुलने वाली clip'), _t('Breathable fabric', 'साँस लेने वाला कपड़ा')],
    avoid: [_t('Underwire that digs in', 'चुभने वाली underwire'), _t('Tight bands', 'कसे बैंड')],
    fromWeek: 30,
    toLabel: _t('Postpartum', 'प्रसव के बाद'),
    totalCount: 16,
  ),
  ProductCategory(
    id: 'breast_pump',
    name: _t('Breast Pump', 'दूध निकालने वाला Pump'),
    emoji: '🍼',
    guidance: _t('Think about how often you will pump - occasional use suits manual, regular use suits electric.', 'सोचें कि आप कितनी बार pump करेंगी — कभी-कभार के लिए manual ठीक है, रोज़ के लिए electric।'),
    lookFor: [_t('Comfortable flange fit', 'आरामदेह flange fit'), _t('Quiet motor', 'शांत motor'), _t('Easy to clean', 'साफ़ करने में आसान')],
    avoid: [_t('Hard-to-clean parts', 'मुश्किल से साफ़ होने वाले हिस्से'), _t('Very loud motors', 'बहुत शोर करने वाले motor')],
    fromWeek: 34,
    toLabel: _t('Postpartum', 'प्रसव के बाद'),
    totalCount: 12,
  ),
  ProductCategory(
    id: 'swaddle',
    name: _t('Swaddles', 'Swaddle कपड़े'),
    emoji: '👶',
    guidance: _t('Soft, breathable fabric and the right size keep your newborn snug and safe.', 'नरम, साँस लेने वाला कपड़ा और सही नाप आपके नवजात को आरामदेह और सुरक्षित रखते हैं।'),
    lookFor: [_t('Breathable muslin or cotton', 'साँस लेने वाला muslin या सूती'), _t('Right newborn size', 'नवजात के लिए सही नाप'), _t('Easy to wrap', 'लपेटने में आसान')],
    avoid: [_t('Thick, overheating fabric', 'मोटा कपड़ा जिसमें गर्मी लगे'), _t('Wraps that come loose', 'ढीले पड़ जाने वाले wrap')],
    fromWeek: 34,
    toLabel: _t('Postpartum', 'प्रसव के बाद'),
    totalCount: 11,
  ),
];

final List<Product> kProducts = [
  // --- Pregnancy Pillow ---
  Product(
    id: 'pp_overall',
    categoryId: 'pregnancy_pillow',
    name: _t('ComfyBump Full-Body Pillow', 'ComfyBump Full-Body Pillow'),
    emoji: '🛏️',
    summary: _t('U-shaped support for bump, back and knees in one.', 'पेट, पीठ और घुटनों — तीनों के लिए एक ही U-आकार का सहारा।'),
    bestFor: _t('Most mothers', 'ज़्यादातर माँओं के लिए'),
    price: '₹2,499',
    badge: ProductBadge.bestOverall,
    score: 9.1,
    why: [_t('Excellent full-body support', 'पूरे शरीर को बेहतरीन सहारा'), _t('Soft, washable cover', 'नरम, धोने लायक़ कवर'), _t('Holds its shape over time', 'समय के साथ अपना आकार बनाए रखता है')],
    consider: [_t('Takes more bed space', 'बिस्तर पर ज़्यादा जगह लेता है'), _t('Slightly heavy to move', 'हटाने में थोड़ा भारी')],
    reviewSummary: ReviewSummary(
      mostLoved: _t('Excellent side-sleeping support.', 'करवट लेकर सोने में बेहतरीन सहारा।'),
      praise: _t('Comfortable and durable.', 'आरामदेह और टिकाऊ।'),
      drawback: _t('Needs a bit more bed space.', 'बिस्तर पर थोड़ी ज़्यादा जगह चाहिए।'),
      wouldBuyAgainPct: 92,
    ),
    reviews: [
      ProductReview(
        author: _t('Neha', 'नेहा'),
        role: _t('Mother of Aarav', 'आरव की माँ'),
        usedDuring: _t('Week 22 → Delivery', 'हफ़्ता 22 → डिलीवरी'),
        liked: _t('Excellent support - my back pain eased a lot at night.', 'बेहतरीन सहारा — रात में मेरा कमर दर्द काफ़ी कम हो गया।'),
        watchOut: _t('Requires a larger bed.', 'बड़ा बिस्तर चाहिए।'),
      ),
      ProductReview(
        author: _t('Pooja', 'पूजा'),
        role: _t('First-time mother', 'पहली बार माँ बनी'),
        usedDuring: _t('Week 24 → Delivery', 'हफ़्ता 24 → डिलीवरी'),
        liked: _t('Stayed supportive right through pregnancy.', 'पूरी गर्भावस्था सहारा देता रहा।'),
        watchOut: _t('Takes a few nights to get used to.', 'आदत पड़ने में कुछ रातें लगती हैं।'),
      ),
    ],
  ),
  Product(
    id: 'pp_budget',
    categoryId: 'pregnancy_pillow',
    name: _t('Snug Wedge Pillow', 'Snug Wedge Pillow'),
    emoji: '🛏️',
    summary: _t('Compact wedge that supports the bump where you need it.', 'छोटा-सा wedge जो पेट को ठीक वहीं सहारा देता है जहाँ ज़रूरत है।'),
    bestFor: _t('Small beds and budgets', 'छोटे बिस्तर और कम बजट के लिए'),
    price: '₹699',
    badge: ProductBadge.bestBudget,
    score: 8.2,
    why: [_t('Very affordable', 'बहुत किफ़ायती'), _t('Compact and light', 'छोटा और हल्का'), _t('Good targeted bump support', 'पेट को ठीक जगह पर अच्छा सहारा')],
    consider: [_t('Less full-body support', 'पूरे शरीर को कम सहारा'), _t('Cover is not removable', 'कवर उतारा नहीं जा सकता')],
  ),
  Product(
    id: 'pp_premium',
    categoryId: 'pregnancy_pillow',
    name: _t('CloudNest Adjustable Pillow', 'CloudNest Adjustable Pillow'),
    emoji: '🛏️',
    summary: _t('Adjustable filling and a premium cover for tailored support.', 'भराव कम-ज़्यादा किया जा सकता है और premium कवर, ताकि सहारा आपके हिसाब से हो।'),
    bestFor: _t('Those who want the best', 'जो सबसे अच्छा चाहती हैं'),
    price: '₹4,299',
    badge: ProductBadge.bestPremium,
    score: 9.0,
    why: [_t('Adjustable firmness', 'सख़्ती कम-ज़्यादा की जा सकती है'), _t('Premium breathable cover', 'साँस लेने वाला premium कवर'), _t('Very durable', 'बहुत टिकाऊ')],
    consider: [_t('Premium price', 'Premium क़ीमत'), _t('Large to store', 'रखने में बड़ी जगह लेता है')],
  ),
  // --- Stretch Mark Care ---
  Product(
    id: 'sc_overall',
    categoryId: 'stretch_care',
    name: _t('VedaGlow Belly Butter', 'VedaGlow Belly Butter'),
    emoji: '🧴',
    summary: _t('Rich, fragrance-free butter that absorbs without stickiness.', 'गाढ़ा, बिना ख़ुशबू वाला butter जो बिना चिपचिपाहट के त्वचा में समा जाता है।'),
    bestFor: _t('Daily use', 'रोज़ के इस्तेमाल के लिए'),
    price: '₹549',
    badge: ProductBadge.bestOverall,
    score: 8.9,
    why: [_t('Deeply moisturising', 'गहराई तक नमी देने वाला'), _t('Fragrance-free', 'बिना ख़ुशबू वाला'), _t('Non-sticky finish', 'चिपचिपा नहीं')],
    consider: [_t('Jar can be a little messy', 'जार से लगाना थोड़ा फैलाव भरा है'), _t('Works best with daily use', 'रोज़ लगाने पर सबसे अच्छा असर')],
    reviewSummary: ReviewSummary(
      mostLoved: _t('How well it absorbs.', 'त्वचा में कितनी अच्छी तरह समा जाता है।'),
      praise: _t('Skin felt soft and supple.', 'त्वचा नरम और मुलायम महसूस हुई।'),
      drawback: _t('You have to be consistent.', 'नियमित रूप से लगाना पड़ता है।'),
      wouldBuyAgainPct: 90,
    ),
  ),
  Product(
    id: 'sc_sensitive',
    categoryId: 'stretch_care',
    name: _t('PureSkin Calm Oil', 'PureSkin Calm Oil'),
    emoji: '🧴',
    summary: _t('Gentle plant oil for reactive, sensitive skin.', 'नाज़ुक और जल्दी असर दिखाने वाली त्वचा के लिए कोमल वनस्पति तेल।'),
    bestFor: _t('Sensitive skin', 'नाज़ुक त्वचा के लिए'),
    price: '₹699',
    badge: ProductBadge.sensitiveSkin,
    score: 8.6,
    why: [_t('Minimal ingredients', 'गिनी-चुनी चीज़ें'), _t('Soothing on sensitive skin', 'नाज़ुक त्वचा पर सुकून देता है'), _t('Lightweight', 'हल्का')],
    consider: [_t('Oily feel for some', 'कुछ लोगों को चिकनापन लगता है'), _t('Mild natural scent', 'हल्की प्राकृतिक ख़ुशबू')],
  ),
  Product(
    id: 'sc_budget',
    categoryId: 'stretch_care',
    name: _t('EverySoft Lotion', 'EverySoft Lotion'),
    emoji: '🧴',
    summary: _t('Everyday moisturiser at a friendly price.', 'रोज़ के लिए moisturiser, वाजिब क़ीमत में।'),
    bestFor: _t('Budgets', 'कम बजट के लिए'),
    price: '₹299',
    badge: ProductBadge.bestBudget,
    score: 8.0,
    why: [_t('Very affordable', 'बहुत किफ़ायती'), _t('Easy daily texture', 'रोज़ लगाने लायक़ हल्का texture'), _t('Widely available', 'हर जगह मिल जाता है')],
    consider: [_t('Lighter moisturisation', 'नमी थोड़ी कम देता है'), _t('Contains a light fragrance', 'इसमें हल्की ख़ुशबू है')],
  ),
  // --- Maternity Wear ---
  Product(
    id: 'mw_overall',
    categoryId: 'maternity_wear',
    name: _t('EasyGrow Maternity Leggings', 'EasyGrow Maternity Leggings'),
    emoji: '👗',
    summary: _t('Soft over-bump leggings that stretch with you.', 'नरम over-bump leggings जो आपके साथ खिंचती हैं।'),
    bestFor: _t('Everyday comfort', 'रोज़ के आराम के लिए'),
    price: '₹899',
    badge: ProductBadge.bestOverall,
    score: 8.8,
    why: [_t('Stretchy over-bump fit', 'पेट के ऊपर तक खिंचने वाला fit'), _t('Breathable cotton blend', 'साँस लेने वाला सूती मिश्रण'), _t('Wearable after delivery too', 'प्रसव के बाद भी पहनी जा सकती हैं')],
    consider: [_t('Limited colours', 'रंग कम हैं'), _t('May need a size up late on', 'आगे चलकर एक size बड़ी लेनी पड़ सकती है')],
  ),
  Product(
    id: 'mw_premium',
    categoryId: 'maternity_wear',
    name: _t('Bloom Nursing Dress', 'Bloom Nursing Dress'),
    emoji: '👗',
    summary: _t('Elegant dress with discreet nursing access.', 'सुंदर dress, जिसमें दूध पिलाने के लिए बिना दिखे खुलने की सुविधा है।'),
    bestFor: _t('Special days and nursing', 'ख़ास दिनों और दूध पिलाने के लिए'),
    price: '₹1,999',
    badge: ProductBadge.bestPremium,
    score: 8.7,
    why: [_t('Nursing-friendly', 'दूध पिलाने में आसान'), _t('Premium fabric', 'Premium कपड़ा'), _t('Flattering fit', 'जँचने वाला fit')],
    consider: [_t('Higher price', 'क़ीमत ज़्यादा'), _t('Gentle wash only', 'सिर्फ़ हल्के हाथ से धुलाई')],
  ),
  Product(
    id: 'mw_budget',
    categoryId: 'maternity_wear',
    name: _t('DailyEase Maternity Kurti', 'DailyEase Maternity Kurti'),
    emoji: '👗',
    summary: _t('Roomy, breathable kurti for everyday wear.', 'खुली-खुली, साँस लेने वाली कुर्ती रोज़ पहनने के लिए।'),
    bestFor: _t('Budgets', 'कम बजट के लिए'),
    price: '₹599',
    badge: ProductBadge.bestBudget,
    score: 8.1,
    why: [_t('Affordable', 'किफ़ायती'), _t('Airy and roomy', 'हवादार और खुली'), _t('Easy to wash', 'धोने में आसान')],
    consider: [_t('Basic styling', 'साधारण design'), _t('Fabric thins over time', 'कपड़ा समय के साथ पतला हो जाता है')],
  ),
  // --- Belly Support Band ---
  Product(
    id: 'bb_overall',
    categoryId: 'belly_band',
    name: _t('SteadyBump Support Band', 'SteadyBump Support Band'),
    emoji: '🤰',
    summary: _t('Adjustable band that eases bump and back strain.', 'कसा-ढीला होने वाला बैंड जो पेट और पीठ का ज़ोर कम करता है।'),
    bestFor: _t('Back relief', 'पीठ को राहत'),
    price: '₹799',
    badge: ProductBadge.bestOverall,
    score: 8.7,
    why: [_t('Adjustable gentle support', 'कसा-ढीला होने वाला हल्का सहारा'), _t('Breathable panel', 'साँस लेने वाला panel'), _t('Eases back strain', 'पीठ का ज़ोर कम करता है')],
    consider: [_t('Visible under fitted clothes', 'चुस्त कपड़ों के नीचे दिख जाता है'), _t('Needs the right size', 'सही नाप ज़रूरी है')],
  ),
  Product(
    id: 'bb_budget',
    categoryId: 'belly_band',
    name: _t('LiteHold Belly Band', 'LiteHold Belly Band'),
    emoji: '🤰',
    summary: _t('Simple, low-cost everyday support.', 'रोज़ के लिए सरल और कम क़ीमत वाला सहारा।'),
    bestFor: _t('Budgets', 'कम बजट के लिए'),
    price: '₹399',
    badge: ProductBadge.bestBudget,
    score: 7.9,
    why: [_t('Very affordable', 'बहुत किफ़ायती'), _t('Light and simple', 'हल्का और सरल'), _t('Easy to wear', 'पहनने में आसान')],
    consider: [_t('Less adjustable', 'कम कसा-ढीला होता है'), _t('Thinner material', 'कपड़ा पतला')],
  ),
  Product(
    id: 'bb_premium',
    categoryId: 'belly_band',
    name: _t('FlexCore Maternity Belt', 'FlexCore Maternity Belt'),
    emoji: '🤰',
    summary: _t('Firmer, contoured support for active days.', 'चलती-फिरती दिनचर्या के लिए ज़्यादा कसा, शरीर के आकार में ढला सहारा।'),
    bestFor: _t('Active mothers', 'सक्रिय माँओं के लिए'),
    price: '₹1,299',
    badge: ProductBadge.bestPremium,
    score: 8.6,
    why: [_t('Firm contoured support', 'कसा हुआ, शरीर में ढला सहारा'), _t('Durable build', 'मज़बूत बनावट'), _t('Good for activity', 'चलने-फिरने के लिए अच्छा')],
    consider: [_t('Warmer to wear', 'पहनने पर ज़्यादा गर्म लगता है'), _t('Premium price', 'Premium क़ीमत')],
  ),
  // --- Compression Socks ---
  Product(
    id: 'cs_overall',
    categoryId: 'compression_socks',
    name: _t('FreshStep Compression Socks', 'FreshStep Compression Socks'),
    emoji: '🧦',
    summary: _t('Graduated compression for swelling and tired legs.', 'सूजन और थकी टाँगों के लिए ऊपर से नीचे घटता compression।'),
    bestFor: _t('Daily swelling', 'रोज़ की सूजन के लिए'),
    price: '₹599',
    badge: ProductBadge.bestOverall,
    score: 8.6,
    why: [_t('Graduated compression', 'ऊपर से नीचे घटता compression'), _t('Breathable knit', 'साँस लेने वाली बुनाई'), _t('Easy to pull on', 'पहनने में आसान')],
    consider: [_t('Snug to put on', 'पहनने में कसे लगते हैं'), _t('Hand wash is best', 'हाथ से धोना सबसे अच्छा')],
  ),
  Product(
    id: 'cs_budget',
    categoryId: 'compression_socks',
    name: _t('DayLite Support Socks', 'DayLite Support Socks'),
    emoji: '🧦',
    summary: _t('Light support at an easy price.', 'हल्का सहारा, आसान क़ीमत में।'),
    bestFor: _t('Budgets', 'कम बजट के लिए'),
    price: '₹299',
    badge: ProductBadge.bestBudget,
    score: 7.8,
    why: [_t('Affordable', 'किफ़ायती'), _t('Comfortable knit', 'आरामदेह बुनाई'), _t('Good for short days', 'कम देर पहनने के लिए अच्छे')],
    consider: [_t('Milder compression', 'Compression हल्का'), _t('Fewer sizes', 'नाप के कम विकल्प')],
  ),
  Product(
    id: 'cs_premium',
    categoryId: 'compression_socks',
    name: _t('AeroFlow Medical Socks', 'AeroFlow Medical Socks'),
    emoji: '🧦',
    summary: _t('Medical-grade compression for all-day wear.', 'पूरे दिन पहनने के लिए medical-grade compression।'),
    bestFor: _t('Long days on your feet', 'पूरे दिन पैरों पर रहने वालों के लिए'),
    price: '₹1,099',
    badge: ProductBadge.bestPremium,
    score: 8.7,
    why: [_t('Strong graduated support', 'ऊपर से नीचे घटता मज़बूत सहारा'), _t('All-day comfort', 'दिन भर आराम'), _t('Durable', 'टिकाऊ')],
    consider: [_t('Firmer to put on', 'पहनने में ज़्यादा कसे'), _t('Premium price', 'Premium क़ीमत')],
  ),
  // --- Nursing Bra ---
  Product(
    id: 'nb_overall',
    categoryId: 'nursing_bra',
    name: _t('SoftClip Nursing Bra', 'SoftClip Nursing Bra'),
    emoji: '👚',
    summary: _t('Wireless support with easy one-hand clips.', 'बिना wire का सहारा, एक हाथ से खुलने वाली clip के साथ।'),
    bestFor: _t('Everyday comfort', 'रोज़ के आराम के लिए'),
    price: '₹699',
    badge: ProductBadge.bestOverall,
    score: 8.8,
    why: [_t('Soft wireless support', 'बिना wire वाला नरम सहारा'), _t('Easy clip-down', 'आसानी से खुलने वाली clip'), _t('Breathable cotton', 'साँस लेने वाला सूती')],
    consider: [_t('Size changes after birth', 'जन्म के बाद नाप बदल जाता है'), _t('Plain design', 'सादा design')],
  ),
  Product(
    id: 'nb_budget',
    categoryId: 'nursing_bra',
    name: _t('DayEase Nursing Bra', 'DayEase Nursing Bra'),
    emoji: '👚',
    summary: _t('Comfortable basics at a friendly price.', 'वाजिब क़ीमत में आरामदेह बुनियादी चीज़ें।'),
    bestFor: _t('Budgets', 'कम बजट के लिए'),
    price: '₹399',
    badge: ProductBadge.bestBudget,
    score: 8.0,
    why: [_t('Affordable multipacks', 'किफ़ायती multipack'), _t('Soft fabric', 'नरम कपड़ा'), _t('Easy care', 'देखभाल आसान')],
    consider: [_t('Lighter support', 'सहारा हल्का'), _t('Fewer sizes', 'नाप के कम विकल्प')],
  ),
  Product(
    id: 'nb_premium',
    categoryId: 'nursing_bra',
    name: _t('Bloom Seamless Nursing Bra', 'Bloom Seamless Nursing Bra'),
    emoji: '👚',
    summary: _t('Seamless premium comfort for day and night.', 'दिन और रात के लिए बिना सिलाई वाला premium आराम।'),
    bestFor: _t('All-day wear', 'पूरे दिन पहनने के लिए'),
    price: '₹1,199',
    badge: ProductBadge.bestPremium,
    score: 8.7,
    why: [_t('Seamless comfort', 'बिना सिलाई वाला आराम'), _t('Great support', 'बढ़िया सहारा'), _t('Soft premium fabric', 'नरम premium कपड़ा')],
    consider: [_t('Premium price', 'Premium क़ीमत'), _t('Hand wash preferred', 'हाथ से धोना बेहतर')],
  ),
  // --- Breast Pump ---
  Product(
    id: 'bp_overall',
    categoryId: 'breast_pump',
    name: _t('GentleFlow Electric Pump', 'GentleFlow Electric Pump'),
    emoji: '🍼',
    summary: _t('Quiet electric pump with a comfortable fit.', 'शांत electric pump, आरामदेह fit के साथ।'),
    bestFor: _t('Regular pumping', 'रोज़ pump करने के लिए'),
    price: '₹4,999',
    badge: ProductBadge.bestOverall,
    score: 9.0,
    why: [_t('Quiet motor', 'शांत motor'), _t('Comfortable flange fit', 'आरामदेह flange fit'), _t('Easy to clean', 'साफ़ करने में आसान')],
    consider: [_t('Higher price', 'क़ीमत ज़्यादा'), _t('Needs charging', 'Charge करना पड़ता है')],
    reviewSummary: ReviewSummary(
      mostLoved: _t('How quiet it is.', 'यह कितना शांत है।'),
      praise: _t('Comfortable and efficient.', 'आरामदेह और असरदार।'),
      drawback: _t('Remember to keep it charged.', 'इसे charge रखना याद रखें।'),
      wouldBuyAgainPct: 88,
    ),
    reviews: [
      ProductReview(
        author: _t('Simran', 'सिमरन'),
        role: _t('Working mother', 'नौकरीपेशा माँ'),
        usedDuring: _t('Week 36 → Postpartum', 'हफ़्ता 36 → प्रसव के बाद'),
        liked: _t('Quiet enough to pump discreetly at work.', 'इतना शांत कि दफ़्तर में बिना किसी को पता चले pump कर सकूँ।'),
        watchOut: _t('Carry the charger with you.', 'Charger साथ रखें।'),
      ),
    ],
  ),
  Product(
    id: 'bp_budget',
    categoryId: 'breast_pump',
    name: _t('EasyHand Manual Pump', 'EasyHand Manual Pump'),
    emoji: '🍼',
    summary: _t('Simple manual pump for occasional use.', 'कभी-कभार इस्तेमाल के लिए सरल manual pump।'),
    bestFor: _t('Occasional use', 'कभी-कभार इस्तेमाल के लिए'),
    price: '₹999',
    badge: ProductBadge.bestBudget,
    score: 8.3,
    why: [_t('Very affordable', 'बहुत किफ़ायती'), _t('No power needed', 'बिजली की ज़रूरत नहीं'), _t('Light to carry', 'साथ ले जाने में हल्का')],
    consider: [_t('Manual effort', 'हाथ से मेहनत करनी पड़ती है'), _t('Slower than electric', 'Electric से धीमा')],
  ),
  Product(
    id: 'bp_premium',
    categoryId: 'breast_pump',
    name: _t('DualEase Double Pump', 'DualEase Double Pump'),
    emoji: '🍼',
    summary: _t('Hospital-grade double pump to save time.', 'समय बचाने के लिए hospital-grade double pump।'),
    bestFor: _t('Frequent pumping', 'बार-बार pump करने के लिए'),
    price: '₹8,999',
    badge: ProductBadge.bestPremium,
    score: 8.9,
    why: [_t('Double pumping saves time', 'दोनों तरफ़ से एक साथ pump करने पर समय बचता है'), _t('Strong, adjustable suction', 'मज़बूत खिंचाव, जिसे कम-ज़्यादा किया जा सकता है'), _t('Durable', 'टिकाऊ')],
    consider: [_t('Expensive', 'महँगा'), _t('More parts to clean', 'साफ़ करने के लिए ज़्यादा हिस्से')],
  ),
  // --- Swaddles ---
  Product(
    id: 'sw_overall',
    categoryId: 'swaddle',
    name: _t('DreamWrap Muslin Swaddle', 'DreamWrap Muslin Swaddle'),
    emoji: '👶',
    summary: _t('Breathable muslin that keeps newborns snug.', 'साँस लेने वाला muslin जो नवजात को आराम से लिपटा रखता है।'),
    bestFor: _t('Newborns', 'नवजात के लिए'),
    price: '₹799',
    badge: ProductBadge.newborns,
    score: 8.9,
    why: [_t('Breathable muslin', 'साँस लेने वाला muslin'), _t('Right newborn size', 'नवजात के लिए सही नाप'), _t('Soft on skin', 'त्वचा पर नरम')],
    consider: [_t('Needs re-wrapping', 'बार-बार लपेटना पड़ता है'), _t('Sold in small packs', 'छोटे pack में मिलता है')],
  ),
  Product(
    id: 'sw_budget',
    categoryId: 'swaddle',
    name: _t('CozyCotton Swaddle Pack', 'CozyCotton Swaddle Pack'),
    emoji: '👶',
    summary: _t('Value pack of soft cotton swaddles.', 'नरम सूती swaddle का किफ़ायती pack।'),
    bestFor: _t('Budgets', 'कम बजट के लिए'),
    price: '₹499',
    badge: ProductBadge.bestBudget,
    score: 8.1,
    why: [_t('Great value pack', 'बढ़िया किफ़ायती pack'), _t('Soft cotton', 'नरम सूती'), _t('Machine washable', 'Machine में धुल जाता है')],
    consider: [_t('Slightly thicker', 'थोड़ा मोटा'), _t('Fewer prints', 'Print कम')],
  ),
  Product(
    id: 'sw_premium',
    categoryId: 'swaddle',
    name: _t('SnugZip Swaddle Sack', 'SnugZip Swaddle Sack'),
    emoji: '👶',
    summary: _t('Zip swaddle for easy, secure wrapping.', 'आसान और सुरक्षित लपेटन के लिए zip वाला swaddle।'),
    bestFor: _t('Easy wrapping', 'आसान लपेटन'),
    price: '₹999',
    badge: ProductBadge.bestPremium,
    score: 8.6,
    why: [_t('Easy zip wrapping', 'Zip से आसान लपेटन'), _t('Secure fit', 'कसकर टिका रहने वाला fit'), _t('Soft fabric', 'नरम कपड़ा')],
    consider: [_t('Outgrown quickly', 'जल्दी छोटा पड़ जाता है'), _t('Premium price', 'Premium क़ीमत')],
  ),
];

// ---------------------------------------------------------------------------
//  Lookups
// ---------------------------------------------------------------------------
ProductCategory? productCategoryById(String id) {
  for (final c in kProductCategories) {
    if (c.id == id) return c;
  }
  return null;
}

Product? productById(String id) {
  for (final p in kProducts) {
    if (p.id == id) return p;
  }
  return null;
}

/// A real photo URL for [p]: its own [Product.imageUrl] if set, else a stable
/// placeholder photo (consistent per product) so cards show real images now.
/// Swap in exact product/Amazon image URLs on the model later.
String productImageUrl(Product p) => p.imageUrl.isNotEmpty
    ? p.imageUrl
    : 'https://picsum.photos/seed/pv_${p.id}/300/300';

/// An Amazon India search URL for [p] (used by affiliate Buy on Amazon).
String amazonSearchUrl(Product p) =>
    // .en: this leaves the app. Amazon India's listings are in English, so a
    // Devanagari query returns nothing useful - the search term identifies a
    // product to an external system rather than showing anything to her.
    'https://www.amazon.in/s?k=${Uri.encodeComponent(p.name.en)}';

/// The ~half of the catalogue treated as AFFILIATE (bought on Amazon), spread
/// across every category; each category's `_overall` hero pick stays ParentVeda.
/// 12 of 24 products. (A product can also opt in via `Product.isAffiliate`.)
final Set<String> _kAffiliateProductIds = {
  'pp_budget', 'pp_premium',
  'sc_budget',
  'mw_premium', 'mw_budget',
  'bb_budget',
  'cs_premium',
  'nb_budget',
  'bp_budget', 'bp_premium',
  'sw_budget', 'sw_premium',
};

/// Is [p] an affiliate (Amazon) product, vs a ParentVeda (in-app cart) product?
bool productIsAffiliate(Product p) =>
    p.isAffiliate || _kAffiliateProductIds.contains(p.id);

List<Product> productsForCategory(String categoryId) =>
    kProducts.where((p) => p.categoryId == categoryId).toList();

Product? bestOverallFor(String categoryId) {
  final list = productsForCategory(categoryId);
  for (final p in list) {
    if (p.badge == ProductBadge.bestOverall || p.badge == ProductBadge.newborns) {
      return p;
    }
  }
  return list.isEmpty ? null : list.first;
}

/// Categories relevant at [week], soonest-starting first.
List<ProductCategory> recommendedCategories(int week) {
  final list = kProductCategories.where((c) => c.relevantAt(week)).toList();
  list.sort((a, b) => a.fromWeek.compareTo(b.fromWeek));
  return list;
}

List<Product> productSearch(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  return kProducts
      // Both languages, as in readSearch: a mother reading in Hindi may still
      // type an English product name she saw on a box, and a Devanagari query
      // must match Devanagari copy. Matching only the rendered language would
      // make results depend on a setting she is not thinking about.
      .where((p) =>
          p.name.en.toLowerCase().contains(q) ||
          p.name.hi.toLowerCase().contains(q) ||
          (productCategoryById(p.categoryId)?.name.en.toLowerCase().contains(q) ??
              false) ||
          (productCategoryById(p.categoryId)?.name.hi.toLowerCase().contains(q) ??
              false))
      .toList();
}

List<ProductCategory> categorySearch(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  return kProductCategories
      .where((c) =>
          c.name.en.toLowerCase().contains(q) ||
          c.name.hi.toLowerCase().contains(q))
      .toList();
}
