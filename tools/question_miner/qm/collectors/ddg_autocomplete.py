"""DuckDuckGo autocomplete, India-English locale.

A second, independent search-demand signal. Fewer suggestions per query
than Google (8) so the expansion is shallower: stem + question prefixes.
"""

from __future__ import annotations

import logging
from collections import Counter

from .. import http
from ..schema import Question
from ..seeds import QUESTION_PREFIXES, STEMS

log = logging.getLogger("qm.ddg_ac")

ENDPOINT = "https://duckduckgo.com/ac/"


def suggest(q: str) -> list[str]:
    r = http.get(ENDPOINT, {"q": q, "kl": "in-en"}, min_interval=0.7, also_throttle=(403,), first_backoff=20.0)
    if r.status_code != 200:
        return []
    try:
        return [d["phrase"] for d in r.json() if "phrase" in d]
    except ValueError:
        return []


def collect(stages: list[str] | None = None, **_) -> list[Question]:
    out: list[Question] = []
    for stage, stems in STEMS.items():
        if stages and stage not in stages:
            continue
        for stem in stems:
            hits: Counter = Counter()
            try:
                for q in [stem] + [f"{p} {stem}" for p in QUESTION_PREFIXES]:
                    for s in suggest(q):
                        hits[s] += 1
            except http.Throttled as e:
                log.error("ddg throttled at %r: %s", stem, e)
                break
            for text, count in hits.items():
                out.append(Question(text=text, stage_hint=stage, source="ddg_ac",
                                    source_detail="in-en", stem=stem, hits=count))
            log.info("ddg_ac    %-10s %-45s %4d suggestions", stage, stem, len(hits))
    return out
