"""Normalise a question for CLUSTERING. The raw text is what we show; this
form is what we embed and dedupe on.

Order matters:
  1. lowercase, unescape, unify quotes, drop emoji
  2. strip the filler that forums add ("hello mam", "please help", "TIA")
  3. expand forum shorthand (lo, dd, tww, bfp, opk, mil, ftm ...)
  4. number words -> digits
  5. one form for every age / duration ("2yo", "2 yr old", "two year old"
     -> "2 year old"; "18mo" -> "18 month old"; "32w", "32 wks" -> "32 weeks")
  6. a light Hinglish -> English word map so romanised-Hindi questions land
     near their English twins instead of in a script-shaped island
  7. collapse punctuation and whitespace

Also `detect_lang`, shared with the collectors.
"""

from __future__ import annotations

import html
import re

DEVANAGARI = re.compile(r"[ऀ-ॿ]")

HINGLISH_MARKERS = {
    "mera", "meri", "mere", "hai", "hain", "kya", "kaise", "kab", "kyu", "kyun", "nahi", "nhi",
    "kare", "karu", "karna", "chahiye", "bacha", "baccha", "bachcha", "bache", "beta", "beti",
    "khana", "khilaye", "mahine", "mahina", "saal", "din", "dudh", "doodh", "hota", "hoti",
    "raha", "rahi", "rha", "rhi", "mujhe", "muje", "usko", "uska", "uski", "ke", "ki", "ka",
    "se", "mein", "wala", "wali", "bahut", "bhut", "bohot", "thoda", "abhi", "kuch", "koi",
    "sahi", "thik", "theek", "dard", "pet", "bukhar", "khansi", "sardi", "ulti", "potty",
    "bataye", "batao", "pls", "plz", "maam", "mam",
}


def detect_lang(text: str) -> str:
    if DEVANAGARI.search(text):
        return "hi"
    words = re.findall(r"[a-z]+", text.lower())
    if not words:
        return "en"
    n = sum(1 for w in words if w in HINGLISH_MARKERS)
    return "hinglish" if n >= 2 or (n >= 1 and len(words) <= 6) else "en"


# -- 2. filler --------------------------------------------------------------------
FILLER_START = [
    r"(hi|hii+|hello|hey|helo|hlo|namaste|namaskar)( there| everyone| all| everybody| mam| ma'?am|"
    r" doctor| dr| moms?| mommies| mummies| ladies| guys| friends| all mommies| dear)?[,!. ]*",
    r"(dear|respected)( mam| ma'?am| doctor| dr| all)?[,!. ]*",
    r"(please|plz|pls|kindly)( help| suggest| advise| advice| guide| tell| answer)?( me)?[,!. ]*",
    r"(question|q|help|advice needed|need advice|need help|urgent|serious question|"
    r"genuine question|quick question|silly question|stupid question|dumb question)[:!,. -]*",
    r"(sorry if this is a (dumb|silly|stupid) question|sorry for the (long|dumb) (post|question))[,. ]*",
    r"(first time (mom|mum|mother|parent)|ftm|stm|new (mom|mum|parent)) here[,. -]*",
    r"(i am|i'm|im) (a )?(first time|new) (mom|mum|mother|parent)[,. ]*(and )?",
    r"(mam|ma'?am|doctor|dr)[,. ]+",
]
FILLER_END = [
    r"[,. ]*(please|plz|pls)( help| suggest| advise| advice| guide| reply| answer)?( me)?( out)?[.! ]*$",
    r"[,. ]*(thank you|thanks|thanx|thnx|thx|tia|thanks in advance)[.! ]*$",
    r"[,. ]*(any (help|advice|tips|suggestions?|ideas?)( would be| is)? (appreciated|welcome|helpful))[.! ]*$",
    r"[,. ]*(help|help me|advice|suggestions?|urgent|asap)[.! ]*$",
]
FILLER_START_RE = [re.compile(r"^\s*" + p, re.I) for p in FILLER_START]
FILLER_END_RE = [re.compile(p, re.I) for p in FILLER_END]

# -- 3. shorthand ------------------------------------------------------------------
SHORTHAND = {
    "lo": "baby", "lo's": "baby's", "little one": "baby", "bub": "baby", "bubs": "baby",
    "bubba": "baby", "babys": "baby", "babies": "baby", "nb": "newborn", "kiddo": "child", "kid": "child", "kids": "children",
    "dd": "daughter", "ds": "son", "dh": "husband", "dw": "wife",
    "mil": "mother in law", "fil": "father in law", "sil": "sister in law", "bil": "brother in law",
    "ftm": "first time mom", "stm": "second time mom", "sahm": "stay at home mom",
    "mum": "mom", "mummy": "mom", "mommy": "mom", "mama": "mom", "mumma": "mom",
    "tww": "two week wait", "bfp": "positive pregnancy test", "bfn": "negative pregnancy test",
    "hpt": "pregnancy test", "opk": "ovulation test", "opks": "ovulation tests", "af": "period",
    "dpo": "days past ovulation", "ttc": "trying to conceive", "mc": "miscarriage",
    "cp": "chemical pregnancy", "ivf": "ivf", "iui": "iui", "fet": "embryo transfer",
    "bc": "birth control", "ob": "doctor", "obgyn": "doctor", "ob/gyn": "doctor",
    "gyno": "gynecologist", "gynac": "gynecologist", "gyna": "gynecologist",
    "ped": "pediatrician", "peds": "pediatrician", "paed": "pediatrician",
    "bf": "breastfeeding", "ebf": "exclusively breastfeeding", "ff": "formula feeding",
    "bfing": "breastfeeding", "pp": "postpartum", "ppd": "postpartum depression",
    "csec": "c section", "c-section": "c section", "cs": "c section", "vbac": "vbac",
    "gd": "gestational diabetes", "u": "you", "ur": "your", "r": "are", "n": "and", "&": "and",
    "w/": "with", "w/o": "without", "b4": "before", "2nd": "second", "1st": "first", "3rd": "third",
    "bcoz": "because", "bcz": "because", "coz": "because", "cuz": "because", "cos": "because",
    "hv": "have", "wat": "what", "wt": "what", "hw": "how", "cn": "can", "dnt": "dont",
    "mnth": "month", "mnths": "months", "mth": "month", "mths": "months", "wk": "week", "wks": "weeks",
    "yr": "year", "yrs": "years", "hr": "hour", "hrs": "hours", "min": "minute", "mins": "minutes",
    "pls": "", "plz": "", "please": "", "ppl": "people", "smth": "something", "sth": "something",
    "tmrw": "tomorrow", "rn": "right now", "abt": "about", "bcs": "because", "thru": "through",
    "vs": "versus", "tbh": "", "imo": "", "lol": "", "omg": "", "wtf": "", "haha": "",
}

NUMBER_WORDS = {
    "zero": 0, "one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7,
    "eight": 8, "nine": 9, "ten": 10, "eleven": 11, "twelve": 12, "thirteen": 13,
    "fourteen": 14, "fifteen": 15, "sixteen": 16, "seventeen": 17, "eighteen": 18,
    "nineteen": 19, "twenty": 20, "thirty": 30, "forty": 40,
}
NUMBER_WORD_RE = re.compile(r"\b(" + "|".join(NUMBER_WORDS) + r")\b(?=[\s-]*(?:year|yr|month|mo|week|wk|day|old|kid|child|baby|toddler|month|mahine|saal))")
HALF_RE = re.compile(r"\b(\d+)(?:\s*and\s*a\s*)?[ -]?(?:half|1/2|\.5)\b")

# -- 5. ages and durations --------------------------------------------------------
AGE_RULES = [
    # "2yo", "2 y.o", "2yr old", "2-year-old", "2 years old", "2 yrs" (when followed by old)
    (re.compile(r"\b(\d+)\s*(?:y\.?o\.?|yo)\b"), r"\1 year old"),
    (re.compile(r"\b(\d+)\s*-?\s*(?:years?|yrs?)\s*-?\s*old\b"), r"\1 year old"),
    (re.compile(r"\b(\d+)\s*-?\s*(?:years?|yrs?)\s*-?\s*(?:ka|ki|ke)\b"), r"\1 year old"),
    # "18mo", "18 mo", "18-month-old", "18 months old"
    (re.compile(r"\b(\d+)\s*(?:mo|mos)\b(?!\s*pregnant)"), r"\1 month old"),
    (re.compile(r"\b(\d+)\s*-?\s*(?:months?|mnths?|mths?)\s*-?\s*old\b"), r"\1 month old"),
    (re.compile(r"\b(\d+)\s*-?\s*(?:months?|mnths?|mths?)\s*-?\s*(?:ka|ki|ke)\b"), r"\1 month old"),
    # weeks: "32w", "32 wks", "32 weeks", "32w3d"
    (re.compile(r"\b(\d+)\s*(?:w|wk|wks|weeks?)\s*\+?\s*\d*\s*d?\b(?!\s*old)"), r"\1 weeks"),
    (re.compile(r"\b(\d+)\s*-?\s*(?:w|wk|wks|weeks?)\s*-?\s*old\b"), r"\1 week old"),
    (re.compile(r"\b(\d+)\s*-?\s*(?:d|days?)\s*-?\s*old\b"), r"\1 day old"),
    (re.compile(r"\b(\d+)\s*(?:months?|mnths?)\s*(?:pregnant|preg|pregnancy)\b"), r"\1 months pregnant"),
    (re.compile(r"\bcd\s*(\d+)\b"), r"cycle day \1"),
    (re.compile(r"\b(\d+)\s*dpo\b"), r"\1 days past ovulation"),
    (re.compile(r"\b(\d+)\s*dp[o]?(\d)dt\b"), r"\1 days past transfer"),
]

# -- 6. hinglish ------------------------------------------------------------------
HINGLISH = {
    "mera": "my", "meri": "my", "mere": "my", "mujhe": "i", "muje": "i", "hmara": "our",
    "hamara": "our", "hamare": "our", "hai": "is", "hain": "are", "h": "is", "tha": "was",
    "thi": "was", "kya": "what", "kaise": "how", "kese": "how", "kab": "when", "kyu": "why",
    "kyun": "why", "kyon": "why", "kitna": "how much", "kitne": "how many", "konsa": "which",
    "kaunsa": "which", "kaun": "who", "kahan": "where", "nahi": "not", "nhi": "not", "nai": "not",
    "na": "not", "kare": "do", "karu": "do", "karun": "do", "karein": "do", "karna": "do",
    "karne": "do", "chahiye": "should", "chaiye": "should",
    "bacha": "child", "baccha": "child", "bachcha": "child", "bache": "child", "bacche": "child",
    "bachche": "child", "bachhe": "child", "bachon": "children", "beta": "son", "bete": "son",
    "beti": "daughter", "ladka": "boy", "ladki": "girl", "khana": "food", "khane": "food",
    "khaye": "eat", "khata": "eats", "khati": "eats", "khilaye": "feed", "khilana": "feed",
    "khilau": "feed", "pilaye": "give to drink", "dudh": "milk", "doodh": "milk", "dud": "milk",
    "mahine": "month", "mahina": "month", "mahino": "month", "mahiney": "month", "mhina": "month",
    "mhine": "month", "saal": "year", "sal": "year", "din": "day", "dino": "days", "raat": "night",
    "sona": "sleep", "sota": "sleeps", "soti": "sleeps", "neend": "sleep", "rona": "crying",
    "rota": "cries", "roti": "cries", "dard": "pain", "pet": "stomach", "bukhar": "fever",
    "khansi": "cough", "sardi": "cold", "ulti": "vomiting", "dast": "loose motion",
    "kabz": "constipation", "wajan": "weight", "vajan": "weight", "lambai": "height",
    "dawa": "medicine", "dawai": "medicine", "davai": "medicine", "tika": "vaccine",
    "garbh": "pregnancy", "garbhavastha": "pregnancy", "garbhpat": "miscarriage",
    "delivery": "delivery", "operation": "c section", "sizeriyan": "c section", "sijar": "c section",
    "period": "period", "periods": "period", "mc": "period", "mahwari": "period",
    "shadi": "marriage", "pati": "husband", "patni": "wife", "saas": "mother in law",
    "hota": "happens", "hoti": "happens", "hote": "happen", "hoga": "will", "hogi": "will",
    "raha": "", "rahi": "", "rha": "", "rhi": "", "rahe": "", "rhe": "", "gaya": "", "gayi": "",
    "gya": "", "gyi": "", "hua": "", "hui": "", "ho": "", "hu": "", "hun": "", "hoon": "",
    "ka": "", "ki": "", "ke": "", "ko": "", "se": "", "me": "in", "mein": "in", "par": "on",
    "pe": "on", "aur": "and", "or": "and", "bhi": "also", "toh": "then", "to": "to", "ya": "or",
    "yaa": "or", "hi": "", "wala": "", "wali": "", "wale": "", "liye": "for", "lie": "for",
    "bahut": "very", "bhut": "very", "bohot": "very", "bahot": "very", "thoda": "little",
    "jyada": "more", "zyada": "more", "kam": "less", "abhi": "now", "ab": "now", "kuch": "some",
    "koi": "any", "sab": "all", "sahi": "right", "thik": "ok", "theek": "ok", "acha": "good",
    "accha": "good", "achha": "good", "bura": "bad", "kharab": "bad", "kala": "dark",
    "gora": "fair", "safed": "white", "hara": "green", "peela": "yellow", "lal": "red",
    "bataye": "tell", "batao": "tell", "batayein": "tell", "bataiye": "tell", "btaye": "tell",
    "suggest": "suggest", "upay": "remedy", "ilaj": "treatment", "gharelu": "home",
    "nuskhe": "remedies", "tarika": "way", "tareeka": "way", "kaise kare": "how to",
    "mam": "", "maam": "", "ji": "", "plz": "", "pls": "",
}
HINGLISH_RE = re.compile(r"\b(" + "|".join(re.escape(k) for k in sorted(HINGLISH, key=len, reverse=True)) + r")\b")

SHORTHAND_RE = re.compile(r"(?<![\w/])(" + "|".join(re.escape(k) for k in sorted(SHORTHAND, key=len, reverse=True)) + r")(?![\w/])")
EMOJI_RE = re.compile("[\U0001F000-\U0001FFFF☀-➿⬀-⯿️]")
QUOTES = {"‘": "'", "’": "'", "“": '"', "”": '"', "–": "-", "—": "-", "…": "..."}


def normalize(text: str, lang: str = "en") -> str:
    t = html.unescape(text)
    for k, v in QUOTES.items():
        t = t.replace(k, v)
    t = EMOJI_RE.sub(" ", t).lower()
    t = t.replace("’", "'")
    for _ in range(2):  # fillers stack: "hello mam, please suggest, ..."
        for rx in FILLER_START_RE:
            t = rx.sub("", t, count=1)
    for rx in FILLER_END_RE:
        t = rx.sub("", t, count=1)
    t = t.replace("won't", "will not").replace("can't", "cannot").replace("n't", " not")
    t = t.replace("'s ", " ").replace("'", "")
    t = SHORTHAND_RE.sub(lambda m: SHORTHAND[m.group(1)], t)
    t = NUMBER_WORD_RE.sub(lambda m: str(NUMBER_WORDS[m.group(1)]), t)
    t = HALF_RE.sub(r"\1", t)
    for rx, rep in AGE_RULES:
        t = rx.sub(rep, t)
    if lang in ("hinglish", "hi"):
        t = HINGLISH_RE.sub(lambda m: HINGLISH.get(m.group(1), m.group(1)), t)
    t = re.sub(r"[^\w\sऀ-ॿ]+", " ", t)
    t = re.sub(r"\s+", " ", t).strip()
    return t
