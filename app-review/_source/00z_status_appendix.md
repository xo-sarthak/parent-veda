## Appendix: Status Highlights for Testers
_A quick cross-app cheat-sheet of what is Live, Mocked, Parked, or Testing-only, gathered while writing these seven references. Full detail sits in each area's PDF. "Parked" means the code and data are kept (commented out or behind a flag) for later revert, not deleted._

### Global, entry and navigation (PDF 00)
- **Due date is pinned to week 20 for testing.** The `setDueDate` calls in Splash's and Profile's auth `onDone` are commented out, so finishing onboarding does not move the app off week 20 by itself. A real due date still comes from the cloud profile or the Due Date Calculator tool.
- **Auth is partly mocked.** Sign-up, log-in, profile save and partner pairing hit real Supabase. Forgot-password / OTP / reset and all social logins are UI-only "coming soon" stubs.
- **Two testing controls remain, both flagged for removal before launch:** a "Reset to Week 20" control in Profile, and a dev-only "Mom | Dad" preview pill on the Today tab (`FatherPreview`).
- The real mother tabs are **Today, Prepare, Tools, Calendar, Community** (the header comment in `main_scaffold.dart` is stale). Profile is reached from the Today-tab avatar, not a tab.

### Today and Weekly Journey (PDF 01)
- `home_screen_b.dart` (Warm Nest) is the live Today home. `home_screen.dart` is legacy and no longer wired in.
- **Weekly Flow V2 is now the only weekly view** for all weeks; the Classic/New toggle and the swipe carousel are parked.
- Baby size view offers **Baby vs Fruit only** (default Fruit, persisted). "What's Next" tabs are Scans (default) / For you / Milestones.
- **All video surfaces are "coming soon" placeholders.** `week6_preview_screen.dart` is a static, unwired prototype. A book "Buy now" is a coming-soon mock.

### Garbh Sanskar (PDF 02)
- **Four live pillars: Shravan, Vichara, Samvad, Kriya.** The fifth, Ahara (diet), is commented out and unreachable.
- The **daily / "today" Garbh mode is parked**; in the Tools tab every pillar is a browsable library (no progress ring or streak surfaced in this build).
- Read-to-baby is folded into Samvad; the record/write composer is parked and the "Myth" strand removed (Stories and Fables remain).
- Shravan audio is a **bundled drone placeholder**, not real recordings. Content is English only despite bilingual UI chrome.

### Tools and Trackers (PDF 03)
- `tools_hub_screen.dart` is the live Tools tab; `tools_screen.dart` is dead legacy (unreachable).
- **Hospital Bag v1 is the live default;** v2 is opt-in behind a floating "Classic | New" pill (flag `hb_use_v2`).
- The **Product Checklist is a got / not-got checklist**, not the approved/rejected/partial workflow (that concept is parked).
- **Reminders: Android is fully configured; iOS notification config is incomplete,** so iOS reminders likely will not fire reliably.
- **Ask Veda is fully offline** (no LLM or network); its voice input and expert booking are "coming soon". The Scans "Care Roadmap" tab is commented out.

### Journal, Keepsakes and Journey Map (PDF 04)
- `my_baby_screen.dart` is **orphaned** (not reachable in current navigation).
- **Two note systems exist and are easy to confuse:** the rich "My Journal" (`JournalStore`) and a lighter per-week note (`MemoryStore`, used by the Journal Writer, weekly flow and finale booklet).
- Journal and Bump Journey **export / share actions are "coming soon" snackbars.** The Dear Baby Vault is read-only. The "Combined (you + Dad)" booklet is the only place father entries appear on the mother side.

### Prepare, Community, Calendar and Shop (PDF 05)
- **All Prepare commerce is mocked; there is no payment gateway.** Booking just persists a "booked" id and tells the user nothing is charged. The Prepare video player is a "coming soon" placeholder.
- **Community posting is real and functional** (text plus device photos, with cloud sync); verified-expert badges, endorsement and view counts are seeded / fictional. Doctor mode is a testing toggle.
- **Shop checkout is simulated** (marks items "bought", no real payment). Roughly half the catalog is affiliate and opens an external Amazon URL.
- Calendar is the 4th nav tab and merges milestones, journal/health logs, personal events and shared scan appointments.

### Father Mode (PDF 06)
- Entered via a **pairing code in production**, plus the testing-only "Mom | Dad" pill. Father tabs: Today, Journey (shared weekly stack), Reads, Read, Journal.
- The live father Today is `father/father_daily_screen.dart`; the older `father_home_screen.dart` is parked.
- Stories/Fables are still live via the Reads tab (60 original tales); the daily stories card and a Tools entry are commented out. The read-aloud mirrors the mother's Samvad and is read-only. The "Switch to Mom's view" sheet is dormant (no trigger).
