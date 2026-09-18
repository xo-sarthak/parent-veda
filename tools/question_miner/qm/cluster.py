"""Embed, cluster within each stage, pick a canonical question, rank.

Embeddings: BAAI/bge-small-en-v1.5 (384-d, ONNX, runs on CPU) via fastembed.
The model files live in tools/question_miner/.models/ because HuggingFace is
unreachable from this network; `fetch_model.py` downloads them from a mirror.

Clustering: agglomerative, average linkage, cosine distance, cut at a fixed
threshold (0.15 by default, calibrated on the first full run) — no need to guess how many clusters there are, and the threshold
means the same thing on every run ("phrasings this close are one question").
Average linkage over single so one bridging phrasing cannot chain two real
questions into one blob. Stages larger than ~4,000 phrasings are k-means
partitioned first and stitched after — see `_labels` for why the obvious
kNN-connectivity shortcut was wrong.

Ranking: cluster size = number of DISTINCT phrasings. That is the demand
signal the brief asks for. Total hits (a suggestion surfacing under many
expansions) and source spread are kept as tie-breakers and as columns.
"""

from __future__ import annotations

import logging
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from pathlib import Path

import numpy as np

from .schema import STAGES, UNCLEAR

log = logging.getLogger("qm.cluster")

MODEL_NAME = "BAAI/bge-small-en-v1.5"
MODEL_DIR = Path(__file__).resolve().parents[1] / ".models" / "bge-small-en-v1.5"


@dataclass
class Phrasing:
    norm: str
    raws: list[str] = field(default_factory=list)      # raw variants that normalised to this
    sources: Counter = field(default_factory=Counter)   # source -> rows
    hits: int = 0
    langs: Counter = field(default_factory=Counter)
    urls: list[str] = field(default_factory=list)
    first_seen: int = 10**9
    stems: Counter = field(default_factory=Counter)
    topics: Counter = field(default_factory=Counter)


@dataclass
class Cluster:
    stage: str
    cluster_id: int
    canonical: str
    size: int                      # distinct phrasings
    hits: int                      # total raw hits
    sources: Counter
    samples: list[str]
    langs: Counter
    new_this_run: bool
    members: list[Phrasing]
    stems: Counter
    topic: str = "general"


def _embedder():
    from fastembed import TextEmbedding
    if not (MODEL_DIR / "model_optimized.onnx").exists():
        raise SystemExit(
            f"embedding model missing at {MODEL_DIR}\n"
            "run:  python tools/question_miner/fetch_model.py")
    return TextEmbedding(MODEL_NAME, specific_model_path=str(MODEL_DIR))


def embed(texts: list[str]) -> np.ndarray:
    m = _embedder()
    E = np.asarray(list(m.embed(texts, batch_size=128)), dtype=np.float32)
    E /= np.linalg.norm(E, axis=1, keepdims=True) + 1e-9
    return E


FULL_MAX = 4000        # full n x n agglomerative up to here (4000^2 x 8 B = 128 MB)
PART_SIZE = 1200       # target partition size above it


def _agglo(E: np.ndarray, threshold: float) -> np.ndarray:
    from sklearn.cluster import AgglomerativeClustering
    if len(E) == 1:
        return np.zeros(1, dtype=int)
    model = AgglomerativeClustering(n_clusters=None, distance_threshold=threshold,
                                    metric="cosine", linkage="average")
    return model.fit_predict(E)


def _labels(E: np.ndarray, threshold: float) -> np.ndarray:
    """Average-linkage agglomerative clustering, cut at `threshold`.

    Above FULL_MAX points the full distance matrix does not fit, and the
    tempting shortcut — a kNN connectivity graph — chains everything into one
    blob (7,780 TTC phrasings -> one cluster of 6,977 on the first run:
    every merge only ever sees short kNN edges, so nothing stops it). So
    instead: k-means into partitions of ~PART_SIZE, run the real agglomerative
    inside each partition, then stitch clusters across partitions whose
    centroids are within the same threshold. Partition borders can split a
    question in two; the stitch pass closes most of those."""
    n = len(E)
    if n <= FULL_MAX:
        return _agglo(E, threshold)

    from sklearn.cluster import MiniBatchKMeans
    k = max(2, int(np.ceil(n / PART_SIZE)))
    parts = MiniBatchKMeans(n_clusters=k, random_state=0, batch_size=2048, n_init=3).fit_predict(E)
    labels = np.full(n, -1, dtype=int)
    offset = 0
    for p in range(k):
        idx = np.where(parts == p)[0]
        if len(idx) == 0:
            continue
        sub = idx
        # a partition can still be too big for one matrix; split it once more
        if len(sub) > FULL_MAX:
            sub_parts = MiniBatchKMeans(n_clusters=int(np.ceil(len(sub) / PART_SIZE)),
                                        random_state=1, batch_size=2048, n_init=3).fit_predict(E[sub])
            for q in np.unique(sub_parts):
                s2 = sub[sub_parts == q]
                labels[s2] = _agglo(E[s2], threshold) + offset
                offset = labels.max() + 1
        else:
            labels[sub] = _agglo(E[sub], threshold) + offset
            offset = labels.max() + 1
    return _stitch(E, labels, threshold)


def _stitch(E: np.ndarray, labels: np.ndarray, threshold: float) -> np.ndarray:
    """Continue the agglomeration ACROSS partitions, with the same linkage.

    Candidate pairs come from each cluster centroid's nearest neighbours
    (cheap), but a pair is merged only if the average-linkage distance
    between the two current member sets is within `threshold` — the same
    test the in-partition step applied — and the test is re-run on the
    merged sets as they grow. The first version of this merged on centroid
    distance with plain union-find and chained 93% of a stage into one
    cluster: centroids of tight clusters sit far closer than their members
    do, and transitive merging never re-checks."""
    from sklearn.neighbors import NearestNeighbors
    ids = np.unique(labels)
    if len(ids) < 2:
        return labels
    members = {i: np.where(labels == c)[0] for i, c in enumerate(ids)}
    C = np.vstack([E[members[i]].mean(axis=0) for i in range(len(ids))])
    C /= np.linalg.norm(C, axis=1, keepdims=True) + 1e-9
    nn = NearestNeighbors(n_neighbors=min(8, len(ids)), metric="cosine").fit(C)
    dist, nbr = nn.kneighbors(C)
    cands = sorted((float(d), i, int(j)) for i in range(len(ids))
                   for d, j in zip(dist[i][1:], nbr[i][1:]) if d <= threshold and i < int(j))
    parent = list(range(len(ids)))

    def find(a):
        while parent[a] != a:
            parent[a] = parent[parent[a]]
            a = parent[a]
        return a

    merges = 0
    for _, i, j in cands:
        ri, rj = find(i), find(j)
        if ri == rj:
            continue
        a, b = members[ri], members[rj]
        avg = 1.0 - float((E[a] @ E[b].T).mean())
        if avg <= threshold:
            parent[rj] = ri
            members[ri] = np.concatenate([a, b])
            del members[rj]
            merges += 1
    if merges:
        log.info("stitched %d cluster pairs across partitions (%d candidates)", merges, len(cands))
    root_of = {c: find(i) for i, c in enumerate(ids)}
    return np.array([root_of[c] for c in labels], dtype=int)


def group_phrasings(rows: list[dict], current_run: int) -> dict[str, list[Phrasing]]:
    """rows carry: norm, stage, text, source, hits, lang, url, first_seen_run, stem."""
    by_stage: dict[str, dict[str, Phrasing]] = defaultdict(dict)
    for r in rows:
        p = by_stage[r["stage"]].setdefault(r["norm"], Phrasing(norm=r["norm"]))
        if r["text"] not in p.raws:
            p.raws.append(r["text"])
        p.sources[r["source"]] += 1
        p.hits += int(r["hits"])
        p.langs[r["lang"]] += 1
        if r.get("url"):
            p.urls.append(r["url"])
        p.first_seen = min(p.first_seen, int(r["first_seen_run"]))
        if r.get("stem"):
            p.stems[r["stem"]] += 1
        p.topics[r.get("topic", "general")] += 1
    return {s: list(d.values()) for s, d in by_stage.items()}


def _canonical(members: list[Phrasing], E: np.ndarray) -> str:
    """The raw phrasing nearest the cluster centroid, nudged towards English,
    a trailing '?', and a length a human would write as a heading."""
    c = E.mean(axis=0)
    c /= np.linalg.norm(c) + 1e-9
    best, best_score = None, -1e9
    for i, p in enumerate(members):
        sim = float(E[i] @ c)
        for raw in p.raws:
            score = sim
            score += 0.05 if raw.strip().endswith("?") else 0
            score += 0.05 if p.langs.most_common(1)[0][0] == "en" else -0.05
            L = len(raw)
            score -= 0.002 * max(0, L - 90)
            score -= 0.05 if L < 20 else 0
            score += 0.01 * min(p.hits, 5)
            if score > best_score:
                best, best_score = raw, score
    return best or members[0].raws[0]


def cluster_stage(stage: str, members: list[Phrasing], threshold: float, current_run: int,
                  id_offset: int = 0) -> list[Cluster]:
    if not members:
        return []
    log.info("%-10s embedding %d phrasings", stage, len(members))
    E = embed([p.norm for p in members])
    labels = _labels(E, threshold)
    groups: dict[int, list[int]] = defaultdict(list)
    for i, l in enumerate(labels):
        groups[int(l)].append(i)
    out: list[Cluster] = []
    for l, idx in groups.items():
        ms = [members[i] for i in idx]
        srcs, langs, stems, topics = Counter(), Counter(), Counter(), Counter()
        for p in ms:
            srcs.update(p.sources); langs.update(p.langs); stems.update(p.stems); topics.update(p.topics)
        canonical = _canonical(ms, E[idx])
        # samples: distinct raws, prefer spread across sources, skip the canonical
        samples, seen_src = [], Counter()
        for p in sorted(ms, key=lambda p: -p.hits):
            src = p.sources.most_common(1)[0][0]
            for raw in p.raws:
                if raw == canonical or raw in samples:
                    continue
                if seen_src[src] >= 3 and len(samples) >= 4:
                    continue
                samples.append(raw); seen_src[src] += 1
                break
            if len(samples) >= 6:
                break
        out.append(Cluster(
            stage=stage, cluster_id=0, canonical=canonical, size=len(ms),
            hits=sum(p.hits for p in ms), sources=srcs, samples=samples, langs=langs,
            new_this_run=all(p.first_seen == current_run for p in ms), members=ms, stems=stems,
            topic=topics.most_common(1)[0][0] if topics else "general"))
    out.sort(key=lambda c: (-c.size, -c.hits, -len(c.sources), c.canonical))
    for i, c in enumerate(out, start=1):
        c.cluster_id = id_offset + i
    log.info("%-10s %d phrasings -> %d clusters (largest %d)", stage, len(members), len(out),
             out[0].size if out else 0)
    return out


def cluster_all(rows: list[dict], threshold: float, current_run: int) -> dict[str, list[Cluster]]:
    grouped = group_phrasings(rows, current_run)
    result: dict[str, list[Cluster]] = {}
    for stage in list(STAGES) + [UNCLEAR]:
        result[stage] = cluster_stage(stage, grouped.get(stage, []), threshold, current_run)
    return result
