// =============================================================================
//  Garbh Sanskar Journey - curated seed content
// -----------------------------------------------------------------------------
//  A starter library across the four pillars. Warm, universal, non-religious;
//  enough to make the experience feel real. Scales to the launch quantities
//  (Shravan 40–50, Samvad 280, Vichara 100–150, Kriya 30–40) by adding entries.
// =============================================================================

import '../models/garbh_content.dart';
import '../localization/app_language.dart';

// ---------------------------------------------------------------------------
//  Shravan - Sacred Listening (placeholder audio uses the bundled drone)
// ---------------------------------------------------------------------------
LocalizedText _t(String en, String hi) => LocalizedText(en: en, hi: hi);

final List<GarbhAudio> kShravan = [
  GarbhAudio(id: 'morning_raga', title: _t('Morning Calm Raga', 'प्रभात शांति राग'), subtitle: _t('Begin the day with calmness', 'दिन की शुरुआत शांति से कीजिए'), emoji: '🌅', minutes: 7, kind: GarbhKind.raga),
  GarbhAudio(id: 'bonding_raga', title: _t('Baby Bonding Raga', 'शिशु से जुड़ाव का राग'), subtitle: _t('A melody to share with your baby', 'एक धुन, जो आप शिशु के साथ बाँट सकती हैं'), emoji: '💗', minutes: 7, kind: GarbhKind.raga),
  GarbhAudio(id: 'evening_raga', title: _t('Evening Raga', 'संध्या राग'), subtitle: _t('Unwind as the day softens', 'दिन ढलते-ढलते मन भी हल्का कीजिए'), emoji: '🌙', minutes: 8, kind: GarbhKind.raga),
  GarbhAudio(id: 'sleep_raga', title: _t('Sleep Raga', 'निद्रा राग'), subtitle: _t('Drift gently into rest', 'धीरे-धीरे नींद में उतर जाइए'), emoji: '😴', minutes: 10, kind: GarbhKind.raga),
  GarbhAudio(id: 'relax_raga', title: _t('Relaxation Raga', 'विश्राम राग'), subtitle: _t('Let the tension melt away', 'तनाव को पिघलकर बह जाने दीजिए'), emoji: '🍃', minutes: 6, kind: GarbhKind.raga),
  GarbhAudio(id: 'rain', title: _t('Gentle Rain', 'हल्की बारिश'), subtitle: _t('Soft, steady rainfall', 'नरम, लगातार बरसती बूँदें'), emoji: '🌧️', minutes: 15, kind: GarbhKind.nature),
  GarbhAudio(id: 'ocean', title: _t('Ocean Waves', 'समुद्र की लहरें'), subtitle: _t('Slow rolling waves', 'धीरे-धीरे लुढ़कती लहरें'), emoji: '🌊', minutes: 15, kind: GarbhKind.nature),
  GarbhAudio(id: 'forest', title: _t('Forest Morning', 'जंगल की सुबह'), subtitle: _t('Birdsong and a gentle breeze', 'चिड़ियों की चहचहाहट और हल्की हवा'), emoji: '🌲', minutes: 12, kind: GarbhKind.nature),
  GarbhAudio(id: 'bells', title: _t('Temple Bells', 'मंदिर की घंटियाँ'), subtitle: _t('Soft, distant bells', 'दूर से आती धीमी घंटियाँ'), emoji: '🔔', minutes: 8, kind: GarbhKind.nature),
  GarbhAudio(id: 'bodyscan', title: _t('Body Awareness Journey', 'शरीर को महसूस करने की यात्रा'), subtitle: _t('A guided full-body relaxation', 'पूरे शरीर को शिथिल करने वाला निर्देशित अभ्यास'), emoji: '🧘', minutes: 9, kind: GarbhKind.guided),
];

// ---------------------------------------------------------------------------
//  Vichara - Positive Contemplation (short reflective reads)
// ---------------------------------------------------------------------------
final List<GarbhStory> kVichara = [
  GarbhStory(
    id: 'curiosity',
    theme: _t('Curiosity', 'जिज्ञासा'),
    title: _t('The Child Who Asked Why', 'वह बच्चा जो पूछता था "क्यों"'),
    blurb: _t('A short reflection on curiosity, wonder and lifelong learning.', 'जिज्ञासा, विस्मय और जीवन भर सीखते रहने पर एक छोटा-सा विचार।'),
    body:
        _t('There was once a child who asked "why" about everything. Why is the sky blue? Why do birds sing in the morning? Why does the moon follow us home?\n\n'
        'At first the grown-ups answered quickly, and then they grew tired of answering at all. But the child kept asking - not to be difficult, but because the world felt endlessly interesting.\n\n'
        'Years later, that same curiosity became the child\'s greatest gift. It made them a careful listener, a patient learner, and someone who never stopped growing.\n\n'
        'Every child is born with this spark. It does not need to be taught - only protected, welcomed, and answered with a little patience.',
        'एक बच्चा था जो हर बात पर "क्यों" पूछता था। आसमान नीला क्यों है? चिड़ियाँ सुबह ही क्यों गाती हैं? चाँद हमारे साथ-साथ घर तक क्यों आता है?\n\n'
        'पहले बड़े जल्दी-जल्दी जवाब देते रहे, फिर जवाब देते-देते थक गए। पर बच्चा पूछता रहा — तंग करने के लिए नहीं, बल्कि इसलिए कि उसे यह दुनिया कभी ख़त्म न होने वाली दिलचस्प लगती थी।\n\n'
        'बरसों बाद वही जिज्ञासा उसकी सबसे बड़ी पूँजी बन गई। उसी ने उसे ध्यान से सुनने वाला, धीरज से सीखने वाला और कभी न रुकने वाला इंसान बनाया।\n\n'
        'यह चिंगारी हर बच्चे के साथ जन्म लेती है। इसे सिखाना नहीं पड़ता — बस बचाना पड़ता है, अपनाना पड़ता है, और थोड़े धीरज से जवाब देना पड़ता है।'),
    reflection: _t('What quality would you most like your child to keep as they grow?', 'बड़े होते हुए आपका बच्चा कौन-सा गुण अपने भीतर बचाए रखे, यह आप सबसे ज़्यादा चाहेंगी?'),
  ),
  GarbhStory(
    id: 'patience',
    theme: _t('Patience', 'धीरज'),
    title: _t('How Trees Grow Slowly Yet Strongly', 'पेड़ धीरे उगते हैं, पर मज़बूत उगते हैं'),
    blurb: _t('A gentle reminder that the strongest things take time.', 'एक कोमल याद — जो सबसे मज़बूत होता है, उसे समय लगता है।'),
    body:
        _t('A tree does not rush. In its first year it may look like nothing more than a thin stem, easily bent by the wind.\n\n'
        'But beneath the soil, quietly and unseen, it is doing the most important work - sending roots deep and wide. Only later does it rise tall, and by then it can hold the weight of storms.\n\n'
        'Pregnancy is a little like this. So much of what matters is happening quietly, unseen, day by day. You do not have to feel productive for important things to be growing.\n\n'
        'Slow is not the same as still. You and your baby are both becoming, a little more each day.',
        'पेड़ को कोई जल्दी नहीं होती। पहले साल में वह बस एक पतली-सी डंडी जैसा दिखता है, जिसे हवा भी झुका दे।\n\n'
        'पर मिट्टी के नीचे, चुपचाप और किसी की नज़र से दूर, वह सबसे ज़रूरी काम कर रहा होता है — जड़ें गहरी और दूर तक फैला रहा होता है। ऊँचा वह बाद में उठता है, और तब तक तूफ़ानों का बोझ सँभालने लायक हो चुका होता है।\n\n'
        'गर्भावस्था भी कुछ ऐसी ही है। जो सबसे ज़रूरी है, वह चुपचाप, दिखे बिना, दिन-ब-दिन हो रहा है। कुछ बड़ा पनपने के लिए यह ज़रूरी नहीं कि आपको हर दिन कुछ करते हुए महसूस हो।\n\n'
        'धीरे चलना रुक जाना नहीं होता। आप भी बन रही हैं और आपका शिशु भी — हर दिन थोड़ा और।'),
    reflection: _t('Where in your life could you offer yourself a little more patience?', 'अपने जीवन में कहाँ आप ख़ुद को थोड़ा और धीरज दे सकती हैं?'),
  ),
  GarbhStory(
    id: 'kindness',
    theme: _t('Kindness', 'दयालुता'),
    title: _t('The Warmth of a Small Gesture', 'एक छोटे-से इशारे की गर्माहट'),
    blurb: _t('How the smallest kindnesses leave the deepest mark.', 'सबसे छोटी दयालुता सबसे गहरा निशान छोड़ जाती है।'),
    body:
        _t('We often think kindness has to be grand - a big gift, a great sacrifice. But ask anyone about a kindness they still remember, and it is almost always something small.\n\n'
        'A warm word on a hard day. Someone who waited. Someone who noticed. These tiny moments stay with us for years.\n\n'
        'Children learn kindness not from lectures but from feeling it, again and again, in ordinary moments. The way they are spoken to becomes the way they speak to the world.\n\n'
        'Your gentleness, even now, is already shaping a gentle heart.',
        'हमें अक्सर लगता है कि दयालुता कोई बड़ी बात होनी चाहिए — कोई बड़ा तोहफ़ा, कोई बड़ा त्याग। पर किसी से भी पूछिए कि आज तक कौन-सी दयालुता याद है, तो जवाब लगभग हमेशा कोई छोटी-सी बात होती है।\n\n'
        'मुश्किल दिन पर कहा गया एक नरम शब्द। कोई जो रुककर इंतज़ार कर गया। कोई जिसने ध्यान दे दिया। ये नन्हे पल बरसों साथ रहते हैं।\n\n'
        'बच्चे दयालुता उपदेश से नहीं सीखते, उसे बार-बार महसूस करके सीखते हैं — रोज़ के मामूली पलों में। जिस तरह उनसे बात की जाती है, वही तरीक़ा वे दुनिया से बात करने में अपनाते हैं।\n\n'
        'आपकी कोमलता, अभी से, एक कोमल दिल गढ़ रही है।'),
    reflection: _t('What small kindness has stayed with you over the years?', 'कौन-सी छोटी-सी दयालुता बरसों से आपके मन में बसी है?'),
  ),
  GarbhStory(
    id: 'gratitude',
    theme: _t('Gratitude', 'कृतज्ञता'),
    title: _t('Counting Quiet Blessings', 'चुपचाप मिली छोटी नेमतें गिनना'),
    blurb: _t('Finding the ordinary moments worth holding onto.', 'रोज़ के उन पलों को पहचानना, जिन्हें सँभालकर रखना अच्छा लगे।'),
    body:
        _t('Gratitude is not about pretending everything is perfect. It is about noticing what is good, even alongside what is hard.\n\n'
        'A warm cup in your hands. A moment of stillness. The flutter of a tiny movement reminding you that you are not alone in your own body.\n\n'
        'When we practise noticing these things, our minds slowly learn to look for them. The same day can feel heavier or lighter depending on where our attention rests.\n\n'
        'Tonight, you might name just one small thing that went gently. That is enough.',
        'कृतज्ञता का मतलब यह दिखावा नहीं कि सब कुछ ठीक है। इसका मतलब है — जो मुश्किल है उसके साथ-साथ, जो अच्छा है उसे भी देख लेना।\n\n'
        'हाथों में एक गरम प्याला। ठहराव का एक पल। कोई नन्ही-सी हलचल, जो याद दिला जाए कि अपने ही शरीर में आप अकेली नहीं हैं।\n\n'
        'जब हम इन्हें देखने की आदत डालते हैं, तो मन धीरे-धीरे इन्हें ढूँढ़ना सीख जाता है। वही दिन भारी भी लग सकता है और हल्का भी — यह इस पर है कि ध्यान कहाँ ठहरता है।\n\n'
        'आज रात बस एक छोटी-सी बात चुन लीजिए जो नरमी से बीती। इतना काफ़ी है।'),
    reflection: _t('What is one small thing from today you feel grateful for?', 'आज की कौन-सी एक छोटी बात के लिए आपका मन शुक्रगुज़ार है?'),
  ),
  GarbhStory(
    id: 'courage',
    theme: _t('Courage', 'साहस'),
    title: _t('The Little Boat and the Big Sea', 'नन्ही नाव और बड़ा समंदर'),
    blurb: _t('Courage is not the absence of fear, but moving with it.', 'साहस डर का न होना नहीं है — डर के साथ चलते रहना है।'),
    body:
        _t('A small boat once worried it was too little for such a wide sea. The waves looked enormous, the horizon far away.\n\n'
        'But the boat discovered something: it did not need to conquer the whole ocean at once. It only needed to ride the next wave, and then the next.\n\n'
        'Courage is rarely a single brave leap. More often it is the quiet decision to keep going, one small step at a time, even when we feel unsure.\n\n'
        'You are doing something extraordinary, one ordinary day at a time. That is courage too.',
        'एक नन्ही नाव को लगता था कि इतने बड़े समंदर के लिए वह बहुत छोटी है। लहरें बहुत ऊँची लगती थीं, किनारा बहुत दूर।\n\n'
        'पर नाव को एक बात समझ आई — उसे पूरा समंदर एक साथ नहीं जीतना था। बस अगली लहर पार करनी थी, और फिर उसके बाद वाली।\n\n'
        'साहस कभी-कभार ही कोई एक बड़ी छलाँग होता है। ज़्यादातर वह चुपचाप लिया गया यह फ़ैसला होता है कि चलते रहना है — एक छोटा क़दम, फिर एक और, भले ही मन डाँवाडोल हो।\n\n'
        'आप कुछ असाधारण कर रही हैं, एक-एक साधारण दिन जोड़कर। यह भी साहस है।'),
    reflection: _t('What is one small, brave step you can take this week?', 'इस हफ़्ते आप कौन-सा एक छोटा, हिम्मत भरा क़दम उठा सकती हैं?'),
  ),
  GarbhStory(
    id: 'wonder',
    theme: _t('Wonder', 'विस्मय'),
    title: _t('The Night Full of Stars', 'तारों से भरी रात'),
    blurb: _t('Remembering how to look at the world with fresh eyes.', 'दुनिया को फिर से नई आँखों से देखना याद कर लेना।'),
    body:
        _t('Children look at the night sky and gasp. Adults, often, forget to look up at all.\n\n'
        'Wonder is the ability to be amazed by ordinary things - a leaf, a raindrop, a sky full of distant light. It is not childish; it is one of the great quiet joys of being alive.\n\n'
        'Your baby will arrive seeing everything for the very first time. In their company, you may rediscover wonder too - the world made new through their eyes.\n\n'
        'For a moment now, let yourself simply marvel that a whole new person is forming, quietly, within you.',
        'बच्चे रात के आसमान को देखकर ठिठक जाते हैं। बड़े अक्सर ऊपर देखना ही भूल जाते हैं।\n\n'
        'विस्मय यानी मामूली चीज़ों पर चकित हो जाना — एक पत्ता, एक बूँद, दूर की रोशनियों से भरा आसमान। यह बचपना नहीं है; यह ज़िंदा होने की सबसे शांत ख़ुशियों में से एक है।\n\n'
        'आपका शिशु हर चीज़ को पहली बार देखता हुआ आएगा। उसके साथ शायद आप भी विस्मय फिर से पा लेंगी — उसकी आँखों से दुनिया एकदम नई लगेगी।\n\n'
        'अभी एक पल के लिए बस इस बात पर ठहर जाइए कि एक पूरा नया इंसान, चुपचाप, आपके भीतर बन रहा है।'),
    reflection: _t('When did you last feel genuine wonder?', 'आपको आख़िरी बार सच्चा विस्मय कब महसूस हुआ था?'),
  ),
  GarbhStory(
    id: 'compassion',
    theme: _t('Compassion', 'करुणा'),
    title: _t('The Bird with the Tired Wing', 'थके पंख वाली चिड़िया'),
    blurb: _t('On caring for others - and for yourself.', 'दूसरों का ख़याल रखने पर — और अपना भी।'),
    body:
        _t('A flock once paused its long journey because one bird could fly no further that day. Rather than leaving it behind, the others rested too, until it was ready.\n\n'
        'Compassion is simply this: noticing when someone needs gentleness, and offering it without keeping score.\n\n'
        'It applies to ourselves as well. On the days you feel tired, slow, or not enough, you deserve the same softness you would offer a dear friend.\n\n'
        'A mother who is kind to herself teaches her child that they, too, are worthy of kindness.',
        'एक झुंड ने अपनी लंबी उड़ान बीच में रोक दी, क्योंकि उस दिन एक चिड़िया आगे उड़ नहीं पा रही थी। उसे पीछे छोड़ने के बजाय बाक़ी भी ठहर गए, जब तक वह तैयार न हो गई।\n\n'
        'करुणा बस इतनी-सी है — यह देख लेना कि किसे इस वक़्त नरमी चाहिए, और बिना हिसाब रखे वह नरमी दे देना।\n\n'
        'यह अपने ऊपर भी उतना ही लागू होता है। जिन दिनों आप थकी, सुस्त या कम पड़ती हुई महसूस करें, आप उसी नरमी की हक़दार हैं जो आप किसी प्यारी सहेली को देतीं।\n\n'
        'जो माँ अपने साथ नरम रहती है, वह अपने बच्चे को सिखाती है कि वह भी नरमी का हक़दार है।'),
    reflection: _t('How could you be a little gentler with yourself today?', 'आज आप ख़ुद के साथ थोड़ा और नरम कैसे हो सकती हैं?'),
  ),
  GarbhStory(
    id: 'resilience',
    theme: _t('Resilience', 'लचीलापन'),
    title: _t('The River That Found Its Way', 'वह नदी जिसने अपना रास्ता ढूँढ़ लिया'),
    blurb: _t('How softness can be its own kind of strength.', 'नरमी भी अपने आप में एक तरह की ताक़त होती है।'),
    body:
        _t('A river never argues with the rock in its path. It simply finds a way around, or over, or slowly, over time, straight through.\n\n'
        'Resilience is not about being hard. It is about being able to bend, adapt, and keep moving toward what matters.\n\n'
        'There will be easier days and harder ones ahead. You will not need to be unbreakable - only to keep flowing, gently, in your own direction.\n\n'
        'You have already come further than you sometimes give yourself credit for.',
        'नदी अपने रास्ते के पत्थर से कभी बहस नहीं करती। वह बस बग़ल से निकल जाती है, या ऊपर से, या धीरे-धीरे, समय लेकर, उसके आर-पार।\n\n'
        'लचीलापन कठोर होना नहीं है। यह झुक पाना है, ढल पाना है, और जो ज़रूरी है उसकी ओर बहते रहना है।\n\n'
        'आगे आसान दिन भी आएँगे और मुश्किल भी। आपको अटूट होने की ज़रूरत नहीं — बस अपनी दिशा में, नरमी से, बहते रहने की।\n\n'
        'आप जितनी दूर आ चुकी हैं, उसका श्रेय आप ख़ुद को अक्सर देती ही नहीं।'),
    reflection: _t('What is something difficult you have already moved through?', 'कौन-सी मुश्किल है जिसे आप पहले ही पार कर चुकी हैं?'),
  ),
];

// ---------------------------------------------------------------------------
//  Kriya - Breath & Grounding (each is one breath cycle, looped)
// ---------------------------------------------------------------------------
final List<GarbhPractice> kKriya = [
  GarbhPractice(
    id: 'bhramari',
    title: _t('Bhramari Breath', 'भ्रामरी प्राणायाम'),
    blurb: _t('A calming humming breath', 'गुनगुनाहट वाली, मन शांत करती साँस'),
    emoji: '🐝',
    minutes: 3,
    phases: [
      BreathPhase(_t('Breathe in', 'साँस लीजिए'), 4, 1.0),
      BreathPhase(_t('Hum out softly', 'धीरे से गुनगुनाते हुए छोड़िए'), 6, 0.5),
    ],
  ),
  GarbhPractice(
    id: 'deep_belly',
    title: _t('Deep Belly Breathing', 'गहरी पेट की साँस'),
    blurb: _t('Slow, grounding belly breaths', 'धीमी, मन को टिका देने वाली पेट की साँसें'),
    emoji: '🌬️',
    minutes: 5,
    phases: [
      BreathPhase(_t('Breathe in', 'साँस लीजिए'), 4, 1.0),
      BreathPhase(_t('Hold', 'रोकिए'), 2, 1.0),
      BreathPhase(_t('Breathe out', 'साँस छोड़िए'), 6, 0.5),
    ],
  ),
  GarbhPractice(
    id: 'box',
    title: _t('Box Breathing', 'चौकोर साँस'),
    blurb: _t('Steady, balancing square breath', 'बराबर लय वाली, संतुलन देती साँस'),
    emoji: '⬜',
    minutes: 4,
    phases: [
      BreathPhase(_t('Breathe in', 'साँस लीजिए'), 4, 1.0),
      BreathPhase(_t('Hold', 'रोकिए'), 4, 1.0),
      BreathPhase(_t('Breathe out', 'साँस छोड़िए'), 4, 0.5),
      BreathPhase(_t('Rest', 'ठहरिए'), 4, 0.5),
    ],
  ),
  GarbhPractice(
    id: 'calm',
    title: _t('Calm Breathing', 'शांत साँस'),
    blurb: _t('A simple settling breath', 'मन को थमा देने वाली सरल साँस'),
    emoji: '🍃',
    minutes: 3,
    phases: [
      BreathPhase(_t('Breathe in', 'साँस लीजिए'), 4, 1.0),
      BreathPhase(_t('Breathe out', 'साँस छोड़िए'), 6, 0.5),
    ],
  ),
  GarbhPractice(
    id: 'relax',
    title: _t('Guided Relaxation', 'निर्देशित विश्राम'),
    blurb: _t('Release tension, head to toe', 'सिर से पाँव तक तनाव छोड़िए'),
    emoji: '🧘',
    minutes: 8,
    phases: [
      BreathPhase(_t('Breathe in', 'साँस लीजिए'), 4, 1.0),
      BreathPhase(_t('Hold', 'रोकिए'), 2, 1.0),
      BreathPhase(_t('Breathe out', 'साँस छोड़िए'), 6, 0.5),
    ],
  ),
];

// ---------------------------------------------------------------------------
//  Samvad - Womb Connection prompts (one shown as "today's connection")
// ---------------------------------------------------------------------------
// Three trimester-specific sets of SPEAKING cards (read aloud to the bump), per
// the Garbh spec (Pillar 3 - Womb Connection):
//  T1 = affirmations - welcome the baby + grow the mother's own confidence.
//  T2 = expressive, multi-genre read-aloud scripts for the "peak auditory window";
//       the punctuation is deliberately dramatic (- … ! CAPS) so her voice
//       naturally rises, falls and plays, helping baby map sound.
//  T3 = visualization prompts - welcome + the birth day as a cooperative team.
// (Old generic kSamvad prompts removed; replaced by these trimester sets.)

final List<GarbhPrompt> kSamvadT1 = [
  GarbhPrompt('aff1',
      _t('Little one, you are so wanted. I am becoming your mother, and my body already knows just what to do.', 'नन्ही जान, तुम्हें कितना चाहा गया है। मैं तुम्हारी माँ बन रही हूँ, और मेरा शरीर पहले से जानता है कि उसे क्या करना है।')),
  GarbhPrompt('aff2',
      _t('My darling, every single day my heart makes a little more room for you. I am strong, and I am yours.', 'मेरी जान, हर एक दिन मेरा दिल तुम्हारे लिए थोड़ी और जगह बना लेता है। मैं मज़बूत हूँ, और मैं तुम्हारी हूँ।')),
  GarbhPrompt('aff3',
      _t('Hello, tiny love. You are safe inside me. We are learning this journey together - you and I, side by side.', 'सुनो, मेरे नन्हे प्यार। तुम मेरे भीतर सुरक्षित हो। यह सफ़र हम दोनों मिलकर सीख रहे हैं — तुम और मैं, एक साथ।')),
  GarbhPrompt('aff4',
      _t('Sweet baby, I welcome you with my whole heart. I trust my body, and I trust the gentle way you are growing.', 'मेरे प्यारे शिशु, मैं पूरे दिल से तुम्हारा स्वागत करती हूँ। मुझे अपने शरीर पर भरोसा है, और जिस नरमी से तुम बढ़ रहे हो, उस पर भी।')),
  GarbhPrompt('aff5',
      _t('I am calm, and I am ready. Every change in me is making a soft, safe home for you, my little one.', 'मैं शांत हूँ, और मैं तैयार हूँ। मुझमें होने वाला हर बदलाव तुम्हारे लिए एक नरम, सुरक्षित घर बना रहा है, मेरी नन्ही जान।')),
  GarbhPrompt('aff6',
      _t('You are already loved beyond measure. Today I am kind to myself, so I can be kind to you.', 'तुमसे कितना प्यार है, इसका कोई नाप नहीं। आज मैं ख़ुद के साथ नरम हूँ, ताकि तुम्हारे साथ भी नरम रह सकूँ।')),
];

final List<GarbhPrompt> kSamvadT2 = [
  GarbhPrompt('scr1',
      _t("Once upon a time, there was a tiny seed… who dreamed of touching the SKY. 'I'm far too small!' it sighed. But the soft rain whispered, 'Just grow - one little leaf at a time.' And do you know what happened, my love? That tiny seed became a GREAT, tall tree!", 'बहुत पहले की बात है — एक नन्हा-सा बीज था… जो आसमान को छूने का सपना देखता था। \'मैं तो बहुत छोटा हूँ!\' उसने आह भरी। पर हल्की बारिश धीरे से बोली, \'बस बढ़ते रहो — एक बार में एक पत्ता।\' और पता है फिर क्या हुआ, मेरी जान? वही नन्हा बीज एक बहुत बड़ा, ऊँचा पेड़ बन गया!')),
  GarbhPrompt('scr2',
      _t("Knock, knock! Who's there? It's the morning sun, peeking through the window - 'Good morning, little one!' it calls. And the birds all answer, 'Tweet! Tweet! Wake UP - it's a beautiful day!'", 'खट, खट! कौन है भला? अरे, यह तो सुबह का सूरज है, खिड़की से झाँकता हुआ — \'सुप्रभात, नन्ही जान!\' वह पुकारता है। और सारी चिड़ियाँ जवाब देती हैं, \'चीं! चीं! उठो — कितना प्यारा दिन है!\'')),
  GarbhPrompt('scr3',
      _t("Listen… can you hear me? My voice goes soft and low… and then - bright and HIGH! This is how we'll talk, you and I. One day you'll giggle right back - and oh, how I cannot WAIT to hear it!", 'सुनो… मेरी आवाज़ सुनाई दे रही है? कभी मैं धीरे से बोलती हूँ, बहुत नरम… और फिर — एकदम चहककर, ऊँचे सुर में! ऐसे ही तो बातें करेंगे हम, तुम और मैं। एक दिन तुम खिलखिलाकर जवाब दोगे — और उस हँसी को सुनने का मुझे कितना इंतज़ार है!')),
  GarbhPrompt('scr4',
      _t("Let me tell you about a clever little crow. He was SO thirsty! He found a pot - but the water sat low, low, low. 'What shall I do?' he wondered… Then - plop! plop! PLOP! - in went the pebbles, and the water rose UP. Clever crow! We never give up, do we, my love?", 'सुनो, एक चतुर नन्हे कौवे की बात बताती हूँ। उसे बहुत, बहुत प्यास लगी थी! उसे एक घड़ा मिला — पर पानी नीचे, बहुत नीचे था। \'अब क्या करूँ?\' उसने सोचा… और फिर — छपाक! छपाक! छपाक! — कंकड़ गिरते गए, और पानी ऊपर आ गया। वाह, चतुर कौवा! हम भी हार नहीं मानते, है ना, मेरी जान?')),
  GarbhPrompt('scr5',
      _t("Round and round the garden hums a gentle bee. Buzz, buzz, BUZZ! 'Hello, flowers!' she sings. And every flower nods - 'Hello, busy bee!' What a happy, humming, wonderful day.", 'बगिया में गोल-गोल घूमती एक नन्ही मधुमक्खी गुनगुनाती है। भन्न, भन्न, भन्न! \'नमस्ते, फूलो!\' वह गाती है। और हर फूल सिर हिलाकर कहता है — \'नमस्ते, मेहनती मधुमक्खी!\' कितना ख़ुश, कितना गुनगुनाता, कितना प्यारा दिन।')),
];

final List<GarbhPrompt> kSamvadT3 = [
  GarbhPrompt('vis1',
      _t('Close your eyes with me, little one. Picture the day we meet - soft light, gentle hands, and the voice you already know so well. We will do this together, as a team.', 'मेरे साथ आँखें बंद करो, नन्ही जान। उस दिन को देखो जब हम मिलेंगे — हल्की रोशनी, नरम हाथ, और वही आवाज़ जिसे तुम पहले से इतना पहचानते हो। हम यह साथ मिलकर करेंगे, एक टीम की तरह।')),
  GarbhPrompt('vis2',
      _t('Soon, my love, you will make your way toward my arms. I am strong, you are strong, and we move as one. I am right here, and I will welcome you.', 'जल्द ही, मेरी जान, तुम अपना रास्ता बनाते हुए मेरी बाँहों तक आओगे। मैं मज़बूत हूँ, तुम मज़बूत हो, और हम दोनों एक होकर चलते हैं। मैं यहीं हूँ, और मैं तुम्हारा स्वागत करूँगी।')),
  GarbhPrompt('vis3',
      _t('Imagine it, sweet baby: the very first time I hold you on my chest. Your tiny breath and my steady heartbeat - the two sounds you have always known, finally together.', 'ज़रा सोचो, मेरे प्यारे शिशु — वह पहला पल जब मैं तुम्हें अपने सीने से लगाऊँगी। तुम्हारी नन्ही साँस और मेरे दिल की एकसार धड़कन — वही दो आवाज़ें जिन्हें तुम हमेशा से जानते हो, आख़िरकार एक साथ।')),
  GarbhPrompt('vis4',
      _t('On your birth day, we are a team. When you are ready, you will show me the way, and I will breathe you gently into the world. I trust you, and I trust us.', 'तुम्हारे जन्म के दिन हम एक टीम हैं। जब तुम तैयार होगे, तुम मुझे रास्ता दिखाओगे, और मैं अपनी साँसों से तुम्हें नरमी से इस दुनिया में ले आऊँगी। मुझे तुम पर भरोसा है, और हम दोनों पर भी।')),
  GarbhPrompt('vis5',
      _t('Picture us, little one - you nestled close, me holding you near. Whatever the day brings, we meet it together. You are not arriving alone; I am right here with you.', 'हम दोनों को देखो, नन्ही जान — तुम मुझसे सटे हुए, मैं तुम्हें अपने पास थामे हुए। वह दिन जो भी लेकर आए, हम उसका सामना साथ करेंगे। तुम अकेले नहीं आ रहे; मैं यहीं, तुम्हारे साथ हूँ।')),
];

/// The speaking-cards for trimester [t]: affirmations (1) → read-aloud scripts
/// (2) → visualizations (3).
List<GarbhPrompt> samvadForTrimester(int t) =>
    t <= 1 ? kSamvadT1 : (t == 2 ? kSamvadT2 : kSamvadT3);

// ---------------------------------------------------------------------------
//  Lookups
// ---------------------------------------------------------------------------
GarbhAudio? shravanById(String id) {
  for (final a in kShravan) {
    if (a.id == id) return a;
  }
  return null;
}

GarbhStory? vicharaById(String id) {
  for (final s in kVichara) {
    if (s.id == id) return s;
  }
  return null;
}

GarbhPractice? kriyaById(String id) {
  for (final p in kKriya) {
    if (p.id == id) return p;
  }
  return null;
}

/// Today's connection card, rotating gently by day - from the set that matches
/// the mother's [trimester] (affirmation / read-aloud script / visualization).
GarbhPrompt promptForDay(int day, int trimester) {
  final list = samvadForTrimester(trimester);
  return list[(day.clamp(1, 280) - 1) % list.length];
}

// ===========================================================================
//  v2.0 - trimester engine + per-pillar "today" pickers
// ===========================================================================
int garbhTrimester(int week) => week <= 13 ? 1 : (week <= 27 ? 2 : 3);

// --- Shravan (today's listening session) ---
GarbhAudio shravanForTrimester(int t) {
  switch (t) {
    case 1:
      return shravanById('morning_raga') ?? kShravan.first;
    case 2:
      return shravanById('bonding_raga') ?? kShravan.first;
    default:
      return shravanById('relax_raga') ?? kShravan.first;
  }
}

LocalizedText shravanWhy(int t) {
  switch (t) {
    case 1:
      return _t('Calming sound can ease early-pregnancy stress and help you settle into the day.', 'शांत करने वाली आवाज़ शुरुआती गर्भावस्था का तनाव हल्का कर सकती है और दिन में मन जमने में मदद करती है।');
    case 2:
      return _t('Your baby is beginning to hear - gentle melodies are soothing for you both.', 'आपका शिशु सुनना शुरू कर रहा है — कोमल धुनें आप दोनों के लिए सुकून भरी हैं।');
    default:
      return _t('Calming music may help create a relaxing environment as birth approaches.', 'जन्म पास आते-आते शांत संगीत एक सुकून भरा माहौल बनाने में मदद कर सकता है।');
  }
}

// --- Vichara: Sacred Insights ---
final List<GarbhInsight> _insights = [
  GarbhInsight(
    sloka: _t('Begin gently; the smallest steady step still moves you forward.', 'नरमी से शुरू कीजिए; सबसे छोटा लेकिन थमा हुआ क़दम भी आगे ले जाता है।'),
    meaning: _t('You do not have to do everything at once - showing up softly is enough.', 'सब कुछ एक साथ करना ज़रूरी नहीं — बस धीरे से हाज़िर हो जाना काफ़ी है।'),
    lesson: _t('Consistency, not intensity, builds calm.', 'शांति ज़ोर से नहीं, निरंतरता से बनती है।'),
    reflection: _t('What is one small, kind thing you can do for yourself today?', 'आज आप अपने लिए कौन-सी एक छोटी, नरम बात कर सकती हैं?'),
  ),
  GarbhInsight(
    sloka: _t('A calm mind is a quiet gift you pass to your child.', 'शांत मन एक चुपचाप दिया गया तोहफ़ा है, जो आप अपने बच्चे तक पहुँचाती हैं।'),
    meaning: _t('Your peace becomes your baby\'s first felt experience of the world.', 'आपका सुकून ही वह पहला अनुभव है जिससे आपका शिशु दुनिया को महसूस करता है।'),
    lesson: _t('Tending to your own calm is also caring for your baby.', 'अपनी शांति सँभालना भी शिशु की देखभाल है।'),
    reflection: _t('What helped you feel most at ease this week?', 'इस हफ़्ते किस चीज़ ने आपको सबसे ज़्यादा सुकून दिया?'),
  ),
  GarbhInsight(
    sloka: _t('Trust the body that has carried you this far.', 'जिस शरीर ने आपको यहाँ तक पहुँचाया है, उस पर भरोसा रखिए।'),
    meaning: _t('As birth nears, confidence and rest matter as much as preparation.', 'जन्म पास आते-आते, तैयारी जितना ही ज़रूरी है भरोसा और आराम।'),
    lesson: _t('Strength can be soft - trusting is its own kind of courage.', 'ताक़त नरम भी हो सकती है — भरोसा करना अपने आप में एक साहस है।'),
    reflection: _t('What are you most looking forward to about meeting your baby?', 'शिशु से मिलने की बात सोचकर आपको सबसे ज़्यादा किसका इंतज़ार है?'),
  ),
];
GarbhInsight insightForTrimester(int t) => _insights[(t - 1).clamp(0, 2)];

/// All Sacred-Insight verses (used by the Tools library - the full repository).
List<GarbhInsight> garbhAllInsights() => _insights;

// --- Vichara: Brain Fitness (gentle puzzles for focused calm) ---
final List<GarbhPuzzle> kPuzzles = [
  GarbhPuzzle(_t('Word Search', 'शब्द खोज'), '🔤', _t('Find the hidden words - a quiet few minutes.', 'छिपे हुए शब्द ढूँढ़िए — कुछ शांत मिनट।')),
  GarbhPuzzle(_t('Sudoku', 'सुडोकू'), '🔢', _t('A gentle number puzzle to settle a busy mind.', 'व्यस्त मन को थमाने के लिए एक हल्की अंक पहेली।')),
  GarbhPuzzle(_t('Logic Puzzle', 'तर्क पहेली'), '🧩', _t('A light brain-teaser for focused calm.', 'ध्यान टिकाने वाली एक हल्की दिमाग़ी पहेली।')),
  GarbhPuzzle(_t('Memory Match', 'याददाश्त जोड़ी'), '🃏', _t('A simple memory game to relax into.', 'आराम से खेलने लायक एक सरल याददाश्त का खेल।')),
];

// --- Samvad: "why this matters" line per trimester (cards rotate by day) ---
LocalizedText samvadThemeForTrimester(int t) {
  switch (t) {
    case 1:
      return _t('Say these affirmations aloud - welcome your baby, and let your own confidence grow with every word.', 'ये संकल्प बोलकर कहिए — अपने शिशु का स्वागत कीजिए, और हर शब्द के साथ अपना भरोसा भी बढ़ने दीजिए।');
    case 2:
      return _t("Your baby's hearing is awake now. Read aloud with feeling - let your voice rise, fall and play, so they learn its music.", 'आपके शिशु की सुनने की शक्ति अब जाग चुकी है। भाव से बोलकर पढ़िए — आवाज़ को ऊपर उठने दीजिए, नीचे आने दीजिए, खेलने दीजिए, ताकि शिशु उसका संगीत पहचान ले।');
    default:
      return _t('Picture the day you meet, and speak it softly - you and your baby, a team getting ready together.', 'उस दिन की तस्वीर मन में लाइए जब आप मिलेंगे, और उसे धीरे से बोलिए — आप और आपका शिशु, साथ मिलकर तैयार होती एक टीम।');
  }
}

// --- Kriya: today's practice + a safety note ---
GarbhPractice kriyaForTrimester(int t) {
  switch (t) {
    case 1:
      return kriyaById('calm') ?? kKriya.first;
    case 2:
      return kriyaById('deep_belly') ?? kKriya.first;
    default:
      return kriyaById('bhramari') ?? kKriya.first;
  }
}

LocalizedText kriyaSafety(int t) {
  switch (t) {
    case 1:
      return _t('Move gently and stop if you feel dizzy or unwell.', 'नरमी से हिलिए-डुलिए, और चक्कर या तकलीफ़ लगे तो रुक जाइए।');
    case 2:
      return _t('Avoid lying flat on your back for long; keep movements slow.', 'देर तक सीधी पीठ के बल लेटने से बचिए; हरकतें धीमी रखिए।');
    default:
      return _t('Support your bump, go slow, and rest whenever you need to.', 'बंप को सहारा दीजिए, धीरे चलिए, और जब भी ज़रूरत लगे आराम कीजिए।');
  }
}

// --- Ahara: Nourishment per trimester ---
final List<GarbhNutrition> _nutrition = [
  GarbhNutrition(
    tip: _t('Sip water through the day and eat small, frequent meals.', 'दिन भर थोड़ा-थोड़ा पानी पीती रहिए और थोड़े-थोड़े अंतराल पर हल्का खाइए।'),
    why: _t('Steady hydration and small meals ease nausea and keep energy stable in the first trimester.', 'लगातार पानी और छोटे-छोटे आहार पहली तिमाही में मतली कम करते हैं और ऊर्जा एक-सी बनाए रखते हैं।'),
    recipe: _t('Lemon-ginger water with a few soaked almonds.', 'नींबू-अदरक का पानी और कुछ भीगे बादाम।'),
    swap: _t('Swap one heavy meal for lighter, frequent snacks.', 'एक भारी भोजन की जगह हल्के, थोड़े-थोड़े नाश्ते ले लीजिए।'),
    habit: _t('Keep a glass of water by your bed for the morning.', 'सुबह के लिए एक गिलास पानी बिस्तर के पास रख लीजिए।'),
  ),
  GarbhNutrition(
    tip: _t('Add a good source of protein and iron to today\'s meals.', 'आज के खाने में Protein और Iron का एक अच्छा स्रोत जोड़ लीजिए।'),
    why: _t('The second trimester is a growth phase - protein, iron and healthy fats support it.', 'दूसरी तिमाही बढ़त का दौर है — Protein, Iron और अच्छी वसा इसे सहारा देते हैं।'),
    recipe: _t('Moong dal khichdi with a side of curd.', 'मूँग दाल की खिचड़ी, साथ में दही।'),
    swap: _t('Swap white rice for a dal-and-vegetable bowl.', 'सफ़ेद चावल की जगह दाल और सब्ज़ी का एक कटोरा लीजिए।'),
    habit: _t('Pair iron-rich food with vitamin C (lemon, amla) for absorption.', 'Iron वाले खाने के साथ Vitamin C (नींबू, आँवला) लीजिए, ताकि वह अच्छे से सोखा जाए।'),
  ),
  GarbhNutrition(
    tip: _t('Focus on fibre and a light, early dinner.', 'फ़ाइबर पर ध्यान दीजिए और रात का खाना हल्का और जल्दी रखिए।'),
    why: _t('Fibre eases the constipation common late in pregnancy, and a light dinner supports sleep.', 'फ़ाइबर गर्भावस्था के आख़िरी दौर में आम कब्ज़ को आसान करता है, और हल्का रात का खाना नींद में मदद करता है।'),
    recipe: _t('Vegetable soup with a fruit for dessert.', 'सब्ज़ियों का सूप, और मीठे में एक फल।'),
    swap: _t('Swap a late, heavy dinner for a lighter early one.', 'देर रात के भारी खाने की जगह जल्दी और हल्का खाना लीजिए।'),
    habit: _t('Dim the lights and screens an hour before bed.', 'सोने से एक घंटा पहले रोशनी और स्क्रीन धीमी कर दीजिए।'),
  ),
];
GarbhNutrition nutritionForTrimester(int t) => _nutrition[(t - 1).clamp(0, 2)];

// ===========================================================================
//  Daily rotation pickers - used ONLY by the Home daily Garbh section, where
//  each pillar shows a different item each day (no recommendation lists). The
//  full Tools Garbh keeps the trimester pickers above.
// ===========================================================================
int _dayIdx(int day, int n) => (day.clamp(1, 280) - 1) % n;

List<GarbhAudio> get _dailyRagas =>
    kShravan.where((a) => a.kind == GarbhKind.raga).toList();

/// A different raga each day (cycles through the raga set).
GarbhAudio shravanForDay(int day) {
  final r = _dailyRagas;
  return r[_dayIdx(day, r.length)];
}

/// A different sacred insight each day.
GarbhInsight insightForDay(int day) => _insights[_dayIdx(day, _insights.length)];

/// One uplifting read per day (rotates through the library).
GarbhStory vicharaStoryForDay(int day) => kVichara[_dayIdx(day, kVichara.length)];

/// A different breath practice each day.
GarbhPractice kriyaForDay(int day) => kKriya[_dayIdx(day, kKriya.length)];

/// A different nourishment focus each day.
GarbhNutrition nutritionForDay(int day) =>
    _nutrition[_dayIdx(day, _nutrition.length)];

// ===========================================================================
//  v2.1 - Shravan month view + raga time-of-day badges (ADDITIVE)
// -----------------------------------------------------------------------------
//  The Shravan library is now browsed month-by-month (Month 1-9) instead of all
//  at once. kShravan items are NOT month-tagged, so we distribute the library
//  across the 9 pregnancy months here. Backward-compatible: kShravan, the daily
//  pickers and lookups above are untouched.
// ===========================================================================

/// Which pregnancy month (1-9) a given [week] falls in. 40 weeks over 9 months
/// (~4.4 weeks each), clamped to 1..9.
int garbhMonth(int week) =>
    ((week - 1) / 4.4).floor().clamp(0, 8) + 1;

/// TODO: approximation - real per-month audio curation not yet available, so the
/// existing 10 kShravan items are hand-distributed across the 9 months (some
/// months share popular ragas). Replace with month-specific recordings later.
final Map<int, List<String>> kShravanMonthIds = {
  1: ['morning_raga', 'relax_raga'],
  2: ['bonding_raga', 'forest'],
  3: ['evening_raga', 'bells'],
  4: ['relax_raga', 'rain'],
  5: ['bonding_raga', 'ocean'],
  6: ['morning_raga', 'forest', 'bells'],
  7: ['sleep_raga', 'rain'],
  8: ['evening_raga', 'bodyscan'],
  9: ['sleep_raga', 'ocean', 'bodyscan'],
};

/// The listening sessions curated for pregnancy [month] (1-9).
List<GarbhAudio> shravanForMonth(int month) {
  final ids = kShravanMonthIds[month.clamp(1, 9)] ?? const <String>[];
  return [for (final id in ids) shravanById(id)]
      .whereType<GarbhAudio>()
      .toList();
}

/// A gentle time-of-day badge for a listening item, derived from its existing
/// title/subtitle/id hints. Falls back to 'Morning'. Returns 'Morning' or
/// 'Evening' (English; the UI supplies its own bilingual label if needed).
String ragaTimeBadge(GarbhAudio a) {
  // .en on BOTH sides on purpose. This classifies by matching English keyword
  // hints, so it must read the English text no matter what is on screen -
  // otherwise in Hindi the haystack is Devanagari, no hint ever matches, and
  // every raga silently badges as Morning. It compiles and every test passes;
  // the only symptom is a wrong badge.
  final hint = '${a.id} ${a.title.en} ${a.subtitle.en}'.toLowerCase();
  const eveningHints = [
    'evening', 'sleep', 'night', 'moon', 'unwind', 'rest', 'ocean', 'rain'
  ];
  // The returned token is an English CONSTANT, not copy: garbh_screen.dart
  // compares it with `== 'Evening'`. Translating it here would make that
  // comparison false in Hindi. The screen supplies its own bilingual label.
  for (final h in eveningHints) {
    if (hint.contains(h)) return 'Evening';
  }
  return 'Morning';
}
