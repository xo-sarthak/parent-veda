"""Tag each question with a ParentVeda stage: ttc / pregnancy / parenting /
skilling, or "unclear".

The source already implies a stage most of the time (the seed stem, the
subreddit). Content decides when it disagrees strongly enough, and content
is the ONLY signal for the Indian sitemaps, which span every stage.

Skilling is the case that matters: it is a question TYPE ("how do I build X
in my child"), not a community, so it must be recognised inside general
parenting sources. Its cues therefore carry more weight than the hint.

Rules, not a model, on purpose: the output must be explainable in one
glance and editable in one file.
"""

from __future__ import annotations

import re

from .schema import STAGES, UNCLEAR

# (pattern, weight). Patterns run on the NORMALISED text.
CUES: dict[str, list[tuple[str, int]]] = {
    "ttc": [
        (r"\btrying to conceive\b", 3), (r"\bovulat", 3), (r"\bfertil", 3), (r"\bconceiv", 3),
        (r"\btwo week wait\b", 3), (r"\bdays past ovulation\b", 3), (r"\bcycle day \d+", 3),
        (r"\bovulation test", 3), (r"\bpositive pregnancy test\b", 2), (r"\bnegative pregnancy test\b", 3),
        (r"\bpregnancy test", 2), (r"\bfaint line\b", 3), (r"\bline progression\b", 3), (r"\bevap", 3),
        (r"\bivf\b", 3), (r"\biui\b", 3), (r"\bembryo\b", 3), (r"\btransfer\b", 1), (r"\bpcos\b", 2),
        (r"\bamh\b", 3), (r"\bsperm\b", 3), (r"\bsemen\b", 3), (r"\bfollicle", 3), (r"\bluteal\b", 3),
        (r"\bimplantation\b", 3), (r"\bchemical pregnancy\b", 3), (r"\bmiscarriage\b", 2),
        (r"\bearly (pregnancy )?(signs|symptoms)\b", 2), (r"\bam i pregnant\b", 3),
        (r"\bmissed period\b", 3), (r"\bperiod (late|missed|delay)", 3), (r"\blate period\b", 3),
        (r"\bcervical mucus\b", 3), (r"\bbasal body\b", 3), (r"\bbbt\b", 3), (r"\bletrozole\b", 3),
        (r"\bclomid\b", 3), (r"\bhsg\b", 3), (r"\binfertil", 3), (r"\bfolic acid\b", 1),
        (r"\bget pregnant\b", 3), (r"\bgetting pregnant\b", 3), (r"\bbecome pregnant\b", 3),
        (r"\bhow to be pregnant\b", 3), (r"\bhcg\b", 1), (r"\btrigger shot\b", 3), (r"\bbefore pregnancy\b", 2),
        (r"\bpreconception\b", 3), (r"\bplanning (a |for )?(baby|pregnancy)\b", 3), (r"\bunprotected\b", 2),
        (r"\bpregnancy chances?\b", 3), (r"\bchances of (getting )?pregnan", 3),
    ],
    "pregnancy": [
        (r"\bpregnan", 3), (r"\btrimester\b", 3), (r"\b\d+ weeks\b", 2), (r"\bweeks pregnant\b", 3),
        (r"\bmonths pregnant\b", 3), (r"\bultrasound\b", 2), (r"\bscan\b", 2), (r"\bdue date\b", 3),
        (r"\bc section\b", 2), (r"\bcesarean\b", 2), (r"\bcaesarean\b", 2), (r"\bdelivery\b", 2),
        (r"\blabou?r\b", 2), (r"\bcontractions?\b", 3), (r"\bepidural\b", 3), (r"\bmorning sickness\b", 3),
        (r"\bnausea\b", 1), (r"\bbraxton\b", 3), (r"\bfetal\b", 3), (r"\bfoetal\b", 3), (r"\bfetus\b", 3),
        (r"\bbump\b", 2), (r"\bgestational\b", 3), (r"\banomaly\b", 3), (r"\bnt scan\b", 3),
        (r"\bplacenta\b", 3), (r"\bamniotic\b", 3), (r"\bbaby movement", 2), (r"\bkicks?\b", 2),
        (r"\bstretch marks?\b", 2), (r"\bbirth plan\b", 3), (r"\bhospital bag\b", 3),
        (r"\bmaternity\b", 2), (r"\bprenatal\b", 3), (r"\bantenatal\b", 3), (r"\bgarbh sanskar\b", 3),
        (r"\bpreeclampsia\b", 3), (r"\bglucose test\b", 3), (r"\bgtt\b", 3), (r"\bwater br(oke|eaking)\b", 3),
        (r"\binduc(tion|ed)\b", 3), (r"\bbreech\b", 3), (r"\bcervix\b", 2), (r"\bdilat", 3),
        (r"\bfirst (kick|movement)", 3), (r"\bbaby (bump|shower)\b", 2), (r"\bsafe (during|in|while) pregnan", 3),
        (r"\bpostpartum\b", 1), (r"\bafter delivery\b", 1),
    ],
    "parenting": [
        (r"\btoddler", 3), (r"\bnewborn", 3), (r"\binfant", 3), (r"\bbaby\b", 1), (r"\bbabies\b", 1),
        (r"\b\d+ month old\b", 3), (r"\b\d+ week old\b", 3), (r"\b\d+ day old\b", 3),
        (r"\b[1-5] year old\b", 2), (r"\bbreastfeed", 3), (r"\bbreast milk\b", 3), (r"\bformula\b", 3),
        (r"\bpumping\b", 2), (r"\bteeth(ing)?\b", 3), (r"\bpotty\b", 3), (r"\btantrum", 3),
        (r"\bdaycare\b", 3), (r"\bweaning\b", 3), (r"\bsolids\b", 3), (r"\bsleep train", 3),
        (r"\bnaps?\b", 2), (r"\bmilestone", 3), (r"\bvaccin", 3), (r"\bimmuni[sz]ation\b", 3),
        (r"\bdiaper", 3), (r"\bnappy\b", 3), (r"\bcolic\b", 3), (r"\bpoop\b", 2), (r"\bpotty\b", 3),
        (r"\bspit up\b", 3), (r"\bswaddl", 3), (r"\bbottle\b", 2), (r"\bpacifier\b", 3),
        (r"\bcrawl", 3), (r"\bwalk(ing)?\b", 1), (r"\btalk(ing)?\b", 1), (r"\bspeech\b", 2),
        (r"\bfever\b", 2), (r"\bcough\b", 1), (r"\bcold\b", 1), (r"\bhitting\b", 2), (r"\bbiting\b", 2),
        (r"\baggress", 3), (r"\bnaughty\b", 3), (r"\bstubborn\b", 3), (r"\brude\b", 3), (r"\bangry\b", 2), (r"\banger\b", 2),
        (r"\bpicky eat", 3), (r"\bnot eating\b", 2), (r"\bcereal\b", 2), (r"\bcerelac\b", 3),
        (r"\bpostpartum\b", 2), (r"\bafter delivery\b", 2), (r"\b40 days\b", 2), (r"\bmassage\b", 1),
        (r"\bpreschool\b", 2), (r"\bplayschool\b", 2), (r"\bscreen time\b", 1), (r"\bcosleep", 3),
        (r"\bco sleep", 3), (r"\bcrib\b", 3), (r"\bstroller\b", 3), (r"\bcar seat\b", 3),
        (r"\bsibling", 2), (r"\bmother in law\b", 1), (r"\bkid\b", 1), (r"\bchild\b", 1), (r"\bson\b", 1),
        (r"\bdaughter\b", 1), (r"\bmilk\b", 1), (r"\bfeed(ing)?\b", 1), (r"\bstool\b", 2), (r"\bloose motion", 2),
        (r"\badhd\b", 2), (r"\bautis", 2), (r"\b\d+(st|nd|rd|th) month\b", 1), (r"\bbaby food\b", 2),
        (r"\bmilk powder\b", 2), (r"\bhead\b", 1), (r"\bskin\b", 1), (r"\brash", 2), (r"\bhair\b", 1),
    ],
    "skilling": [
        (r"\bcoding\b", 4), (r"\bcode\b", 3), (r"\bprogramming\b", 4), (r"\bscratch\b", 2),
        (r"\bpython\b", 3), (r"\brobotic", 4), (r"\bstem\b(?! cell)", 3), (r"\bai\b", 2), (r"\bartificial intelligence\b", 4),
        (r"\bread(ing)?\b", 2), (r"\blearn(ing)? to read\b", 4), (r"\bphonics\b", 4), (r"\bsight words\b", 4),
        (r"\bfocus\b", 4), (r"\bconcentrat", 4), (r"\battention span\b", 4), (r"\bdistract", 3),
        (r"\bconfiden", 4), (r"\bshy\b", 4), (r"\bself esteem\b", 4), (r"\bpublic speaking\b", 4),
        (r"\bcommunication skill", 4), (r"\bconversation", 2), (r"\bvocabulary\b", 3),
        (r"\bmaths?\b", 4), (r"\bmathematic", 4), (r"\babacus\b", 4), (r"\bvedic\b", 4), (r"\bcounting\b", 3),
        (r"\bnumbers\b", 2), (r"\bmemory\b", 4), (r"\bmemori[sz]", 4), (r"\bremember\b", 2),
        (r"\bcreativ", 4), (r"\bimagination\b", 4), (r"\bdrawing\b", 3), (r"\bart\b", 2),
        (r"\bcurios", 4), (r"\bcritical thinking\b", 4), (r"\bproblem solving\b", 4), (r"\blogic", 3),
        (r"\bpuzzle", 3), (r"\bchess\b", 4), (r"\bemotional intelligence\b", 4), (r"\bempath", 4),
        (r"\bgratitude\b", 4), (r"\bvalues\b", 4), (r"\bmanners\b", 3), (r"\bkindness\b", 3),
        (r"\bhonest", 3), (r"\bl(ie|ying|ies)\b", 2), (r"\bcurriculum\b", 3), (r"\bfeelings\b", 3), (r"\bemotions?\b", 2), (r"\bresilien", 4),
        (r"\bmindful", 4), (r"\bmeditation\b", 3), (r"\bcalm\b", 1), (r"\bhandwriting\b", 4),
        (r"\bwriting\b", 2), (r"\bhomework\b", 3), (r"\bstud(y|ies)\b", 3), (r"\bexam", 3),
        (r"\bschool\b", 1), (r"\bkumon\b", 4), (r"\btuition\b", 3), (r"\bgifted\b", 4),
        (r"\bintelligen", 4), (r"\biq\b", 4), (r"\bbrain development\b", 3), (r"\bsmart(er)?\b", 3),
        (r"\blearn(ing)?\b", 2), (r"\bskills?\b", 3), (r"\bteach(ing)?\b", 2), (r"\bslow learner\b", 4),
        (r"\bmotivat", 3), (r"\bindependen", 2), (r"\bscreen time\b", 1), (r"\beducational\b", 3),
        (r"\bmontessori\b", 3), (r"\bhomeschool", 3), (r"\bextracurricular\b", 3), (r"\bhobby\b", 3),
        (r"\bmusic\b", 2), (r"\binstrument\b", 3), (r"\blanguage\b", 2), (r"\bbilingual\b", 3),
        (r"\bstorytelling\b", 3), (r"\bsports?\b", 2), (r"\bdiscipline\b", 1), (r"\btalent", 3),
        (r"\b(6|7|8|9|10|11|12) year old\b", 1), (r"\bkids? (and|with) (screen|tablet|ipad)", 2),
    ],
}
COMPILED = {s: [(re.compile(p), w) for p, w in cues] for s, cues in CUES.items()}

# Once a question is clearly about a pregnant body, "learning" and "reading"
# are not skilling. Same for TTC: "how to teach" does not appear there.
HARD_PREGNANCY = re.compile(r"\b(weeks pregnant|months pregnant|trimester|pregnan(t|cy)|ultrasound|scan|delivery|labou?r)\b")
HARD_TTC = re.compile(r"\b(ovulat|conceiv|fertil|two week wait|days past ovulation|ivf|iui|trying to conceive)")


def scores(norm: str) -> dict[str, int]:
    return {s: sum(w for rx, w in rules if rx.search(norm)) for s, rules in COMPILED.items()}


def classify(norm: str, hint: str) -> tuple[str, dict[str, int]]:
    sc = scores(norm)
    if HARD_PREGNANCY.search(norm):
        sc["skilling"] = 0
    if HARD_TTC.search(norm):
        sc["skilling"] = 0
        sc["parenting"] = max(0, sc["parenting"] - 2)
    best = max(sc, key=sc.get)
    top = sc[best]
    runner = sorted(sc.values(), reverse=True)[1]
    hinted = hint if hint in STAGES else None

    if top == 0:
        return (hinted or UNCLEAR), sc
    if hinted is None:
        # Content only (the Indian sitemaps). A clear winner wins; a lone
        # weak cue still beats "unclear" when nothing else fired at all.
        if top >= 2 and top > runner:
            return best, sc
        if top == 1 and runner == 0:
            return best, sc
        return UNCLEAR, sc
    if best == hinted:
        return best, sc
    # Override the hint only on a strong, unambiguous content signal.
    if top >= 4 and top >= sc[hinted] + 3:
        return best, sc
    return hinted, sc
