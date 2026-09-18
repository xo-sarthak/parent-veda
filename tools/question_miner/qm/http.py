"""One polite HTTP door for every collector.

Per-host minimum spacing, exponential backoff on 429 / 5xx / connection
resets, a browser-like User-Agent and an India locale. Every collector goes
through `get()` so the rate-limiting lives in exactly one place.
"""

from __future__ import annotations

import logging
import random
import threading
import time
from urllib.parse import urlparse

import requests

log = logging.getLogger("qm.http")

UA = ("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
      "(KHTML, like Gecko) Chrome/128.0 Safari/537.36")
HEADERS = {"User-Agent": UA, "Accept-Language": "en-IN,en;q=0.9"}

_session = requests.Session()
_session.headers.update(HEADERS)
_last_call: dict[str, float] = {}
_not_before: dict[str, float] = {}   # host -> earliest time the next call may go out
_lock = threading.Lock()


class Throttled(Exception):
    """Raised when a host keeps answering 429 after every retry."""


def get(url: str, params: dict | None = None, *, min_interval: float = 0.4,
        retries: int = 4, timeout: int = 30, also_throttle: tuple[int, ...] = (),
        first_backoff: float = 2.0) -> requests.Response:
    """`also_throttle`: statuses this host uses to mean "slow down" besides
    429 — Google autocomplete answers a burst with 403, not 429."""
    host = urlparse(url).netloc
    delay = first_backoff
    for attempt in range(retries + 1):
        _space(host, min_interval)
        try:
            r = _session.get(url, params=params, timeout=timeout)
        except requests.RequestException as e:
            log.warning("%s -> %s (attempt %d)", url, type(e).__name__, attempt)
            time.sleep(delay); delay *= 2
            continue
        _learn_budget(host, r)
        if r.status_code == 429 or r.status_code >= 500 or r.status_code in also_throttle:
            wait = _reset_hint(r) or delay
            log.warning("%s -> %s, waiting %.0fs (attempt %d)", host, r.status_code, wait, attempt)
            time.sleep(wait); delay *= 2
            continue
        return r
    raise Throttled(f"{host} kept refusing after {retries} retries")


def _reset_hint(r: requests.Response) -> float | None:
    """Seconds the server itself says to wait, if it says."""
    for h in ("Retry-After", "x-ratelimit-reset"):
        v = r.headers.get(h)
        if v:
            try:
                return float(v) + 1.0
            except ValueError:
                pass
    return None


def _learn_budget(host: str, r: requests.Response) -> None:
    """Reddit answers anonymous feeds with x-ratelimit-remaining / -reset
    (one request per clock minute as of 2026-09). When the budget is spent,
    park this host until the window resets rather than burn a 429 finding out."""
    rem = r.headers.get("x-ratelimit-remaining")
    if rem is None:
        return
    try:
        if float(rem) < 1:
            wait = _reset_hint(r) or 60.0
            with _lock:
                _not_before[host] = max(_not_before.get(host, 0.0), time.time() + wait)
    except ValueError:
        pass


def _space(host: str, min_interval: float) -> None:
    """Reserve the next slot for this host under the lock, then sleep outside
    it, so two threads on the same host queue instead of racing."""
    with _lock:
        last = _last_call.get(host, 0.0)
        slot = max(last + min_interval * random.uniform(1.0, 1.4), time.time(),
                   _not_before.get(host, 0.0))
        _last_call[host] = slot
    wait = slot - time.time()
    if wait > 0:
        time.sleep(wait)
