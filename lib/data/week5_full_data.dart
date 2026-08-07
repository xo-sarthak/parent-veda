// =============================================================================
//  Week 5 — FULL page content (bilingual)
// -----------------------------------------------------------------------------
//  The complete, doc-faithful Week 5 content authored for the "Full" weekly
//  flow (Week5FullFlowView), a preview alternative to the schema-driven V2 flow.
//  Sections mirror the content doc exactly: Opening Snapshot · About Your Baby ·
//  Baby Science · You This Week · Health (Symptoms + Diet) · Trimester Tips ·
//  Share With Partner. Every leaf is a bilingual LocalizedText (en + romanised
//  Hinglish). Medical framing kept non-diagnostic; a doctor disclaimer is shown
//  by the screen. Not wired to weekContent.json on purpose — this is the richer
//  shape we may later promote into the schema for all weeks.
// =============================================================================

import '../localization/app_language.dart';

LocalizedText _t(String en, String hi) => LocalizedText(en: en, hi: hi);

// ---- section models ---------------------------------------------------------
class W5Snapshot {
  const W5Snapshot({required this.fruit, required this.length, required this.weight});
  final LocalizedText fruit;
  final LocalizedText length;
  final LocalizedText weight;
}

class W5About {
  const W5About({
    required this.teaser,
    required this.opening,
    required this.howBig,
    required this.whatsHappening,
    this.behaviour = const [],
  });
  final LocalizedText teaser; // cover teaser (before tap)
  final LocalizedText opening;
  final LocalizedText howBig;
  final LocalizedText whatsHappening;

  /// "Behavioural highlights" — rendered inline as a heading + description on
  /// the expanded page, deliberately not a tappable card.
  final List<W5Card> behaviour;
}

class W5Card {
  const W5Card({required this.title, required this.body});
  final LocalizedText title;
  final LocalizedText body;
}

class W5Highlight {
  const W5Highlight({required this.title, required this.teaser, required this.body});
  final LocalizedText title;
  final LocalizedText teaser;
  final LocalizedText body;
}

class W5You {
  const W5You({
    required this.feeling,
    required this.changingBody,
    required this.beKind,
    required this.highlights,
    required this.selfCare,
  });
  final LocalizedText feeling;
  final LocalizedText changingBody;
  final LocalizedText beKind;
  final List<W5Highlight> highlights;
  final LocalizedText selfCare;
}

class W5Symptom {
  const W5Symptom({
    required this.name,
    required this.teaser,
    required this.howCommon,
    required this.why,
    required this.helps,
    required this.whenDoctor,
  });
  final LocalizedText name;
  final LocalizedText teaser;
  final LocalizedText howCommon;
  final LocalizedText why;
  final List<LocalizedText> helps;
  final LocalizedText whenDoctor;
}

class W5Superfood {
  const W5Superfood({
    required this.food,
    required this.benefit,
    required this.tryAs,
    required this.note,
  });
  final LocalizedText food;
  final LocalizedText benefit;
  final LocalizedText tryAs;
  final LocalizedText note;
}

class W5Diet {
  const W5Diet({required this.superfood, required this.favour, required this.avoid});
  final W5Superfood superfood;
  final List<W5Card> favour;
  final List<W5Card> avoid;
}

class W5Tip {
  const W5Tip({required this.oneLine, required this.readMore});
  final LocalizedText oneLine;
  final LocalizedText readMore;
}

class W5Scan {
  const W5Scan({required this.name, required this.window});
  final LocalizedText name;
  final LocalizedText window;
}

class W5Partner {
  const W5Partner({
    required this.baby,
    required this.mother,
    required this.scans,
    required this.help,
  });
  final LocalizedText baby;
  final LocalizedText mother;
  final List<W5Scan> scans;
  final List<LocalizedText> help;
}

class Week5Full {
  const Week5Full({
    required this.trimesterMonth,
    required this.snapshot,
    required this.about,
    required this.science,
    required this.you,
    required this.symptoms,
    required this.diet,
    required this.tips,
    required this.partner,
  });
  final LocalizedText trimesterMonth;
  final W5Snapshot snapshot;
  final W5About about;
  final List<W5Card> science;
  final W5You you;
  final List<W5Symptom> symptoms;
  final W5Diet diet;
  final List<W5Tip> tips;
  final W5Partner partner;
}

// =============================================================================
//  THE CONTENT
// =============================================================================
final Week5Full week5Full = Week5Full(
  trimesterMonth: _t('Trimester 1 · Month 3', 'तिमाही 1 · महीना 3'),

  // ---- 1 · Opening Snapshot -------------------------------------------------
  snapshot: W5Snapshot(
    fruit: _t('Strawberry', 'स्ट्रॉबेरी'),
    length: _t('3.1 to 3.2 cm', '3.1 से 3.2 cm'),
    weight: _t('About 4 g', 'लगभग 4 g'),
  ),

  // ---- 2 · About Your Baby --------------------------------------------------
  about: W5About(
    teaser: _t(
      "This week my fingers and toes finally separate completely, and tiny nails begin to grow. I'm about the size of a strawberry now.", 'इस हफ़्ते मेरे हाथ और पैर की उँगलियाँ आख़िरकार पूरी तरह अलग हो जाती हैं, और नन्हे नाख़ून बनने लगते हैं। अब मेरा आकार लगभग एक स्ट्रॉबेरी जितना है।',
    ),
    opening: _t(
      "I've grown to about the size of a strawberry this week, and I'm looking more like a tiny person every day. My fingers and toes have fully separated, and my head still makes up about half of my length.", 'इस हफ़्ते बढ़कर मेरा आकार लगभग एक स्ट्रॉबेरी जितना हो गया है, और हर दिन मेरी शक्ल थोड़ी और एक नन्हे इंसान जैसी लगने लगी है। मेरे हाथ और पैर की उँगलियाँ पूरी तरह अलग हो चुकी हैं, और मेरा सिर अब भी मेरी लंबाई का लगभग आधा हिस्सा है।',
    ),
    howBig: _t(
      "I'm about 3.1 to 3.2 centimetres long now, roughly the size of a strawberry, and I weigh about 4 grams.", 'अब मेरी लंबाई लगभग 3.1 से 3.2 सेंटीमीटर है, मोटे तौर पर एक स्ट्रॉबेरी जितनी, और मेरा वज़न लगभग 4 ग्राम है।',
    ),
    whatsHappening: _t(
      "My fingers and toes have completely separated this week, with no more webbing, and tiny nails are just beginning to grow. My skeleton keeps turning from soft cartilage into bone, and my ears are taking their outer shape. I'm swallowing tiny sips of fluid and kicking my legs, simply practising movements I'll need later. My head still makes up about half of my length because my brain is growing so quickly.", 'इस हफ़्ते मेरे हाथ और पैर की उँगलियाँ पूरी तरह अलग हो चुकी हैं, बीच की झिल्ली अब नहीं रही, और नन्हे नाख़ून अभी-अभी बनने लगे हैं। मेरा ढाँचा नरम cartilage से हड्डी में बदलता जा रहा है, और मेरे कानों की बाहरी बनावट उभर रही है। आसपास के पानी के नन्हे घूँट भरना और पैर चलाना भी शुरू हो गया है — बस उन हरकतों का अभ्यास, जो आगे चलकर मेरे काम आएँगी। मेरा सिर अब भी मेरी लंबाई का लगभग आधा है, क्योंकि मेरा दिमाग़ इतनी तेज़ी से बढ़ रहा है।',
    ),
    // Shown inline as a heading + description, not a tappable card.
    behaviour: [
      W5Card(
        title: _t("I'm swallowing and kicking", 'मैं निगल रहा हूँ और लात मार रहा हूँ'),
        body: _t(
          "This week I'm becoming a little more active, swallowing tiny sips of the fluid around me and kicking my legs. These movements help my muscles, joints and nervous system develop, even though I don't need them for feeding or moving around just yet. You can't feel any of it, but if you had a scan now, you might just catch me in action.", 'इस हफ़्ते मेरी हलचल थोड़ी और बढ़ गई है — आसपास के पानी के नन्हे घूँट भरना, और पैर चलाना। ये हरकतें मेरी मांसपेशियों, जोड़ों और तंत्रिका तंत्र को बनने में मदद करती हैं, हालाँकि अभी न मुझे खाने के लिए इनकी ज़रूरत है, न इधर-उधर जाने के लिए। आपको इनमें से कुछ भी महसूस नहीं होगा, पर अगर अभी स्कैन हो, तो शायद आप मुझे हरकत करते हुए देख भी लें।',
        ),
      ),
    ],
  ),

  // ---- 3 · Baby Science -----------------------------------------------------
  science: [
    W5Card(
      title: _t('My fingers and toes are free', 'मेरी उँगलियाँ अब अलग-अलग हो गई हैं'),
      body: _t(
        "This week my fingers and toes have fully separated, with the webbing between them completely gone. My thumbs have rotated into place, ready for gripping and holding one day. For now, I'm simply getting used to having my own separate fingers and toes.", 'इस हफ़्ते मेरे हाथ और पैर की उँगलियाँ पूरी तरह अलग हो चुकी हैं, और उनके बीच की झिल्ली बिलकुल ख़त्म हो गई है। मेरे अंगूठे घूमकर अपनी जगह पर आ गए हैं — एक दिन पकड़ने और थामने के लिए तैयार। फ़िलहाल तो बस अपनी अलग-अलग उँगलियों की आदत पड़ रही है।',
      ),
    ),
    W5Card(
      title: _t('My nails are starting to grow', 'मेरे नाख़ून बनने लगे हैं'),
      body: _t(
        "Tiny nails are just beginning to grow at the ends of my fingers and toes this week. They're barely there for now, more like the faintest suggestion of a nail than anything you'd recognise. Over the coming weeks and months, they'll keep growing, all the way until the day you first trim them.", 'इस हफ़्ते मेरे हाथ और पैर की उँगलियों के सिरों पर नन्हे नाख़ून बनने लगे हैं। अभी वे मुश्किल से हैं — नाख़ून की सबसे हल्की झलक भर, ऐसा कुछ नहीं जिसे आप पहचान सकें। आने वाले हफ़्तों और महीनों में वे बढ़ते रहेंगे, उस दिन तक जब आप पहली बार उन्हें काटेंगी।',
      ),
    ),
    W5Card(
      title: _t('My skeleton keeps turning to bone', 'मेरा ढाँचा धीरे-धीरे हड्डी बनता जा रहा है'),
      body: _t(
        "My skeleton keeps turning to bone this week, with ossification now underway in many more places than before. Bit by bit, the soft cartilage that has held my shape so far is being replaced by harder, stronger bone. It's a slow process that will continue quietly for months, long after I'm born.", 'इस हफ़्ते मेरा ढाँचा हड्डी में बदलता जा रहा है, और ossification अब पहले से कहीं ज़्यादा जगहों पर चल रही है। थोड़ा-थोड़ा करके, जो नरम cartilage अब तक मेरा आकार सँभाले हुए था, उसकी जगह ज़्यादा सख़्त और मज़बूत हड्डी ले रही है। यह एक धीमी प्रक्रिया है, जो महीनों तक चुपचाप चलती रहेगी — मेरे जन्म के बहुत बाद तक।',
      ),
    ),
    W5Card(
      title: _t('My ears are taking their outer shape', 'मेरे कानों की बाहरी बनावट उभर रही है'),
      body: _t(
        "The outer shape of my ears is coming together this week, slowly moving into the familiar shell-like form you'll recognise. They still have some settling to do, gradually shifting into their final position on the sides of my head. One day soon, they'll be ready to catch every sound around them.", 'इस हफ़्ते मेरे कानों की बाहरी बनावट उभर रही है, धीरे-धीरे उसी जानी-पहचानी सीपी जैसी शक्ल में आती हुई। उन्हें अभी थोड़ा और सँवरना है, धीरे-धीरे मेरे सिर के दोनों किनारों पर अपनी आख़िरी जगह पर पहुँचते हुए। एक दिन, बहुत जल्द, वे आसपास की हर आवाज़ पकड़ने के लिए तैयार होंगे।',
      ),
    ),
    W5Card(
      title: _t('My kidneys are building their filters', 'मेरी kidney अपने छन्ने बना रही हैं'),
      body: _t(
        "The tiny filtering units inside my kidneys are continuing to develop this week. They're not ready to do their real job yet, but this is important groundwork being laid. In time, these filters will help keep my blood clean and support the fluid around me.", 'इस हफ़्ते मेरी kidney के अंदर के नन्हे छन्ने बनते जा रहे हैं। वे अभी अपना असली काम करने के लिए तैयार नहीं हैं, पर यह ज़रूरी नींव अभी रखी जा रही है। आगे चलकर ये छन्ने मेरा ख़ून साफ़ रखने और मेरे आसपास के पानी को सँभालने में मदद करेंगे।',
      ),
    ),
    W5Card(
      title: _t('My organs are starting to work together', 'मेरे अंग आपस में तालमेल बिठाने लगे हैं'),
      body: _t(
        "By now, all of my major organs have formed, and this week they're beginning to work together as a team. None of them can do their full jobs on their own yet, but this teamwork is an important step. From here, it's less about building new parts and more about everything maturing together.", 'अब तक मेरे सभी बड़े अंग बन चुके हैं, और इस हफ़्ते वे एक टीम की तरह साथ काम करने लगे हैं। कोई भी अभी अकेले अपना पूरा काम नहीं कर सकता, पर यह तालमेल एक ज़रूरी क़दम है। यहाँ से बात नए हिस्से बनाने की कम है, और सबके साथ-साथ पकने की ज़्यादा।',
      ),
    ),
    W5Card(
      title: _t('My brain is producing millions of nerve cells', 'मेरा दिमाग़ लाखों तंत्रिका कोशिकाएँ बना रहा है'),
      body: _t(
        "My brain keeps producing new nerve cells at an incredible rate this week, roughly 250,000 every single minute. This pace will continue throughout the rest of pregnancy, eventually building the complex web of connections behind everything I'll one day think, feel and do.", 'इस हफ़्ते मेरा दिमाग़ ग़ज़ब की रफ़्तार से नई तंत्रिका कोशिकाएँ बना रहा है — लगभग 2,50,000 हर एक मिनट। यह रफ़्तार बाक़ी पूरी गर्भावस्था चलती रहेगी, और आगे चलकर जुड़ावों का वह पेचीदा जाल बुनेगी, जिसके पीछे एक दिन मेरा हर सोचना, हर महसूस करना और हर काम होगा।',
      ),
    ),
  ],

  // ---- 4 · You This Week ----------------------------------------------------
  you: W5You(
    feeling: _t(
      "Week 10 often marks a turning point, and for many women, symptoms start easing over the coming weeks as you near the end of the first trimester. Nausea, fatigue and headaches may still be strong right now, and some women notice new discomforts too, such as brief sharp twinges low in the belly as the uterus grows and the supporting tissues stretch. Others may already feel their symptoms beginning to lift. Whichever way it goes for you, it's completely normal. You're almost through the trickiest stretch, and many women start to feel more like themselves again very soon.", 'हफ़्ता 10 अक्सर एक मोड़ होता है, और बहुत सी महिलाओं के लिए आने वाले हफ़्तों में लक्षण हल्के पड़ने लगते हैं, जैसे-जैसे आप पहली तिमाही के अंत के क़रीब आती हैं। मतली, थकान और सिर दर्द अभी भी तेज़ हो सकते हैं, और कुछ महिलाओं को नई तकलीफ़ें भी महसूस होती हैं — जैसे पेट के निचले हिस्से में पल भर की तेज़ चुभन, जब गर्भाशय बढ़ता है और उसे थामे रखने वाले ऊतक खिंचते हैं। कुछ को अपने लक्षण अभी से हल्के होते लग सकते हैं। आपके साथ जो भी हो, वह बिलकुल सामान्य है। सबसे मुश्किल हिस्सा लगभग पीछे छूट चुका है, और बहुत सी महिलाएँ जल्द ही फिर से अपने जैसा महसूस करने लगती हैं।',
    ),
    changingBody: _t(
      "You may notice your waist looking a little rounder, though for many women this is still mostly due to bloating and the growing uterus remaining within the pelvis. Veins on your breasts and tummy may look more visible as your blood volume keeps rising. Your skin might feel drier or spottier than usual, and some women begin to notice fine red thread-like lines called spider naevi, which are harmless and fade after birth. Small, steady signs that your body is working hard behind the scenes.", 'आपको अपनी कमर थोड़ी गोल लग सकती है, हालाँकि बहुत सी महिलाओं में यह अभी ज़्यादातर पेट फूलने और बढ़ते गर्भाशय की वजह से होता है, जो अभी pelvis के अंदर ही है। आपके स्तनों और पेट पर नसें पहले से ज़्यादा दिखने लग सकती हैं, क्योंकि आपके ख़ून की मात्रा बढ़ती जा रही है। आपकी त्वचा आम दिनों से ज़्यादा रूखी या दानों वाली लग सकती है, और कुछ महिलाओं को बारीक लाल धागे जैसी लकीरें दिखने लगती हैं, जिन्हें spider naevi कहते हैं — ये नुक़सान नहीं करतीं और जन्म के बाद ख़ुद ही मिट जाती हैं। छोटे-छोटे, लगातार संकेत कि आपका शरीर परदे के पीछे कितनी मेहनत कर रहा है।',
    ),
    beKind: _t(
      "If sharp twinges in your lower belly catch you off guard, it is often caused by your growing uterus and the tissues supporting it stretching, not a sign of anything wrong. Move a little slower when you stand up or sit down, rest when you need to, and be patient with your changing skin and body.", 'अगर पेट के निचले हिस्से में तेज़ चुभन आपको अचानक पकड़ ले, तो यह अक्सर बढ़ते गर्भाशय और उसे थामे रखने वाले ऊतकों के खिंचने से होती है — किसी गड़बड़ी का संकेत नहीं। उठते या बैठते वक़्त थोड़ा धीरे चलिए, जब ज़रूरत लगे आराम कीजिए, और अपनी बदलती त्वचा और शरीर के साथ थोड़ा सब्र रखिए।',
    ),
    highlights: [
      W5Highlight(
        title: _t('Round ligament twinges', 'Round ligament का खिंचाव'),
        teaser: _t(
          'Sharp, quick twinges low in your belly as your womb stretches.', 'गर्भाशय के खिंचने पर पेट के निचले हिस्से में तेज़, झटपट चुभन।',
        ),
        body: _t(
          "As your womb grows, the ligaments supporting it stretch and tighten, sometimes causing a sudden, sharp twinge low in your belly or groin. It is often caused by your growing uterus and the tissues supporting it stretching quickly, triggered by movements like standing up, coughing or laughing. Moving a little more slowly, and resting when it happens, can help ease it.", 'जैसे-जैसे आपका गर्भाशय बढ़ता है, उसे थामे रखने वाले ligaments खिंचते और कसते हैं, जिससे कभी पेट के निचले हिस्से या जाँघ के जोड़ में अचानक तेज़ चुभन होती है। यह अक्सर बढ़ते गर्भाशय और उसे सँभालने वाले ऊतकों के तेज़ी से खिंचने से होती है, और उठने, खाँसने या हँसने जैसी हरकतों से शुरू होती है। थोड़ा धीरे चलना, और जब ऐसा हो तब रुककर आराम कर लेना, इसे हल्का करने में मदद करता है।',
        ),
      ),
      W5Highlight(
        title: _t('Your visible veins', 'आपकी उभरी नसें'),
        teaser: _t(
          'More visible veins on your breasts and belly are common now.', 'स्तनों और पेट पर नसों का ज़्यादा दिखना अब आम है।',
        ),
        body: _t(
          "As your blood volume keeps rising to support your pregnancy, veins on your breasts and abdomen may become more visible than before. This is simply extra blood flow doing its job, and it isn't a cause for concern. It usually becomes less noticeable again after you give birth.", 'जैसे-जैसे गर्भावस्था को सँभालने के लिए आपके ख़ून की मात्रा बढ़ती है, आपके स्तनों और पेट पर नसें पहले से ज़्यादा दिख सकती हैं। यह बस बढ़ा हुआ ख़ून का बहाव अपना काम कर रहा है, और यह फ़िक्र की बात नहीं। जन्म के बाद ये आमतौर पर फिर से कम दिखने लगती हैं।',
        ),
      ),
      W5Highlight(
        title: _t('Your changing skin', 'आपकी बदलती त्वचा'),
        teaser: _t(
          'Dryness, spots, or fine red lines are all common right now.', 'रूखापन, दाने, या बारीक लाल लकीरें — सब अभी आम हैं।',
        ),
        body: _t(
          "Rising hormones can affect your skin in different ways this week. Some women notice dryness or a few extra spots, while some begin to notice fine, thread-like red lines called spider naevi on their chest or arms, though these are usually more common a little later on. Both are harmless and usually fade on their own after your baby arrives.", 'बढ़ते हार्मोन इस हफ़्ते आपकी त्वचा को अलग-अलग तरह से बदल सकते हैं। कुछ महिलाओं को रूखापन या थोड़े और दाने दिखते हैं, तो कुछ को अपने सीने या बाँहों पर बारीक, धागे जैसी लाल लकीरें दिखने लगती हैं, जिन्हें spider naevi कहते हैं — हालाँकि ये आमतौर पर थोड़ा आगे चलकर ज़्यादा दिखती हैं। दोनों ही नुक़सान नहीं करतीं और शिशु के आने के बाद आमतौर पर अपने आप मिट जाती हैं।',
        ),
      ),
    ],
    selfCare: _t(
      "If your first prenatal visit hasn't happened yet, it's likely coming up very soon. Keep taking your prenatal vitamin, stay hydrated, and treat yourself gently as your body keeps changing.", 'अगर आपकी पहली prenatal विज़िट अभी तक नहीं हुई, तो वह शायद बहुत जल्द आने वाली है। अपना prenatal vitamin लेती रहिए, पानी पीती रहिए, और जैसे-जैसे शरीर बदलता जाए, ख़ुद के साथ नरमी बरतिए।',
    ),
  ),

  // ---- 5 · Health · Symptoms ------------------------------------------------
  symptoms: [
    W5Symptom(
      name: _t('Nausea', 'मतली'),
      teaser: _t(
        'That queasy feeling that can come at any time of day. Many women begin noticing improvement from around this stage, though for others it continues into the second trimester.', 'वह जी मिचलाने जैसा एहसास, जो दिन के किसी भी वक़्त आ सकता है। बहुत सी महिलाओं को इसी पड़ाव के आसपास से सुधार दिखने लगता है, हालाँकि कुछ के लिए यह दूसरी तिमाही तक चलता है।',
      ),
      howCommon: _t(
        'Very common, though many women notice it beginning to ease this week.', 'बहुत आम, हालाँकि बहुत सी महिलाओं को इस हफ़्ते यह हल्की होती महसूस होती है।',
      ),
      why: _t(
        'Rising pregnancy hormones, especially hCG, have been behind the queasiness. As hCG eases past its peak, nausea often follows.', 'बढ़ते गर्भावस्था के हार्मोन, ख़ासकर hCG, इस जी मिचलाने के पीछे रहे हैं। जैसे-जैसे hCG अपने सबसे ऊँचे स्तर से नीचे आता है, मतली भी अक्सर पीछे-पीछे हल्की हो जाती है।',
      ),
      helps: [
        _t('Eat small, frequent meals through the day', 'दिन भर थोड़ा-थोड़ा, बार-बार खाइए'),
        _t('Keep plain snacks like crackers or toast nearby', 'सादा नाश्ता जैसे बिस्किट या टोस्ट पास रखिए'),
        _t('Sip ginger tea, lemon water or nimbu paani', 'अदरक की चाय, नींबू पानी या शिकंजी पीजिए'),
        _t('Avoid smells that set off your nausea', 'जिन गंधों से मतली बढ़े, उनसे दूर रहिए'),
      ],
      whenDoctor: _t(
        'If you cannot keep food or fluids down, or are losing weight, call your doctor.', 'अगर खाना या पानी अंदर टिक ही न पा रहा हो, या वज़न घट रहा हो, तो अपने डॉक्टर को फ़ोन कीजिए।',
      ),
    ),
    W5Symptom(
      name: _t('Fatigue', 'थकान'),
      teaser: _t(
        'A heavy tiredness that can hit even after a full night\'s sleep. Common through this trimester.', 'एक भारी थकान, जो पूरी रात सोने के बाद भी आ सकती है। इस तिमाही भर आम है।',
      ),
      howCommon: _t(
        'Very common, and still noticeable for many women at this stage.', 'बहुत आम, और इस पड़ाव पर बहुत सी महिलाओं को अब भी महसूस होती है।',
      ),
      why: _t(
        'Rising progesterone can make you feel sleepier, while your body uses extra energy to build the placenta and support your pregnancy.', 'बढ़ता progesterone आपको ज़्यादा नींद में रख सकता है, और साथ ही आपका शरीर placenta बनाने और गर्भावस्था को सँभालने में अलग से ऊर्जा लगाता है।',
      ),
      helps: [
        _t('Rest whenever you can, even short naps', 'जब भी मौक़ा मिले आराम कीजिए, छोटी झपकी भी'),
        _t('Go to bed a little earlier than usual', 'रोज़ से थोड़ा पहले सो जाइए'),
        _t('Stay hydrated and eat regular, balanced meals', 'पानी पीती रहिए और समय पर संतुलित खाना खाइए'),
        _t('Gentle movement like a short walk can help', 'हल्की हलचल, जैसे थोड़ी देर टहलना, मदद करती है'),
      ],
      whenDoctor: _t(
        'If tiredness feels extreme, or comes with breathlessness or dizziness, mention it to your doctor.', 'अगर थकान बहुत ज़्यादा लगे, या साँस फूलने या चक्कर के साथ आए, तो अपने डॉक्टर को बताइए।',
      ),
    ),
    W5Symptom(
      name: _t('Tender breasts', 'स्तनों में नरमी और दर्द'),
      teaser: _t(
        'Fuller, heavier breasts with more visible veins as blood flow increases.', 'ख़ून का बहाव बढ़ने के साथ भरे, भारी स्तन और ज़्यादा दिखती नसें।',
      ),
      howCommon: _t(
        'Very common, and many notice ongoing growth and sensitivity this week.', 'बहुत आम, और बहुत सी महिलाओं को इस हफ़्ते लगातार बढ़ोतरी और छूने पर ज़्यादा नरमी महसूस होती है।',
      ),
      why: _t(
        'Rising hormones increase blood flow to your breasts, which can make them feel fuller and more sensitive, with veins more visible underneath the skin.', 'बढ़ते हार्मोन आपके स्तनों में ख़ून का बहाव बढ़ा देते हैं, जिससे वे ज़्यादा भरे और नरम लग सकते हैं, और त्वचा के नीचे नसें ज़्यादा दिखती हैं।',
      ),
      helps: [
        _t('Wear a soft, well-fitting supportive bra', 'नरम, सही नाप की सहारा देने वाली ब्रा पहनिए'),
        _t('Try a wireless or sleep bra at night', 'रात में बिना तार वाली या स्लीप ब्रा आज़माइए'),
        _t('Avoid tight clothing that presses on the area', 'तंग कपड़ों से बचिए जो वहाँ दबाव डालें'),
        _t('Warm or cool compresses can ease soreness', 'गुनगुनी या ठंडी सिंकाई से आराम मिलता है'),
      ],
      whenDoctor: _t(
        'If you feel a lump, or notice unusual discharge, have it checked by your doctor.', 'अगर कोई गाँठ महसूस हो, या कोई अनोखा स्राव दिखे, तो अपने डॉक्टर से जाँच करवाइए।',
      ),
    ),
    W5Symptom(
      name: _t('Headaches', 'सिर दर्द'),
      teaser: _t(
        'A dull ache in the head, often linked to hormones and blood flow. Common at this stage.', 'सिर में हल्का सा दर्द, अक्सर हार्मोन और ख़ून के बहाव से जुड़ा। इस पड़ाव पर आम है।',
      ),
      howCommon: _t(
        'Common in the first trimester, and can continue until around week 12.', 'पहली तिमाही में आम, और लगभग हफ़्ते 12 तक चल सकता है।',
      ),
      why: _t(
        'Rising hormones, increased blood volume, hunger and dehydration can all trigger headaches at this stage of pregnancy.', 'बढ़ते हार्मोन, ख़ून की बढ़ी हुई मात्रा, भूख और पानी की कमी — ये सब गर्भावस्था के इस पड़ाव पर सिर दर्द शुरू कर सकते हैं।',
      ),
      helps: [
        _t('Drink water and eat small, regular meals', 'पानी पीजिए और थोड़ा-थोड़ा, समय पर खाइए'),
        _t('Rest in a cool, quiet, dark room', 'ठंडे, शांत, अँधेरे कमरे में आराम कीजिए'),
        _t('Try a warm or cool compress on your head', 'सिर पर गुनगुनी या ठंडी सिंकाई आज़माइए'),
        _t('Get enough sleep and manage stress where you can', 'पूरी नींद लीजिए और जितना हो सके तनाव कम रखिए'),
      ],
      whenDoctor: _t(
        'If a headache is severe, will not go away, or comes with vision changes, call your doctor.', 'अगर सिर दर्द बहुत तेज़ हो, जा ही न रहा हो, या नज़र में बदलाव के साथ आए, तो अपने डॉक्टर को फ़ोन कीजिए।',
      ),
    ),
    W5Symptom(
      name: _t('Increased discharge', 'स्राव का बढ़ना'),
      teaser: _t(
        'More vaginal discharge than usual. Very common and usually a healthy sign.', 'आम दिनों से ज़्यादा योनि से स्राव। बहुत आम, और आमतौर पर सेहत का ही संकेत।',
      ),
      howCommon: _t(
        'Very common, and normal for most women throughout pregnancy.', 'बहुत आम, और ज़्यादातर महिलाओं के लिए पूरी गर्भावस्था भर सामान्य।',
      ),
      why: _t(
        "Rising estrogen increases blood flow to the area, leading to more discharge, called leukorrhea. It's your body's normal protective response.", 'बढ़ता estrogen उस जगह ख़ून का बहाव बढ़ा देता है, जिससे स्राव ज़्यादा होता है — इसे leukorrhea कहते हैं। यह आपके शरीर का सामान्य, बचाव वाला जवाब है।',
      ),
      helps: [
        _t('Wear a panty liner if it feels more comfortable', 'ज़्यादा आराम लगे तो पैंटी लाइनर लगाइए'),
        _t('Wear breathable, cotton underwear', 'सूती, हवा आने-जाने वाला अंतर्वस्त्र पहनिए'),
        _t('Keep the area clean with water only', 'उस जगह की सफ़ाई सिर्फ़ पानी से कीजिए'),
        _t('Avoid scented soaps or douching', 'ख़ुशबूदार साबुन या douching से बचिए'),
      ],
      whenDoctor: _t(
        'If it smells strong, changes colour, or causes itching, tell your doctor.', 'अगर तेज़ गंध आए, रंग बदले, या खुजली हो, तो अपने डॉक्टर को बताइए।',
      ),
    ),
  ],

  // ---- 6 · Health · Diet ----------------------------------------------------
  diet: W5Diet(
    superfood: W5Superfood(
      food: _t('Paneer (Cottage Cheese)', 'पनीर'),
      benefit: _t(
        "Rich in calcium and complete protein, supporting your baby's bones and your own health.", 'कैल्शियम और पूरे प्रोटीन से भरपूर, जो आपके शिशु की हड्डियों और आपकी अपनी सेहत, दोनों को सँभालता है।',
      ),
      tryAs: _t('Try it as: palak paneer or grilled paneer cubes.', 'ऐसे खाइए: पालक पनीर या सिंके हुए पनीर के टुकड़े।'),
      note: _t(
        "Choose paneer made from pasteurised milk, and cook it well, especially if you're unsure how it was made.", 'pasteurised दूध से बना पनीर चुनिए, और उसे अच्छे से पकाइए — ख़ासकर तब, जब आपको पता न हो कि वह कैसे बना है।',
      ),
    ),
    favour: [
      W5Card(
        title: _t('Paneer & dairy', 'पनीर और दूध से बनी चीज़ें'),
        body: _t(
          "Rich in calcium and protein, good for your baby's bones and your own health.", 'कैल्शियम और प्रोटीन से भरपूर, आपके शिशु की हड्डियों और आपकी अपनी सेहत के लिए अच्छा।',
        ),
      ),
      W5Card(
        title: _t('Curd & buttermilk', 'दही और छाछ'),
        body: _t(
          'Cooling and easy on the stomach, with calcium and gentle probiotics for your gut.', 'ठंडा और पेट पर हल्का — इसमें कैल्शियम है और हल्के probiotics, जो आपके हाजमे के लिए अच्छे हैं।',
        ),
      ),
      W5Card(
        title: _t('Whole grains & oats', 'साबुत अनाज और ओट्स'),
        body: _t(
          'Steady, slow-release energy that helps with digestion and keeps hunger in check.', 'स्थिर, धीरे-धीरे मिलने वाली ऊर्जा, जो हाजमे में मदद करती है और भूख को क़ाबू में रखती है।',
        ),
      ),
      W5Card(
        title: _t('Citrus & amla', 'खट्टे फल और आँवला'),
        body: _t(
          'Vitamin C from oranges, sweet lime and amla helps your body absorb iron better.', 'संतरा, मौसमी और आँवला से मिलने वाला Vitamin C आपके शरीर को आयरन बेहतर सोखने में मदद करता है।',
        ),
      ),
      W5Card(
        title: _t('Bananas & simple fruit', 'केला और सादे फल'),
        body: _t(
          "A gentle, quick source of energy that's easy to manage on queasy days.", 'ऊर्जा का एक नरम, झटपट ज़रिया, जो मतली वाले दिनों में भी आसानी से गले उतर जाता है।',
        ),
      ),
      W5Card(
        title: _t('Nuts & seeds', 'मेवे और बीज'),
        body: _t(
          'A small handful of almonds or walnuts adds healthy fats, folate and protein.', 'बादाम या अखरोट की एक छोटी सी मुट्ठी सेहतमंद चिकनाई, Folate और प्रोटीन देती है।',
        ),
      ),
      W5Card(
        title: _t('Spinach & leafy greens', 'पालक और हरी पत्तेदार सब्ज़ियाँ'),
        body: _t(
          'Palak and methi provide folate, iron and other important nutrients.', 'पालक और मेथी से Folate, आयरन और दूसरे ज़रूरी पोषक तत्व मिलते हैं।',
        ),
      ),
    ],
    avoid: [
      W5Card(
        title: _t('Raw or undercooked meat & eggs', 'कच्चा या अधपका माँस और अंडे'),
        body: _t(
          'Can carry bacteria like salmonella or listeria, so cook everything thoroughly before eating.', 'इनमें salmonella या listeria जैसे बैक्टीरिया हो सकते हैं, इसलिए खाने से पहले सब कुछ अच्छी तरह पका लीजिए।',
        ),
      ),
      W5Card(
        title: _t('Unpasteurised dairy', 'बिना pasteurise किया दूध'),
        body: _t(
          'Avoid unpasteurised milk, paneer, and soft cheese, which may carry listeria bacteria; choose pasteurised options instead.', 'बिना pasteurise किया दूध, पनीर और soft cheese से बचिए — इनमें listeria बैक्टीरिया हो सकता है; इनकी जगह pasteurised चीज़ें चुनिए।',
        ),
      ),
      W5Card(
        title: _t('High-mercury fish', 'ज़्यादा Mercury वाली मछली'),
        body: _t(
          "Limit shark, swordfish and king mackerel, as mercury can affect your baby's developing brain.", 'shark, swordfish और king mackerel कम कीजिए, क्योंकि mercury आपके शिशु के बनते दिमाग़ पर असर डाल सकता है।',
        ),
      ),
      W5Card(
        title: _t('Too much caffeine', 'बहुत ज़्यादा caffeine'),
        body: _t(
          'Keep caffeine below 200 mg a day, about one to two small cups of coffee.', 'caffeine दिन में 200 mg से नीचे रखिए — लगभग एक से दो छोटे कप कॉफ़ी।',
        ),
      ),
      W5Card(
        title: _t('Alcohol', 'शराब'),
        body: _t(
          'No amount is considered safe in pregnancy, so it is best avoided completely.', 'गर्भावस्था में इसकी कोई भी मात्रा सुरक्षित नहीं मानी जाती, इसलिए इसे पूरी तरह छोड़ देना ही बेहतर है।',
        ),
      ),
    ],
  ),

  // ---- 7 · Trimester Tips (T1 · Weeks 1–13) ---------------------------------
  tips: [
    W5Tip(
      oneLine: _t('Take your folic acid every single day.', 'Folic acid हर एक दिन लीजिए।'),
      readMore: _t(
        "Folic acid is one of the most important things you can take right now. In these early weeks, it helps your baby's brain and spine form properly. Most doctors suggest 400 micrograms a day, ideally from before pregnancy through the first trimester. Take it at the same time each day so it becomes a habit.", 'Folic acid अभी आप जो ले सकती हैं, उनमें सबसे ज़रूरी चीज़ों में से एक है। इन शुरुआती हफ़्तों में यह आपके शिशु के दिमाग़ और रीढ़ को ठीक से बनने में मदद करता है। ज़्यादातर डॉक्टर दिन में 400 माइक्रोग्राम की सलाह देते हैं — बेहतर हो तो गर्भावस्था से पहले से लेकर पहली तिमाही के अंत तक। इसे हर दिन एक ही वक़्त पर लीजिए, ताकि आदत बन जाए।',
      ),
    ),
    W5Tip(
      oneLine: _t("Book your first doctor's visit as early as you can.", 'डॉक्टर के पास पहली बार जितनी जल्दी हो सके जाइए।'),
      readMore: _t(
        "Once you know you are pregnant, book your first appointment with a doctor or gynaecologist. This first visit sets up your care for the months ahead. Your doctor will confirm your pregnancy, talk through your health, and guide you on tests, diet and supplements. Do not worry if you have many questions. That is exactly what this visit is for.", 'जैसे ही पता चले कि आप गर्भवती हैं, डॉक्टर या gynaecologist के साथ अपनी पहली मुलाक़ात तय कर लीजिए। यह पहली विज़िट आने वाले महीनों की देखभाल की नींव रखती है। आपके डॉक्टर गर्भावस्था की पुष्टि करेंगे, आपकी सेहत पर बात करेंगे, और जाँचों, खान-पान तथा supplements पर राह दिखाएँगे। अगर बहुत सारे सवाल हैं तो फ़िक्र मत कीजिए — यह विज़िट इसी के लिए है।',
      ),
    ),
    W5Tip(
      oneLine: _t('Eat small, frequent meals to ease nausea.', 'मतली कम करने के लिए थोड़ा-थोड़ा, बार-बार खाइए।'),
      readMore: _t(
        "Morning sickness can strike at any time of day, and an empty stomach often makes it worse. Instead of three big meals, try eating small amounts every few hours. Keep simple snacks like biscuits, toast or a banana close by, even next to your bed. Ginger and nimbu paani help many women feel a little settled.", 'जी मिचलाना दिन के किसी भी वक़्त आ सकता है, और ख़ाली पेट इसे अक्सर और बढ़ा देता है। तीन बड़े खानों की जगह, हर कुछ घंटे में थोड़ा-थोड़ा खाने की कोशिश कीजिए। बिस्किट, टोस्ट या केले जैसा सादा नाश्ता पास रखिए — अपने बिस्तर के पास भी। अदरक और नींबू पानी से बहुत सी महिलाओं को थोड़ा चैन मिलता है।',
      ),
    ),
    W5Tip(
      oneLine: _t('Rest as much as your body needs.', 'शरीर जितना आराम माँगे, उतना दीजिए।'),
      readMore: _t(
        "First-trimester tiredness is real, and it can feel heavier than any tiredness before. Your body is doing huge work behind the scenes, so give yourself permission to slow down. Sleep a little earlier, take short naps when you can, and let some chores wait. Rest is not being lazy. It is part of looking after your baby.", 'पहली तिमाही की थकान सच होती है, और यह पहले की किसी भी थकान से भारी लग सकती है। आपका शरीर परदे के पीछे बहुत बड़ा काम कर रहा है, इसलिए ख़ुद को धीमे होने की इजाज़त दीजिए। थोड़ा जल्दी सो जाइए, जब मौक़ा मिले छोटी झपकी ले लीजिए, और कुछ कामों को इंतज़ार करने दीजिए। आराम करना आलस नहीं है — यह अपने शिशु की देखभाल का ही हिस्सा है।',
      ),
    ),
    W5Tip(
      oneLine: _t('Drink plenty of water through the day.', 'दिन भर ख़ूब पानी पीजिए।'),
      readMore: _t(
        "Staying well hydrated helps with many early pregnancy small discomforts, from tiredness to headaches to constipation. Aim to sip water steadily through the day rather than a lot at once. If plain water feels dull, try coconut water, buttermilk or nimbu paani. On queasy days, cool drinks are sometimes easier to manage than food.", 'अच्छी तरह पानी पीते रहना शुरुआती गर्भावस्था की कई छोटी तकलीफ़ों में मदद करता है — थकान से लेकर सिर दर्द और कब्ज़ तक। एक साथ बहुत सारा पीने की जगह, दिन भर थोड़ा-थोड़ा घूँट लेती रहिए। सादा पानी फीका लगे तो नारियल पानी, छाछ या नींबू पानी आज़माइए। मतली वाले दिनों में ठंडे पेय कभी-कभी खाने से ज़्यादा आसानी से गले उतरते हैं।',
      ),
    ),
    W5Tip(
      oneLine: _t('Cook food well and wash fruits and vegetables.', 'खाना अच्छी तरह पकाइए और फल-सब्ज़ियाँ धोइए।'),
      readMore: _t(
        "In pregnancy, your body fights off infections less easily, so food safety matters more than usual. Cook meat, fish and eggs fully, and choose pasteurised milk and dairy. Wash fruits and vegetables well before eating. Avoid raw or undercooked items and unpasteurised foods for now. These simple habits lower the chance of an upset that could affect you both.", 'गर्भावस्था में आपका शरीर संक्रमण से कम आसानी से लड़ पाता है, इसलिए खाने की सफ़ाई आम दिनों से ज़्यादा मायने रखती है। माँस, मछली और अंडे पूरी तरह पकाइए, और pasteurised दूध और दूध से बनी चीज़ें चुनिए। फल और सब्ज़ियाँ खाने से पहले अच्छे से धोइए। कच्ची या अधपकी चीज़ें और बिना pasteurise किए खाने अभी के लिए छोड़ दीजिए। ये छोटी-छोटी आदतें उस गड़बड़ी का ख़तरा कम करती हैं, जो आप दोनों पर असर डाल सकती है।',
      ),
    ),
    W5Tip(
      oneLine: _t('Limit caffeine, and skip alcohol and smoking.', 'Caffeine कम कीजिए, और शराब व धूम्रपान बिलकुल नहीं।'),
      readMore: _t(
        "A little caffeine is fine, but try to keep it under about 200 milligrams a day, roughly one cup of coffee, counting tea and cola too. Alcohol has no known safe amount in pregnancy, so it is best left. If you smoke, or are around smoke, this is a good time to step away, for you both.", 'थोड़ी caffeine ठीक है, पर उसे दिन में लगभग 200 मिलीग्राम से नीचे रखने की कोशिश कीजिए — मोटे तौर पर एक कप कॉफ़ी, और उसमें चाय और कोला भी गिनकर। गर्भावस्था में शराब की कोई सुरक्षित मात्रा मानी ही नहीं गई है, इसलिए उसे छोड़ देना ही बेहतर है। अगर आप धूम्रपान करती हैं, या धुएँ के आसपास रहती हैं, तो यह दूर हट जाने का अच्छा वक़्त है — आप दोनों के लिए।',
      ),
    ),
    W5Tip(
      oneLine: _t("Keep moving gently, with your doctor's okay.", 'डॉक्टर की मंज़ूरी से, हल्की हलचल जारी रखिए।'),
      readMore: _t(
        "Unless your doctor advises otherwise, gentle movement is good for you now. A daily walk, light stretching or prenatal yoga can lift your mood, help you sleep and ease early aches. There is no need to push hard. Move at a pace where you can still chat comfortably. Always check with your doctor before starting anything new.", 'जब तक आपके डॉक्टर मना न करें, हल्की हलचल अभी आपके लिए अच्छी है। रोज़ की सैर, हल्की stretching या prenatal yoga आपका मन बेहतर कर सकती है, नींद में मदद कर सकती है और शुरुआती दर्द हल्के कर सकती है। ज़ोर लगाने की ज़रूरत नहीं। उतनी ही रफ़्तार से चलिए, जिसमें आप आराम से बात भी कर सकें। कुछ भी नया शुरू करने से पहले हमेशा अपने डॉक्टर से पूछ लीजिए।',
      ),
    ),
    W5Tip(
      oneLine: _t('Share how you feel with someone you trust.', 'अपना मन किसी अपने के साथ बाँटिए।'),
      readMore: _t(
        "Early pregnancy can bring a mix of joy, worry and mood swings, often all at once. This is normal, and hormones play a big part. You do not have to carry it alone. Talking to your partner, a close friend or family member can lighten the load. If low feelings stay for long, tell your doctor.", 'शुरुआती गर्भावस्था ख़ुशी, फ़िक्र और मन के उतार-चढ़ाव — तीनों साथ ला सकती है, अक्सर एक ही वक़्त पर। यह सामान्य है, और इसमें हार्मोन की बड़ी भूमिका है। इसे अकेले उठाने की ज़रूरत नहीं। अपने साथी, किसी क़रीबी दोस्त या घर के किसी अपने से बात करना बोझ हल्का कर देता है। अगर मन लंबे समय तक उदास बना रहे, तो अपने डॉक्टर को बताइए।',
      ),
    ),
  ],

  // ---- 8 · Share With Partner -----------------------------------------------
  partner: W5Partner(
    baby: _t(
      "This week my fingers and toes have fully separated, and tiny nails are just beginning to grow. I'm about the size of a strawberry now, and all my major organs have formed and are starting to work together as a team.", 'इस हफ़्ते मेरे हाथ और पैर की उँगलियाँ पूरी तरह अलग हो चुकी हैं, और नन्हे नाख़ून अभी-अभी बनने लगे हैं। अब मेरा आकार लगभग एक स्ट्रॉबेरी जितना है, और मेरे सभी बड़े अंग बन चुके हैं और एक टीम की तरह साथ काम करने लगे हैं।',
    ),
    mother: _t(
      "For many women, this is when the toughest symptoms start easing, though everyone's timeline is a little different. She may still be dealing with tiredness, headaches or nausea, alongside newer things like visible veins or sharp twinges as her body keeps changing. Small comforts and patience go a long way right now.", 'बहुत सी महिलाओं के लिए यही वह वक़्त है जब सबसे मुश्किल लक्षण हल्के पड़ने लगते हैं, हालाँकि हर किसी का समय थोड़ा अलग होता है। उन्हें अब भी थकान, सिर दर्द या मतली से जूझना पड़ सकता है, और साथ में कुछ नई बातें भी — जैसे उभरी नसें या तेज़ चुभन, क्योंकि उनका शरीर लगातार बदल रहा है। छोटी-छोटी सहूलियतें और थोड़ा धीरज अभी बहुत मायने रखते हैं।',
    ),
    // Current week to week+4; scans whose window has already closed are dropped.
    scans: [
      W5Scan(name: _t('NT scan', 'NT scan'), window: _t('Week 11 to 14', 'हफ़्ता 11 से 14')),
      W5Scan(
        name: _t('Double marker test', 'Double marker test'),
        window: _t('Week 11 to 14 · usually with the NT scan', 'हफ़्ता 11 से 14 · आम तौर पर NT scan के साथ'),
      ),
    ],
    help: [
      _t('Be patient with any lingering symptoms.', 'बचे हुए लक्षणों को लेकर धीरज रखिए।'),
      _t('Take on more of the cooking and chores.', 'रसोई और घर के काम ज़्यादा अपने ज़िम्मे लीजिए।'),
      _t('Help her move slowly if twinges strike.', 'खिंचाव उठे तो उन्हें धीरे-धीरे चलने में मदद कीजिए।'),
      _t('Keep supportive, comfortable clothing handy.', 'आरामदायक, सहारा देने वाले कपड़े पास रखिए।'),
      _t('Ask about the upcoming NT scan together.', 'आने वाले NT scan के बारे में साथ मिलकर पूछिए।'),
      _t('Celebrate how close you are to trimester two.', 'दूसरी तिमाही कितनी क़रीब है, यह साथ में मनाइए।'),
    ],
  ),
);
