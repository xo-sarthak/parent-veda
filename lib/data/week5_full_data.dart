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
      "This week my fingers and toes finally separate completely, and tiny nails begin to grow. I'm about the size of a strawberry now.",
      'Is hafte meri ungliyan aur pairon ki ungliyan aakhirkaar poori tarah alag ho jaati hain, aur nanhe naakhun ugna shuru hote hain. Ab main lagbhag ek strawberry jitna hoon.',
    ),
    opening: _t(
      "I've grown to about the size of a strawberry this week, and I'm looking more like a tiny person every day. My fingers and toes have fully separated, and my head still makes up about half of my length.",
      'Is hafte main badhkar lagbhag strawberry jitna ho gaya hoon, aur har din thoda aur ek nanhe insaan jaisa dikhne laga hoon. Meri ungliyan aur pairon ki ungliyan poori tarah alag ho gayi hain, aur mera sar abhi bhi meri lambai ka lagbhag aadha hissa hai.',
    ),
    howBig: _t(
      "I'm about 3.1 to 3.2 centimetres long now, roughly the size of a strawberry, and I weigh about 4 grams.",
      'Ab main lagbhag 3.1 se 3.2 centimetre lamba hoon, motey taur par ek strawberry jitna, aur mera wazan lagbhag 4 gram hai.',
    ),
    whatsHappening: _t(
      "My fingers and toes have completely separated this week, with no more webbing, and tiny nails are just beginning to grow. My skeleton keeps turning from soft cartilage into bone, and my ears are taking their outer shape. I'm swallowing tiny sips of fluid and kicking my legs, simply practising movements I'll need later. My head still makes up about half of my length because my brain is growing so quickly.",
      'Is hafte meri ungliyan aur pairon ki ungliyan poori tarah alag ho gayi hain, beech ki jaali ab nahi rahi, aur nanhe naakhun abhi ugna shuru hue hain. Mera skeleton naram cartilage se haddi mein badalta ja raha hai, aur mere kaan apna bahri aakaar le rahe hain. Main fluid ke nanhe ghoont nigal raha hoon aur apni taangein chala raha hoon, bas woh harkatein practice karta hua jo aage mujhe chahiye hongi. Mera sar abhi bhi meri lambai ka lagbhag aadha hai, kyunki mera brain itni tezi se badh raha hai.',
    ),
    // Shown inline as a heading + description, not a tappable card.
    behaviour: [
      W5Card(
        title: _t("I'm swallowing and kicking", 'मैं निगल रहा हूँ और लात मार रहा हूँ'),
        body: _t(
          "This week I'm becoming a little more active, swallowing tiny sips of the fluid around me and kicking my legs. These movements help my muscles, joints and nervous system develop, even though I don't need them for feeding or moving around just yet. You can't feel any of it, but if you had a scan now, you might just catch me in action.",
          'Is hafte main thoda aur active ho raha hoon, apne aaspaas ke fluid ke nanhe ghoont nigalta hua aur apni taangein chalata hua. Yeh harkatein mere muscles, joints aur nervous system ko develop hone mein madad karti hain, halaanki abhi mujhe inki khaane ya ghoomne ke liye zaroorat nahi hai. Tum inmein se kuch bhi mehsoos nahi kar sakti, par agar abhi scan hota, to shayad tum mujhe action mein pakad leti.',
        ),
      ),
    ],
  ),

  // ---- 3 · Baby Science -----------------------------------------------------
  science: [
    W5Card(
      title: _t('My fingers and toes are free', 'मेरी उँगलियाँ अब अलग-अलग हो गई हैं'),
      body: _t(
        "This week my fingers and toes have fully separated, with the webbing between them completely gone. My thumbs have rotated into place, ready for gripping and holding one day. For now, I'm simply getting used to having my own separate fingers and toes.",
        'Is hafte meri ungliyan aur pairon ki ungliyan poori tarah alag ho gayi hain, aur unke beech ki jaali bilkul khatam ho gayi hai. Mere angoothe apni jagah par ghoom gaye hain, ek din pakadne aur thaamne ke liye taiyaar. Filhaal, main bas apni alag-alag ungliyon ka aadi ho raha hoon.',
      ),
    ),
    W5Card(
      title: _t('My nails are starting to grow', 'मेरे नाख़ून बनने लगे हैं'),
      body: _t(
        "Tiny nails are just beginning to grow at the ends of my fingers and toes this week. They're barely there for now, more like the faintest suggestion of a nail than anything you'd recognise. Over the coming weeks and months, they'll keep growing, all the way until the day you first trim them.",
        'Is hafte meri ungliyon aur pairon ki ungliyon ke siron par nanhe naakhun abhi ugna shuru hue hain. Filhaal woh mushkil se hain, kisi naakhun ki sabse halki jhalak jaise, na ki kuch aisa jise tum pehchaan sako. Aane waale hafton aur mahinon mein woh badhte rahenge, us din tak jab tum pehli baar unhe kaatogi.',
      ),
    ),
    W5Card(
      title: _t('My skeleton keeps turning to bone', 'मेरा ढाँचा धीरे-धीरे हड्डी बनता जा रहा है'),
      body: _t(
        "My skeleton keeps turning to bone this week, with ossification now underway in many more places than before. Bit by bit, the soft cartilage that has held my shape so far is being replaced by harder, stronger bone. It's a slow process that will continue quietly for months, long after I'm born.",
        'Is hafte mera skeleton haddi mein badalta ja raha hai, aur ossification ab pehle se kai zyada jagahon par chal rahi hai. Thoda-thoda karke, jo naram cartilage ab tak mera aakaar sambhaale hue tha, uski jagah zyada sakht aur mazboot haddi le rahi hai. Yeh ek dheemi prakriya hai jo mahinon tak chupchaap chalti rahegi, mere paida hone ke bahut baad tak.',
      ),
    ),
    W5Card(
      title: _t('My ears are taking their outer shape', 'मेरे कानों की बाहरी बनावट उभर रही है'),
      body: _t(
        "The outer shape of my ears is coming together this week, slowly moving into the familiar shell-like form you'll recognise. They still have some settling to do, gradually shifting into their final position on the sides of my head. One day soon, they'll be ready to catch every sound around them.",
        'Is hafte mere kaanon ka bahri aakaar ban raha hai, dheere-dheere us jaani-pehchaani shell jaisi shakal mein aata hua. Unhe abhi thoda aur set hona hai, dheere-dheere mere sar ke kinaron par apni aakhri jagah par pahunchte hue. Ek din jald hi, woh aaspaas ki har aawaaz pakadne ke liye taiyaar honge.',
      ),
    ),
    W5Card(
      title: _t('My kidneys are building their filters', 'मेरी kidney अपने छन्ने बना रही हैं'),
      body: _t(
        "The tiny filtering units inside my kidneys are continuing to develop this week. They're not ready to do their real job yet, but this is important groundwork being laid. In time, these filters will help keep my blood clean and support the fluid around me.",
        'Is hafte meri kidneys ke andar ke nanhe filtering units develop hote ja rahe hain. Woh abhi apna asli kaam karne ke liye taiyaar nahi hain, par yeh zaroori neenv rakhi ja rahi hai. Aage chalkar, yeh filters mera blood saaf rakhne aur mere aaspaas ke fluid ko support karne mein madad karenge.',
      ),
    ),
    W5Card(
      title: _t('My organs are starting to work together', 'मेरे अंग आपस में तालमेल बिठाने लगे हैं'),
      body: _t(
        "By now, all of my major organs have formed, and this week they're beginning to work together as a team. None of them can do their full jobs on their own yet, but this teamwork is an important step. From here, it's less about building new parts and more about everything maturing together.",
        'Ab tak mere sabhi bade organs ban chuke hain, aur is hafte woh ek team ki tarah saath kaam karna shuru kar rahe hain. Koi bhi abhi akela apna poora kaam nahi kar sakta, par yeh teamwork ek zaroori kadam hai. Yahan se, baat naye hisse banane se zyada sab kuch saath-saath pakne ki hai.',
      ),
    ),
    W5Card(
      title: _t('My brain is producing millions of nerve cells', 'मेरा दिमाग़ लाखों तंत्रिका कोशिकाएँ बना रहा है'),
      body: _t(
        "My brain keeps producing new nerve cells at an incredible rate this week, roughly 250,000 every single minute. This pace will continue throughout the rest of pregnancy, eventually building the complex web of connections behind everything I'll one day think, feel and do.",
        'Is hafte mera brain gazab ki raftaar se naye nerve cells banata ja raha hai, lagbhag 2,50,000 har ek minute. Yeh raftaar baaki pregnancy bhar jaari rahegi, aur aage chalkar connections ka woh pecheeda jaal banayegi jo mere har sochne, mehsoos karne aur karne ke peeche hoga.',
      ),
    ),
  ],

  // ---- 4 · You This Week ----------------------------------------------------
  you: W5You(
    feeling: _t(
      "Week 10 often marks a turning point, and for many women, symptoms start easing over the coming weeks as you near the end of the first trimester. Nausea, fatigue and headaches may still be strong right now, and some women notice new discomforts too, such as brief sharp twinges low in the belly as the uterus grows and the supporting tissues stretch. Others may already feel their symptoms beginning to lift. Whichever way it goes for you, it's completely normal. You're almost through the trickiest stretch, and many women start to feel more like themselves again very soon.",
      'Week 10 aksar ek mod hota hai, aur bahut si mahilaon ke liye aane waale hafton mein symptoms halke padne lagte hain jab tum pehle trimester ke ant ke kareeb aati ho. Matli, thakaan aur sar dard abhi bhi tez ho sakte hain, aur kuch mahilaayein nayi takleefein bhi mehsoos karti hain, jaise pet ke neeche halki tez chubhan jab uterus badhta hai aur use sambhaalne waale tissues khinchte hain. Kuch ko apne symptoms pehle se halke hote mehsoos ho sakte hain. Tumhare saath jo bhi ho, woh bilkul normal hai. Tum sabse mushkil hisse se lagbhag nikal chuki ho, aur bahut si mahilaayein jald hi dobara khud jaisa mehsoos karne lagti hain.',
    ),
    changingBody: _t(
      "You may notice your waist looking a little rounder, though for many women this is still mostly due to bloating and the growing uterus remaining within the pelvis. Veins on your breasts and tummy may look more visible as your blood volume keeps rising. Your skin might feel drier or spottier than usual, and some women begin to notice fine red thread-like lines called spider naevi, which are harmless and fade after birth. Small, steady signs that your body is working hard behind the scenes.",
      'Tumhein apni kamar thodi gol lag sakti hai, halaanki bahut si mahilaon ke liye yeh abhi zyadatar bloating aur badhte uterus ki wajah se hai, jo abhi pelvis ke andar hi hai. Tumhare breasts aur pet par nasein zyada dikhne lag sakti hain, kyunki tumhara blood volume badhta ja raha hai. Tumhari skin aam se zyada rookhi ya daane waali lag sakti hai, aur kuch mahilaayein baareek laal dhaage jaisi lakeerein dekhna shuru karti hain jinhe spider naevi kehte hain, jo nuksaandeh nahi hain aur delivery ke baad fade ho jaati hain. Chhote, lagataar sanket ki tumhara body parde ke peeche mehnat kar raha hai.',
    ),
    beKind: _t(
      "If sharp twinges in your lower belly catch you off guard, it is often caused by your growing uterus and the tissues supporting it stretching, not a sign of anything wrong. Move a little slower when you stand up or sit down, rest when you need to, and be patient with your changing skin and body.",
      'Agar pet ke neeche ki tez chubhan tumhein achanak pakad le, to yeh aksar tumhare badhte uterus aur use sambhaalne waale tissues ke khinchne se hoti hai, kisi gadbad ka sanket nahi. Uthte ya baithte waqt thoda dheere chalo, jab zaroorat ho aaram karo, aur apni badalti skin aur body ke saath sabr rakho.',
    ),
    highlights: [
      W5Highlight(
        title: _t('Round ligament twinges', 'Round ligament का खिंचाव'),
        teaser: _t(
          'Sharp, quick twinges low in your belly as your womb stretches.',
          'Womb ke khinchne par pet ke neeche tez, jhatpat chubhan.',
        ),
        body: _t(
          "As your womb grows, the ligaments supporting it stretch and tighten, sometimes causing a sudden, sharp twinge low in your belly or groin. It is often caused by your growing uterus and the tissues supporting it stretching quickly, triggered by movements like standing up, coughing or laughing. Moving a little more slowly, and resting when it happens, can help ease it.",
          'Jaise-jaise tumhara womb badhta hai, use sambhaalne waale ligaments khinchte aur kasste hain, jisse kabhi pet ke neeche ya groin mein achanak tez chubhan hoti hai. Yeh aksar tumhare badhte uterus aur use sambhaalne waale tissues ke tezi se khinchne se hoti hai, aur uthne, khaansne ya hansne jaisi harkaton se shuru hoti hai. Thoda dheere chalna, aur jab yeh ho tab aaram karna, ise halka karne mein madad karta hai.',
        ),
      ),
      W5Highlight(
        title: _t('Your visible veins', 'आपकी उभरी नसें'),
        teaser: _t(
          'More visible veins on your breasts and belly are common now.',
          'Breasts aur pet par nason ka zyada dikhna ab aam hai.',
        ),
        body: _t(
          "As your blood volume keeps rising to support your pregnancy, veins on your breasts and abdomen may become more visible than before. This is simply extra blood flow doing its job, and it isn't a cause for concern. It usually becomes less noticeable again after you give birth.",
          'Jaise-jaise tumhara blood volume pregnancy ko support karne ke liye badhta hai, tumhare breasts aur pet par nasein pehle se zyada dikhne lag sakti hain. Yeh bas extra blood flow apna kaam kar raha hai, aur yeh fikr ki baat nahi hai. Delivery ke baad yeh aksar dobara kam dikhne lagti hain.',
        ),
      ),
      W5Highlight(
        title: _t('Your changing skin', 'आपकी बदलती त्वचा'),
        teaser: _t(
          'Dryness, spots, or fine red lines are all common right now.',
          'Rookhapan, daane, ya baareek laal lakeerein, sab abhi aam hain.',
        ),
        body: _t(
          "Rising hormones can affect your skin in different ways this week. Some women notice dryness or a few extra spots, while some begin to notice fine, thread-like red lines called spider naevi on their chest or arms, though these are usually more common a little later on. Both are harmless and usually fade on their own after your baby arrives.",
          'Badhte hormones is hafte tumhari skin ko alag-alag tareeke se badal sakte hain. Kuch mahilaayein rookhapan ya kuch extra daane dekhti hain, jabki kuch apne seene ya baahon par baareek, dhaage jaisi laal lakeerein dekhna shuru karti hain jinhe spider naevi kehte hain, halaanki yeh aksar thoda baad mein zyada aam hoti hain. Dono nuksaandeh nahi hain aur baby ke aane ke baad aksar apne aap fade ho jaati hain.',
        ),
      ),
    ],
    selfCare: _t(
      "If your first prenatal visit hasn't happened yet, it's likely coming up very soon. Keep taking your prenatal vitamin, stay hydrated, and treat yourself gently as your body keeps changing.",
      'Agar tumhari pehli prenatal visit abhi tak nahi hui, to woh shayad bahut jald aane waali hai. Apna prenatal vitamin lete raho, paani peete raho, aur jab tumhara body badalta rahe to khud ke saath naram raho.',
    ),
  ),

  // ---- 5 · Health · Symptoms ------------------------------------------------
  symptoms: [
    W5Symptom(
      name: _t('Nausea', 'मतली'),
      teaser: _t(
        'That queasy feeling that can come at any time of day. Many women begin noticing improvement from around this stage, though for others it continues into the second trimester.',
        'Woh ubkai jaisa ehsaas jo din ke kisi bhi waqt aa sakta hai. Bahut si mahilaayein is stage ke aaspaas sudhaar dekhna shuru karti hain, halaanki kuch ke liye yeh doosre trimester tak chalta hai.',
      ),
      howCommon: _t(
        'Very common, though many women notice it beginning to ease this week.',
        'Bahut aam, halaanki bahut si mahilaayein is hafte ise halka hota mehsoos karti hain.',
      ),
      why: _t(
        'Rising pregnancy hormones, especially hCG, have been behind the queasiness. As hCG eases past its peak, nausea often follows.',
        'Badhte pregnancy hormones, khaaskar hCG, is ubkai ke peeche rahe hain. Jab hCG apne peak se neeche aata hai, matli bhi aksar peeche-peeche halki ho jaati hai.',
      ),
      helps: [
        _t('Eat small, frequent meals through the day', 'दिन भर थोड़ा-थोड़ा, बार-बार खाइए'),
        _t('Keep plain snacks like crackers or toast nearby', 'सादा नाश्ता जैसे बिस्किट या टोस्ट पास रखिए'),
        _t('Sip ginger tea, lemon water or nimbu paani', 'अदरक की चाय, नींबू पानी या शिकंजी पीजिए'),
        _t('Avoid smells that set off your nausea', 'जिन गंधों से मतली बढ़े, उनसे दूर रहिए'),
      ],
      whenDoctor: _t(
        'If you cannot keep food or fluids down, or are losing weight, call your doctor.',
        'Agar khaana ya paani andar nahi tik pa raha, ya wazan ghat raha hai, to doctor ko call karo.',
      ),
    ),
    W5Symptom(
      name: _t('Fatigue', 'थकान'),
      teaser: _t(
        'A heavy tiredness that can hit even after a full night\'s sleep. Common through this trimester.',
        'Ek bhaari thakaan jo poori raat sone ke baad bhi aa sakti hai. Is trimester bhar aam hai.',
      ),
      howCommon: _t(
        'Very common, and still noticeable for many women at this stage.',
        'Bahut aam, aur is stage par bahut si mahilaon ko abhi bhi mehsoos hoti hai.',
      ),
      why: _t(
        'Rising progesterone can make you feel sleepier, while your body uses extra energy to build the placenta and support your pregnancy.',
        'Badhta progesterone tumhein zyada neend mein rakh sakta hai, jabki tumhara body placenta banane aur pregnancy ko support karne mein extra energy lagata hai.',
      ),
      helps: [
        _t('Rest whenever you can, even short naps', 'जब भी मौक़ा मिले आराम कीजिए, छोटी झपकी भी'),
        _t('Go to bed a little earlier than usual', 'रोज़ से थोड़ा पहले सो जाइए'),
        _t('Stay hydrated and eat regular, balanced meals', 'पानी पीती रहिए और समय पर संतुलित खाना खाइए'),
        _t('Gentle movement like a short walk can help', 'हल्की हलचल, जैसे थोड़ी देर टहलना, मदद करती है'),
      ],
      whenDoctor: _t(
        'If tiredness feels extreme, or comes with breathlessness or dizziness, mention it to your doctor.',
        'Agar thakaan bahut zyada lage, ya saans phoolne ya chakkar ke saath aaye, to doctor ko bataao.',
      ),
    ),
    W5Symptom(
      name: _t('Tender breasts', 'स्तनों में नरमी और दर्द'),
      teaser: _t(
        'Fuller, heavier breasts with more visible veins as blood flow increases.',
        'Blood flow badhne ke saath bhare, bhaari breasts aur zyada dikhti nasein.',
      ),
      howCommon: _t(
        'Very common, and many notice ongoing growth and sensitivity this week.',
        'Bahut aam, aur bahut si mahilaayein is hafte lagataar badhotri aur sensitivity mehsoos karti hain.',
      ),
      why: _t(
        'Rising hormones increase blood flow to your breasts, which can make them feel fuller and more sensitive, with veins more visible underneath the skin.',
        'Badhte hormones tumhare breasts mein blood flow badhaate hain, jisse woh zyada bhare aur sensitive lag sakte hain, aur skin ke neeche nasein zyada dikhti hain.',
      ),
      helps: [
        _t('Wear a soft, well-fitting supportive bra', 'नरम, सही नाप की सहारा देने वाली ब्रा पहनिए'),
        _t('Try a wireless or sleep bra at night', 'रात में बिना तार वाली या स्लीप ब्रा आज़माइए'),
        _t('Avoid tight clothing that presses on the area', 'तंग कपड़ों से बचिए जो वहाँ दबाव डालें'),
        _t('Warm or cool compresses can ease soreness', 'गुनगुनी या ठंडी सिंकाई से आराम मिलता है'),
      ],
      whenDoctor: _t(
        'If you feel a lump, or notice unusual discharge, have it checked by your doctor.',
        'Agar koi gaanth mehsoos ho, ya asaadhaaran discharge dikhe, to doctor se check karwao.',
      ),
    ),
    W5Symptom(
      name: _t('Headaches', 'सिर दर्द'),
      teaser: _t(
        'A dull ache in the head, often linked to hormones and blood flow. Common at this stage.',
        'Sar mein halka dard, aksar hormones aur blood flow se juda. Is stage par aam hai.',
      ),
      howCommon: _t(
        'Common in the first trimester, and can continue until around week 12.',
        'Pehle trimester mein aam, aur lagbhag week 12 tak chal sakta hai.',
      ),
      why: _t(
        'Rising hormones, increased blood volume, hunger and dehydration can all trigger headaches at this stage of pregnancy.',
        'Badhte hormones, badha hua blood volume, bhookh aur paani ki kami, sab pregnancy ke is stage par sar dard shuru kar sakte hain.',
      ),
      helps: [
        _t('Drink water and eat small, regular meals', 'पानी पीजिए और थोड़ा-थोड़ा, समय पर खाइए'),
        _t('Rest in a cool, quiet, dark room', 'ठंडे, शांत, अँधेरे कमरे में आराम कीजिए'),
        _t('Try a warm or cool compress on your head', 'सिर पर गुनगुनी या ठंडी सिंकाई आज़माइए'),
        _t('Get enough sleep and manage stress where you can', 'पूरी नींद लीजिए और जितना हो सके तनाव कम रखिए'),
      ],
      whenDoctor: _t(
        'If a headache is severe, will not go away, or comes with vision changes, call your doctor.',
        'Agar sar dard bahut tez ho, jaa hi na raha ho, ya nazar mein badlaav ke saath aaye, to doctor ko call karo.',
      ),
    ),
    W5Symptom(
      name: _t('Increased discharge', 'स्राव का बढ़ना'),
      teaser: _t(
        'More vaginal discharge than usual. Very common and usually a healthy sign.',
        'Aam se zyada vaginal discharge. Bahut aam, aur aksar ek healthy sanket.',
      ),
      howCommon: _t(
        'Very common, and normal for most women throughout pregnancy.',
        'Bahut aam, aur zyadatar mahilaon ke liye poori pregnancy bhar normal.',
      ),
      why: _t(
        "Rising estrogen increases blood flow to the area, leading to more discharge, called leukorrhea. It's your body's normal protective response.",
        'Badhta estrogen us jagah blood flow badhaata hai, jisse zyada discharge hota hai, jise leukorrhea kehte hain. Yeh tumhare body ka normal, bachaav waala jawaab hai.',
      ),
      helps: [
        _t('Wear a panty liner if it feels more comfortable', 'ज़्यादा आराम लगे तो पैंटी लाइनर लगाइए'),
        _t('Wear breathable, cotton underwear', 'सूती, हवा आने-जाने वाला अंतर्वस्त्र पहनिए'),
        _t('Keep the area clean with water only', 'उस जगह की सफ़ाई सिर्फ़ पानी से कीजिए'),
        _t('Avoid scented soaps or douching', 'ख़ुशबूदार साबुन या douching से बचिए'),
      ],
      whenDoctor: _t(
        'If it smells strong, changes colour, or causes itching, tell your doctor.',
        'Agar tez smell aaye, rang badle, ya khujli ho, to doctor ko bataao.',
      ),
    ),
  ],

  // ---- 6 · Health · Diet ----------------------------------------------------
  diet: W5Diet(
    superfood: W5Superfood(
      food: _t('Paneer (Cottage Cheese)', 'पनीर'),
      benefit: _t(
        "Rich in calcium and complete protein, supporting your baby's bones and your own health.",
        'Calcium aur poore protein se bharpoor, jo tumhare baby ki haddiyon aur tumhari apni sehat ko support karta hai.',
      ),
      tryAs: _t('Try it as: palak paneer or grilled paneer cubes.', 'ऐसे खाइए: पालक पनीर या सिंके हुए पनीर के टुकड़े।'),
      note: _t(
        "Choose paneer made from pasteurised milk, and cook it well, especially if you're unsure how it was made.",
        'Pasteurised doodh se bana paneer chuno, aur use acche se pakao, khaaskar agar tumhein pata na ho ki woh kaise bana hai.',
      ),
    ),
    favour: [
      W5Card(
        title: _t('Paneer & dairy', 'पनीर और दूध से बनी चीज़ें'),
        body: _t(
          "Rich in calcium and protein, good for your baby's bones and your own health.",
          'Calcium aur protein se bharpoor, tumhare baby ki haddiyon aur tumhari sehat ke liye accha.',
        ),
      ),
      W5Card(
        title: _t('Curd & buttermilk', 'दही और छाछ'),
        body: _t(
          'Cooling and easy on the stomach, with calcium and gentle probiotics for your gut.',
          'Thanda aur pet par halka, calcium aur naram probiotics ke saath tumhare gut ke liye.',
        ),
      ),
      W5Card(
        title: _t('Whole grains & oats', 'साबुत अनाज और ओट्स'),
        body: _t(
          'Steady, slow-release energy that helps with digestion and keeps hunger in check.',
          'Sthir, dheere-dheere milne waali energy jo hazme mein madad karti hai aur bhookh ko kaabu mein rakhti hai.',
        ),
      ),
      W5Card(
        title: _t('Citrus & amla', 'खट्टे फल और आँवला'),
        body: _t(
          'Vitamin C from oranges, sweet lime and amla helps your body absorb iron better.',
          'Santra, mosambi aur amla se milne waala Vitamin C tumhare body ko iron behtar absorb karne mein madad karta hai.',
        ),
      ),
      W5Card(
        title: _t('Bananas & simple fruit', 'केला और सादे फल'),
        body: _t(
          "A gentle, quick source of energy that's easy to manage on queasy days.",
          'Energy ka ek naram, turant zariya jo matli waale dinon mein aasaan rehta hai.',
        ),
      ),
      W5Card(
        title: _t('Nuts & seeds', 'मेवे और बीज'),
        body: _t(
          'A small handful of almonds or walnuts adds healthy fats, folate and protein.',
          'Badaam ya akhrot ki ek chhoti mutthi healthy fats, folate aur protein deti hai.',
        ),
      ),
      W5Card(
        title: _t('Spinach & leafy greens', 'पालक और हरी पत्तेदार सब्ज़ियाँ'),
        body: _t(
          'Palak and methi provide folate, iron and other important nutrients.',
          'Palak aur methi folate, iron aur doosre zaroori nutrients dete hain.',
        ),
      ),
    ],
    avoid: [
      W5Card(
        title: _t('Raw or undercooked meat & eggs', 'कच्चा या अधपका माँस और अंडे'),
        body: _t(
          'Can carry bacteria like salmonella or listeria, so cook everything thoroughly before eating.',
          'Insme salmonella ya listeria jaise bacteria ho sakte hain, isliye khaane se pehle sab kuch acche se pakao.',
        ),
      ),
      W5Card(
        title: _t('Unpasteurised dairy', 'बिना pasteurise किया दूध'),
        body: _t(
          'Avoid unpasteurised milk, paneer, and soft cheese, which may carry listeria bacteria; choose pasteurised options instead.',
          'Bina pasteurise kiya doodh, paneer aur soft cheese se bacho, inmein listeria bacteria ho sakta hai; iske badle pasteurised options chuno.',
        ),
      ),
      W5Card(
        title: _t('High-mercury fish', 'ज़्यादा Mercury वाली मछली'),
        body: _t(
          "Limit shark, swordfish and king mackerel, as mercury can affect your baby's developing brain.",
          'Shark, swordfish aur king mackerel kam karo, kyunki mercury tumhare baby ke ban rahe brain ko nuksaan pahuncha sakta hai.',
        ),
      ),
      W5Card(
        title: _t('Too much caffeine', 'बहुत ज़्यादा caffeine'),
        body: _t(
          'Keep caffeine below 200 mg a day, about one to two small cups of coffee.',
          'Caffeine ek din mein 200 mg se kam rakho, lagbhag ek se do chhote cup coffee.',
        ),
      ),
      W5Card(
        title: _t('Alcohol', 'शराब'),
        body: _t(
          'No amount is considered safe in pregnancy, so it is best avoided completely.',
          'Pregnancy mein koi bhi maatra surakshit nahi maani jaati, isliye ise poori tarah chhod dena hi behtar hai.',
        ),
      ),
    ],
  ),

  // ---- 7 · Trimester Tips (T1 · Weeks 1–13) ---------------------------------
  tips: [
    W5Tip(
      oneLine: _t('Take your folic acid every single day.', 'Folic acid हर एक दिन लीजिए।'),
      readMore: _t(
        "Folic acid is one of the most important things you can take right now. In these early weeks, it helps your baby's brain and spine form properly. Most doctors suggest 400 micrograms a day, ideally from before pregnancy through the first trimester. Take it at the same time each day so it becomes a habit.",
        'Folic acid abhi tum jo le sakti ho usme sabse zaroori cheezon mein se ek hai. In shuruaati hafton mein yeh tumhare baby ke brain aur spine ko theek se banne mein madad karta hai. Zyadatar doctor din mein 400 microgram salaah dete hain, behtar hai pregnancy se pehle se pehle trimester tak. Ise har din ek hi waqt lo taaki aadat ban jaaye.',
      ),
    ),
    W5Tip(
      oneLine: _t("Book your first doctor's visit as early as you can.", 'डॉक्टर के पास पहली बार जितनी जल्दी हो सके जाइए।'),
      readMore: _t(
        "Once you know you are pregnant, book your first appointment with a doctor or gynaecologist. This first visit sets up your care for the months ahead. Your doctor will confirm your pregnancy, talk through your health, and guide you on tests, diet and supplements. Do not worry if you have many questions. That is exactly what this visit is for.",
        'Jaise hi pata chale ki tum pregnant ho, doctor ya gynaecologist se pehli appointment book karo. Yeh pehli visit aane waale mahinon ki dekhbhaal tay karti hai. Tumhara doctor pregnancy confirm karega, tumhari sehat par baat karega, aur tests, diet tatha supplements par maargdarshan dega. Agar bahut sawaal hain to fikr mat karo. Yeh visit isi ke liye hai.',
      ),
    ),
    W5Tip(
      oneLine: _t('Eat small, frequent meals to ease nausea.', 'मतली कम करने के लिए थोड़ा-थोड़ा, बार-बार खाइए।'),
      readMore: _t(
        "Morning sickness can strike at any time of day, and an empty stomach often makes it worse. Instead of three big meals, try eating small amounts every few hours. Keep simple snacks like biscuits, toast or a banana close by, even next to your bed. Ginger and nimbu paani help many women feel a little settled.",
        'Morning sickness din ke kisi bhi waqt aa sakti hai, aur khaali pet ise aksar badha deta hai. Teen bade meals ke bajaay, har kuch ghante mein thoda-thoda khaane ki koshish karo. Biscuit, toast ya kela jaise simple snacks paas rakho, apne bistar ke paas bhi. Adrak aur nimbu paani bahut si mahilaon ko thoda behtar mehsoos karaate hain.',
      ),
    ),
    W5Tip(
      oneLine: _t('Rest as much as your body needs.', 'शरीर जितना आराम माँगे, उतना दीजिए।'),
      readMore: _t(
        "First-trimester tiredness is real, and it can feel heavier than any tiredness before. Your body is doing huge work behind the scenes, so give yourself permission to slow down. Sleep a little earlier, take short naps when you can, and let some chores wait. Rest is not being lazy. It is part of looking after your baby.",
        'Pehle trimester ki thakaan sach hoti hai, aur yeh pehle ki kisi bhi thakaan se bhaari lag sakti hai. Tumhara body parde ke peeche bahut bada kaam kar raha hai, isliye khud ko dheema hone ki ijaazat do. Thoda jaldi so jao, jab ho sake chhoti jhapki lo, aur kuch kaam ko intezaar karne do. Aaram karna aalas nahi hai. Yeh apne baby ki dekhbhaal ka hissa hai.',
      ),
    ),
    W5Tip(
      oneLine: _t('Drink plenty of water through the day.', 'दिन भर ख़ूब पानी पीजिए।'),
      readMore: _t(
        "Staying well hydrated helps with many early pregnancy small discomforts, from tiredness to headaches to constipation. Aim to sip water steadily through the day rather than a lot at once. If plain water feels dull, try coconut water, buttermilk or nimbu paani. On queasy days, cool drinks are sometimes easier to manage than food.",
        'Achhe se hydrated rehna shuruaati pregnancy ki kai chhoti takleefon mein madad karta hai — thakaan se lekar sardard aur constipation tak. Ek saath bahut zyada ke bajaay din bhar thoda-thoda paani piyo. Agar saada paani boring lage, to nariyal paani, chhaach ya nimbu paani try karo. Matli waale din, thande drinks kabhi khaane se aasaan hote hain.',
      ),
    ),
    W5Tip(
      oneLine: _t('Cook food well and wash fruits and vegetables.', 'खाना अच्छी तरह पकाइए और फल-सब्ज़ियाँ धोइए।'),
      readMore: _t(
        "In pregnancy, your body fights off infections less easily, so food safety matters more than usual. Cook meat, fish and eggs fully, and choose pasteurised milk and dairy. Wash fruits and vegetables well before eating. Avoid raw or undercooked items and unpasteurised foods for now. These simple habits lower the chance of an upset that could affect you both.",
        'Pregnancy mein tumhara body infections se kam aasaani se ladta hai, isliye food safety aam se zyada mayne rakhti hai. Meat, machhli aur ande poore pakao, aur pasteurised doodh aur dairy chuno. Khaane se pehle fal aur sabziyan achhe se dhoyo. Kacchi ya adhpaki cheezein aur bina-pasteurised khaane abhi ke liye chhodo. Yeh simple aadatein us gadbadi ka khatra kam karti hain jo tum dono ko prabhaavit kar sakti hai.',
      ),
    ),
    W5Tip(
      oneLine: _t('Limit caffeine, and skip alcohol and smoking.', 'Caffeine कम कीजिए, और शराब व धूम्रपान बिलकुल नहीं।'),
      readMore: _t(
        "A little caffeine is fine, but try to keep it under about 200 milligrams a day, roughly one cup of coffee, counting tea and cola too. Alcohol has no known safe amount in pregnancy, so it is best left. If you smoke, or are around smoke, this is a good time to step away, for you both.",
        'Thodi caffeine theek hai, par ise din mein lagbhag 200 milligram ke neeche rakhne ki koshish karo — mote taur par ek cup coffee, chai aur cola ko bhi ginte hue. Pregnancy mein sharaab ki koi surakshit maatra nahi maani jaati, isliye ise chhod dena behtar hai. Agar tum smoke karti ho, ya smoke ke aaspaas ho, to yeh door hat-ne ka accha waqt hai, tum dono ke liye.',
      ),
    ),
    W5Tip(
      oneLine: _t("Keep moving gently, with your doctor's okay.", 'डॉक्टर की मंज़ूरी से, हल्की हलचल जारी रखिए।'),
      readMore: _t(
        "Unless your doctor advises otherwise, gentle movement is good for you now. A daily walk, light stretching or prenatal yoga can lift your mood, help you sleep and ease early aches. There is no need to push hard. Move at a pace where you can still chat comfortably. Always check with your doctor before starting anything new.",
        'Jab tak tumhara doctor mana na kare, halki movement abhi tumhare liye acchi hai. Roz ki walk, halki stretching ya prenatal yoga tumhara mood behtar kar sakti hai, neend mein madad kar sakti hai aur shuruaati dard kam kar sakti hai. Zor lagaane ki zaroorat nahi. Us raftaar par chalo jahaan tum aaraam se baat bhi kar sako. Kuch naya shuru karne se pehle hamesha apne doctor se poochho.',
      ),
    ),
    W5Tip(
      oneLine: _t('Share how you feel with someone you trust.', 'अपना मन किसी अपने के साथ बाँटिए।'),
      readMore: _t(
        "Early pregnancy can bring a mix of joy, worry and mood swings, often all at once. This is normal, and hormones play a big part. You do not have to carry it alone. Talking to your partner, a close friend or family member can lighten the load. If low feelings stay for long, tell your doctor.",
        'Shuruaati pregnancy khushi, fikr aur mood swings ka mishran la sakti hai, aksar sab ek saath. Yeh normal hai, aur hormones badi bhoomika nibhaate hain. Ise akele uthaane ki zaroorat nahi. Apne partner, kisi kareebi dost ya parivaar se baat karna bojh halka kar sakta hai. Agar udaasi lambe samay tak rahe, to apne doctor ko bataao.',
      ),
    ),
  ],

  // ---- 8 · Share With Partner -----------------------------------------------
  partner: W5Partner(
    baby: _t(
      "This week my fingers and toes have fully separated, and tiny nails are just beginning to grow. I'm about the size of a strawberry now, and all my major organs have formed and are starting to work together as a team.",
      'Is hafte meri ungliyan aur pairon ki ungliyan poori tarah alag ho gayi hain, aur nanhe naakhun abhi ugna shuru hue hain. Ab main lagbhag ek strawberry jitna hoon, aur mere sabhi bade organs ban chuke hain aur ek team ki tarah saath kaam karna shuru kar rahe hain.',
    ),
    mother: _t(
      "For many women, this is when the toughest symptoms start easing, though everyone's timeline is a little different. She may still be dealing with tiredness, headaches or nausea, alongside newer things like visible veins or sharp twinges as her body keeps changing. Small comforts and patience go a long way right now.",
      'Bahut si mahilaon ke liye yahi woh waqt hai jab sabse mushkil symptoms halke padne lagte hain, halaanki har kisi ka timeline thoda alag hota hai. Woh abhi bhi thakaan, sar dard ya matli se jujh rahi ho sakti hai, saath hi nayi cheezein jaise dikhti nasein ya tez chubhan, jab uska body badalta ja raha hai. Chhoti sahoolatein aur sabr abhi bahut mayne rakhte hain.',
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
