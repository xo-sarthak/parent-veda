"""Collectors. Each exposes `collect(**opts) -> list[Question]` and is
registered here by name so the CLI can switch any one of them on or off
without touching the rest.
"""

from . import google_autocomplete, ddg_autocomplete, reddit, india_sitemaps

REGISTRY = {
    "google_ac": google_autocomplete.collect,
    "ddg_ac": ddg_autocomplete.collect,
    "reddit": reddit.collect,
    "babychakra": india_sitemaps.collect_babychakra,
    "parentune": india_sitemaps.collect_parentune,
    "mylo": india_sitemaps.collect_mylo,
}

DEFAULT_ORDER = ["google_ac", "ddg_ac", "babychakra", "parentune", "mylo", "reddit"]
