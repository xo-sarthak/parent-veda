# Directus setup — the runbook

Everything in `supabase/migrations/0045`–`0051` exists to be driven from
Directus, but a table is not a panel. This file is the click-by-click
configuration that turns four content tables into something a non-technical
person can publish from, and the two webhooks that make publishing actually
reach the app, the website and Ask Veda.

Work through it in order. Each section says what to do, and — more usefully —
what breaks if it is skipped.

> **Sibling files.** `docs/CONTENT-BACKEND.md` is the architecture and the
> decision log. `docs/ADMIN-PANEL.md` is the running list of everything that
> still needs the panel. This file is only the setup.

---

## 0. Before opening Directus

| Step | Why |
|---|---|
| Run `0045` … `0051` in the SQL editor, in order | Later files grant to the role `0045` creates and call the function `0046` creates |
| Run the three generated seeds (`build/seed_recipes.sql`, `seed_reads.sql`, `seed_products.sql`) | Empty tables look identical to a broken fetch. Seeded, the app keeps showing exactly what it shipped with |
| `alter role directus_cms with password '<long random>';` | The migration deliberately creates the role without one — the file is in git, and git does not forget a secret |
| Render → `parentveda-cms` → `DB_USER=directus_cms.<project-ref>`, `DB_PASSWORD=<that>` → redeploy | The pooler encodes the project in the username; this format is the usual cause of a boot failure, not the grants |

**Verify before letting anyone else log in:**

```sql
set role directus_cms;
select count(*) from public.journal_entries;   -- expect: permission denied
select count(*) from public.recipes;           -- expect: 28
reset role;
```

If the first one returns a number, stop. Nothing below matters until it does not.

---

## 1. Register the collections

Settings → Data Model → the tables appear as "uncontrolled". Register only these:

| Collection | Note |
|---|---|
| `articles` | already registered |
| `content_posts`, `content_categories` | already registered — the website's |
| `recipes` | new |
| `reads` | new |
| `products` | new |
| `veda_drafts` | Ask Veda's editorial inbox, if `sql/veda_drafts.sql` has been run |
| `veda_content_gaps` | the "what to write next" board |
| the six config tables | §4 |

**Do not register anything else.** After `0045` the user-data tables should not
even be offered — `information_schema` filters by privilege and Directus reads
it. If `profiles` or `journal_entries` *does* appear in that list, the role is
not in effect: check `DB_USER` on Render before going further.

---

## 2. Field configuration, per collection

Directus guesses an interface from the column type. The guesses are wrong in
ways that matter, and each of these has a specific failure behind it.

### Every content collection (`articles`, `recipes`, `reads`, `products`)

| Field | Interface | Why |
|---|---|---|
| `status` | **Dropdown** — `draft`, `published`, `archived` | A free-text box lets an editor type "Published". The read policy is `status = 'published'`, so the row silently never appears and the publish button looks broken. `0046` added a CHECK so the database now refuses it — the dropdown is what stops them hitting the error at all |
| `source_key` | **Read-only** | It is the identity every cross-reference in the app points at. Editing it orphans the row's relationships and lets a re-run of the seed insert a duplicate |
| `id` | **Hidden** | The uuid is Directus's business. The app never sees it |
| `hero_file` | **File** → the R2 storage folder | Uploads land in R2 and a trigger writes the public URL into `hero_image` |
| `hero_image` | **Read-only**, or hidden | Derived. Two ways to set an image means one of them is wrong and nobody knows which |
| `sort` | Input | Controls order within the type |
| `domain` | Dropdown — `pregnancy`, `parenting`, `universal` | Free text here files content where nothing reads it |
| `created_at`, `updated_at`, `published_at` | Hidden / read-only | |

Group the `_hi` fields into a **"Hinglish" tab** in the layout rather than
leaving them inline. They are a second pass, not a second thought, and mixed
into the English fields they make every form twice as long.

### `articles`

* `has_hi` — hidden (it is a generated column and cannot be written).
* Save a **filter preset named "Missing Hinglish"**: `has_hi` is `false`. That
  turns "bilingual from the first string" from a rule people forget into a
  worklist someone can pick up.

### `content_posts` (the website's)

* `category` → **Many to One** on `content_categories`, display template
  `{{name}}`.
  A dropdown was the original plan; the relation is better, because the FK
  already exists, the editor sees real names, and new categories appear on
  their own. **No migration needed** — this is purely an interface choice.
* `body` → Markdown (already set).
* `og_image_file` → File; `og_image` read-only.

### `recipes`

* `ingredients`, `steps`, `storage`, `mistakes`, `equipment` → **Repeater** of a
  single text field. They are ordered lists an editor writes line by line; a raw
  JSON box invites a syntax error that saves fine and renders as nothing.
* `nutrients` → Repeater with `name`, `amount`, `note`.
* `substitutions` → Repeater of key/value, or a JSON field if the repeater
  fights the object shape.
* `tags`, `situations`, `ingredient_keys` → **Tags**.
  ⚠️ `ingredient_keys` is a **controlled vocabulary** — the Smart Meal Builder
  only offers keys that exist in the catalogue, so an invented key matches
  nothing and simply never appears. Note that in the field description.
* `veg` / `vegan` — the CHECK enforces that vegan implies veg. Surface the
  error; do not work around it.

### `reads`

* `sections` → **Repeater**: `heading` (text), `paragraphs` (repeater of text),
  `tip` (group: title, body), `mythFact` (group: myth, fact), `image` (toggle).
  This is the article body and the reader's signature elements live in it. A
  plain JSON box is where a dropped key silently removes a myth-vs-fact card
  from a published article.
* `collection` → **Dropdown** of the `kReadCollections` ids:
  `sleep`, `brain`, `feeding`, `behaviour`, `health`, `play`, `parent`.
  Collections are Dart-owned (they carry icons), so this cannot be a relation.
  An unknown value files the article nowhere while it still looks published.
* `kind` → Dropdown: `article`, `bookSummary`, `research`.

### `products`

* `pros` / `cons` → Repeater of text. **Both.** A product with pros and no cons
  reads as an advert, and Ask Veda now grounds its answers on both halves —
  `test/products_seed_test.dart` fails if any ships one-sided.
* `specs` → Repeater of key/value.
* `spec_auto_off`, `spec_volume_lock` → **nullable toggles**. Null means "not
  checked"; false means "does not have it". If Directus renders them as a plain
  two-state switch, change it to a dropdown with an explicit empty option —
  otherwise every product silently claims to lack a safety feature nobody
  verified, on a screen built for comparing.
* `price_inr` → Input, with the field note **"whole rupees"**. Nothing is
  charged here; these are display prices linking out to a retailer.
* `rating` → 0–5, one decimal. A CHECK enforces the range.

---

## 3. Roles

Three roles, granting only what each needs. Directus permissions are a
convenience layer on top of the database grants from `0045` — helpful, but the
grants are the boundary.

| Role | Collections | Can publish? |
|---|---|---|
| **Admin** (you) | everything registered | yes |
| **Editor** | `articles`, `recipes`, `reads`, `products`, `content_posts`, `content_categories`, `veda_drafts`, `veda_content_gaps` | yes — there is no medical-review step, see below |
| **Ops** | the six config tables + read-only `care_partners`, `partner_referrals` | n/a |

Editor must **not** see the config tables or the partner records. Ops must not
see content. Neither can reach user data even if you misconfigure this, which is
the entire point of doing `0045` first.

> **No medical-reviewer role exists yet**, so the workflow is draft → published
> with nothing in between. That is why clinically-loaded content stayed bundled
> — `can_i_data.dart`, `tests_scans_reports_data.dart`, `pp_vaccine_data.dart`,
> `pp_nuskhe_data.dart`, `report_findings_data.dart`. Those are exactly the
> files an editor would most want, and exactly the ones needing sign-off first.
> Adding the states later is cheap: the public-read policy stays
> `status = 'published'` either way, so every extra state is invisible to the
> app, the website and the RAG by construction.

Turn on **Activity & Revisions** for the content collections. The day the panel
exists is the day admin acts need a trail.

---

## 4. The config collections

Register the six as **update-only** — no create, no delete. `0045` grants only
`select, update`, so Directus will fail if configured otherwise; setting it
correctly in the UI just means the buttons are not there to press.

| Collection | Holds |
|---|---|
| `referral_config` | rewards, caps, qualification rules, dates |
| `care_visibility_rules` | where and when a partner appears |
| `care_trust_messages` | the labels and welcome copy |
| `care_commission_rules` | rates, currently seeded at zero everywhere |
| `care_partner_config` | attribution window and model, token rotation |
| `wa_message_templates` | WhatsApp message copy |

Two behaviours the forms must respect:

* **`care_trust_messages` has a CHECK** rejecting sponsor/advert/promot/"ad by"
  wording. Surface that error to the editor. Do **not** work around it by
  editing `care_partners.trust` instead, which is unconstrained `jsonb` — that
  constraint is the only thing enforcing "never *Sponsored by*".
* **`care_partner_config.token_rotation`** invalidates every printed QR when
  bumped. Posters on clinic walls stop working. That needs a confirmation step,
  not a toggle — it is a physical-world action.

`test/care_partner_config_test.dart` fails if these rows drift from the values
compiled into the app, so the panel cannot silently diverge.

---

## 5. Publishing must reach three places

One write, three readers. Without these two Flows, publishing changes a row and
nothing else.

### 5a. Flow → Ask Veda (`/reindex`)

**Trigger:** Event Hook, non-blocking, `items.create` / `items.update` /
`items.delete`, on `articles`, `content_posts`, `recipes`, `reads`, `products`.

**Operation:** Webhook

```
POST  https://<askveda-host>/reindex
Header: x-reindex-secret: <REINDEX_SECRET>
Body:   {"collection":"{{$trigger.collection}}","keys":{{$trigger.keys}}}
```

`/reindex` already parses this exact shape natively — no Python change needed
for the endpoint itself. Unpublishing is handled correctly too: `reindex_source`
deletes the row's chunks, re-fetches with `.eq('status','published')`, finds
nothing, and the stale chunks stay gone.

⚠️ **The new tables are not in `SOURCE_SPECS` yet**, so a reindex call naming
`recipes` will do nothing until the AskVeda half lands (§7).

### 5b. Flow → the website (`revalidateTag`)

**Trigger:** the same events on `content_posts` and `content_categories`.

**Operation:** Webhook

```
POST  https://parentveda.in/api/revalidate
Header: x-revalidate-secret: <REVALIDATE_SECRET>
```

⚠️ **That route does not exist yet** (§6). Until it does, the site updates on
its 60-second ISR window, which is the backstop and is fine.

Point the Flow at the **production domain explicitly**. A Vercel preview URL
returns 200 and revalidates nothing anyone can see — a webhook that looks
healthy and does nothing is worse than one that fails.

### 5c. The app

Nothing to configure. It refreshes on app-resume and pull-to-refresh through
`ContentRegistry`. Do not build a push channel.

---

## 5d. The admin ACTIONS (approve a doctor, rotate a QR, run a campaign)

These are not table edits and must not be built as them. `0051` provides five
`security definer` functions, each granted to `service_role` alone — so the
doctor app and the parent app cannot call them regardless of how Directus is
configured. Every call, allowed or refused, writes `admin_audit`.

**Register two more collections:**

| Collection | Role | Note |
|---|---|---|
| `care_partner_verification` | Ops | The paperwork. Private table — never public-read |
| `admin_audit_log` (**the view**) | Admin, read-only | Register the VIEW, never `admin_audit` itself. Granting the table would give the panel a path to editing the record of its own actions |

**The flow shape.** A Directus Flow cannot call a Postgres function directly,
and the sandboxed Run Script operation has network restrictions. Use a
manual-trigger Flow with a Webhook operation:

```
POST https://<project>.supabase.co/rest/v1/rpc/approve_care_partner
Headers: apikey: <service_role>, Authorization: Bearer <service_role>
Body:    {"p_partner_id":"{{$trigger.body.keys[0]}}",
          "p_actor":"{{$accountability.user}}",
          "p_note":"..."}
```

Pass `$accountability.user` as the actor, so the audit row names a human rather
than "unknown".

⚠️ **The Flow must assert on the response.** A refusal comes back as a PostgREST
error, and a Flow that ignores it looks exactly like success — the same failure
mode as the app's fire-and-forget writes. If a Flow reports a green tick for a
refused approval, the panel is actively lying to whoever clicked it.

| Flow | Function | What it refuses |
|---|---|---|
| Approve partner | `approve_care_partner` | Missing verification record; blank council / registration / KYC; expired registration |
| Deactivate partner | `deactivate_care_partner` | Soft only — attribution and ledger history survive |
| New campaign | `create_partner_campaign` | A partner who is not `active` |
| Rotate QR codes | `rotate_partner_tokens` | Unless the partner id is **retyped** as confirmation — this invalidates every printed poster |
| Remove demo partners | `remove_demo_partners` | If any demo partner has acquired a real attribution or ledger row |

**Approval order matters.** Fill in `care_partner_verification` first, then run
the approval Flow. Doing it the other way round just produces a refusal, which is
the intended behaviour but a confusing first experience — put the verification
form next to the approve button in the layout.

---

## 6. Cross-repo handoff — the website (`C:\parentveda-web`)

New file, and it creates the folder: the site has no `src/app/api/**` at all.

**`src/app/api/revalidate/route.ts`**

```ts
import { revalidateTag } from "next/cache";
import { CONTENT_TAG } from "@/lib/supabase";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function POST(req: Request) {
  const got  = req.headers.get("x-revalidate-secret") ?? "";
  const want = process.env.REVALIDATE_SECRET ?? "";
  if (!want || got !== want) return new Response("unauthorized", { status: 401 });

  revalidateTag(CONTENT_TAG);
  return Response.json({ ok: true });
}
```

Why it is this short: `CONTENT_TAG` is **already exported** from
`src/lib/supabase.ts` and **already attached to every content fetch** via the
injected `next: { tags: [CONTENT_TAG] }`. The hook was built; only the caller
was missing.

Notes for whoever picks this up:

* **Flush the tag; do not resolve slugs.** Directus sends ids, not slugs, and
  resolving them adds a query and a failure mode. A tag flush costs one cold
  render per affected route.
* **Keep `CONTENT_REVALIDATE = 60`.** On-demand is the fast path; the ISR window
  is the backstop for a dropped webhook. Setting it to `false` means one missed
  webhook freezes the site indefinitely.
* Add `REVALIDATE_SECRET` to Vercel (all environments) and to the Flow header.
* **The site is on Next 16.2.9.** The `fetch({next:{tags}})` + `revalidateTag`
  pairing in use is the correct one, but Next 16's `cacheComponents` / `use
  cache` model has a *different* tag API (`cacheTag`). Verify against the 16.2
  docs and do not mix the two.

---

## 7. Cross-repo handoff — Ask Veda (`C:\Projects\parentveda-askveda`)

Two changes, and the second is the one that will bite.

### 7a. Add the new tables to `SOURCE_SPECS`

`ingest/ingest.py` maps a source table to its chunk metadata; adding one is a
single entry, by design. Needed for `recipes`, `reads`, `products` — select the
columns worth embedding (title, the teaching prose, and for products **both**
`pros` and `cons`).

### 7b. Hinglish will silently stop being searchable

`tool/export_ttc_corpus.dart` deliberately emits each item **twice** — an `_hi`
twin — because `ingest.py` embeds only the `body` column. A live table read
through the standard `SOURCE_SPECS` path emits **one** chunk set, from `body`.

So the moment a bilingual type is served from its table, **Hinglish retrieval
dies with no error anywhere and no test that catches it.** The fix is a second
pass over `body_hi`, which needs a `lang` dimension in the
`(source_table, source_id, chunk_index)` upsert key.

### 7c. Then, and only then, flip ownership

Three things in one window, or none:

1. `lib/services/content_ownership.dart` — the entry → `ContentOwner.editor`
2. the `SOURCE_SPECS` entry above
3. **delete that type's old `veda_knowledge` rows by `doc_id` prefix**

Skip (3) and retrieval holds two copies of the same knowledge — one live, one
frozen — and Ask Veda answers from whichever scores higher.

**Recipes has a wrinkle.** Ask Veda's recipe docs come from `kRecipes` in
`pp_recipes_data.dart` — the *legacy* list — not from `kFoodRecipes`, which is
what the `recipes` table holds. Flipping ownership stops the export emitting the
legacy docs, so the table must be in `SOURCE_SPECS` in the same window or the
RAG loses every dish it knows and gains nothing. The upside: it retires a shim
that exists only to feed the RAG, and upgrades Ask Veda from thin legacy entries
to 28 dishes carrying the *why*, nutrients, storage and common mistakes.

`test/recipes_seed_test.dart`, `reads_seed_test.dart` and
`products_seed_test.dart` each assert their type is still `bundled`, so the flip
cannot happen by halves. Change those expectations in the same commit as the
AskVeda work, never before.

---

## 8. Verify end to end

Per type, once configured:

1. Edit a title in Directus → **app** shows it after backgrounding and
   reopening; **website** within seconds of the revalidate hook; **Ask Veda**
   cites it after the reindex.
2. **Unpublish a row and confirm it disappears from the app.** This is the
   defect the engine rewrite fixed — the old store discarded a successful empty
   fetch, so unpublishing could never remove anything.
3. Set `status` to something invalid → the database refuses it.
4. Sign in as the **Editor** role and confirm no user-data table is reachable,
   and that none appears in the collection-registration list.
5. Upload an image → `hero_image` fills with an **R2** URL, not a
   `parentveda-cms.onrender.com/assets/...` one. If it is the latter, every
   image request is waking your sleeping free-tier box, and Directus has quietly
   become a user-facing CDN.
