# Pee Safe × ParentVeda — stakeholder demo (master plan)

> **Start every chat here.** Do ONLY the next unticked item. Then: tick it (date + one line), give the
> git file list, write the next prompt. No subagents. Read only the section your item needs.
> Kept short on purpose (slimmed 2026-11-02): put detail in code comments, not here.

## Why
A meeting demo for Pee Safe stakeholders (brief: voice note
`C:\whisper\output\WhatsApp Ptt 2026-11-02 at 6.05.07 PM.txt`). Pee Safe sold **knowledge first**
across 7–8 placements: launch film on app open, articles + FAQs, a tool, notifications that lead
to a sale, a brand page, every placement **triggerable on demand**, and **one Showcase page in
You** that walks every flow in order (heading, talking points, live placement below).

## Decided (2026-11-02, the user)
P1 demo only, no database change · P2 two tracks: **A Partner Edition** (store QR families),
**B Brand Studio** (sponsored, always labelled) · P3 relevance, not stage (TTC included) ·
P4 Ask Veda out · P5 Showcase row always visible behind `kPeeSafeDemo` · P6 Premiere and brand
page get the Mobbin redesign · P7/10b video uploaded by the user · P8 one item per chat.

## Reuse (don't rebuild)
- **Brand Studio** `lib/brand/` (rules `docs/BRAND-STUDIO.md`): content only via
  `BrandStudio.resolve()`; `BrandStudioStore.demoMode` relaxes caps; campaigns in
  `brand_campaigns.dart`; `premiere_screen.dart` (fired from `main_scaffold.dart`);
  `launch_hub_screen.dart` + `BrandCreative`; `brand_notifications.dart`; `outbound.dart`;
  `presented_by.dart`, `brand_disclosure.dart`; `rank_floor.dart`; tour pattern
  `lib/screens/brand_showcase_screen.dart`. Invariants: `test/brand_studio_test.dart`.
- **Partner Edition** `lib/services/partner_brand.dart`, `widgets/partner_lockup.dart`,
  `partner_exclusive_rail.dart`, `partner_benefit_card.dart`, `services/partner_offer_store.dart`.
- **You tab** `lib/screens/profile/pv_you_screen.dart` (`PartnerBenefitsRow` ~2441).
- **Reader:** `PvReaderScreen` / `PvRead`; unknown blocks → `PvReadSection.custom`.
- **Pee Safe data (item 2):** `lib/brand/pee_safe/pee_safe_brand.dart` (`kPeeSafe`,
  `kPeeSafeDemo`, `kPeeSafeWash`, `kPeeSafeInk`), `pee_safe_products.dart` (`kPeeSafeProducts`,
  13 items, `PeeSafeMoment` tags, `peeSafeFor(moment)`, `product.open(campaign:)` via
  `openOutbound`). Assets `assets/brand/pee_safe/` (logo.png + 600px jpgs). `kPeeSafe` is **not**
  in `kBrands` yet: add it when its first campaign lands (item 3). No prices stored (stale risk);
  the store page shows the live price.

## Rules every item follows
Disclosure on every surface ("Presented by Pee Safe"; "Sponsored" on ranked items). No change to
ratings. Clinical copy ends at "see your doctor". **Lime `#B3E053` only on Pee Safe's own
surfaces** (Premiere, brand page, logo); shared surfaces stay ParentVeda ink. Our tone stays calm.
Comment out, never delete. English, line icons, no emoji. Don't run git.

## Video (item 10b)
Build with `videoRef: null` (animated fallback) until then. The user uploads a **recent** 10–30s
720p MP4 (<15 MB) to `assets/brand/pee_safe/launch.mp4`. Candidates: sanitizer ad
`youtube.com/watch?v=7x-x7RmXTMU` (dated), Menstrual Hygiene Day film (`youtube.com/peesafe`).

## Mobbin: what to adopt
- **Premiere (3):** full-bleed video, no card; Skip pill top right, Mute top left, caption over a
  bottom scrim; "Presented by Pee Safe" chip. End card: logo, one line, primary pill "See what's
  new", quiet "Not now".
- **Brand page (4):** hero with round logo overlapping its edge; name; trust line "ParentVeda
  partner"; one full-width "Visit Pee Safe store"; story prose broken by a photo; 2-column product
  grid; "Read with Pee Safe" shelf.
- **Sponsored article (5):** eyebrow "PRESENTED BY PEE SAFE" above title; one disclosure line
  after the intro; "From Pee Safe" products at the end only; brand mentions link to the brand page.
- **Product placements (7), the user 2026-11-02:** a *collab* look, the way fashion apps present a
  designer or brand collaboration (Puma × Mercedes-style): a "ParentVeda × Pee Safe" lockup, the
  Pee Safe logo in its own colour, sleek and native to the app rather than an ad. One featured
  pick only. Travel products are in (find their screen). Research on Mobbin before building
  (queries: "collaboration collection", "designer collab", "brand partnership product page").
  Lime only in the logo; the surface stays ParentVeda ink.
  *Adopted (Mobbin 2026-11-02, Doji / Zara / Yami / Klarna):* "A × B" lockup with the partner's
  round logo at the head of the block (Doji "by Doji"); a small-caps eyebrow + one plain line above
  the products (Zara "INSPIRING LOOKS"); brand name in small caps above each product name (Yami);
  the disclosure as a quiet outlined label at the right, never a banner (Klarna "Promoted").
  Declined: price badges and ranking ribbons (no prices stored; ranking is ours).
- **Showcase (10):** stack of rounded cards: preview, numbered heading + 2–3 lines, "Show me ›",
  "In the app: …". Sticky top: "ParentVeda × Pee Safe" lockup + "Reset demo".

## Checklist
| # | Item | Track | Output | Done |
|---|---|---|---|---|
| 1 | Research + this doc | — | this doc | ✓ 2026-11-02 |
| 2 | Pee Safe data: brand, 13 products, assets, `kPeeSafeDemo`, BEFORE-LAUNCH line | B | `lib/brand/pee_safe/pee_safe_brand.dart`, `pee_safe_products.dart` | ✓ 2026-11-02: analyze clean, brand_studio_test 29/29 |
| 3 | **Premiere redesign + Pee Safe launch** (Mobbin above); a Pee Safe premiere + linked launchHub campaign; "Replay" ignoring the once-per-campaign cap only under demo mode | B | `premiere_screen.dart` reworked (old UI commented out) | ✓ 2026-11-02: full-bleed + end card, `video_player` path ready for 10b; `replayPremiere()` (demo-mode gated) wired to Brand Showcase "Show me"; ids `kPeeSafePremiereId`/`kPeeSafeLaunchId`; analyze clean, brand_studio_test 29/29 |
| 4 | **Brand page** (generic per `Brand`): hero, logo, story, video, where it's used by moment, products → Buy, shelf. Reuses `BrandCreative` | A+B | `lib/brand/brand_page_screen.dart` | ✓ 2026-11-02: generic page, story/film from the brand's launch, products via `brandPageCatalogueFor` (Pee Safe only), shelf = launch resources with a `readId` (empty → invitation); route `'brand_page'` via `BrandPageScreen.route`, wired from `LaunchDetailScreen` brand link; `test/brand_page_test.dart` 4/4, brand_studio_test 29/29, analyze clean |
| 5 | **Reading shelf:** 5–6 `PvRead`s + FAQ (pregnancy discharge; UTI/toilet hygiene; postpartum bleeding and pads; peri care; periods returning; intimate hygiene while TTC) | B | reads + `sponsoredEducation` campaign | ✓ 2026-11-02: 6 reads + FAQ in `lib/brand/pee_safe/pee_safe_reads.dart` (eyebrow via new `PvRead.eyebrow`, disclosure block after intro, products via new `PvRead.footer` after the doctor callout); `_peeSafeEducation` campaign; 7 launch resources with `readId`; shelf + `LaunchDetailScreen._resource` open `openPeeSafeRead`; reads held to 350 words, not the 600 long-read floor; `test/pee_safe_reads_test.dart` 12/12, brand_page 4/4, brand_studio, reader_unification, pv_reader_renders pass; analyze clean |
| 6 | **Tool:** postpartum recovery kit checklist → products | B | tool screen + `sponsoredTool` campaign | ✓ 2026-11-02: `lib/brand/pee_safe/pee_safe_recovery_kit_screen.dart`, route `'pee_safe_recovery_kit'` via `PeeSafeRecoveryKitScreen.route()`; 8 generic items, "Why this helps" → `openPeeSafeRead`, doctor callout, then "FROM PEE SAFE" rows labelled Sponsored; ticks in `RecoveryKitTicks` (shared_preferences, device only, `reset()` for item 10); `_peeSafeKitTool` (`kPeeSafeKitToolId` / `kPeeSafeKitPlacement`); entry card on the Pee Safe brand page; `test/pee_safe_recovery_kit_test.dart` 3/3, brand_studio, brand_page, pee_safe_reads pass; no new analyze issues |
| 7 | **Product placements:** one featured pick (rank floor), hospital-bag rows, catalogue collection, travel rows; collab look (Mobbin section) | B | campaigns + catalogue | ✓ 2026-11-02: `pee_safe_collab.dart` (`PeeSafeCollabLockup`, `PeeSafeCollabShelf`, `PeeSafePlacement`); 4 campaigns on 4 keys: featured `pp_selfcare` (rating 4.5 unchanged; replaces Cetaphil's while demo on), bag V1 (the default) `hospital_bag`, collection `afterbirth` "After Birth Care" (demo-gated, 3 picks), travel `tv_essentials` (nativeDiscovery); fixed `_featuredItem` asking resolve() with no key (featured picks never resolved); `test/pee_safe_placements_test.dart` 4/4, rank_floor, brand_studio, brand_page, pee_safe_reads, recovery_kit pass; analyze clean |
| 8 | **Notifications → sale:** 2–3 (week 36 bag; postpartum day 3 peri care; travel), demo "send now" bypassing the gap only in demo mode | B | `brand_notifications.dart` hook | ✓ 2026-11-02: 3 campaigns (`kPeeSafeNotifBagId` pregnancy wk 36–40, `kPeeSafeNotifPeriId` parenting month 0 (context has months, not days), `kPeeSafeNotifTravelId` 3–24 months), each `maxImpressions: 1`, plain titles, peri copy ends "see your doctor."; taps via `openPeeSafeNotification` (`pee_safe/pee_safe_notifications.dart`) from the opener's brand branch: bag V1 / `ps_read_peri` / `tv_essentials` reco detail, else sponsor sheet; `maybeSend` takes `pregnancyWeek`, new pregnancy call site in `main_scaffold.dart` (kPeeSafeDemo); `demoSendable`/`sendNow` (kPeeSafeDemo + demoMode, skips gap + cap, records nothing), wired to Brand Showcase "Show me" #15 (cycles the 3); `test/pee_safe_notifications_test.dart` 4/4, brand_studio, phone_emoji, pee_safe_placements pass; analyze clean |
| 9 | **Partner track:** "Pee Safe store QR" demo switch; `PartnerBrand` returns a Pee Safe lockup locally; rail + offer light up | A | `partner_brand.dart` override + seed || ✓ 2026-11-02: `pee_safe/pee_safe_partner.dart` (`PeeSafeStoreQr.set/on/reset()`, `PeeSafeStoreQrSwitch`, `kPeeSafePartnerLockup` kind `'store'` + bundled logo, `kPeeSafeDemoOffer` 15%); memory-only `PartnerBrand.demoLockup` + `reset()`, `PartnerOfferStore.demoOffers`; `PartnerMark` draws `logoAsset`; store kind → "Presented by Pee Safe" on rail eyebrow, benefit card (`storeBenefitCopy`), You row; switch in Brand Studio tour; `test/pee_safe_partner_test.dart` 3/3, partner_brand, brand_studio, partner_editions_a3 pass; a2 "rail at the top" fails pre-existing (CRLF in `home_v3_screen.dart`, untouched); analyze clean |
| 10 | **Showcase in You** (numbered, voice-note order, "Reset demo") | Demo | `lib/brand/pee_safe/pee_safe_showcase_screen.dart` + row | ✓ 2026-11-02: 7 cards from const `kPeeSafeShowcaseSteps` (premiere `replayPremiere` / brand page `BrandPageScreen.route(kPeeSafe)` / shelf `openPeeSafeRead('ps_read_discharge')` / kit route / placements sheet (featured → Recommendations, bag V1 needs a pregnancy profile else toast, After Birth Care collection, `tv_essentials` detail) / `sendNow` cycling the 3 / `PeeSafeStoreQrSwitch` on the card); sticky lockup + "Reset demo" → `resetPeeSafeDemo()` (`PeeSafeStoreQr.reset` + `RecoveryKitTicks.reset`; replays and demo sends record nothing, so no `replayAll`); demo mode on in initState; You row `pv_profile_pee_safe_showcase` after `PartnerBenefitsRow`, behind `kPeeSafeDemo`, route `'pee_safe_showcase'`; `test/pee_safe_showcase_test.dart` 4/4, brand_studio 29/29, pee_safe_partner 3/3; no new analyze issues |
| 10b | **Launch film:** upload MP4, set two `videoRef`s, check play/mute/skip | B | asset + 2 refs | ✓ 2026-11-02: Pee Safe's own "Your Personal Hygiene" (YouTube `eDEeei2Oi9U`, Sep 2026; picked over two 2¼-min product films as the only one that fits 10–30 s uncut) → `assets/brand/pee_safe/launch.mp4`, 25.1 s, 1280×720 H.264/AAC, 1.7 MB; one const `kPeeSafeLaunchFilm` (`pee_safe_brand.dart`) set on the Premiere and the launch creative; folder already in pubspec; Premiere already had Mute/Skip pills + title-sequence fallback; `_BrandFilmSlot` gained a Mute button, disposes a failed controller, and no longer says "Film coming soon" when a film exists but fails (falls back to the still — the page has no animated version); both loads time out at 6 s into the fallback; `test/pee_safe_film_test.dart` 2/2, brand_studio, brand_page, pee_safe_showcase pass (39); no new analyze issues. **Owed before any real-user use:** the file was taken from YouTube for this demo only — get the master and written permission from Pee Safe. **Presenter pass (same day):** partner "Show me" now turns the store QR on and returns to You, where the offer card renders ("Your benefits" opens the employer screen, which shows no Pee Safe); the Showcase opens the bag with `forceV1` so a phone left on V2 never shows a bag without the Pee Safe rows; film card says "in every stage"; showcase test +1 (5/5), placements, partner, brand_studio pass |
| 11 | **Finish:** analyze clean, full suite (2026-11-02 run after item 6: 30 failing, visible ones are backend SQL scans — admin_actions, auth_delete_account, care_rotation, credits_truth_contract — sort out here), grep every call site, `BRAND-STUDIO.md`, PR list | — | PR-ready | ✓ 2026-11-02: full suite 33 failing; **ours, fixed (5):** `sync_reset_coverage` (kit ticks now `SyncRegistry.registerReset`: they say she is postpartum, so hers), `tap_feedback_guard` (kit "Why this helps" wrapped in `PvPress`), new Show-me test caught a real overflow in the collab card's "View in store" row (now `Flexible`, 2 cases) + its notification case (test timing); **pre-existing, not ours (28):** SQL scans of `supabase/` (admin_actions, auth_delete_account, care_rotation, credits_truth_contract ×2, doctor_referrals ×2, partner_account, phone_otp_contract, purge_removed, push_b3 ×5, push_b4 ×3, push_l1, push_l3 ×2) — demo changed no `supabase/` file; date-dependent on 2026-11-02 (`ttc_pcos_stand` +60 days crosses the year, `ttc_cycle_hub` 2 days ago is last month); source scans of untouched files (`pp_milestones_one_place`, `preg_home_pass`, `ttc_records_rebuild`, `partner_editions_a2`); `ttc_more_profile` fails with `kPeeSafeDemo` off too; `tap_feedback_guard` also counts 4 in `ask_veda_search_shell.dart` (last commit). New `test/pee_safe_showcase_show_me_test.dart` 9/9 (each "Show me" + placement row opens its route). Call sites grepped: all live; Premiere reached only via the two Showcases (off at app open since 2026-09-17). `BRAND-STUDIO.md` §15. Demo + guard tests 119 pass; analyze: no new issues (54 pre-existing, none in a Pee Safe file). **Same day, the user:** the launch film must play as the app opens (as Blinkit/Zepto/Swiggy) → `showPeeSafePremiereAtOpen`, once per phone, all three stages, cap read directly (not `kPremiereAlwaysShow`), "Reset demo" re-arms via `forgetImpressions`; Show-me test +3 (12/12), the 5 stage-shell test files 226 pass |

## Prompt template
> Pee Safe demo, item N: <name>. Read `docs/PEE-SAFE-DEMO.md` and CLAUDE.md. Do ONLY item N.
> Start from: <files>. Done when: <criteria>. Then tick it with the date, give the git file list,
> write item N+1's prompt. No subagents; save tokens.

## Verification
Per item: `test/brand_studio_test.dart` (+ `reader_unification_test.dart`, `phone_emoji_test.dart`
where touched) and no new `flutter analyze` issues. Before the device: a test that every Showcase
"Show me" opens its real screen. On the device (ask first): walk the Showcase, reset, walk again.

## Second pass (2026-11-03, the user, after the phone walk)
Dev APK hid the Brand Studio (`kPvShowDeveloper` needs `--dart-define=PV_DEV=true`) and the 47 seed
products (`PV_SEED_PRODUCTS=true`): build with both. Added: Messages rows for sent notifications in all
three stages (`brand_inbox.dart`, ParentVeda's voice, "With Pee Safe · Sponsored"); recovery kit in
Pregnancy + Parenting Tools and search, on `PregToolScaffold`; TTC hygiene card withdrawn (Tools holds
tools only); Brand Studio Pee Safe hero + chips + Pee Safe routes, off the purple; no "coming soon" on
brand pages; livelier notification copy. `test/pee_safe_integrations_test.dart` 9/9.
Dev APK: `flutter build apk --release --flavor parent --dart-define=PV_DEV=true --dart-define=PV_SEED_PRODUCTS=true`.
**Off the retired screens (same day, verified):** placements were on screens the shipped app no longer
opens. Bag rows now on `ReadyForBirthScreen` (the live bag; Showcase + bag notification open it, never
after a loss). The 13 products are in the live store via `pee_safe_store.dart` (15 rows: Maternal
Recovery, Skincare & Hygiene, Parenting · On the move; badge Sponsored, rating 0, no price, after our
own picks, not TTC); Showcase/Brand Studio/travel notification open those shelves, not the old
Recommendations screens. Parenting app-open film + `maybeSend` moved from `MyChildScreen` (V1) to
`pp_home_version.dart` (V3 ships, so neither ran). Purple ink/lavender off Showcase, kit, collab, reads,
Launch Hub, Presented-by sheet. The team sheet already holds 2 Pee Safe products as unsponsored picks;
left alone. `pee_safe_integrations_test` 13/13; analyze 54 (unchanged).

