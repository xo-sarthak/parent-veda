"""The common schema every collector writes into, and the SQLite store.

One table, keyed by (source, text). A row is upserted on every run: its
`last_seen_run` moves forward and its per-run `hits` is reset, so the
pipeline can read "everything the latest run saw" while the table keeps the
history that tells us when a question first appeared. That is what makes a
re-run both a refresh (counts) and a discovery (new since last time).
"""

from __future__ import annotations

import sqlite3
import time
from dataclasses import dataclass, field
from pathlib import Path

STAGES = ("ttc", "pregnancy", "parenting", "skilling")
UNCLEAR = "unclear"


@dataclass
class Question:
    text: str
    stage_hint: str          # what the SOURCE implies: a stage or "unclear"
    source: str              # google_ac | ddg_ac | reddit | babychakra | parentune | mylo
    source_detail: str = ""  # subreddit, sitemap name, autocomplete client
    url: str = ""
    ts: str = ""             # raw timestamp from the source, if any
    stem: str = ""           # the seed stem or search query that surfaced it
    lang: str = "en"         # en | hinglish | hi
    hits: int = 1            # times seen in THIS run (autocomplete repeats etc.)
    weight: float = 1.0      # optional source weight (reddit score), not used for rank
    extra: dict = field(default_factory=dict)


class Store:
    def __init__(self, path: Path):
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.db = sqlite3.connect(str(self.path))
        self.db.execute("PRAGMA journal_mode=WAL")
        self.db.executescript(
            """
            CREATE TABLE IF NOT EXISTS runs (
              run_id     INTEGER PRIMARY KEY AUTOINCREMENT,
              started_at TEXT NOT NULL,
              finished_at TEXT,
              sources    TEXT,
              note       TEXT
            );
            CREATE TABLE IF NOT EXISTS questions (
              source        TEXT NOT NULL,
              text          TEXT NOT NULL,
              stage_hint    TEXT NOT NULL,
              source_detail TEXT DEFAULT '',
              url           TEXT DEFAULT '',
              ts            TEXT DEFAULT '',
              stem          TEXT DEFAULT '',
              lang          TEXT DEFAULT 'en',
              hits          INTEGER DEFAULT 1,
              weight        REAL DEFAULT 1.0,
              first_seen_run INTEGER NOT NULL,
              last_seen_run  INTEGER NOT NULL,
              PRIMARY KEY (source, text)
            );
            CREATE INDEX IF NOT EXISTS q_last_seen ON questions(last_seen_run);
            """
        )

    # -- runs ---------------------------------------------------------------
    def start_run(self, sources: list[str], note: str = "") -> int:
        cur = self.db.execute(
            "INSERT INTO runs(started_at, sources, note) VALUES (?,?,?)",
            (_now(), ",".join(sources), note),
        )
        self.db.commit()
        return int(cur.lastrowid)

    def finish_run(self, run_id: int) -> None:
        self.db.execute("UPDATE runs SET finished_at=? WHERE run_id=?", (_now(), run_id))
        self.db.commit()

    def latest_run(self) -> int | None:
        row = self.db.execute("SELECT MAX(run_id) FROM runs").fetchone()
        return row[0] if row and row[0] is not None else None

    # -- questions ------------------------------------------------------------
    def add_many(self, run_id: int, qs: list[Question]) -> int:
        """Upsert. Same (source, text) seen again this run adds to hits;
        seen in an earlier run keeps first_seen and refreshes last_seen."""
        n = 0
        for q in qs:
            self.db.execute(
                """
                INSERT INTO questions(source, text, stage_hint, source_detail, url, ts,
                                      stem, lang, hits, weight, first_seen_run, last_seen_run)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
                ON CONFLICT(source, text) DO UPDATE SET
                  hits = CASE WHEN questions.last_seen_run = excluded.last_seen_run
                              THEN questions.hits + excluded.hits ELSE excluded.hits END,
                  last_seen_run = excluded.last_seen_run,
                  stage_hint = excluded.stage_hint,
                  source_detail = excluded.source_detail,
                  url = CASE WHEN excluded.url != '' THEN excluded.url ELSE questions.url END,
                  ts = CASE WHEN excluded.ts != '' THEN excluded.ts ELSE questions.ts END,
                  stem = excluded.stem,
                  lang = excluded.lang,
                  weight = excluded.weight
                """,
                (q.source, q.text, q.stage_hint, q.source_detail, q.url, q.ts,
                 q.stem, q.lang, q.hits, q.weight, run_id, run_id),
            )
            n += 1
        self.db.commit()
        return n

    def rows_for_run(self, run_id: int) -> list[dict]:
        cur = self.db.execute(
            "SELECT source, text, stage_hint, source_detail, url, ts, stem, lang, hits, weight, "
            "first_seen_run, last_seen_run FROM questions WHERE last_seen_run = ?",
            (run_id,),
        )
        cols = [c[0] for c in cur.description]
        return [dict(zip(cols, r)) for r in cur.fetchall()]

    def carry_forward(self, run_id: int, prev_run: int | None, sources: list[str]) -> int:
        """When a run only re-collects SOME sources, the untouched sources keep
        their previous rows: their last_seen_run moves to this run unchanged."""
        if prev_run is None or not sources:
            return 0
        marks = ",".join("?" * len(sources))
        cur = self.db.execute(
            f"UPDATE questions SET last_seen_run=? WHERE last_seen_run=? AND source IN ({marks})",
            (run_id, prev_run, *sources),
        )
        self.db.commit()
        return cur.rowcount

    def count_for_run(self, run_id: int, source: str | None = None) -> int:
        if source:
            return self.db.execute(
                "SELECT COUNT(*) FROM questions WHERE last_seen_run=? AND source=?", (run_id, source)
            ).fetchone()[0]
        return self.db.execute(
            "SELECT COUNT(*) FROM questions WHERE last_seen_run=?", (run_id,)
        ).fetchone()[0]

    def close(self) -> None:
        self.db.close()


def _now() -> str:
    return time.strftime("%Y-%m-%dT%H:%M:%S")
