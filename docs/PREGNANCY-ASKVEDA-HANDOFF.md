# Ask Veda × Pregnancy — handoff

**Written:** 2026-10-02
**For:** whoever runs the import and deploys the service (the user), and the next
terminal that touches `C:\Projects\parentveda-askveda`.
**Pattern:** the one TTC got (`docs/TTC-ASKVEDA-HANDOFF.md`, STILL-OPEN §79), for
pregnancy. Read that for the why; this is what was built and what you run.

> Ask Veda is the pregnancy side's **search as well as its answers**. A question is
> answered from pregnancy content, and the cards under the answer open the real
> read, door card or tool in the app, so it is also the way into the app.

---

## What was wrong

| | Before | Now |
|---|---|---|
| The request | week and language only; the service could not tell this side from any other | also `stage: "pregnancy"` |
| What it could ground on | the older offline corpus (can-I, symptoms, products, weekly articles) | that **plus** 152 reads, 468 questions, 279 door cards and 14 tools |
| What a card did | product and film were handled; everything else opened a text sheet | a `pv…` card opens the read, the door card or the tool |
| Offline | "connect to the internet" and nothing | the same, plus the app's own matches, which work without a signal |
| Scope | unscoped: a pregnancy question could be answered from, and point to, any stage | pregnancy content only |

The new content did not exist for Ask Veda at all: the doors, the 150+ reads, the
partner reads and the week guide were all built after the corpus was exported.

---

## The two-repo contract

The wire body is a contract across both repos. **Adding a field on one side alone
does nothing**, and nothing says so on the app side (`timing_ownership` was sent
for days and discarded). So:

| Field | App (`ask_veda_screen.dart`) | Service |
|---|---|---|
| `stage: "pregnancy"` | sent on every question | `app/answer.py` `scope_domain` → domain `pregnancy`; `app/cache.py` `stage_key_for` → keys `pw20:s1`, `ptsecond:s1`, `p:s1` |

**Until the service is deployed, the app half is inert**: the service already
declares `stage`, but only TTC was scoped on it. An older app build that sends only
a week keeps its old, unscoped behaviour and its old cache key, by design.

### What scoping costs, said plainly
As for TTC: a pregnancy question about newborn feeding or about trying to conceive
now finds no pregnancy content, logs a **gap**, and goes to the trusted-web
fallback. The gain is that every "open in the app" pointer lands on her own side of
the app. Parenting is **not** scoped (it keeps the old behaviour until its own pass).

---

## Document ids (the namespace)

Made in one place, `lib/ask_veda/pv_veda_links.dart`, which is also where they are
resolved back into a screen.

| Id | What | Opens |
|---|---|---|
| `pvread_<readId>` | a long read | the reader on that read |
| `pvfaq_<readId>_<n>` | one question and answer from a read, its own small document | the read it came from |
| `pvdoor_<bracketId>` | a door as a whole (what it is, its tabs, its warning signs) | that door |
| `pvdoor_<bracketId>__<slug>` | one card on a door that is not itself a read | what the card opens |
| `pvtool_<toolId>` | a tool on the Tools list | the tool |

* **None is kind `read`.** `read` is the editor-owned reads table
  (`content_ownership.dart`) and the export ratchet would silently skip every
  document of that kind. TTC hit exactly this and named its kind `ttcread`.
* **Every id starts `pv`**, so the service can prune exactly this namespace.
* **A card that is not made yet is never a document.** The answer would point at a
  card that does nothing.
* **The clinical half is exported with the rest:** a read's "when to see someone"
  and evidence line are in its body; a door tab's pinned warning signs are in the
  door's document.
* **English only**, by the current rule. The older pregnancy documents keep their
  own Hindi twins untouched.

`test/pv_veda_links_test.dart` round-trips **every** exported id through the
resolver, so a half cannot change alone, and pumps the Tools list to check the
exported tool titles are the ones on it.

---

## What to run (in this order)

You run the Supabase steps. Nothing below touches the database until you do.

```
# 1. The app repo: write the corpus (about 900 documents, 1.2 MB).
cd C:\Projects\parentveda
flutter test tool/export_pregnancy_corpus.dart

# 2. The Ask Veda repo: import it, then embed.
cd C:\Projects\parentveda-askveda
.venv\Scripts\activate
python -m ingest.import_corpus C:/Projects/parentveda/build/pregnancy_corpus.json --prune-prefix pv
python -m ingest.ingest

# 3. Deploy the service (scope_domain + the cache key), THEN ship the app build.
```

> ⚠️ **`--prune-prefix pv`, never a plain `--prune`.** These documents share the
> `pregnancy` domain with the older offline corpus. A plain `--prune` deletes every
> older document the new file does not contain (can-I, symptoms, products, weekly
> articles). The prefix limits the prune to ids starting `pv`, which only this
> export makes. (`--prune-prefix` is new in `ingest/import_corpus.py`.)

`ingest.ingest` re-embeds everything and is idempotent. It skips, loudly, a table
the service role cannot read (the three `service_role` grants in `askveda.md` are
still owed for recipes, reads and products).

**Order matters in one place only:** import and embed **before** deploying the
scoped service, so that on the day scoping starts the new content is already in
the pool.

---

## Service-side changes (uncommitted in `parentveda-askveda`)

| File | Change |
|---|---|
| `app/answer.py` | `_STAGE_DOMAINS["pregnancy"] = "pregnancy"`; docstring says why |
| `app/cache.py` | pregnancy key gets `:s1` only when `stage == "pregnancy"` |
| `ingest/import_corpus.py` | `--prune-prefix PREFIX` |
| `tests/test_stage_scope.py` | pregnancy scoped; an older build stays unscoped; keys; parenting and TTC untouched |

148 service tests pass. Commit those four files in that repo.

---

## App-side changes

| File | Change |
|---|---|
| `lib/ask_veda/pv_veda_links.dart` | ids, the tool table, `openPvVedaDoc`, `pvVedaDocResolves` |
| `lib/ask_veda/pv_veda_corpus.dart` | builds the documents |
| `tool/export_pregnancy_corpus.dart` | writes `build/pregnancy_corpus.json` |
| `lib/screens/tools/ask_veda_screen.dart` | sends `stage`; a card opens the real page; the app's own matches fill "More information" and show offline |
| `test/pv_veda_links_test.dart`, `test/pv_ask_veda_pregnancy_test.dart` | the claims above |

---

## Things to know

1. **The reads are not clinician-reviewed.** Every pregnancy read carries
   `reviewed: false` today. Ask Veda will ground answers in them, as it grounds TTC
   answers in TTC's. The service's truth hierarchy and "never a diagnosis" rules
   still apply, but the source text has not had a clinician's sign-off. Worth a
   decision before launch (the same one as the "Reviewed by" ticks, STILL-OPEN).
2. **Privacy:** the app sends the week and the stage, nothing else about her. The
   richer pregnancy context (twins, a loss, a clinic-set due date) is **not**
   sent: those need a new field on both sides and a decision about each.
3. **WhatsApp** sends no stage, so it stays unscoped.
4. **The floating Ask Veda button is hidden** and is not part of this.
5. `ttc_checklist` is still sent by the app and not yet declared by the service
   (`docs/ASKVEDA-CHECKLIST-HANDOVER.md`); unrelated to this pass.

## Not done, on purpose
* **Hindi twins** of the new documents (new work is English).
* **Red-flag phrases** for pregnancy: the service's existing list already covers
  pregnancy and parenting; nothing new was added.
* **Parenting's own scoping pass.**
