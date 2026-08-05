"""Make the Ready-for-Birth insight cards and provides-labels bilingual.

`ReadyInsight.text` stays a plain String: the insights are BUILT at call time
from week, delivery type, season and twins, so resolving the language where
each one is constructed costs nothing and leaves the widget that renders them
untouched. The `const` on each construction has to go — a getter is not a
compile-time constant.
"""

import re

PATH = 'lib/data/ready_for_birth_data.dart'

PAIRS = [
    ("You're full term — your bag is best kept packed and by the door now.",
     'आप पूरे समय पर हैं — अब बैग पैक करके दरवाज़े के पास ही रखना बेहतर है।'),
    ('Around week 36 is the ideal time to have everything packed and ready.',
     'लगभग हफ़्ता 36 सब कुछ पैक करके तैयार रखने का सबसे सही समय है।'),
    ('A lovely time to start collecting essentials — no rush, just a little at a time.',
     'ज़रूरी चीज़ें जुटाना शुरू करने का प्यारा समय — कोई जल्दी नहीं, थोड़ा-थोड़ा करके।'),
    ("Plenty of time yet. Explore what you'll eventually need, gently.",
     'अभी बहुत समय है। आगे क्या लगेगा, आराम से देखती रहिए।'),
    ('For your planned C-section, loose high-waisted clothing is usually more comfortable afterward.',
     'तय C-section के लिए, बाद में ढीले और ऊँची कमर वाले कपड़े आम तौर पर ज़्यादा आरामदेह रहते हैं।'),
    ('Twins on the way — pack a few extra bodysuits, more diapers and a second going-home outfit.',
     'जुड़वाँ आ रहे हैं — कुछ अतिरिक्त जोड़े, ज़्यादा नैपियाँ और घर लौटने का दूसरा जोड़ा रख लीजिए।'),
    ('Winter delivery — one extra blanket and a warm cap make the ride home cosy.',
     'सर्दी की डिलीवरी — एक अतिरिक्त कंबल और गर्म टोपी घर का सफ़र आरामदेह बना देते हैं।'),
    ('Summer delivery — light muslin layers keep your baby comfortable; skip the heavy blanket.',
     'गर्मी की डिलीवरी — हल्की मलमल की परतें शिशु को आरामदेह रखती हैं; भारी कंबल रहने दीजिए।'),
    ('Monsoon days — a waterproof cover for the bag and one spare dry set are worth it.',
     'बारिश के दिन — बैग के लिए एक वाटरप्रूफ़ कवर और एक सूखा जोड़ा रखना काम आता है।'),
    ('Most hospitals provide a cot and basic newborn care — pack for comfort, not duplication.',
     'ज़्यादातर अस्पताल पालना और नवजात की बुनियादी देखभाल देते हैं — आराम के लिए पैक कीजिए, दोहराने के लिए नहीं।'),
]

LABELS = {
    'diapers': ('Diapers', 'नैपियाँ'),
    'blankets': ('Receiving blankets', 'लपेटने वाले कंबल'),
    'babytowel': ('Baby towels', 'शिशु के तौलिये'),
    'wipes': ('Wipes', 'वाइप्स'),
}


def lit(text, quote="'"):
    return quote + text.replace('\\', '\\\\').replace(quote, '\\' + quote) + quote


src = open(PATH, encoding='utf-8').read()

# 1. The insight strings -> _t(en, hi).now, and drop the const that blocks it.
missed = []
for en, hi in PAIRS:
    for quote in ("'", '"'):
        needle = lit(en, quote)
        if needle in src:
            src = src.replace(needle, f'_t({needle}, {lit(hi)}).now')
            break
    else:
        missed.append(en[:50])
src = src.replace('const ReadyInsight(', 'ReadyInsight(')

# 2. The hospital-provides labels become pairs.
block = re.search(r"const Map<String, String> kHospitalProvidableLabel = \{.*?\};",
                  src, re.S)
rows = ',\n'.join(
    f"  '{k}': _t({lit(en)}, {lit(hi)})" for k, (en, hi) in LABELS.items())
src = (src[:block.start()]
       + 'const Map<String, LocalizedText> kHospitalProvidableLabel = {\n'
       + rows + ',\n};'
       + src[block.end():])

# 3. The sentence built from a label needs both halves, not a lowercased English.
old = ("      out.add(ReadyInsight(Icons.local_hospital_outlined,\n"
       "          'Your hospital provides ${label.toLowerCase()} — no need to pack your own.'));")
new = ("      out.add(ReadyInsight(\n"
       "          Icons.local_hospital_outlined,\n"
       "          _t('Your hospital provides ${label.en.toLowerCase()} — no need to '\n"
       "                  'pack your own.',\n"
       "              'आपका अस्पताल ${label.hi} देता है — अपनी लाने की ज़रूरत नहीं।')\n"
       "              .now));")
if old in src:
    src = src.replace(old, new)
else:
    missed.append('the hospital-provides sentence')

open(PATH, 'w', encoding='utf-8', newline='').write(src)
print(f'{len(PAIRS) - len([m for m in missed if m != "the hospital-provides sentence"])}'
      f'/{len(PAIRS)} insights + {len(LABELS)} labels converted')
for m in missed:
    print('  MISS: ' + m)
