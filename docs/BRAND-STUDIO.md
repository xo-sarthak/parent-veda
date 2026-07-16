# ParentVeda Brand Studio — Architecture

> Status: Phase 1 implemented (foundation + Premiere + Launch Hub). Phases 2–4 designed, not built.
> Last updated: 2026-07-15

This is not an advertising platform. It is a brand **partnership** platform.
The distinction is architectural, not aspirational — it is enforced by the
structures below and pinned by tests in `test/brand_studio_test.dart`.

---

## 1. The one rule

**Brand content enters the UI through exactly one door: `BrandStudio.resolve()`.**

No screen constructs a sponsored widget directly. No screen imports a campaign
list. A surface that wants brand content asks the resolver for a *slot*, and
gets back either a campaign or `null`. This is what makes "no banners sprinkled
through the app" a property of the system rather than a promise we have to keep
remembering.

If you find yourself reaching for `kBrandCampaigns` inside a screen, stop — that
is the bug.

## 2. The order that must never reverse

```
Education  →  Confidence  →  Recommendation  →  Commerce
```

Encoded concretely:
- A slot may only exist on a surface where the parent is **already** learning or
  deciding. There is no slot on a bare Home feed, no slot on a splash screen.
- `BrandSlot` is a closed enum. Adding a placement is a deliberate, reviewable
  act — not something that happens by dropping a widget into a build method.

## 3. The reduction: 15 products → 4 archetypes

The brief names 15 brand products. They are 4 shapes. This is the reduction that
makes the system reusable instead of 15 bespoke ad units.

| Archetype | Products | Contract |
|---|---|---|
| **Takeover** | 1 Premiere | Full-screen, once per *campaign*, 3–6× a year. The only interruption we permit, and it is rare, beautiful, and skippable. |
| **Destination** | 2 Launch Hub | A place parents choose to visit. Never pushed. Revisitable forever. |
| **Presented-by** | 3 Education, 4 Product Guide, 6 Compare, 7 Journeys, 8 Tools, 10 Live, 11 Community, 13 Milestones | ParentVeda's content, a brand's funding, a visible attribution. The brand pays for the *existence* of the thing, never its *contents*. |
| **Ranked inventory** | 5 Featured recos, 9 Collections, 12 Sampling, 14 Native discovery, 15 Notifications | Entry into a curated or ranked list, gated by a quality floor and a rank floor. |

`BrandSlot.archetype` returns the shape; the archetype determines the contract
the resolver enforces.

## 4. Domain model (`lib/brand/brand_models.dart`)

```
Brand          id, name, colour, logo, certified, landingUrl   ← the missing spine
BrandCampaign  id, brand, slot, creative, schedule, audience, maxImpressions, disclosure
BrandCreative  headline, story, videoRef, image, cta, highlights, resources
BrandSchedule  start, end          → isLiveAt(now)
BrandAudience  stage, signals, childAgeMonths range, pregnancyWeek range → matches(ctx)
BrandContext   stage, pregnancyWeek, childAgeMonths, signals, now   ← a snapshot, captured once
```

**Why `Brand` matters:** today `PromoSlide.brand`, `PpProduct.brand`,
`PpProduct.retailer`, `PpDeal.retailer` and `_Cat.brand` are five unrelated
strings with no shared identity. Campaign analytics, certification and
commerce all require one ID space. `Brand` is it. Existing models are not
migrated yet (Phase 4) — but new brand surfaces use `Brand` from day one.

## 5. Targeting — relevance, never volume

`BrandAudience.matches(BrandContext)` can only ever **narrow** eligibility.

The precise guarantee took a failing test to get right, and the distinction is
worth stating carefully, because the naive version of this rule is false:

- **Pushed** content (takeover, notification, ranked inventory) is delivered to a
  parent whether they asked or not. Its volume must not grow with what we know.
  The structural defence is that `resolve()` returns **one** campaign per slot —
  so three differently-targeted Premieres cannot stack into three interruptions
  for the parent who told us most. Caps live on the campaign; no audience field
  can raise one.
- **Pulled** content (the Launch Hub) is a place a parent opens deliberately.
  There, more relevant launches is the entire point — a breastfeeding mother
  *should* find the nursing launch. Nothing is delivered to anyone.

So the enforced rule is: **personalization narrows a fixed, commercially-sold
catalogue. It cannot invent a campaign, and it cannot raise a cap.** The volume
ceiling is set by what was sold, never by what we learned about a family.

Targeting also **fails closed**: an unknown age or an unspoken feeding method
matches nothing. Silence costs a parent nothing.

`BrandContext.capture()` reads the singletons (`FamilyProfileStore`,
`ChildProfileStore`) and flattens them to a `Set<String>` of signals
(`feeding.name`, `condition.name`, `priority.name`). Pregnancy week is passed in
explicitly, because `PregnancyController` is deliberately **not** a singleton —
it is constructed in `main.dart` and handed down.

Targeting reads the profile. It never gates navigation, hides a feature, or
renames a section — the Personalization Engine's existing guardrail
(`pp_family_profile.dart:7-11`) applies here unchanged.

## 6. Disclosure standard

Every brand surface renders `SponsorDisclosure`. Not "should" — the resolver
hands back a campaign whose `disclosure` string is non-empty by construction
(asserted in the constructor), and the invariant test walks every campaign.

- Takeover / Destination: `Presented by <Brand>` — visible without scrolling.
- Presented-by: `Presented by <Brand>` adjacent to the section heading, plus
  `<Brand> funded this. They did not write it.` on the detail.
- Ranked inventory: `Sponsored` on the item itself, never only in a legend.

Wording is centralized. A brand may not supply its own disclosure text.

## 7. Editorial integrity — the invariants

These are `test/brand_studio_test.dart`, not prose:

1. **Slot isolation** — `resolve(slot)` never returns a campaign declared for another slot.
2. **Once per campaign** — Premiere resolves `null` after one recorded impression, and it *persists* (see §8).
3. **Targeting narrows** — a campaign with an audience does not resolve for a context lacking it.
4. **Personalization ≠ more ads** — a rich profile cannot stack takeovers (one per slot, ever); a cap belongs to the campaign, not the profile; targeting can only narrow a fixed catalogue. The Hub's deliberate exemption is itself pinned by a test, so the exception stays a decision rather than a drift.
5. **Kill switch** — `BrandStudio.enabled = false` empties every slot, globally.
6. **Schedule** — expired and not-yet-started campaigns never resolve.
7. **Ratings are untouchable** — `ProductGuide.parentScore` / `parentsPct` / `expertsPct` are byte-identical with the Studio on, off, and with a live campaign for that exact brand. These derive only from `rating` + `reco`, both hand-seeded editorial fields; a sponsor field must never be read by `_adj`.
8. **Disclosure always** — every campaign carries a non-empty disclosure.
9. **Research pages stay clean** — no `BrandSlot` resolves on a Product Guide research surface. See §11.

### The rank floor (Phase 3, specified now)

A sponsored item may enter a ranked list **only** at a position that respects the
organic score. It is never given a score bonus — scoring stays commercially
blind. The insertion is post-rank:

```dart
// never above an organic item that scores higher; never slot 0
final promoScore = _score(promo, ctx);
final i = organic.indexWhere((r) => _score(r, ctx) < promoScore);
final at = i < 0 ? organic.length : i.clamp(1, organic.length);
```

`pp_reco_data.dart::_score` has no commercial term today and must keep none.
Deals already model the right instinct: a separate, labelled, bottom-mounted
rail *outside* the ranked list (`reco_common.dart::recoDealsSection`).

### Pushed vs pulled — what gets capped

Frequency caps apply to **pushed** archetypes only (`takeover`, `rankedInventory`).
A destination the parent opened, and a presented-by line on a tool they chose to
use, are attribution rather than interruption — capping those would make the
disclosure vanish mid-use, which is strictly worse for the parent than seeing
who funded the thing. `BrandArchetypeX.isPushed` encodes it.

### Placement keys

A slot alone is too coarse for presented-by and ranked inventory: without a
`placementKey`, buying "tool sponsorship" would brand *every* tool in the app.
Campaigns name their exact placement (`sleep_journey`, a `ReadCollection.id`),
matched exactly — so a campaign can never leak onto a surface it did not name.

## 8. Campaign lifecycle

```
draft → scheduled → live → capped/expired → archived
```

- **Scheduling**: `BrandSchedule.isLiveAt(now)`. `now` is injectable for tests.
- **Frequency**: `BrandStudioStore` persists `impressions[campaignId]` via
  `CloudSyncedStore`, so caps survive reinstall and follow the parent across
  devices. The old `launch_promo` guard was an in-memory bool that reset every
  process start — "once per campaign" was never actually true. It is now.
- **Expiry**: a campaign past `end` resolves `null` forever; creative stays in
  the repo for the Launch Hub archive.
- **Kill switch**: `kBrandStudioEnabled` (compile-time) + `BrandStudio.enabled`
  (runtime, listenable). Studio is auto-disabled under widget tests.

## 9. Analytics (`lib/brand/brand_analytics.dart`)

Mirrors the proven `PvVideoAnalytics` sink pattern — swap the sink for Supabase
later without touching a call site.

```dart
BrandAnalytics.instance.setSink(SupabaseBrandSink());   // one line, later
BrandAnalytics.instance.fire(BrandAnalyticsRecord(...));
```

Events: `impression, opened, dismissed, completed, ctaTapped, videoStarted,
videoMilestone, videoCompleted, hubOpened, resourceOpened, productOpened,
wishlistSaved, compareOpened, purchaseClicked`.

Campaign ROI is derived downstream from these; the app emits facts, not metrics.

## 10. Commerce — `lib/brand/outbound.dart`

`openOutbound(url, campaign:, productId:)` is the single door out of the app.
It appends the partner tag for that retailer, fires `purchaseClicked`, and
no-ops safely on a bad url.

**`kPartnerTags` is empty until real affiliate accounts exist.** An empty map
means links go out clean — exactly today's behaviour — so this changes nothing
until there is a tag to add. Filling in one entry switches on attribution for
that retailer everywhere at once. Before this existed, every "affiliate" link in
the app was a bare retailer *search* url with no tag: the app has been sending
real purchase traffic to retailers and earning nothing from any of it, because
there was nowhere to put the tag.

Deliberately **not** a redirect through our own server: a parent tapping "Buy on
Amazon" should land on Amazon, not on a tracker that forwards them. Tagging only
ever adds query params and never changes the host — pinned by a test. It also
never overwrites a param the url already carries: if a brand hands us a deep
link with its own tracking, that is theirs.

Brand surfaces (Premiere, Launch Hub) route through it now. The ~10 legacy
`url_launcher` call sites in product/checklist/reads screens still call directly
and should be migrated — mechanical, no behaviour change while the tag map is
empty.

## 11. Open conflict — needs a ruling

**Brand Product 4 (Product Guide Sponsorship) contradicts shipped copy.**

`post_pregnancy_home.dart:525` promises parents:

> "Sponsored & affiliate picks — always labelled, and never on your research pages."

A Product Guide is a research page by that definition. Product 4 asks to sponsor
its expert videos and Research Corner. Options:

- **(a)** Honour the promise: no sponsorship inside Product Guides. Sell the
  adjacent Launch Hub / Education slots instead. *Recommended.*
- **(b)** Narrow the promise to "never influences ratings or rankings" and change
  the shipped copy — deliberately, in the open.
- **(c)** Allow only `byMaker`-style labelled first-party research, which the
  Guide already supports and already weights below independent work.

Until ruled, invariant #9 holds the line and no Product Guide slot exists.

## 12. Phasing

- **Phase 1 (done)** — foundation: models, context, resolver, store, analytics,
  disclosure, kill switch, invariant tests. Products 1 (Premiere) + 2 (Launch Hub).
  Old `launch_promo` retired behind a flag, kept for revert. Launch Hub's front
  door is a Tools tile in both apps.
- **Phase 2 (done)** — Presented-by archetype + the reusable `PresentedBy`
  widget and sponsor-explainer sheet. Wired: 3 Education (parenting Learn
  collections), 8 Tools (sleep journey), 13 Milestones (development journey),
  11 Community (replacing a hardcoded brand card that bypassed the resolver
  entirely), 10 Live (Prepare hub).
  - **7 Journeys — not built, no host.** The parenting "journeys" are ambient
    trackers: no start date, no day counter, no enrolment. A "30-Day
    Breastfeeding Journey" has nothing to attach to. The model must exist
    before the sponsorship can. `BrandSlot.sponsoredJourney.isLive == false`.
  - **4 Product Guide, 6 Compare — PARKED.** Both are research surfaces; see §11.
- **Phase 3 (in progress)** — Ranked inventory.
  - **5 Featured recos — done.** `lib/brand/rank_floor.dart`, wired into
    `recommendedToday()` *after* `_ranked`, never inside `_score`. Labelled on
    the item via `SponsoredTag`. Proven exhaustively and against the live engine.
  - **9 Collections — done.** `RecoCollectionScreen`; ParentVeda still picks
    every item, and the picks do not change.
  - Remaining: 14 Native discovery, 12 Sampling (needs an eligibility +
    registration + feedback flow), 15 Notifications
    (`sponsoredNotification.isLive == false` — needs the notification seam).
- **Phase 4 (in progress)**
  - **Commerce — done.** `outbound.dart`; see §10. Tag map empty by design.
  - **Certified — done, and deliberately inert.** See §13.
  - Remaining: `Brand` migration across `PpProduct`/`PpDeal`/hospital bag (four
    unrelated representations, no shared id space), migrating the ~10 legacy
    `url_launcher` sites onto `openOutbound`, Supabase analytics sink, remote
    campaign config.

## 14. Guided journeys — a note on order

`BrandSlot.sponsoredJourney` was blocked for a while because the app had no
day-N-of-M concept to sponsor: the existing "journeys" are ambient trackers with
no start, no day counter and no enrolment.

The fix was to build the feature first (`pp_journeys_data.dart` +
`journeys_screen.dart`, parenting Explore) as something a parent would want with
no brand attached — self-paced, nothing locked, no streaks, and an escalation
line naming a real person on every day that touches a medical edge. The
sponsorship is one line on top, and a test asserts the journey renders fully
with no sponsor at all.

That order is the general rule: if a placement has no host, the answer is a
product decision about whether the host is worth building — never a thinner
version of the sponsorship.

## 13. ParentVeda Certified — architecture only

Designed, not built, and deliberately inert: `Brand.certified` exists and is
never settable from campaign data. Certification is an editorial judgement with
an independent evaluation and a published methodology. **It is not for sale.**
The field is on `Brand`, not `BrandCampaign`, precisely so a campaign can never
confer it.
