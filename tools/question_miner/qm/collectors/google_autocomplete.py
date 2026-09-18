"""Google autocomplete, India locale.

For every stem we ask Google to complete:
  - the stem itself
  - "<question word> <stem>"   (why / how / is it safe / ...)
  - "<stem> <letter>"          (a..z)
and then, one level deeper, the question-shaped suggestions that came back.
That is the "answer the public" expansion; it is where the long tail lives.

No approval, no key. Kept polite: ~1s between calls. Google answers a burst
with 403 (seen after ~450 calls at 2/s on 2026-09-18) and lifts it within a
minute, so 403 is treated as "slow down", not "no results": back off 30s,
60s, 120s, 240s and retry, and a stem that still fails is retried once after
a five-minute pause rather than recorded as empty.
Hits count how many different expansions surfaced the same suggestion.
"""

from __future__ import annotations

import logging
import time
from collections import Counter

from .. import http
from ..filter import looks_like_question
from ..schema import Question
from ..seeds import LETTERS, QUESTION_PREFIXES, STEMS

log = logging.getLogger("qm.google_ac")

ENDPOINT = "https://suggestqueries.google.com/complete/search"


MIN_INTERVAL = 0.9


def suggest(q: str) -> list[str]:
    r = http.get(ENDPOINT, {"client": "firefox", "q": q, "hl": "en", "gl": "in"},
                 min_interval=MIN_INTERVAL, also_throttle=(403,), first_backoff=30.0, retries=4)
    if r.status_code != 200:
        log.warning("autocomplete %s -> %s", q, r.status_code)
        return []
    try:
        data = r.json()
    except ValueError:
        return []
    return [s for s in data[1] if isinstance(s, str)] if len(data) > 1 else []


def expand(stem: str, depth2_cap: int) -> Counter:
    """All suggestions for one stem, counted by how many queries produced them."""
    hits: Counter = Counter()
    queries = [stem] + [f"{p} {stem}" for p in QUESTION_PREFIXES] + [f"{stem} {c}" for c in LETTERS]
    for q in queries:
        for s in suggest(q):
            hits[s] += 1
    # Depth 2: re-expand question-shaped suggestions, most-seen first.
    seeds = [s for s, _ in hits.most_common() if looks_like_question(s, slug=False)][:depth2_cap]
    for s in seeds:
        for s2 in suggest(s):
            hits[s2] += 1
    return hits


def collect(depth2_cap: int = 25, stages: list[str] | None = None, **_) -> list[Question]:
    out: list[Question] = []
    for stage, stems in STEMS.items():
        if stages and stage not in stages:
            continue
        for stem in stems:
            hits = None
            for attempt in range(2):
                try:
                    hits = expand(stem, depth2_cap)
                    break
                except http.Throttled as e:
                    log.error("google throttled at stem %r (%s); pausing 5 min", stem, e)
                    time.sleep(300)
            if hits is None:
                log.error("google_ac %s %r skipped after two throttled attempts", stage, stem)
                continue
            n = 0
            for text, count in hits.items():
                out.append(Question(text=text, stage_hint=stage, source="google_ac",
                                    source_detail="firefox/in", stem=stem, hits=count))
                n += 1
            log.info("google_ac %-10s %-45s %4d suggestions", stage, stem, n)
    return out
