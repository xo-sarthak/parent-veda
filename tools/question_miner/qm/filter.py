"""Keep the strings that are questions; drop the rest.

Three ways in:
  1. ends with "?"                           (Reddit titles, autocomplete)
  2. opens with a question / request word    ("how", "is it", "anyone", "any tips")
  3. carries a question cue mid-string       ("how to", "kya kare", "please suggest")

Slug sources (BabyChakra, Parentune, Mylo) lose their "?" in the URL, so (2)
and (3) carry them, and the cue list includes Hinglish question words.

A short junk list removes what is question-shaped but not a question we want
(megathreads, giveaways, links).
"""

from __future__ import annotations

import re

OPENERS = (
    "is ", "are ", "am ", "was ", "were ", "how ", "when ", "why ", "should ", "can ", "could ",
    "would ", "will ", "what ", "which ", "who ", "where ", "does ", "do ", "did ", "has ",
    "have ", "anyone", "any one", "anybody", "any tips", "any advice", "any suggestion",
    "any idea", "need advice", "need help", "advice on", "advice for", "help with", "tips for",
    "tips on", "question about", "question:", "question -", "q:", "eli5", "wwyd", "thoughts on",
    "is it ", "isnt ", "isn't ", "dont ", "don't ", "kya ", "kaise ", "kab ", "kyu", "kitna ",
    "kitne ", "konsa ", "kaun", "koi ", "please suggest", "pls suggest", "plz suggest",
)

MID_CUES = re.compile(
    r"(\bhow (to|do|does|can|long|much|many|often|old)\b|\bwhat (to|should|can|is|are|if)\b|"
    r"\bwhen (to|should|can|do|does|will)\b|\bwhy (is|does|do|did|wont|won't|am|are)\b|"
    r"\bis (it|this|there|that|my|he|she)\b|\bshould i\b|\bcan i\b|\bcould i\b|\bdo i\b|"
    r"\bam i\b|\bwill (it|my|he|she|this)\b|\banyone\b|\banybody\b|\bany (tips|advice|idea|"
    r"suggestion|recommendation)s?\b|\bhelp me\b|\bplease (help|suggest|advise|advice|tell|"
    r"guide)\b|\b(pls|plz) (help|suggest|advise|tell|guide)\b|\bsuggest me\b|\bwhat should\b|"
    r"\bkya\b|\bkaise\b|\bkab\b|\bkyu\b|\bkyun\b|\bkyon\b|\bkitna\b|\bkitne\b|\bkonsa\b|"
    r"\bkaun\b|\bkare\b|\bkaru\b|\bkarun\b|\bkarein\b|\bchahiye\b|\bya nahi\b|\bya nhi\b|"
    r"\bsahi hai\b|\bthik hai\b|\bnormal hai\b|\bhai kya\b|\bhota hai\b|\bhoti hai\b|"
    r"\bbataye\b|\bbatao\b|\bbatayein\b|\bkarna chahiye\b|\bkarne chahiye\b|\b(kya|kaise) (kare|karu|karun)\b)",
    re.I,
)

JUNK = re.compile(
    r"(https?://|\bmegathread\b|\bdaily (chat|thread|discussion)\b|\bweekly (thread|discussion|"
    r"chat)\b|\bgiveaway\b|\[deleted\]|\[removed\]|\bmod post\b|\bmoderator\b|\bsubreddit\b|"
    r"\bAMA\b|\bpoll\b|\bupdate:|\bpsa\b|\brant\b|\bvent\b|\bbingo\b|\bmeme\b|\bxpost\b|"
    r"\bcrosspost\b|\bcalculator\b$|\bapp download\b|\bpdf\b|\bmovie\b|\bsong\b|\blyrics\b|"
    r"\bquotes?\b$|\bwallpaper\b|\bhindi meaning\b|\bmeaning in hindi\b|\bin telugu\b|"
    r"\bin tamil\b|\bin marathi\b|\bin malayalam\b|\bin kannada\b|\bin bengali\b|\bin gujarati\b)",
    re.I,
)

# Slug sources only: a Q&A post titled "my 19 month son has not started
# speaking" IS the question, with the "?" lost in the URL. These cues admit a
# stated concern from a source whose whole population is user questions.
CONCERN_CUES = re.compile(
    r"(\bnot\b|\bno\b|\bnever\b|\bdoes ?n[o']?t\b|\bdon ?t\b|\bwon ?t\b|\bcan ?t\b|\bcannot\b|"
    r"\brefus|\bproblem|\bissue|\btrouble|\bworr|\bunable\b|\bdifficult|\bremed|\btips?\b|"
    r"\badvice\b|\bsuggest|\bnormal\b|\bsafe\b|\bokay\b|\bok\b|\bgood\b|\bbad\b|\bbest\b|"
    r"\bwhich\b|\bstill\b|\byet\b|\btoo much\b|\bvery\b|\balways\b|\bonly\b|\bnahi\b|\bnhi\b|"
    r"\bbahut\b|\bbhut\b|\bkam\b|\bzyada\b|\bjyada\b|\bhota\b|\bhoti\b|\bkarti\b|\bkarta\b|"
    r"\bkhata\b|\bkhati\b|\bsota\b|\bsoti\b|\brota\b|\broti\b|\bdard\b|\bbukhar\b|\bupay\b|"
    r"\bilaj\b|\bchahiye\b|\bhelp\b|\bconcern|\bconfus|\bwhat to do\b|\bhow\b|\bwhy\b|\bwhen\b)",
    re.I,
)

WORD = re.compile(r"[a-zA-Zऀ-ॿ]+")


def looks_like_question(text: str, *, slug: bool) -> bool:
    """`slug` = the source lost punctuation, so do not require '?'."""
    t = text.strip()
    if len(t) < 12 or len(t) > 320:
        return False
    if len(WORD.findall(t)) < 3:
        return False
    if JUNK.search(t):
        return False
    low = t.lower().lstrip("\"'“”‘’([ ")
    core = low.rstrip(" .!?…\"'”’)]")
    if "?" in low:
        return True
    if any(core.startswith(o) for o in OPENERS):
        return True
    if MID_CUES.search(core):
        return True
    if slug and len(WORD.findall(t)) >= 4 and CONCERN_CUES.search(core):
        return True
    return False
