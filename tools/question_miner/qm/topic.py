"""Topic tag within a stage, aligned to the app's doors so the pool can be
worked door by door.

  Pregnancy doors (lib/data/doors/pv_door_*):  belly-skin, complications,
      garbh-sanskar, labour, mind-mood, nutrition, scans
  Parenting doors (pp_door_*):  behaviour, development, early-learning,
      feeding, first-40-days, health, potty, sleep, traditions, you-maa
  Skilling doors (sk_door_* built + planned):  coding, communication,
      confidence, feelings, making, stillness, thinking, focus, memory,
      creativity, maths, reading, values
  TTC has no doors yet; topics follow the TTC spec's chapters.

First matching topic wins by weight; "general" when nothing fires. Rules run
on the normalised text. Same shape as stage.py so both are edited alike.
"""

from __future__ import annotations

import re

TOPICS: dict[str, dict[str, list[tuple[str, int]]]] = {
    "ttc": {
        "cycle-and-ovulation": [(r"\bovulat", 3), (r"\bfertile window\b", 3), (r"\bcervical mucus\b", 3),
                                (r"\bbasal body\b", 3), (r"\bcycle\b", 2), (r"\bluteal\b", 3), (r"\bperiod", 2),
                                (r"\bcycle day\b", 3), (r"\bovulation test", 3), (r"\bfollicle", 2)],
        "testing-and-early-signs": [(r"\bpregnancy test", 3), (r"\bfaint line\b", 3), (r"\bline progression\b", 3),
                                    (r"\bdays past ovulation\b", 3), (r"\btwo week wait\b", 3), (r"\bimplantation\b", 3),
                                    (r"\bearly (pregnancy )?(signs|symptoms)\b", 3), (r"\bam i pregnant\b", 3),
                                    (r"\bmissed period\b", 2), (r"\bhcg\b", 2), (r"\bevap", 3), (r"\bsymptom", 1)],
        "fertility-treatment": [(r"\bivf\b", 3), (r"\biui\b", 3), (r"\bembryo\b", 3), (r"\btransfer\b", 2),
                                (r"\bletrozole\b", 3), (r"\bclomid\b", 3), (r"\btrigger\b", 3), (r"\binfertil", 2),
                                (r"\bfertility (doctor|clinic|specialist|treatment)\b", 3), (r"\bhsg\b", 3),
                                (r"\bamh\b", 2), (r"\begg (retrieval|freezing)\b", 3), (r"\bstimulation\b", 2)],
        "loss-and-trying-again": [(r"\bmiscarriage\b", 3), (r"\bchemical pregnancy\b", 3), (r"\bloss\b", 2),
                                  (r"\bd ?and ?c\b", 3), (r"\bectopic\b", 3), (r"\bafter (a )?(loss|miscarriage)\b", 3)],
        "conditions": [(r"\bpcos\b", 3), (r"\bendometriosis\b", 3), (r"\bthyroid\b", 2), (r"\bfibroid", 3),
                       (r"\bblocked tube", 3), (r"\bprolactin\b", 3), (r"\binsulin\b", 2), (r"\bcyst\b", 2)],
        "male-fertility": [(r"\bsperm\b", 3), (r"\bsemen\b", 3), (r"\bmale\b", 2), (r"\bhusband", 1),
                           (r"\bmotility\b", 3), (r"\bvaricocele\b", 3)],
        "lifestyle-and-diet": [(r"\bdiet\b", 2), (r"\bfood", 2), (r"\bfolic\b", 2), (r"\bvitamin", 2),
                               (r"\bsupplement", 2), (r"\bcoffee\b", 2), (r"\balcohol\b", 2), (r"\bsmok", 2),
                               (r"\bexercise\b", 2), (r"\bweight\b", 2), (r"\bstress\b", 1), (r"\bage\b", 1),
                               (r"\bafter 35\b", 3), (r"\bafter 40\b", 3)],
        "timing-and-sex": [(r"\bsex\b", 2), (r"\bintercourse\b", 3), (r"\bhow often\b", 2), (r"\bposition", 2),
                           (r"\bwhen to (try|have)\b", 3), (r"\bbest time\b", 2), (r"\bhow long (to|does it take)", 2)],
    },
    "pregnancy": {
        "scans": [(r"\bscan\b", 3), (r"\bultrasound\b", 3), (r"\bsonograph", 3), (r"\bnt\b", 2), (r"\banomaly\b", 3),
                  (r"\bgender\b", 1), (r"\bheartbeat\b", 2), (r"\bblood test", 2), (r"\bglucose\b", 2),
                  (r"\breport\b", 2), (r"\bdue date\b", 2), (r"\btest\b", 1)],
        "labour": [(r"\blabou?r\b", 3), (r"\bdelivery\b", 3), (r"\bc section\b", 3), (r"\bcesarean\b", 3),
                   (r"\bcaesarean\b", 3), (r"\bcontraction", 3), (r"\bepidural\b", 3), (r"\binduc", 3),
                   (r"\bwater br", 3), (r"\bhospital bag\b", 3), (r"\bbirth\b", 2), (r"\bdilat", 3),
                   (r"\bbreech\b", 2), (r"\bnormal delivery\b", 3), (r"\bmucus plug\b", 3), (r"\bbraxton\b", 3)],
        "nutrition": [(r"\beat\b", 3), (r"\bfood", 3), (r"\bdiet\b", 3), (r"\bdrink\b", 2), (r"\bfruit", 2),
                      (r"\bvitamin", 2), (r"\bsupplement", 2), (r"\bcoffee\b", 2), (r"\btea\b", 2),
                      (r"\bmilk\b", 2), (r"\bpapaya\b", 3), (r"\bpineapple\b", 3), (r"\bweight gain\b", 2),
                      (r"\bcraving", 3), (r"\bsafe to (eat|drink|have)\b", 3), (r"\bnausea\b", 1),
                      (r"\bmorning sickness\b", 2)],
        "complications": [(r"\bbleed", 3), (r"\bspotting\b", 3), (r"\bcramp", 2), (r"\bgestational diabetes\b", 3),
                          (r"\bpreeclampsia\b", 3), (r"\bblood pressure\b", 3), (r"\bhigh risk\b", 3),
                          (r"\bplacenta\b", 3), (r"\bcervi", 2), (r"\bpreterm\b", 3), (r"\bpremature\b", 3),
                          (r"\bmiscarriage\b", 2), (r"\binfection\b", 2), (r"\bfever\b", 2), (r"\bpain\b", 1),
                          (r"\bdischarge\b", 2), (r"\bswelling\b", 2), (r"\blow (lying|amniotic)\b", 3),
                          (r"\bthyroid\b", 2), (r"\banemia\b", 2), (r"\bhemoglobin\b", 2), (r"\bmovement", 2),
                          (r"\bkick", 2), (r"\bhospital\b", 1), (r"\bdoctor\b", 1), (r"\bsafe\b", 1)],
        "mind-mood": [(r"\banxi", 3), (r"\bstress", 3), (r"\bdepress", 3), (r"\bmood", 3), (r"\bcry", 2),
                      (r"\bscared\b", 3), (r"\bworr", 2), (r"\bsleep\b", 2), (r"\binsomnia\b", 3), (r"\bdream", 2),
                      (r"\bhusband", 2), (r"\bpartner", 2), (r"\bsex\b", 2), (r"\bwork\b", 1), (r"\btravel", 2),
                      (r"\bfeel", 1)],
        "belly-skin": [(r"\bbelly\b", 3), (r"\bbump\b", 3), (r"\bstretch mark", 3), (r"\bskin\b", 3), (r"\bitch", 3),
                       (r"\bhair\b", 2), (r"\bpimple", 3), (r"\bacne\b", 3), (r"\blinea\b", 3), (r"\bshow(ing)?\b", 2),
                       (r"\bback pain\b", 2), (r"\bexercise\b", 2), (r"\byoga\b", 2), (r"\bwalk", 1)],
        "garbh-sanskar": [(r"\bgarbh", 3), (r"\bsanskar\b", 3), (r"\bmantra\b", 3), (r"\bmusic\b", 2),
                          (r"\bread(ing)? to (the )?baby\b", 3), (r"\btalk(ing)? to (the )?baby\b", 3),
                          (r"\bbond", 2), (r"\bmeditat", 2), (r"\bspiritual\b", 3), (r"\bshloka\b", 3)],
        "weeks-and-symptoms": [(r"\b\d+ weeks\b", 2), (r"\btrimester\b", 2), (r"\bsymptom", 2), (r"\bmonths pregnant\b", 2)],
    },
    "parenting": {
        "sleep": [(r"\bsleep", 3), (r"\bnap", 3), (r"\bnight", 2), (r"\bwak", 2), (r"\bbedtime\b", 3),
                  (r"\bcosleep", 3), (r"\bco sleep", 3), (r"\bcrib\b", 2), (r"\bswaddl", 3), (r"\bregression\b", 3)],
        "feeding": [(r"\bbreastfeed", 3), (r"\bbreast milk\b", 3), (r"\bformula\b", 3), (r"\bfeed", 2),
                    (r"\bmilk\b", 2), (r"\bsolid", 3), (r"\bwean", 3), (r"\beat", 2), (r"\bfood", 2),
                    (r"\bbottle\b", 2), (r"\bpump", 2), (r"\bcerelac\b", 3), (r"\bpicky\b", 3), (r"\blatch", 3),
                    (r"\bsupply\b", 2), (r"\bcereal\b", 2), (r"\bwater\b", 1), (r"\bmeal", 2), (r"\bsnack", 2)],
        "health": [(r"\bfever\b", 3), (r"\bcough\b", 3), (r"\bcold\b", 3), (r"\bvaccin", 3), (r"\bimmuni", 3),
                   (r"\bdoctor\b", 2), (r"\bpediatric", 2), (r"\bmedicine\b", 3), (r"\bteeth", 3), (r"\brash", 3),
                   (r"\bskin\b", 2), (r"\bcolic\b", 3), (r"\breflux\b", 3), (r"\bvomit", 3), (r"\bdiarr", 3),
                   (r"\bconstipat", 3), (r"\bweight\b", 2), (r"\bheight\b", 2), (r"\bgrowth\b", 2),
                   (r"\bjaundice\b", 3), (r"\ballerg", 3), (r"\binfection\b", 3), (r"\bear\b", 2), (r"\beye", 2),
                   (r"\bhair\b", 2), (r"\bhead\b", 2), (r"\bsick\b", 3), (r"\bpain\b", 2), (r"\bhospital\b", 2),
                   (r"\bstool\b", 2), (r"\bloose motion", 3), (r"\bmassage\b", 2), (r"\boil\b", 2), (r"\bsafe\b", 1)],
        "potty": [(r"\bpotty\b", 4), (r"\btoilet\b", 4), (r"\bdiaper", 3), (r"\bnappy\b", 3), (r"\bpoop", 2),
                  (r"\bpee\b", 3), (r"\bwet", 2), (r"\baccident", 2)],
        "behaviour": [(r"\btantrum", 4), (r"\bhit", 3), (r"\bbit(e|ing)\b", 3), (r"\bscream", 3), (r"\bcry", 2),
                      (r"\bwhin", 3), (r"\blisten", 3), (r"\bdiscipline\b", 3), (r"\btime out\b", 3),
                      (r"\bangry\b", 3), (r"\banger\b", 3), (r"\bmeltdown", 4), (r"\bclingy\b", 3),
                      (r"\bseparation\b", 3), (r"\bshar(e|ing)\b", 2), (r"\bno\b", 1), (r"\bdefian", 3),
                      (r"\bsibling", 2), (r"\bjealous", 3), (r"\bscreen", 2), (r"\btv\b", 2), (r"\bphone\b", 2),
                      (r"\byell", 3), (r"\bpunish", 3), (r"\bbehav", 3), (r"\bhabit", 2), (r"\bthumb\b", 2)],
        "development": [(r"\bmilestone", 4), (r"\bcrawl", 3), (r"\bwalk", 3), (r"\btalk", 3), (r"\bspeech\b", 3),
                        (r"\bspeak", 3), (r"\bword", 3), (r"\bsit", 2), (r"\bstand", 2), (r"\broll", 2),
                        (r"\bdelay", 3), (r"\bautis", 3), (r"\badhd\b", 3), (r"\bdevelop", 3), (r"\bleap\b", 3),
                        (r"\bmotor\b", 3), (r"\bgrowth spurt\b", 3), (r"\bteeth", 1), (r"\bhead control\b", 3),
                        (r"\btherapy\b", 2), (r"\bnormal\b", 1)],
        "early-learning": [(r"\bplay", 3), (r"\btoy", 3), (r"\bactivit", 3), (r"\bbook", 3), (r"\bread", 2),
                           (r"\blearn", 2), (r"\bpreschool\b", 3), (r"\bplayschool\b", 3), (r"\bdaycare\b", 3),
                           (r"\bmontessori\b", 3), (r"\bteach", 2), (r"\bengage\b", 3), (r"\bstimulat", 3),
                           (r"\brhyme", 3), (r"\bsong", 2), (r"\bcolou?r", 2), (r"\bshape", 2), (r"\bcount", 2)],
        "first-40-days": [(r"\bnewborn\b", 3), (r"\b40 days\b", 4), (r"\bpostpartum\b", 3), (r"\bafter delivery\b", 3),
                          (r"\bumbilical\b", 4), (r"\bcord\b", 3), (r"\bconfinement\b", 4), (r"\bjaundice\b", 2),
                          (r"\b\d+ (day|week) old\b", 3), (r"\bstitches\b", 3), (r"\bbleeding\b", 2)],
        "you-maa": [(r"\bmom\b", 1), (r"\bmother\b", 1), (r"\bmyself\b", 3), (r"\bme time\b", 3), (r"\bguilt", 3),
                    (r"\bburn ?out\b", 3), (r"\bdepress", 3), (r"\banxi", 3), (r"\bexhaust", 3), (r"\btired\b", 2),
                    (r"\bhusband", 2), (r"\bpartner", 2), (r"\bmother in law\b", 3), (r"\bin laws?\b", 3),
                    (r"\bwork", 2), (r"\bjob\b", 3), (r"\bcareer\b", 3), (r"\bweight loss\b", 3), (r"\bhair fall\b", 3),
                    (r"\bperiod", 2), (r"\bsex\b", 2), (r"\bbody\b", 2), (r"\bmarriage\b", 3), (r"\balone\b", 2)],
        "traditions": [(r"\btradition", 4), (r"\bceremon", 4), (r"\bmundan\b", 4), (r"\bannaprashan", 4),
                       (r"\bnamkaran\b", 4), (r"\bnaming\b", 3), (r"\bjanam ghutti\b", 4), (r"\bgripe water\b", 3),
                       (r"\bkajal\b", 4), (r"\bnazar\b", 4), (r"\bhome remed", 3), (r"\bgharelu\b", 3),
                       (r"\bmalish\b", 3), (r"\bastrolog", 3), (r"\bname", 2)],
    },
    "skilling": {
        "coding": [(r"\bcod(e|ing)\b", 4), (r"\bprogramm", 4), (r"\bscratch\b", 3), (r"\bpython\b", 4),
                   (r"\brobot", 4), (r"\bcomputer", 3), (r"\bai\b", 3), (r"\bartificial intelligence\b", 4),
                   (r"\bstem\b(?! cell)", 2), (r"\bapp\b", 2), (r"\bgame", 1), (r"\btech", 2), (r"\bscreen", 2)],
        "reading": [(r"\bread", 4), (r"\bphonics\b", 4), (r"\bbook", 3), (r"\bsight words\b", 4), (r"\bletter", 3),
                    (r"\balphabet\b", 3), (r"\bstor(y|ies)\b", 3), (r"\bliterac", 4), (r"\bspell", 3), (r"\blibrary\b", 3)],
        "focus": [(r"\bfocus", 4), (r"\bconcentrat", 4), (r"\battention\b", 4), (r"\bdistract", 4), (r"\bsit still\b", 4),
                  (r"\bhomework\b", 2), (r"\bstud(y|ies)\b", 2), (r"\bhyperactiv", 3), (r"\badhd\b", 3), (r"\brestless\b", 3)],
        "confidence": [(r"\bconfiden", 4), (r"\bshy", 4), (r"\bself esteem\b", 4), (r"\bself worth\b", 4),
                       (r"\bstage\b", 2), (r"\bfear\b", 2), (r"\bafraid\b", 3), (r"\bbrave\b", 3), (r"\bintrovert", 4),
                       (r"\btimid\b", 4), (r"\bbull", 3), (r"\bassertive\b", 4), (r"\bindependen", 3), (r"\bsensitive\b", 2)],
        "communication": [(r"\bcommunicat", 4), (r"\bpublic speaking\b", 4), (r"\bspeak", 3), (r"\btalk", 3),
                          (r"\bvocabular", 4), (r"\blanguage\b", 3), (r"\bconversation", 4), (r"\bexpress", 3),
                          (r"\bbilingual\b", 4), (r"\benglish\b", 3), (r"\bhindi\b", 3), (r"\bstutter", 3),
                          (r"\blisten", 2), (r"\bsocial skill", 3), (r"\bfriend", 3)],
        "maths": [(r"\bmath", 4), (r"\babacus\b", 4), (r"\bvedic\b", 4), (r"\bcount", 3), (r"\bnumber", 3),
                  (r"\baddition\b", 4), (r"\bsubtract", 4), (r"\bmultipl", 4), (r"\btables\b", 3), (r"\bkumon\b", 3),
                  (r"\bgeometry\b", 4), (r"\bfraction", 4), (r"\bmental math", 4)],
        "memory": [(r"\bmemor", 4), (r"\bremember", 4), (r"\bforget", 4), (r"\brecall\b", 4), (r"\bretain", 3),
                   (r"\bbrain\b", 2), (r"\bsharp\b", 2), (r"\bmnemonic", 4)],
        "creativity": [(r"\bcreativ", 4), (r"\bimagin", 4), (r"\bart\b", 3), (r"\bdraw", 3), (r"\bpaint", 3),
                       (r"\bcraft", 3), (r"\bmusic\b", 3), (r"\binstrument\b", 3), (r"\bdance\b", 3), (r"\bhobby\b", 3),
                       (r"\btalent", 3), (r"\bsing", 2), (r"\bwriting\b", 2), (r"\bstorytelling\b", 2)],
        "thinking": [(r"\bthink", 4), (r"\bcritical\b", 4), (r"\bproblem solv", 4), (r"\blogic", 4), (r"\breason", 4),
                     (r"\bpuzzle", 4), (r"\bchess\b", 4), (r"\bcurio", 3), (r"\bquestion", 2), (r"\bscien", 3),
                     (r"\bexperiment", 3), (r"\bdecision", 3), (r"\bintelligen", 3), (r"\biq\b", 3), (r"\bsmart", 3),
                     (r"\bgifted\b", 3), (r"\bbrain development\b", 2)],
        "feelings": [(r"\bfeeling", 4), (r"\bemotion", 4), (r"\bempath", 4), (r"\banger\b", 3), (r"\bangry\b", 3),
                     (r"\bfrustrat", 3), (r"\bsad\b", 3), (r"\bcry", 2), (r"\bregulat", 4), (r"\btantrum", 2),
                     (r"\bmental health\b", 4), (r"\banxi", 3), (r"\bstress", 3), (r"\bworr", 2), (r"\bresilien", 4),
                     (r"\bfail", 3), (r"\blos(e|ing)\b", 2), (r"\bdisappoint", 3)],
        "stillness": [(r"\bmindful", 4), (r"\bmeditat", 4), (r"\bcalm\b", 4), (r"\byoga\b", 4), (r"\bbreath", 4),
                      (r"\bpatien", 4), (r"\bquiet\b", 3), (r"\bstill\b", 2), (r"\bsleep\b", 1), (r"\brelax", 3),
                      (r"\bslow down\b", 3), (r"\bboredom\b", 3), (r"\bbored\b", 3)],
        "values": [(r"\bvalue", 4), (r"\bgratitude\b", 4), (r"\bgrateful\b", 4), (r"\bmanners\b", 4), (r"\bkind", 3),
                   (r"\bhonest", 4), (r"\bl(ie|ying|ies)\b", 3), (r"\brespect", 4), (r"\bshar(e|ing)\b", 3),
                   (r"\bresponsib", 4), (r"\bdiscipline\b", 2), (r"\bmoral", 4), (r"\bgood habits?\b", 3),
                   (r"\bchores?\b", 3), (r"\bhelp(ing)? (at home|others)\b", 3), (r"\bpolite\b", 4), (r"\bthank", 3),
                   (r"\bspoil", 3), (r"\bgreed", 3), (r"\bentitle", 3), (r"\bculture\b", 2), (r"\breligio", 3)],
        "making": [(r"\bmak(e|ing)\b", 3), (r"\bbuild", 3), (r"\blego\b", 4), (r"\bblocks?\b", 3), (r"\bdiy\b", 4),
                   (r"\bproject", 3), (r"\bhands? on\b", 3), (r"\bcraft", 2), (r"\btinker", 4), (r"\bexperiment", 2)],
        "school-and-study": [(r"\bschool\b", 3), (r"\bhomework\b", 3), (r"\bexam", 4), (r"\bstud(y|ies)\b", 3),
                             (r"\btuition\b", 4), (r"\bteacher\b", 3), (r"\bgrade", 3), (r"\bmarks\b", 4),
                             (r"\bboard\b", 3), (r"\bhomeschool", 4), (r"\bcurriculum\b", 4), (r"\bextracurricular\b", 3),
                             (r"\bsport", 3), (r"\bclass\b", 2), (r"\bslow learner\b", 3), (r"\blearning\b", 1)],
    },
    "unclear": {},
}

COMPILED = {stage: {t: [(re.compile(p), w) for p, w in rules] for t, rules in topics.items()}
            for stage, topics in TOPICS.items()}


def topic(norm: str, stage: str) -> str:
    rules = COMPILED.get(stage) or {}
    if not rules:
        return "general"
    best, best_score = "general", 0
    for t, rx in rules.items():
        s = sum(w for r, w in rx if r.search(norm))
        if s > best_score:
            best, best_score = t, s
    return best
