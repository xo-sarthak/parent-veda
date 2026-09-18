"""Reddit, titles only.

Two transports, same output:

  * OAuth via PRAW when credentials are present (env or tools/question_miner/.env:
    REDDIT_CLIENT_ID, REDDIT_CLIENT_SECRET, REDDIT_USER_AGENT). 100 req/min,
    1,000-item listing cap, read-only. This is the intended path.
  * Public RSS/Atom feeds when they are not. Same listings, same titles, but
    Reddit allows anonymous feeds ONE request per minute per IP (measured
    2026-09-18 from x-ratelimit-* headers), so it is slow and shallower:
    ~29 subs x 3 listings + 48 searches = ~2.5 hours for ~4,000 titles that
    OAuth would fetch in five minutes. It exists so a run never blocks on
    credentials.

Either way we read `title`, `permalink`, `created`, `score` and nothing else.
No selftext, no comments. That is the whole legal posture of this tool.
"""

from __future__ import annotations

import html
import logging
import os
import re
import xml.etree.ElementTree as ET
from pathlib import Path

from .. import http
from ..schema import Question
from ..seeds import SKILLING_SEARCH_QUERIES, SKILLING_SEARCH_SUBS, SUBREDDITS

log = logging.getLogger("qm.reddit")

ATOM = "{http://www.w3.org/2005/Atom}"
RSS_INTERVAL = 6.5       # floor between anonymous feed calls; the real pacing comes from
                         # Reddit's x-ratelimit headers, learned in qm/http.py (1/min in 2026-09)
RSS_SEARCH_QUERIES = 8   # skilling searches per general sub on the anonymous budget


# -- credentials --------------------------------------------------------------
def _load_dotenv() -> None:
    p = Path(__file__).resolve().parents[2] / ".env"
    if not p.exists():
        return
    for line in p.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        os.environ.setdefault(k.strip(), v.strip().strip('"').strip("'"))


def _praw_client():
    _load_dotenv()
    cid, sec = os.environ.get("REDDIT_CLIENT_ID"), os.environ.get("REDDIT_CLIENT_SECRET")
    if not (cid and sec):
        return None
    try:
        import praw
    except ImportError:
        log.warning("praw not installed; falling back to RSS")
        return None
    ua = os.environ.get("REDDIT_USER_AGENT", "windows:parentveda-question-miner:0.1 (research)")
    kw = dict(client_id=cid, client_secret=sec, user_agent=ua)
    if os.environ.get("REDDIT_USERNAME") and os.environ.get("REDDIT_PASSWORD"):
        kw.update(username=os.environ["REDDIT_USERNAME"], password=os.environ["REDDIT_PASSWORD"])
    r = praw.Reddit(**kw)
    r.read_only = True
    return r


# -- PRAW transport -------------------------------------------------------------
def _praw_listing(sub, listing: str, time_filter: str | None, limit: int):
    if listing == "top":
        return sub.top(time_filter=time_filter, limit=limit)
    if listing == "hot":
        return sub.hot(limit=limit)
    return sub.new(limit=limit)


def _collect_praw(reddit, stages, limit_per_listing: int) -> list[Question]:
    out: list[Question] = []
    seen: set[str] = set()

    def take(sub_name: str, stage: str, posts, stem: str = "") -> int:
        n = 0
        for p in posts:
            if p.id in seen:
                continue
            seen.add(p.id)
            out.append(Question(
                text=p.title, stage_hint=stage, source="reddit", source_detail=f"r/{sub_name}",
                url=f"https://www.reddit.com{p.permalink}", ts=str(int(p.created_utc)),
                stem=stem, weight=float(max(p.score, 1))))
            n += 1
        return n

    for stage, subs in SUBREDDITS.items():
        if stages and stage not in stages:
            continue
        for s in subs:
            try:
                sub = reddit.subreddit(s)
                n = 0
                for listing, tf in (("top", "year"), ("top", "all"), ("hot", None), ("new", None)):
                    n += take(s, stage, _praw_listing(sub, listing, tf, limit_per_listing))
                log.info("reddit(oauth) r/%-24s %4d titles", s, n)
            except Exception as e:  # private / banned / typo — never fatal
                log.warning("reddit r/%s skipped: %s", s, e)
    if not stages or "skilling" in stages:
        for s in SKILLING_SEARCH_SUBS:
            try:
                sub = reddit.subreddit(s)
                for q in SKILLING_SEARCH_QUERIES:
                    take(s, "skilling", sub.search(q, sort="top", time_filter="all", limit=100), stem=q)
                log.info("reddit(oauth) r/%-24s skilling search done", s)
            except Exception as e:
                log.warning("reddit search r/%s skipped: %s", s, e)
    return out


# -- RSS transport ------------------------------------------------------------
def _parse_atom(xml_text: str) -> list[dict]:
    try:
        root = ET.fromstring(xml_text)
    except ET.ParseError:
        return []
    items = []
    for e in root.findall(f"{ATOM}entry"):
        title = e.findtext(f"{ATOM}title") or ""
        link = e.find(f"{ATOM}link")
        items.append({
            "id": (e.findtext(f"{ATOM}id") or "").strip(),
            "title": html.unescape(title).strip(),
            "url": link.get("href") if link is not None else "",
            "ts": (e.findtext(f"{ATOM}updated") or "").strip(),
        })
    return items


def _rss_pages(url: str, params: dict, pages: int) -> list[dict]:
    items, after = [], None
    for _ in range(pages):
        p = dict(params, limit=100)
        if after:
            p["after"] = after
        try:
            r = http.get(url, p, min_interval=RSS_INTERVAL, retries=3)
        except http.Throttled:
            log.warning("rss throttled at %s", url)
            break
        if r.status_code != 200:
            log.warning("rss %s -> %s", url, r.status_code)
            break
        batch = _parse_atom(r.text)
        if not batch:
            break
        items.extend(batch)
        after = batch[-1]["id"]
        if len(batch) < 100:
            break
    return items


def _collect_rss(stages, pages_top: int, pages_other: int) -> list[Question]:
    out: list[Question] = []
    seen: set[str] = set()

    def take(sub_name: str, stage: str, items: list[dict], stem: str = "") -> int:
        n = 0
        for it in items:
            if not it["title"] or it["id"] in seen:
                continue
            seen.add(it["id"])
            out.append(Question(text=it["title"], stage_hint=stage, source="reddit",
                                source_detail=f"r/{sub_name}", url=it["url"], ts=it["ts"], stem=stem))
            n += 1
        return n

    # Anonymous budget is ONE request a minute (qm/http.py learns the window
    # from Reddit's headers), so every listing below costs a minute. Order is
    # by question yield: new and hot are where people ask; top is stories.
    for stage, subs in SUBREDDITS.items():
        if stages and stage not in stages:
            continue
        for s in subs:
            base = f"https://www.reddit.com/r/{s}"
            n = 0
            n += take(s, stage, _rss_pages(f"{base}/new.rss", {}, pages_other))
            if n == 0:
                log.warning("reddit(rss) r/%s returned nothing — private, banned or misspelt", s)
                continue
            n += take(s, stage, _rss_pages(f"{base}/hot.rss", {}, pages_other))
            n += take(s, stage, _rss_pages(f"{base}/top.rss", {"t": "year"}, pages_top))
            log.info("reddit(rss) r/%-24s %4d titles", s, n)
    if not stages or "skilling" in stages:
        for s in SKILLING_SEARCH_SUBS:
            n = 0
            for q in SKILLING_SEARCH_QUERIES[:RSS_SEARCH_QUERIES]:
                n += take(s, "skilling", _rss_pages(
                    f"https://www.reddit.com/r/{s}/search.rss",
                    {"q": q, "restrict_sr": 1, "sort": "top", "t": "all"}, 1), stem=q)
            log.info("reddit(rss) r/%-24s %4d skilling-search titles", s, n)
    return out


# -- entry point --------------------------------------------------------------
def collect(stages: list[str] | None = None, reddit_pages: int = 1, **_) -> list[Question]:
    client = _praw_client()
    if client is not None:
        log.info("reddit: OAuth credentials found, using PRAW")
        try:
            return _collect_praw(client, stages, limit_per_listing=1000)
        except Exception as e:
            log.error("reddit OAuth failed (%s); falling back to RSS", e)
    else:
        log.warning("reddit: no OAuth credentials (REDDIT_CLIENT_ID / REDDIT_CLIENT_SECRET); "
                    "using public RSS feeds — slower and shallower")
    return _collect_rss(stages, pages_top=reddit_pages, pages_other=reddit_pages)
