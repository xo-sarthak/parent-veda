"""Make the hospital-bag catalogue's why/consider bullets bilingual.

These are the lines under each product that argue for it — the trust layer. They
rendered English inside a screen that is otherwise Devanagari.

Product NAMES stay Latin on purpose. They are catalogue entries under the
ParentVeda brand, and `_valueName` derives the budget option by string surgery
on the "ParentVeda " prefix — translating the name would quietly break that
derivation as well as reading like a translated shop listing.
"""

import re

PATH = 'lib/data/hospital_bag_catalog.dart'

HI = {
    'Soft, breathable cotton': 'नरम, साँस लेने वाला सूती',
    'Front-open for skin-to-skin & feeding':
        'आगे से खुलने वाला — त्वचा से त्वचा और दूध पिलाने के लिए',
    'Darker shades hide stains': 'गहरे रंग दाग़ छिपा लेते हैं',
    'Warm for cold labour rooms': 'ठंडे प्रसव कक्ष में गर्म',
    'Non-slip soles': 'न फिसलने वाले तले',
    'Heavy breathing dries lips fast': 'तेज़ साँस से होंठ जल्दी सूखते हैं',
    'Natural, safe ingredients': 'क़ुदरती, सुरक्षित सामग्री',
    'Keeps hair off your face': 'बाल चेहरे से दूर रखता है',
    'Gentle, no-pull hold': 'हल्की पकड़, बाल नहीं खींचती',
    'Sip lying down without spills': 'लेटे-लेटे घूँट, बिना गिराए',
    'Stays cool for hours': 'घंटों ठंडा रहता है',
    'Quick energy between contractions': 'संकुचन के बीच तुरंत ऊर्जा',
    'Easy to digest': 'आसानी से पचने वाला',
    'Check what your hospital allows': 'अपने अस्पताल से पूछ लीजिए क्या ले जा सकती हैं',
    'Extra-long, high absorbency': 'ज़्यादा लंबे, ज़्यादा सोखने वाले',
    'Soft top layer for comfort': 'ऊपर की नरम परत, आराम के लिए',
    'You will need more than you think': 'सोच से ज़्यादा लगेंगे',
    'High-waist, won’t press on stitches': 'ऊँची कमर, टाँकों पर दबाव नहीं',
    'Soft, breathable & disposable': 'नरम, साँस लेने वाले और एक बार के',
    'Size up for comfort': 'आराम के लिए एक नाप बड़ा लीजिए',
    'Soft, breathable fabric': 'नरम, साँस लेने वाला कपड़ा',
    'Easy one-hand nursing access': 'एक हाथ से खुलने वाली, दूध पिलाने में आसान',
    'Size up from your usual': 'अपने रोज़ के नाप से एक बड़ा',
    'Super absorbent, stay-dry': 'ख़ूब सोखने वाले, सूखा रखने वाले',
    'Gentle on sensitive skin': 'नाज़ुक त्वचा पर हल्के',
    'Soothes sore skin': 'दुखती त्वचा को आराम',
    'Safe for baby - no need to wipe off':
        'शिशु के लिए सुरक्षित — पोंछने की ज़रूरत नहीं',
    'Loose & soft on a healing body': 'ठीक हो रहे शरीर पर ढीला और नरम',
    'Easy nursing access': 'दूध पिलाने में आसान',
    'Hospital-ready travel sizes': 'अस्पताल के लिए छोटे पैक',
    'Gentle, fragrance-free': 'हल्के, बिना ख़ुशबू के',
    'Soft & quick-drying': 'नरम और जल्दी सूखने वाला',
    'Compact for the bag': 'बैग में आसानी से समाने वाला',
    'Easy slip-on, washable': 'झट से पहनने वाले, धुलने वाले',
    'Cushioned sole': 'गद्देदार तला',
    'Gentle support after a C-section': 'C-section के बाद हल्का सहारा',
    'Adjustable fit': 'अपने हिसाब से कसा जा सकता है',
    'Use only if your doctor advises': 'सिर्फ़ तब लीजिए जब डॉक्टर कहें',
    'Gentle cotton on newborn skin': 'नवजात की त्वचा पर हल्का सूती',
    'Easy snap changes': 'बटन से झट से बदलने वाला',
    'Newborn size is outgrown quickly': 'नवजात का नाप जल्दी छोटा पड़ जाता है',
    'Soft muslin, breathable': 'नरम मलमल, साँस लेने वाला',
    'Keeps baby snug & calm': 'शिशु को लिपटा और शांत रखता है',
    'Muslin for warm weather, fleece for cold':
        'गर्मी में मलमल, सर्दी में ऊनी',
    'Keeps tiny hands & feet warm': 'नन्हे हाथ-पैर गर्म रखते हैं',
    'Prevents face scratches': 'चेहरे पर खरोंच नहीं लगने देते',
    'Newborns lose heat from the head': 'नवजात सिर से गर्मी खोते हैं',
    'Soft, seam-free': 'नरम, बिना सिलाई के',
    'Soft, snug newborn fit': 'नवजात पर नरम और ठीक बैठने वाली',
    'Wetness indicator': 'गीलेपन का संकेत',
    'Gentle on the cord stump': 'नाभि की ठूँठ पर हल्की',
    'Newborn size lasts only a few weeks':
        'नवजात का नाप कुछ ही हफ़्ते चलता है',
    '99% water, fragrance-free': '99% पानी, बिना ख़ुशबू के',
    'Gentle on newborn skin': 'नवजात की त्वचा पर हल्के',
    'Cozy & breathable': 'गर्म और साँस लेने वाला',
    'Doubles as a cover': 'ओढ़नी के तौर पर भी काम आता है',
    'Hooded, soft on delicate skin': 'टोपी वाला, नाज़ुक त्वचा पर नरम',
    'Quick-drying': 'जल्दी सूखने वाला',
    'Gentle, hypoallergenic': 'हल्का, एलर्जी की कम आशंका',
    'Light & non-greasy': 'हल्का, चिपचिपा नहीं',
    'Patch-test first': 'पहले थोड़ा सा लगाकर देख लीजिए',
    'Soft first outfit for home & photos':
        'घर और तस्वीरों के लिए पहला नरम जोड़ा',
    'Easy to put on': 'पहनाने में आसान',
    'Newborn size': 'नवजात का नाप',
    'Keeps your partner going': 'आपके पार्टनर को चलता रखता है',
    'Long shelf life': 'लंबे समय तक ख़राब नहीं होता',
    'Long cable for hospital beds': 'अस्पताल के बिस्तर के लिए लंबी तार',
    'Backup power for long stays': 'लंबे ठहराव के लिए बैकअप पावर',
    'Travel-size basics': 'सफ़र के छोटे पैक',
    'Compact & light': 'छोटा और हल्का',
    'Blocks out bright hospital lights': 'अस्पताल की तेज़ रोशनी रोकता है',
    'Soft & gentle': 'नरम और हल्का',
    'Gentle focus during labour': 'प्रसव के दौरान हल्का ध्यान',
    'Written for Indian mothers': 'भारतीय माँओं के लिए लिखा गया',
    'Supports baby at the breast': 'दूध पिलाते वक़्त शिशु को सहारा',
    'Eases arm & back strain': 'बाँह और कमर का ज़ोर कम करता है',
    'A spare for the inevitable changes': 'एक अतिरिक्त, क्योंकि बदलना पड़ेगा ही',
    'Soft newborn cotton': 'नवजात के लिए नरम सूती',
    'Eases swelling & aches': 'सूजन और दर्द में आराम',
    'Comfortable all-day wear': 'दिन भर पहनने में आरामदेह',
    'Cooling relief during labour': 'प्रसव के दौरान ठंडक',
    'USB-rechargeable': 'USB से चार्ज होने वाला',
    'Chosen for quality & comfort': 'गुणवत्ता और आराम देखकर चुना गया',
    'Trusted by ParentVeda parents': 'ParentVeda के माता-पिता का भरोसा',
    'A simpler, budget-friendly option': 'एक सरल, कम दाम वाला विकल्प',
}


def lit(text, quote="'"):
    return quote + text.replace('\\', '\\\\').replace(quote, '\\' + quote) + quote


src = open(PATH, encoding='utf-8').read()

# Field and parameter types.
src = src.replace('  final List<String> why;\n  final List<String> consider;',
                  '  final List<LocalizedText> why;\n'
                  '  final List<LocalizedText> consider;')
src = src.replace('  final List<String> why; // why ParentVeda recommends it',
                  '  final List<LocalizedText> why; '
                  '// why ParentVeda recommends it')
src = src.replace('  final List<String> consider; // things to consider',
                  '  final List<LocalizedText> consider; '
                  '// things to consider')

# Every bullet inside a why:/consider: list becomes a pair.
missed = set()


def convert(block):
    def one(m):
        quote, text = m.group(1), m.group(2)
        plain = text.replace("\\'", "'")
        if plain not in HI:
            missed.add(plain)
            return m.group(0)
        return f'_t({quote}{text}{quote}, {lit(HI[plain])})'
    return re.sub(r"""(['"])((?:\\.|(?!\1).)+?)\1""", one, block)


def rewrite(m):
    return m.group(1) + convert(m.group(2)) + m.group(3)


src = re.sub(r"((?:why|consider):\s*(?:const\s*)?\[)(.*?)(\])", rewrite, src,
             flags=re.S)

# `_t` is a function call, so any const on these collections has to go.
src = src.replace('const Map<String, _Cat> _catalog', 'final Map<String, _Cat> _catalog')
src = src.replace('why: const [', 'why: [').replace('consider: const [', 'consider: [')

if 'localization/app_language.dart' not in src:
    imports = list(re.finditer(r"^import .*;$", src, re.M))
    at = imports[-1].end() if imports else src.index('\n', src.index('// ===='))
    src = src[:at] + "\nimport '../localization/app_language.dart';" + src[at:]

if 'LocalizedText _t(' not in src:
    anchor = src.index('/// A purchasable product option')
    src = (src[:anchor]
           + 'LocalizedText _t(String en, String hi) => '
             'LocalizedText(en: en, hi: hi);\n\n'
           + src[anchor:])

open(PATH, 'w', encoding='utf-8', newline='').write(src)
print(f'converted; {len(missed)} bullet(s) had no Hindi')
for m in sorted(missed):
    print('  MISS: ' + m)
