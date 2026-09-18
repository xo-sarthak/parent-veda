"""ParentVeda Question Miner — CLI.

    python tools/question_miner/run.py run                 # collect everything, then cluster
    python tools/question_miner/run.py run --sources google_ac,reddit
    python tools/question_miner/run.py cluster             # re-cluster the latest run only
    python tools/question_miner/run.py run --threshold 0.2 --reddit-pages 2

Output lands in research/questions/. The raw store is research/questions/questions.sqlite.
"""

from __future__ import annotations

import argparse
import logging
import sys
import time
from collections import Counter
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

from qm.collectors import DEFAULT_ORDER, REGISTRY          # noqa: E402
from qm.filter import looks_like_question                  # noqa: E402
from qm.normalize import detect_lang, normalize            # noqa: E402
from qm.schema import Store                                # noqa: E402
from qm.stage import classify                              # noqa: E402
from qm.topic import topic                                 # noqa: E402

REPO = HERE.parents[1]
OUT_DIR = REPO / "research" / "questions"
DB_PATH = OUT_DIR / "questions.sqlite"
SLUG_SOURCES = {"babychakra", "parentune", "mylo"}

log = logging.getLogger("qm")


def collect(store: Store, sources: list[str], stages: list[str] | None, reddit_pages: int,
            parallel: bool = True) -> int:
    """Each source is one job. They talk to different hosts, so running them
    side by side does not touch the per-host politeness in qm/http.py; it only
    stops Google's hour of autocomplete calls serialising behind Reddit's.
    SQLite is written from this thread only — collectors return lists."""
    prev = store.latest_run()
    run_id = store.start_run(sources)
    untouched = [s for s in REGISTRY if s not in sources]
    kept = store.carry_forward(run_id, prev, untouched)
    if kept:
        log.info("carried forward %d rows from untouched sources %s", kept, untouched)

    def job(name: str):
        t0 = time.time()
        qs = REGISTRY[name](stages=stages, reddit_pages=reddit_pages)
        return name, qs, time.time() - t0

    def done(name, qs, secs):
        n = store.add_many(run_id, qs)
        log.info("== %-11s %5d raw strings in %.0fs (%d distinct in store)",
                 name, n, secs, store.count_for_run(run_id, name))

    if parallel and len(sources) > 1:
        from concurrent.futures import ThreadPoolExecutor, as_completed
        with ThreadPoolExecutor(max_workers=len(sources), thread_name_prefix="src") as ex:
            futures = {ex.submit(job, s): s for s in sources}
            for f in as_completed(futures):
                try:
                    done(*f.result())
                except Exception as e:  # one source failing must not sink the run
                    log.exception("source %s failed: %s", futures[f], e)
    else:
        for s in sources:
            try:
                done(*job(s))
            except Exception as e:
                log.exception("source %s failed: %s", s, e)
    store.finish_run(run_id)
    return run_id


def process(store: Store, run_id: int) -> tuple[list[dict], dict]:
    """filter -> tag -> normalise. Returns rows ready to cluster, plus counts."""
    raw = store.rows_for_run(run_id)
    counts = Counter()
    counts["raw strings"] = len(raw)
    rows: list[dict] = []
    for r in raw:
        slug = r["source"] in SLUG_SOURCES
        if not looks_like_question(r["text"], slug=slug):
            counts["dropped: not a question"] += 1
            continue
        lang = r["lang"] or detect_lang(r["text"])
        norm = normalize(r["text"], lang)
        if len(norm.split()) < 3:
            counts["dropped: too short after normalise"] += 1
            continue
        stage, _ = classify(norm, r["stage_hint"])
        rows.append({**r, "lang": lang, "norm": norm, "stage": stage, "topic": topic(norm, stage)})
        counts[f"stage: {stage}"] += 1
    counts["questions kept"] = len(rows)
    for k, v in sorted(counts.items()):
        log.info("%-40s %6d", k, v)
    return rows, dict(counts)


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("command", choices=["run", "collect", "cluster"])
    ap.add_argument("--sources", default=",".join(DEFAULT_ORDER),
                    help=f"comma list from {list(REGISTRY)}")
    ap.add_argument("--stages", default="", help="comma list of stages to limit collection to")
    ap.add_argument("--threshold", type=float, default=0.15,
                    help="cosine distance at which two phrasings are one question (lower = stricter)")
    ap.add_argument("--reddit-pages", type=int, default=1,
                    help="RSS pages per listing (100 titles each; anonymous Reddit allows one page a minute)")
    ap.add_argument("--out", default=str(OUT_DIR))
    ap.add_argument("--serial", action="store_true", help="collect sources one after another")
    ap.add_argument("-v", "--verbose", action="store_true")
    a = ap.parse_args(argv)

    logging.basicConfig(level=logging.DEBUG if a.verbose else logging.INFO,
                        format="%(asctime)s %(levelname)-7s %(name)-14s %(message)s",
                        datefmt="%H:%M:%S", stream=sys.stderr)
    logging.getLogger("urllib3").setLevel(logging.WARNING)
    out_dir = Path(a.out)
    store = Store(out_dir / "questions.sqlite")
    sources = [s.strip() for s in a.sources.split(",") if s.strip()]
    bad = [s for s in sources if s not in REGISTRY]
    if bad:
        ap.error(f"unknown sources {bad}; choose from {list(REGISTRY)}")
    stages = [s.strip() for s in a.stages.split(",") if s.strip()] or None

    if a.command in ("run", "collect"):
        run_id = collect(store, sources, stages, a.reddit_pages, parallel=not a.serial)
        log.info("collected run #%d: %d distinct strings", run_id, store.count_for_run(run_id))
        if a.command == "collect":
            return 0
    else:
        run_id = store.latest_run()
        if run_id is None:
            log.error("nothing collected yet — use `run`")
            return 1

    from qm.cluster import cluster_all      # imports onnxruntime; keep it off the collect path
    from qm.export import write_all

    rows, counts = process(store, run_id)
    clusters = cluster_all(rows, a.threshold, run_id)
    counts["clusters"] = sum(len(v) for v in clusters.values())
    written = write_all(out_dir, clusters, {"run_id": run_id, "counts": counts})
    for p in written:
        log.info("wrote %s", p.relative_to(REPO) if p.is_relative_to(REPO) else p)
    return 0


if __name__ == "__main__":
    sys.exit(main())
