// =============================================================================
//  Ready for Birth - the readiness layer over the hospital-bag data
// -----------------------------------------------------------------------------
//  "Ready for Birth" is a redesign of the Hospital Bag as a calm READINESS
//  experience, not a checklist. It reuses the existing bag data wholesale
//  (BagItem / catalogue / seed / HospitalBagV2Store) but reframes it:
//    • the six bag sections collapse into FOUR readiness categories
//      (Mom · Baby · Documents · Partner & Extras),
//    • every item carries a one-line "why pack this",
//    • contextual ParentVeda insights replace long articles,
//    • an emergency grab-list and a guided packing order live here too.
//  Pure data/logic - no widgets, no state. Personalisation inputs (week,
//  delivery, season, twins, hospital-provides) are passed in by the caller.
// =============================================================================

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../services/hospital_bag_store.dart' show BagCategory, BagItem, DeliveryType;
import '../theme/app_theme.dart';

// ---- the four readiness categories -----------------------------------------
enum ReadyCategory { mom, baby, documents, partnerExtras }

/// A bilingual pair. Local to this file, matching the shape the other data
/// files use, so a new entry cannot be added without its Hindi being an
/// obvious omission rather than an invisible one.
///
/// Not const, because Dart has no const functions — which is why the tables
/// below are `final` rather than `const`. They are top-level and built once,
/// so at runtime the difference is nothing.
LocalizedText _t(String en, String hi) => LocalizedText(en: en, hi: hi);

class ReadyCatMeta {
  const ReadyCatMeta(this.label, this.blurb, this.icon, this.color);
  final LocalizedText label;
  final LocalizedText blurb;
  final IconData icon;
  final Color color;
}

final Map<ReadyCategory, ReadyCatMeta> kReadyCatMeta = {
  ReadyCategory.mom: ReadyCatMeta(
      _t('Mom', 'माँ'),
      _t('For you — labour, recovery and comfort',
          'आपके लिए — प्रसव, रिकवरी और आराम'),
      Icons.spa_rounded,
      AppTheme.secondary500),
  ReadyCategory.baby: ReadyCatMeta(
      _t('Baby', 'शिशु'),
      _t('The first clothes, changes and cosy things',
          'पहले कपड़े, नैपी और गर्माहट भरी चीज़ें'),
      Icons.child_friendly_rounded,
      AppTheme.tertiary400),
  ReadyCategory.documents: ReadyCatMeta(
      _t('Documents', 'काग़ज़ात'),
      _t('The papers the hospital will ask for',
          'वे काग़ज़ जो अस्पताल माँगेगा'),
      Icons.folder_rounded,
      AppTheme.primary500),
  ReadyCategory.partnerExtras: ReadyCatMeta(
      _t('Partner & extras', 'साथी और बाक़ी'),
      _t('For your partner, and the nice-to-haves',
          'आपके साथी के लिए, और वे चीज़ें जो अच्छी लगती हैं'),
      Icons.handshake_rounded,
      AppTheme.primary300),
};

/// Collapse the six bag sections into the four readiness categories.
ReadyCategory readyCategoryOfBag(BagCategory c) {
  switch (c) {
    case BagCategory.labour:
    case BagCategory.afterDelivery:
    case BagCategory.comfort:
      return ReadyCategory.mom;
    case BagCategory.baby:
      return ReadyCategory.baby;
    case BagCategory.documents:
      return ReadyCategory.documents;
    case BagCategory.partner:
    case BagCategory.custom:
      return ReadyCategory.partnerExtras;
  }
}

ReadyCategory readyCategoryOf(BagItem i) => readyCategoryOfBag(i.category);

/// The display order of the four categories (Documents first — quickest win).
const List<ReadyCategory> kReadyOrder = [
  ReadyCategory.documents,
  ReadyCategory.mom,
  ReadyCategory.baby,
  ReadyCategory.partnerExtras,
];

// ---- one-line "why pack this" ----------------------------------------------
//  Answers "why should I pack this?" in a single calm line. Keyed by item id;
//  a gentle generic line covers custom/unknown items.
final Map<String, LocalizedText> kWhyPack = {
  'labour_gown': _t('Comfortable, and easy for the team to work around.', 'आरामदायक, और टीम को काम करने में आसानी।'),
  'labour_socks': _t('Labour rooms are kept cold — warm feet help you relax.', 'प्रसव कक्ष ठंडा रखा जाता है — गर्म पैर आपको ढीला छोड़ने में मदद करते हैं।'),
  'labour_lipbalm': _t('Heavy breathing dries your lips surprisingly fast.', 'तेज़ साँस लेने से होंठ सोच से जल्दी सूख जाते हैं।'),
  'labour_hairties': _t('Keeps your hair off your face through the long hours.', 'लंबे घंटों में बाल चेहरे से दूर रहते हैं।'),
  'labour_water': _t('A straw lets you sip lying down, without spills.', 'स्ट्रॉ से लेटे-लेटे घूँट भरा जा सकता है, बिना गिराए।'),
  'labour_snacks': _t('Quick energy between contractions — check what your hospital allows.', 'संकुचन के बीच तुरंत ऊर्जा — अपने अस्पताल से पूछ लीजिए कि क्या ले जा सकती हैं।'),
  'labour_glasses': _t("If you wear them, you'll want to see your baby clearly.", 'अगर आप चश्मा पहनती हैं, तो शिशु को साफ़ देखना चाहेंगी।'),
  'labour_music': _t('A familiar playlist can calm and focus you.', 'जानी-पहचानी धुनें शांत करती हैं और ध्यान टिकाती हैं।'),
  'after_pads': _t("Post-delivery flow is heavy — you'll need more than you think.", 'जन्म के बाद रक्तस्राव ज़्यादा होता है — सोच से ज़्यादा लगेंगे।'),
  'after_underwear': _t('High-waist and disposable, so nothing presses on stitches.', 'ऊँची कमर वाले और एक बार इस्तेमाल के, ताकि टाँकों पर दबाव न पड़े।'),
  'after_nursingbra': _t('Soft, with easy one-hand access for feeding.', 'नरम, और एक हाथ से खुलने वाली — दूध पिलाने में आसान।'),
  'after_breastpads': _t('For the leaks that come as your milk settles in.', 'दूध उतरने के दिनों में रिसाव के लिए।'),
  'after_nipplecream': _t('Soothes sore skin in the early feeding days.', 'शुरुआती दिनों में दुखती त्वचा को आराम देती है।'),
  'after_outfit': _t('Something loose and soft for a healing body.', 'ठीक हो रहे शरीर के लिए कुछ ढीला और नरम।'),
  'after_toiletries': _t('Your own basics make a hospital room feel human.', 'अपनी रोज़ की चीज़ें अस्पताल के कमरे को अपना बना देती हैं।'),
  'after_towel': _t('Hospitals rarely provide a soft towel for you.', 'अस्पताल आपके लिए नरम तौलिया कम ही देते हैं।'),
  'after_slippers': _t('Easy to slip on for slow walks down the ward.', 'वार्ड में धीमे टहलने के लिए झट से पहनने लायक़।'),
  'after_binder': _t('Gentle support after a C-section — only if your doctor advises.', 'C-section के बाद हल्का सहारा — सिर्फ़ तब, जब डॉक्टर कहें।'),
  'baby_bodysuits': _t('A few soft changes — newborns go through them fast.', 'कुछ नरम जोड़े — नवजात इन्हें बहुत जल्दी गंदा करते हैं।'),
  'baby_swaddle': _t('Keeps your baby snug, warm and calm.', 'शिशु को लिपटा हुआ, गर्म और शांत रखता है।'),
  'baby_mittens': _t('Warm hands, and no accidental face scratches.', 'हाथ गर्म रहें, और चेहरे पर अनजाने में खरोंच न लगे।'),
  'baby_cap': _t('Newborns lose heat from the head — a cap keeps them cosy.', 'नवजात सिर से गर्मी खोते हैं — टोपी उन्हें गर्म रखती है।'),
  'baby_diapers': _t('For the very first changes — your hospital may provide some.', 'सबसे पहली नैपियों के लिए — कुछ आपका अस्पताल भी दे सकता है।'),
  'baby_wipes': _t('Gentle, water-based, for brand-new skin.', 'बिलकुल नई त्वचा के लिए, हल्के और पानी वाले।'),
  'baby_blanket': _t('A soft cover for the cot and the ride home.', 'पालने के लिए और घर लौटते वक़्त एक नरम ओढ़नी।'),
  'baby_towel': _t('A hooded towel keeps your baby warm after the first bath.', 'टोपी वाला तौलिया पहले स्नान के बाद शिशु को गर्म रखता है।'),
  'baby_lotion': _t('A mild moisturiser for delicate newborn skin.', 'नाज़ुक नवजात त्वचा के लिए हल्का मॉइस्चराइज़र।'),
  'baby_homeoutfit': _t('The going-home outfit — and those first photos.', 'घर लौटने वाला जोड़ा — और वही पहली तस्वीरें।'),
  'partner_clothes': _t('A change of clothes, for a stay that can run long.', 'कपड़ों का एक जोड़ा, क्योंकि रुकना लंबा खिंच सकता है।'),
  'partner_snacks': _t('Keeps your partner fuelled and steady beside you.', 'आपके साथी को भूखा नहीं रहने देते, ताकि वे साथ टिके रहें।'),
  'partner_charger': _t('One long night drains every phone — pack a power bank.', 'एक लंबी रात हर फ़ोन ख़त्म कर देती है — पावर बैंक रख लीजिए।'),
  'partner_cash': _t('Small cash and cards for parking, canteen and forms.', 'पार्किंग, कैंटीन और फ़ॉर्म के लिए थोड़े नक़द और कार्ड।'),
  'partner_toiletries': _t('The basics, so your partner can freshen up too.', 'ज़रूरी चीज़ें, ताकि आपके साथी भी ताज़ा हो सकें।'),
  'docs_id': _t('Admission needs a photo ID — keep it right on top.', 'भर्ती के लिए फ़ोटो पहचान-पत्र चाहिए — इसे सबसे ऊपर रखिए।'),
  'docs_admission': _t('Your hospital registration and admission papers.', 'आपके अस्पताल का रजिस्ट्रेशन और भर्ती के काग़ज़।'),
  'docs_insurance': _t('Insurance or TPA card, to smooth the paperwork.', 'बीमा या TPA कार्ड, ताकि काग़ज़ी काम आसान रहे।'),
  'docs_records': _t('Your scan reports and medical file, for the team.', 'आपकी स्कैन रिपोर्ट और मेडिकल फ़ाइल, टीम के लिए।'),
  'docs_birthplan': _t("If you've written one, keep a copy handy.", 'अगर आपने लिखा है, तो एक प्रति पास रखिए।'),
  'docs_contacts': _t("Your doctor's number — saved, and on paper.", 'आपके डॉक्टर का नंबर — सेव भी, और काग़ज़ पर भी।'),
  'comfort_pillow': _t('Your own pillow makes a strange bed feel like home.', 'अपना तकिया एक अजनबी बिस्तर को घर जैसा बना देता है।'),
  'comfort_eyemask': _t('Blocks bright ward lights so you can rest.', 'वार्ड की तेज़ रोशनी रोकता है, ताकि आप आराम कर सकें।'),
  'comfort_scent': _t('A familiar scent is grounding when things feel intense.', 'जानी-पहचानी ख़ुशबू तब सहारा देती है जब सब कुछ भारी लगे।'),
  'comfort_affirm': _t('A few calming words to focus on during labour.', 'प्रसव के दौरान ध्यान टिकाने के लिए कुछ शांत शब्द।'),
  'sugg_nursingpillow': _t('Supports your baby at the breast and saves your arms.', 'दूध पिलाते वक़्त शिशु को सहारा देता है और आपकी बाँहें बचाता है।'),
  'sugg_extraoutfit': _t('A spare, for the inevitable little accidents.', 'एक अतिरिक्त जोड़ा, क्योंकि छोटी-मोटी गड़बड़ होती ही है।'),
  'sugg_compsocks': _t('Eases the swelling that often comes after birth.', 'जन्म के बाद अक्सर आने वाली सूजन में आराम देते हैं।'),
  'sugg_handfan': _t('A little cooling relief through the warm hours.', 'गर्म घंटों में थोड़ी ठंडक।'),
  'sugg_speaker': _t('To play your calming music out loud.', 'अपना शांत करने वाला संगीत खुलकर बजाने के लिए।'),
  'sugg_journal': _t('For the first notes and feelings you\'ll want to keep.', 'पहले नोट और वे भाव, जिन्हें आप सहेजना चाहेंगी।'),
};

/// Resolves to the reading language here rather than at the call site, so the
/// two screens that show this line did not have to change at all.
String whyPack(BagItem i) =>
    (kWhyPack[i.id] ??
            _t('A thoughtful thing to have with you.',
                'साथ रखने लायक़ एक सोची-समझी चीज़।'))
        .now;

// ---- season -----------------------------------------------------------------
enum Season { winter, summer, monsoon, pleasant }

/// India-leaning season from a month (1–12).
Season seasonForMonth(int month) {
  if (month == 12 || month <= 2) return Season.winter;
  if (month >= 3 && month <= 5) return Season.summer;
  if (month >= 6 && month <= 9) return Season.monsoon;
  return Season.pleasant; // Oct–Nov
}

String seasonLabel(Season s) => switch (s) {
      Season.winter => _t('Winter', 'सर्दी').now,
      Season.summer => _t('Summer', 'गर्मी').now,
      Season.monsoon => _t('Monsoon', 'बारिश').now,
      Season.pleasant => _t('Pleasant', 'सुहाना').now,
    };

// ---- hospital-provides tokens ----------------------------------------------
//  Things a hospital commonly provides; if the mother marks one, we drop the
//  matching catalogue item from "what's left" and surface a reassuring insight.
final Map<String, LocalizedText> kHospitalProvidableLabel = {
  'diapers': _t('Diapers', 'नैपियाँ'),
  'blankets': _t('Receiving blankets', 'लपेटने वाले कंबल'),
  'babytowel': _t('Baby towels', 'शिशु के तौलिये'),
  'wipes': _t('Wipes', 'वाइप्स'),
};

/// The catalogue item id a hospital-provides token removes from the bag.
const Map<String, String> kProvidesToItemId = {
  'diapers': 'baby_diapers',
  'blankets': 'baby_blanket',
  'babytowel': 'baby_towel',
  'wipes': 'baby_wipes',
};

Set<String> providedItemIds(Set<String> tokens) =>
    {for (final t in tokens) if (kProvidesToItemId[t] != null) kProvidesToItemId[t]!};

// ---- contextual insight cards ----------------------------------------------
class ReadyInsight {
  ReadyInsight(this.icon, this.text);
  final IconData icon;
  final String text;
}

/// The intelligent, contextual insights that replace long articles. Ordered by
/// relevance; the caller shows the top few.
List<ReadyInsight> readyInsights({
  required int week,
  required DeliveryType delivery,
  required Season season,
  required bool twins,
  required Set<String> hospitalProvides,
}) {
  final out = <ReadyInsight>[];

  // Timing (week-aware, never pressuring).
  if (week >= 38) {
    out.add(ReadyInsight(Icons.event_available_rounded,
        _t("You're full term — your bag is best kept packed and by the door now.", 'आप पूरे समय पर हैं — अब बैग पैक करके दरवाज़े के पास ही रखना बेहतर है।').now));
  } else if (week >= 36) {
    out.add(ReadyInsight(Icons.event_available_rounded,
        _t('Around week 36 is the ideal time to have everything packed and ready.', 'लगभग हफ़्ता 36 सब कुछ पैक करके तैयार रखने का सबसे सही समय है।').now));
  } else if (week >= 32) {
    out.add(ReadyInsight(Icons.inventory_2_outlined,
        _t('A lovely time to start collecting essentials — no rush, just a little at a time.', 'ज़रूरी चीज़ें जुटाना शुरू करने का प्यारा समय — कोई जल्दी नहीं, थोड़ा-थोड़ा करके।').now));
  } else {
    out.add(ReadyInsight(Icons.spa_outlined,
        _t('Plenty of time yet. Explore what you\'ll eventually need, gently.', 'अभी बहुत समय है। आगे क्या लगेगा, आराम से देखती रहिए।').now));
  }

  // Delivery type.
  if (delivery == DeliveryType.csection) {
    out.add(ReadyInsight(Icons.checkroom_rounded,
        _t('For your planned C-section, loose high-waisted clothing is usually more comfortable afterward.', 'तय C-section के लिए, बाद में ढीले और ऊँची कमर वाले कपड़े आम तौर पर ज़्यादा आरामदेह रहते हैं।').now));
  }

  // Twins.
  if (twins) {
    out.add(ReadyInsight(Icons.child_friendly_rounded,
        _t('Twins on the way — pack a few extra bodysuits, more diapers and a second going-home outfit.', 'जुड़वाँ आ रहे हैं — कुछ अतिरिक्त जोड़े, ज़्यादा नैपियाँ और घर लौटने का दूसरा जोड़ा रख लीजिए।').now));
  }

  // Season.
  switch (season) {
    case Season.winter:
      out.add(ReadyInsight(Icons.ac_unit_rounded,
          _t('Winter delivery — one extra blanket and a warm cap make the ride home cosy.', 'सर्दी की डिलीवरी — एक अतिरिक्त कंबल और गर्म टोपी घर का सफ़र आरामदेह बना देते हैं।').now));
      break;
    case Season.summer:
      out.add(ReadyInsight(Icons.wb_sunny_rounded,
          _t('Summer delivery — light muslin layers keep your baby comfortable; skip the heavy blanket.', 'गर्मी की डिलीवरी — हल्की मलमल की परतें शिशु को आरामदेह रखती हैं; भारी कंबल रहने दीजिए।').now));
      break;
    case Season.monsoon:
      out.add(ReadyInsight(Icons.umbrella_rounded,
          _t('Monsoon days — a waterproof cover for the bag and one spare dry set are worth it.', 'बारिश के दिन — बैग के लिए एक वाटरप्रूफ़ कवर और एक सूखा जोड़ा रखना काम आता है।').now));
      break;
    case Season.pleasant:
      break;
  }

  // Hospital provides.
  for (final t in hospitalProvides) {
    final label = kHospitalProvidableLabel[t];
    if (label != null) {
      out.add(ReadyInsight(
          Icons.local_hospital_outlined,
          _t('Your hospital provides ${label.en.toLowerCase()} — no need to '
                  'pack your own.',
              'आपका अस्पताल ${label.hi} देता है — अपनी लाने की ज़रूरत नहीं।')
              .now));
    }
  }

  // Always-true gentle reassurance (kept last).
  out.add(ReadyInsight(Icons.favorite_border_rounded,
      _t('Most hospitals provide a cot and basic newborn care — pack for comfort, not duplication.', 'ज़्यादातर अस्पताल पालना और नवजात की बुनियादी देखभाल देते हैं — आराम के लिए पैक कीजिए, दोहराने के लिए नहीं।').now));

  return out;
}

// ---- emergency grab-list ----------------------------------------------------
class GrabItem {
  const GrabItem(this.icon, this.title, this.sub);
  final IconData icon;
  final LocalizedText title;
  final LocalizedText sub;
}

final List<GrabItem> kEmergencyGrab = [
  GrabItem(Icons.luggage_rounded, _t('Your hospital bag', 'आपका अस्पताल बैग'),
      _t('Packed and by the door', 'पैक करके दरवाज़े के पास')),
  GrabItem(Icons.folder_rounded, _t('Documents folder', 'काग़ज़ात की फ़ाइल'),
      _t('ID, admission papers, records',
          'पहचान-पत्र, भर्ती के काग़ज़, रिकॉर्ड')),
  GrabItem(Icons.smartphone_rounded, _t('Phone + charger', 'फ़ोन + चार्जर'),
      _t("And your doctor's number", 'और आपके डॉक्टर का नंबर')),
  GrabItem(Icons.water_drop_outlined, _t('Water bottle', 'पानी की बोतल'),
      _t('For the journey there', 'वहाँ तक के सफ़र के लिए')),
];

// ---- guided packing order ---------------------------------------------------
//  Documents first (fastest win), then Mom, Baby, Partner & extras.
const List<ReadyCategory> kGuidedOrder = [
  ReadyCategory.documents,
  ReadyCategory.mom,
  ReadyCategory.baby,
  ReadyCategory.partnerExtras,
];

/// A gentle estimate of minutes left from the number of unpacked items.
int estMinutesFor(int remaining) => remaining <= 0 ? 0 : (remaining * 0.6).ceil().clamp(1, 60);
