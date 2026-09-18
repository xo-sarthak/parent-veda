# Question Miner

Finds what real people ask across the four ParentVeda stages — Trying to
Conceive, Pregnancy, Parenting, Skilling — and ranks the questions by how
often they are asked. The output is a research pool for deciding what to
write and expert-verify. It is **not** wired into the app.

**Questions only, never answers.** A question is a statement of what
someone wants to know; it carries no copyright weight. An answer is someone's
expression. So this tool reads post *titles*, URL *slugs* and search
*suggestions*, and nothing else — no comment bodies, no answer text, no
article bodies. If a collector ever needs a page body, it is out of scope.

```
python tools/question_miner/fetch_model.py      # once: the 66 MB embedding model
python tools/question_miner/run.py run          # collect all sources, then cluster + export
python tools/question_miner/run.py cluster      # re-cluster the latest collection (fast)
python tools/question_miner/run.py run --sources google_ac,ddg_ac   # a subset; others carry forward
```

Deps: `python -m pip install requests praw scikit-learn fastembed openpyxl`.
Output: `research/questions/` — see the README written there by each run.

## Pipeline

| step | file | what it does |
|---|---|---|
| collect | `qm/collectors/*` | each source → `list[Question]` in one schema; sources are independent and switchable |
| store | `qm/schema.py` | SQLite, keyed `(source, text)`; a re-run refreshes `last_seen` and marks what is new |
| filter | `qm/filter.py` | keep question-shaped strings; slug sources also admit stated concerns, with Hinglish cues |
| tag stage | `qm/stage.py` | source hint + weighted keyword rules; skilling recognised inside general sources; `unclear` allowed |
| tag topic | `qm/topic.py` | door-aligned topic within the stage (sleep / feeding / scans / coding / ...) |
| normalise | `qm/normalize.py` | one form for ages and weeks, forum shorthand expanded, filler stripped, light Hinglish→English |
| cluster | `qm/cluster.py` | bge-small embeddings, agglomerative (average linkage, cosine, threshold 0.15), **per stage**; big stages are k-means partitioned and stitched with the same linkage test |
| rank + export | `qm/export.py` | cluster size = demand; workbook + CSVs + README |

## Sources and what each one really gives

| source | how | rate | notes |
|---|---|---|---|
| `google_ac` | Google autocomplete, `gl=in` | ~0.4s/call | stem → `<why/how/is it safe…> stem`, `stem a…z`, then depth-2 on the question-shaped hits. The long tail lives here. ~400 suggestions per stem. |
| `ddg_ac` | DuckDuckGo autocomplete, `kl=in-en` | ~0.5s/call | second, independent search signal; 8 per query |
| `reddit` | PRAW (OAuth) **or** public RSS | OAuth 100/min; RSS **1/min** | titles only. Anonymous feeds are one request per clock minute per IP (measured 2026-09-18), so the RSS path is a slow fallback. Put creds in `tools/question_miner/.env` (gitignored): `REDDIT_CLIENT_ID`, `REDDIT_CLIENT_SECRET`, `REDDIT_USER_AGENT`. |
| `babychakra` | sitemap.xml slugs | 1 call | `/community/question(s)/…` — the slug is the question; a few slugs are Devanagari as code points and are decoded |
| `parentune` | `talks_all.xml` + `hi_talks.xml` slugs | 2 calls | 4,700 parent-talk titles, a lot of them Hinglish |
| `mylo` | `questions-sitemap.xml` slugs | 1 call | 169 Hindi/Hinglish questions |

Dead or blocked, checked 2026-09-18: Momspresso (TLS dead), Quora (Cloudflare
challenge), Google/Bing "People also ask" (rendered client-side, not in the
HTML), HuggingFace (connection
reset from this network — hence `fetch_model.py` via the mirror).
Semrush is deliberately not a source: its use is the user's decision, later.

## Reading the output

- **cluster_size** is the demand signal: how many *distinct phrasings* fell
  into one question. Autocomplete duplicates across expansions are counted
  separately as **total_hits**, a tie-breaker.
- **canonical_question** is the member nearest the cluster centroid, nudged
  towards English, a trailing "?", and heading length. It is a label, not a
  vote: read the samples.
- **languages** shows `hinglish`/`hi` counts. Indian users type romanised
  Hindi; the normaliser maps ~150 common words so those phrasings land near
  their English twins, but the mapping is partial and Hinglish clusters are
  smaller than they should be. The raw text is kept so the real language is
  visible.
- **unclear** is a real bucket, not a failure: nothing in the text placed it.
  Skim it once per run for cues to add to `qm/stage.py`.

## Tuning

- `--threshold` (default 0.15 cosine distance): lower = stricter = more,
  smaller clusters. Calibrated on the 2026-09-19 run: 0.22 gave topic-sized
  clusters ("implantation bleeding", 408 phrasings — when, how long, how
  much, all in one); 0.12 split one question in two ("how soon after a
  miscarriage can you try" vs "after how much time can we conceive after
  miscarriage"); 0.15 holds those together and keeps "when is the luteal
  phase" apart from "folic acid before pregnancy".
- Coverage grows in `qm/seeds.py` only. New stems, new subs, new searches.
- A wrong stage tag is a missing rule in `qm/stage.py`; a wrong topic, in
  `qm/topic.py`. Both are weighted regex lists run on the normalised text.
