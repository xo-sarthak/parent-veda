"""India-first communities, from their sitemaps.

BabyChakra, Parentune and Mylo all put the question text in the URL slug
("/community/questions/6month-complete-hone-k-baad-baby-ko-kya-khilaye"),
so the sitemap alone hands us the question line. We fetch ONE xml file per
site and never open a question page — no answers, no comments, no load on
them, and no ToS friction beyond reading a public sitemap.

The cost: slugs lose punctuation (no "?"), so the question filter for these
sources leans on question words, including Hinglish ones (kya, kaise, kab).
"""

from __future__ import annotations

import logging
import re
from urllib.parse import unquote

from .. import http
from ..normalize import detect_lang
from ..schema import UNCLEAR, Question
from ..seeds import INDIA_SITEMAPS

log = logging.getLogger("qm.india")

LOC = re.compile(r"<loc>(.*?)</loc>", re.S)
# BabyChakra cuts long slugs at ~75 chars and appends a 4-char alnum hash ("-1dhf").
TRAILING_HASH = re.compile(r"^(?P<body>.{70,}?)-(?=[0-9a-z]{4}$)(?:[a-z]*\d[0-9a-z]*)$")
TRAILING_ID = re.compile(r"-\d{4,}$")                                    # mylo "-5503805"


def _locs(url: str) -> list[str]:
    r = http.get(url, min_interval=1.0)
    if r.status_code != 200:
        log.warning("sitemap %s -> %s", url, r.status_code)
        return []
    return LOC.findall(r.text)


CODEPOINT_SLUG = re.compile(r"^(?:\d{3,5}-)+\d{0,5}-?$")


def _slug_to_text(slug: str) -> str:
    slug = unquote(slug)
    # BabyChakra writes Devanagari slugs as hyphen-joined code points
    # ("2325-2381-2351-..." = "क्या ..."); turn them back into text.
    if CODEPOINT_SLUG.match(slug):
        cps = [int(x) for x in slug.strip("-").split("-") if x]
        if cps and all(0x0900 <= c <= 0x097F or c == 32 for c in cps):
            return "".join(chr(c) for c in cps).strip()
    slug = TRAILING_HASH.sub(r"\g<body>", slug)
    slug = TRAILING_ID.sub("", slug)
    return re.sub(r"[-_]+", " ", slug).strip()


def _q(text: str, source: str, detail: str, url: str, stage_hint: str = UNCLEAR) -> Question:
    return Question(text=text, stage_hint=stage_hint, source=source, source_detail=detail,
                    url=url, lang=detect_lang(text))


def collect_babychakra(**_) -> list[Question]:
    out: list[Question] = []
    # /community/questions/<slug> and /community/question/<id>/<slug>.
    # feedposts are skipped: they are the site's own promos, not user questions.
    for loc in _locs(INDIA_SITEMAPS["babychakra"]):
        m = re.search(r"/community/(questions?)/(?:\d+/)?([^/?#]+)$", loc)
        if not m:
            continue
        kind, slug = m.groups()
        text = _slug_to_text(slug)
        if text:
            out.append(_q(text, "babychakra", kind, loc))
    log.info("babychakra %d slugs", len(out))
    return out


def collect_parentune(**_) -> list[Question]:
    out: list[Question] = []
    for key in ("parentune_talks", "parentune_hi_talks"):
        n = 0
        for loc in _locs(INDIA_SITEMAPS[key]):
            m = re.search(r"/parent-talk/([^/?#]+)/\d+/?$", loc) or \
                re.search(r"/parent-talk/([^/?#]+)/?$", loc)
            if not m:
                continue
            text = _slug_to_text(m.group(1))
            if text:
                out.append(_q(text, "parentune", key.replace("parentune_", ""), loc))
                n += 1
        log.info("parentune %s %d slugs", key, n)
    return out


def collect_mylo(**_) -> list[Question]:
    out: list[Question] = []
    locs = _locs(INDIA_SITEMAPS["mylo_questions"])
    # a sitemap index points at more sitemaps; a urlset is the list itself
    if locs and all(l.endswith(".xml") for l in locs):
        nested = []
        for l in locs:
            nested.extend(_locs(l))
        locs = nested
    for loc in locs:
        m = re.search(r"/(?:[a-z]{2}/)?questions/([^/?#]+)$", loc)
        if not m:
            continue
        text = _slug_to_text(m.group(1))
        if text:
            out.append(_q(text, "mylo", "questions", loc))
    log.info("mylo %d slugs", len(out))
    return out
