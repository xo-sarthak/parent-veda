# T4: TTC treatment and records

## Context
Family T4 of the tools pass (`00-MASTER.md`) covers five tools: **Treatment cycle, Medication (the `MedicineStore` it shares with Pregnancy), Records and reports, Appointments, Semen report**. It also takes **TTC-GAP 25**, which Terminal A handed over on 2026-10-28: the round screen's title (`ttc_treatment_screen.dart:1591`) never names today's step. T4 waits on nothing from Terminal A.

The audit was read-only, on 2026-10-29. Three helpers read the code against the 8-point checklist (`docs/pp-tool-plans/00-MASTER.md:19-28`). The lead checked every Broken and Wrong claim at its file:line, and folded two claims into others (the "shared with him" read into B1, the Semen report's filing into W10). The user answered the four genuine questions the same day.

**The build runs in a new terminal.** Read this whole file first, then "Build waves". Every file:line below was true on 2026-10-29. If lines have moved, find them again by the quoted text.

Files the build touches. None were dirty on 2026-10-29; other terminals had door-relevance docs, `journey_milestones.dart` and `veda_index.dart` open. **Run `git status` before each edit.**
- **Treatment:** `lib/ttc/ttc_treatment_store.dart`, `ttc_treatment_round.dart`, `ttc_treatment_content.dart`; `lib/screens/ttc/ttc_treatment_screen.dart`, `ttc_treatment_round_screens.dart`, `ttc_round_strings.dart`. Reads (not door files): `lib/ttc/reads/ttc_reads_age.dart`, `ttc_reads_ivf.dart`.
- **Medication:** `lib/services/notification_service.dart` (the medication scheduler only), `lib/services/medicine_store.dart`, `lib/screens/ttc/ttc_medication_screen.dart`, `ttc_dose_parts.dart`, `ttc_strings.dart` (the hint), `ttc_tools_screen.dart` (**one entry in `kTtcHisToolIds` only**, Q3).
- **Records:** `lib/ttc/ttc_records_store.dart`, `lib/screens/ttc/ttc_records_v2.dart`, `ttc_record_edit_screen.dart`, `ttc_records_screen.dart`.
- **Appointments:** `lib/screens/ttc/ttc_appointments_screen.dart`, `lib/screens/ttc/ttc_calendar_screen.dart` (the clinic-and-visit match only).
- **Semen report:** `lib/ttc/ttc_semen_reading.dart`, `ttc_semen_limits.dart` (comment only), `lib/screens/ttc/ttc_semen_report_screen.dart`, `lib/services/ttc_surfaces.dart` (one id).
- **Migration:** one new file, `supabase/migrations/01xx_ttc_records_files_and_own_writes.sql`. Take the next free number at build time; 0126 was the latest on 2026-10-29.
- **Tests:** a new `test/ttc_t4_treatment_records_test.dart`, plus updates wherever an existing test pins old copy. `test/ttc_his_side_test.dart:524-532` pins W13's wording.

## Out of scope, said plainly
- **The Semen report's Tools row and its place in his set** go to **C1** with its test, like T2's and T3's rows. The only Tools edit in T4 is Q3's `'medication'` entry in `kTtcHisToolIds`.
- **Ask Veda medication context** (no medications field on the wire today, `ask_veda_service.dart:229-251`) is recorded, not built. It is a two-repo change and needs access to `parentveda-askveda`.
- **A follicle-size field on the round:** not built. W4 corrects the read's promise instead.
- **Extra semen numbers** (volume 1.4 mL, total 39 M, vitality 54%, pH 7.2) are recorded, not built. The tool keeps its four lines, and W13 corrects the wording.
- **A kept semen result feeding the doctor check's `partnerConcern`:** not done. Our own reading must not move a clinical route, so the check keeps asking her.
- **`kPrecheckFromRecords` reading Records** (a filed AMH or TSH ticking "baseline tests"): recorded, not built. This is the same principle as T3 W12: a name match is evidence, not a tick.
- **The four known TTC test fails** are not T4's: the door photos and ids for the PCOS circle and the Loss room, "Others who have been here" in the loss reads, and "What you're working on" twice on the Tools tab.
- **Hindi:** new copy is English. Existing `_t` pairs and the Latin-script `t.treatmentIntro` stay as they are.
- **Door files** (`lib/ttc/focus/ttc_focus_*.dart`, `pv_door_*.dart`, `pv_door_router.dart`) belong to Terminal A. W8 and the name lines go on the hand-over list below.

## Findings (checked)
### Broken
| # | Finding | Where |
|---|---|---|
| B1 | Couple sync on the round. `pullFromCloud` decodes only when the local copy is empty, and then takes `rows.first` from `fetchShared(..., orderBy: 'updated_at')`, which returns both partners' rows and never prefers either. Every launch then pushes this phone's copy stamped `updated_at: now`, so his row is usually the newest. **If she reinstalls or changes phones, she pulls his stale copy, and her next push writes it over her own row, history included.** His phone also stops seeing her edits once it holds a copy. | `ttc_treatment_store.dart:860-889`; `ttc_sync.dart:221-225`; `supabase_repo.dart:114-122` |
| B2 | Following from B1: his phone arms "Time to take your trigger injection" from its stale copy, even after she has ticked it taken. The alert also says "your injection" to him. | `ttc_treatment_store.dart:816, 907-910` |
| B3 | **Records attachments are lost on sign-out on the same phone.** `toJson` caches `'files'` on the phone, but `_cloudColumns` has no files column. `LocalWipe` runs `prefs.clear()`, and `applyCloudRows` rebuilds each row with `attachments: const []`. The files are still in `media/<uid>/ttc_record/`, but nothing points to them. STILL-OPEN §9.7 covers only "not on the next phone". | `ttc_records_store.dart:97-100, 353-361, 397`; `local_wipe.dart:101` |

### Wrong
| # | Finding | Where |
|---|---|---|
| W1 | Treatment has no partner view, although `'treatment'` is in `kTtcHisToolIds`. He gets her wording and every edit. His edits go to his own row only, which feeds B1. | `ttc_treatment_screen.dart` and `ttc_treatment_round_screens.dart` (no `TtcPartnerMode`); `ttc_tools_screen.dart:964` |
| W2 | In the stimulation phase, an IUI round is called "Tablets and scans", while the same round's step reads "First tablet or injection". | `ttc_round_strings.dart:286-288, 669-671` vs `:112` |
| W3 | For a round with no kind (older rounds stored IUIs as "Egg retrieval / IUI"), the 4-hours-before trigger body falls to `_ =>`, which says "Egg collection is timed from it, about 34 to 36 hours later". | `ttc_treatment_store.dart:498` |
| W4 | Two reads over-promise. The age read promises "Scans, sizes and the trigger", but there is no size field. The IVF read promises the round is "shared with him", which is not reliable until B1 is fixed. | `ttc_reads_age.dart:2029`; `ttc_reads_ivf.dart:717` |
| W5 | "We'll remind you 4 hours before… and 15 minutes before" shows whenever a trigger date exists: after it was ticked taken (both reminders are cancelled then), after the time has passed, and when the 4-hour time had already passed when it was set. | `ttc_treatment_screen.dart:1721-1729`; `notification_service.dart:233` |
| W6 | **Medication "Stop" does not stop reminders.** P1's Stop sets `isActive: false` and toasts "Its reminders are off too", but `scheduleMedicationAlarms` never reads `isActive`. `updateMed` re-arms the medicine, and every launch re-arms all medicines (`syncMedicationAlarms(_meds)`). In TTC the stopped medicine is hidden (`activeMeds`), so she cannot find it to remove it. | `medicine_tracker_screen.dart:346-352`; `notification_service.dart:301-312, 359-365`; `medicine_store.dart:59-62, 333-343`; `ttc_medication_screen.dart:190` |
| W7 | Reminders have no first day. The sheet builds a `MedAlarm` with no `startDateIso`, so it rings from today, while the hint invites "Days 3 to 7, once a day". The scheduler already honours a start date. | `ttc_medication_screen.dart:915-924`; `ttc_strings.dart:1310` |
| W8 | The IVF door tile reads "What to take and when, including the trigger time that really matters." and opens Medication. The trigger lives in Treatment cycle. | `ttc_focus_ivf.dart:955-958` (**door file: Terminal A**) |
| W9 | The medicine page always says "…at {times}, every day", even for weekday or custom alarms made in Pregnancy. | `ttc_medication_screen.dart:459-460` vs `:901-909` |
| W10 | **"Whose" reads backwards on his phone** (the shape of T3 W11). `for_partner` is an absolute "his" flag (`picked.forHim`), but `ttcWhose` and `ttcWhoseLong` read it as "the other person's", and Records never reads partner mode. On his phone his semen analysis reads "Your partner's", and "Yours" files a result as hers. The Semen report files every report as `forPartner: true`, so it inherits this. | `ttc_records_v2.dart:133, 141-142`; `ttc_record_edit_screen.dart:204-214, 344-348`; `ttc_semen_report_screen.dart:190` |
| W11 | He can edit and remove her results. The his-side comment says he "never logs or edits hers" (`ttc_tools_screen.dart:945-947`), but the folder's actions are not gated, and RLS lets either partner write any row (`0042_ttc_records.sql:49-52`, kept in 0103). | `ttc_records_v2.dart:1457, 1989` |
| W12 | Remove says the record goes "with its photos", but nothing in TTC calls `StorageService.remove`, so the uploaded scan stays in the bucket for good. | `ttc_record_edit_screen.dart:94-101`; `storage_service.dart:107` |
| W13 | The volume sentence says volume "is not one of the four numbers with a reference line", and the limits comment says a line "would invent a threshold WHO did not publish". WHO 2021 publishes 1.4 mL, as the reading file's own comment admits (`:187`). A test pins the false wording. | `ttc_semen_reading.dart:195-197`; `ttc_semen_limits.dart:67-70`; `test/ttc_his_side_test.dart:524-532` |
| W14 | The semen form says "This stays on your phone. It isn't a medical record.", but "Keep the report" writes a `ttc_records` row that syncs and that the partner reads. | `ttc_semen_report_screen.dart:442`; `ttc_tool_chrome.dart:1150` |

### Weak and Polish (built where the wave says so; the rest recorded)
- **K1 Treatment after a close (built).** `closeRound` empties `_cycle`, so the screen leads with "Starting treatment?" the day after a test. The IVF door shows "Between rounds" or "Positive test" for 90 days (`ttcIvfPanelNow`, `ttc_treatment_round_screens.dart:2370-2390`).
- **K2 Treatment removals and saves (built).** "Remove this round's dates" (`clearCycle`, store `:763`) is a hard remove with no Undo, against the store's "nothing is deleted" header. Undo on a closed round has no toast (`:1984`). Date saves through `_edit` (`round_screens:1544-1560`) say nothing. A trigger save should say "Reminders set for 5:15pm and 9:00pm".
- **K3 Treatment OHSS (built).** The OHSS signs are one rotating card (`ttc_treatment_content.dart:302-307`), shown on about half the embryo days. They never show for freeze-all after collection or in the wait (late OHSS). "Find it hard to breathe" says "call your clinic", where NHS says urgent care. The OHSS read (`ttc_read_ivf_ohss`) is not linked.
- **K4 Treatment, older rounds (built).** `next` drops a step dated today (`store:288`, midnight dates and `isBefore(now)`). The collection note says "Don't eat anything after midnight" (`store:151`), but the card says the clinic will tell her (`content:279`). An IUI with a trigger but no IUI date stays in "Trigger" until the test.
- **K5 Treatment names (built for our files; door lines to A).** There are four names: "Treatment cycle", "Your treatment cycle", the title, and You's "Treatment" (`pv_you_content.dart:1052`). The surface label reads "IUI & IVF explained" (`ttc_surfaces.dart:83`). The body-conditions step "Tablets, IUI and IVF side by side" lands on the dates form (`ttc_reads_body_conditions.dart:967`). There are two route names (`ttc/treatment`, `ttc_treatment`). The start flow's `pushReplacement` stacks two treatment screens (`round_screens:731`).
- **K6 Treatment, recorded.** `_kOrder` has no trigger-to-transfer pair for a natural frozen transfer, and the screen does not rebuild at midnight.
- **K7 Medication (built).** Remove has no Undo (P1's `restoreMed` is unused, `:568-571`). A plain edit saves silently (`:962-966`). Swiping the sheet away drops a half-typed entry (`ttc_dose_parts.dart:756-764`). After a loss there is no TTC version of P1's D3 card ("Added while you were pregnant: check these with your doctor"). The checklist's count and `takesFolate` read `.all`, finished courses included (`ttc_precheck_rules.dart:169, 180-182, 228`), while Tools counts `activeMeds` (`ttc_tools_screen.dart:1576`).
- **K8 Medication, recorded.** It never reads the care pathway (deliberate: no inference from a drug name, `:38-43`). TTC home and Today show no medicines. There is no missed-dose line. A past day can be ticked before the medicine existed. Route `ttc/medication` vs `ttc_medication`.
- **K9 Appointments (built).** The round's clinic dates never show here (`ttcApptEntries`, `:140-163`), so she types them in again, and the Calendar shows the same visit twice with two reminders (`ttc_calendar_screen.dart:589, 626`). Past ParentVeda bookings never reach Past (`status == upcoming`, `:154`). The quick names have no IUI, retrieval or transfer (`:1841-1846`). Editing a visit the partner has just removed still toasts "Changes saved." (`:1935`; `ttc_records_store.dart:801-802`).
- **K10 Appointments, polish (built).** Switching a reminder off has no toast (`:1506-1521`). A new visit's leave guard ignores a picked date (`:1851-1855`). The Calendar comment "he never edits it" is stale (`ttc_calendar_screen.dart:1470`).
- **K11 Records (built).** The add page has no unsaved-changes guard, and backing out leaves any photo already uploaded in storage (`ttc_record_edit_screen.dart:257-262`). The edit toast is a generic "Changes saved." (`:303`). There are two route names (`ttc/records` vs `ttc_records`).
- **K12 Semen report (built).** The reading is not kept. Leaving the form mid-entry asks nothing (`PopScope(canPop: !_read)`, `:214-219`). Keeping the same numbers in a later session writes a duplicate (`_keptId` is per session). Azoospermia says "There's a piece in this section…" with no link (`ttc_semen_reading.dart:288`; read `ttc_read_azoospermia`). "A normal result rules out the most common male causes" overclaims (`:349`). The morphology note says "normal" beside "not a pass mark". With the abstinence window off, "These are in the usual range." sits over a "may not be reliable" note. There are three names (door, Tests `:283`, `ttc_kind_cards.dart:456`). `ttc_semen_report` is missing from `ttc_surfaces.dart`.

### Clean, as checked
- No personalised probability or diagnosis in any of the five tools. The semen outcome is a closed set of routes, and every path ends "isn't a diagnosis… can't tell you whether you'll conceive". `ttc_clinical_review_test` scans `lib/ttc`.
- The clinic owns the dates. The step is derived (`ttcTreatmentPhase`), never asked. Out-of-order dates get a check dialog that never refuses. The trigger clock never invents a time.
- The numbers hold. Collection is 34-36 h after the trigger (HFEA). The IUI test is about 14 days after. The beta test is 9-14 days after transfer, with a repeat about 48 h later. Stimulation is 8-12 days. The semen limits are 16 M/mL, 42%, 30% and 4% (WHO 2021); abstinence is 2-7 days; no WHO 2010 values remain.
- Phone emoji rule. No medication, appointment or trigger alert passes through `phoneTitle`.
- Appointments. Undo restores the same id. The leave guard covers edits. Reminders are per phone and never synced. Times are stored in UTC.
- Backend. Every store is local-first with app ids and does nothing without a user id. Columns are pinned in `ttc_schema_contract_test.dart` and `preg_records_schema_contract_test.dart:76-129`. Ask Veda's `treatment_step` comes from her round and is declared in the service (`answer.py:239`).

## Decisions
| # | Question | Recommended | User's answer |
|---|---|---|---|
| Q1 | Can he edit the treatment round, or only see it? | See only. His phone shows her round read-only and never pushes a row. B1 reads her row. | **"He should not be editing something personal of hers… his app should be a check more than starting to edit."** Read-only, and a tap on an edit tells him why with a toast (2026-10-29) |
| Q2 | Records: may he change or remove her results? | He reads hers and changes only his own. The UI gates Edit and Remove, and RLS is tightened to match. | **"He changes his own results and only reads her results"**, with a toast that says so (2026-10-29) |
| Q3 | His own Medication (male-factor clomiphene, hCG)? | Yes: `'medication'` goes into `kTtcHisToolIds`, own-only, as the store already is. | Not answered directly. **Taken as Recommended**, on the user's "he changes his own" and "if it's a clinical decision, recommend the better thing" (2026-10-29). Say so at the build's start. |
| Q4 | What does the lock screen show for a fertility medicine? | "Time for your medicine" for medicines added in TTC, with the name inside the app. | **Recommended**: "if someone else reads it… less private" (2026-10-29) |
| — | His tap on her edit | One toast, the same words across the tools: "This is hers to change. You can see it here." A remove or edit control on her items is not drawn on his phone. Where a control has to stay (a shared form), it toasts instead of acting. | chosen and recorded |
| — | B1 fix | On pull, prefer the row whose `user_id` is hers. On her phone that is her own row. On his phone it is the partner's row, read fresh on every pull and not only when the local copy is empty. His phone never pushes `ttc_treatment` (`pushToCloud` returns under partner mode). The row he may already have written stays in the cloud and is ignored. | chosen and recorded |
| — | B2 | No trigger alarm on his phone (`_rescheduleTrigger` returns under partner mode). His home's partner line already tells him the day. | chosen and recorded |
| — | B3 | A `files` jsonb column on `ttc_records` (migration, run by the user). `_cloudColumns` sends the refs, and `applyCloudRows` reads them, falling back to the local list when the column is null (old rows). Close STILL-OPEN §9.7. The trade-off is named in BACKEND-PATTERNS: a column costs one migration and makes the cloud the record's memory, where the prefs-only cache made a sign-out a deletion. | chosen and recorded |
| — | Q2 RLS | In the same migration: update and delete on `ttc_records` only where `user_id = auth.uid()`. Select stays couple-wide, and insert stays own. A UI gate alone would leave a second client able to do what the product forbids. | chosen and recorded |
| — | W6 | `scheduleMedicationAlarms` cancels and returns when `!m.isActive`. This changes Pregnancy too, so Pregnancy's medicine tests run with ours. | chosen and recorded |
| — | W7 | An optional "First day" beside "Last day" in the sheet, written as `startDateIso`. Its line: "Reminders start on {date}." | chosen and recorded |
| — | Q4 build | `MedAlarm.title`, an existing field, is set to "Time for your medicine" for medicines saved from the TTC sheet. The body drops the name too ("Open ParentVeda to see which"), because the body also shows on the lock screen. Pregnancy keeps its own titles. Pin it with a test. | chosen and recorded |
| — | W2 | IUI and ovulation induction: "Medicines and scans". | chosen and recorded |
| — | W3 | A null-kind round gets the neutral body: "Your clinic set this for {time}, and the next step is timed from it. If anything is unclear, call them now." | chosen and recorded |
| — | W4 | Age read: "Scans and the trigger". IVF read: "shared with him to see", true after B1. | chosen and recorded |
| — | W5 | The reminder row shows only while a reminder is still to come. After "taken": "Taken. Reminders are off." | chosen and recorded |
| — | W9 | The detail line comes from the alarm's own repeat: "every day", "on Mondays and Thursdays", or "on the days you set". | chosen and recorded |
| — | W10 | `for_partner` stays absolute ("his"). Records reads `TtcPartnerMode`. On his phone, `ttcWhose(forHim)` reads "You" for his and "Partner" for hers, and the add page's "Yours" means his. One helper, `ttcWhoseFor(forHim, partnerMode)`, is used everywhere the two words show. | chosen and recorded |
| — | W12 | When a removed record is finally purged, its refs are removed from storage (`StorageService.remove`). Remove and Undo leave the files alone. A photo picked from the gallery stays in the gallery, as the dialog says. | chosen and recorded |
| — | W13 | "Your volume is {n} ml. WHO also publishes a lower reference for volume, 1.4 ml. A low volume on its own is worth mentioning to your doctor, who reads it with the rest." The four lines stay four. The limits comment is corrected, and the test pin is updated. | chosen and recorded |
| — | W14 | The privacy line goes from the semen form, commented out and kept for revert. Under "Keep the report": "Kept in your records, which you both can see." | chosen and recorded |
| — | K1 | After a close, the tool leads with the door's own state for the same 90 days (`ttcIvfPanelNow`), plus "Start a new round". | chosen and recorded |
| — | K2 | "Remove this round's dates" moves the round to history (outcome `cleared`), with an Undo toast. Every date save says what it set, and the trigger names both reminder times. | chosen and recorded |
| — | K3 | One fixed red-flag line on the tool from collection until the test (any kind with a collection), linking the OHSS read: "Bad tummy pain or swelling, vomiting, or passing much less urine: call your clinic today. If you're short of breath, go to A&E." The rotating card's breathing line changes to match. | chosen and recorded |
| — | K7 | Remove gets Undo (`restoreMed`). An edit toast says what changed. The sheet asks before it is dismissed with changes. The TTC after-loss card mirrors D3 with the same wording rule. The checklist's count and `takesFolate` read `activeMeds`. | chosen and recorded |
| — | K9 | Round dates show on Appointments read-only, marked "From your treatment cycle", and open the round. The Calendar draws one line per visit: an appointment on the same day as a round step, with a matching type, wins, and the round line drops. Past bookings appear under Past. Quick names gain IUI, Egg collection and Embryo transfer. A save on a removed visit says "This visit was removed on the other phone." | chosen and recorded |
| — | K12 | "Keep the report" checks for the same date and numbers before writing. The azoospermia line links `ttc_read_azoospermia`. "…makes the most common male causes less likely". Morphology "4 per cent or above is in the usual range". The headline under the abstinence note: "These look in the usual range, but read the note first." One name, "Read your semen report". `ttc_semen_report` goes into `ttc_surfaces.dart`. | chosen and recorded |

## TTC-GAP 25: a title that names today's step
Everything is already worked out in `TtcTreatmentScreen.build` (`ttc_treatment_screen.dart:1572-1587`). One function, `ttcTreatmentTitle(round, store, now, partner:)`, in `ttc_round_strings.dart`, with the hard `\n` dropped:

| State | Read from | Title |
|---|---|---|
| No round, no recent close | `none` | "Your clinic's dates, in one place." |
| Closed within 90 days: negative, ended or stopped | `ttcIvfPanelNow() == between` | "Between rounds." |
| Closed, paused | `lastClosed.outcome == paused` | "Taking a break." |
| Closed, positive | `ttcIvfPanelNow() == positive` | "A positive test." |
| Older round with no kind | `legacy` | Stays "The dates your clinic gave you." (the phase maths assumes IVF and would call an IUI "Egg collection day") |
| Kind, no dates | `round.isEmpty` | "No dates yet." |
| Planned | `ttcFirstTreatmentDate` | "Starts {date}." |
| Getting ready to the wait | phase + `ttcRoundDayCount` | "Stimulation, day 6." / "Embryo day 3." / "The wait, day 4." |
| Test day | phase | "Test day." Once the test date has passed: "Waiting to hear." |
| His phone | partner mode + `ttcPartnerRoundLine` | "Her round", then his line as the intro. The line returns null while she waits to hear, so the title never shows her result. |

`_TodayCard` and the round panel already head "{step} · day N" (`round_screens:2432-2436`, `:1817-1821`). On this screen the card leads with its "Today: …" line instead, so the step is not said twice. Close TTC-GAP 25 in `docs/door-relevance/TTC-GAP.md`, but only on the user's word, because that file belongs to Terminal A.

## Clinical calls (each one goes on a BEFORE-LAUNCH clinician CHECK line, written on the user's word)
1. The OHSS red-flag line and its routes: clinic the same day, A&E if short of breath (NHS, HFEA).
2. The neutral trigger body for a round with no kind, and "Medicines and scans" for IUI.
3. Semen: WHO 2021's 1.4 mL volume sentence, and "makes the most common male causes less likely".
4. Morphology "4 per cent or above is in the usual range" (WHO 2021).
5. The after-loss medication card in TTC (the same review as P1's D3).

**LAUNCH line** (beside "Relevance Batch 6 Ask Veda refresh"): re-ingest the two corrected reads (age, IVF). No service code changes: nothing in `parentveda-askveda` hard-codes this copy. Check that at build time.

## Build waves (no stop between waves; tests after each)
**Wave 1: data safety and sync**
- B1 and B2: prefer her row, pull fresh on his phone, no push and no trigger alarm under partner mode.
- B3 and the Q2 RLS: one migration (the user runs it), `_cloudColumns` and `applyCloudRows`, plus the contract test.
- W6: the scheduler skips a stopped medicine. W12: storage cleanup on purge.
- W10: `ttcWhoseFor`, used by Records and the Semen report.

**Wave 2: partner view and screens**
- Q1 and W1: the treatment screen under partner mode is read-only, with "Her round" and the toast. Q2 and W11: Records gates Edit and Remove on her rows, with the toast. Q3: `'medication'` into `kTtcHisToolIds`; check that his list is his own and the add flow says "Yours".
- GAP 25: `ttcTreatmentTitle`, and the card heading change.
- W2, W3, W4, W5, W7, W9, W13, W14, and Q4's lock-screen title and body.
- K1, K2, K3, K7, K9, K12.

**Wave 3: polish**
- K4, K5 (our files only), K10, K11. Superseded UI is commented out with "kept for revert".

**Tests** (new `test/ttc_t4_treatment_records_test.dart`, plus updates to tests that pin old copy):
- B1: two rows, hers older than his, so her phone and his phone both decode hers; no push under partner mode. B2: no trigger alarm under partner mode.
- B3: the `files` column round-trips, a sign-out followed by applying cloud rows keeps the attachments, and the contract test pins `files`.
- W6: a stopped medicine schedules nothing (Pregnancy's tracker tests also run). W7: `startDateIso` written, and nothing rings before it. Q4: a TTC-saved medicine's alarm title and body do not contain its name.
- W10: under partner mode his record reads "You", and "Yours" files `forPartner: true`. W11: his phone draws no Remove on her record.
- Q1: the treatment screen under partner mode has no edit control and shows the toast.
- GAP 25: one title per state in the table, and the partner title never shows a result.
- W13: the volume sentence names 1.4 ml (the old pin is updated). W14: no "stays on your phone" on the semen form. K12: no duplicate keep.
- K1: after a close, the screen shows "Between rounds". K2: clearing dates goes to history and Undo brings it back. K3: the red-flag line shows in the wait. K9: one Calendar line for a matching visit and round step.

**Verification:** `flutter analyze` on the touched files. The TTC tests (`test/ttc_*`), Pregnancy's medicine tests (`test/preg_*medic*`, `test/preg_records_schema_contract_test.dart`), the schema contract tests and the new file only, because the machine is short on memory. The wiring grep on every new reader: `ttcWhoseFor`, `ttcTreatmentTitle`, the partner-mode guards in the treatment store, `files` in `_cloudColumns`, `isActive` in the scheduler, `startDateIso` in the sheet, the round dates in `ttcApptEntries`, and `'medication'` in his set. Phone walk later, on the user's word, on two phones for B1, Q1 and Q2.

## Backend
- One migration: `ttc_records.files jsonb` (nullable), and update and delete policies narrowed to own rows. The user runs it.
- `ttc_treatment`: no schema change. Reading prefers her row, and his phone stops writing. The old row of his stays and is ignored. **The trade-off:** last-write-wins was right for one writer and wrong for two. Making her the only writer is simpler than a merge, and it matches the product rule.
- `ttc_records`: `files` sent and read. W12 removes storage objects on purge.
- `MedicineStore`: no schema change. `startDateIso` and `title` already exist on `MedAlarm`.
- On the user's word (check `git status` first): a BACKEND-SYNC-LOG step, a BACKEND-PATTERNS note ("one writer for a couple-shared blob" and "a cache is not a record"), STILL-OPEN §9.7 closed, and a STILL-OPEN-BACKEND row.

## Owed and hand-over
- **Terminal A (door files), adding to hand-over item 4:**
  - W8: the IVF tile "Your medicines and timings" drops "including the trigger time", or points the trigger to `ttc_treatment`.
  - The round's one name, "Treatment cycle".
  - The semen tool's one name, "Read your semen report", and the his-side tile "Keep his reports with yours" reads as hers on his phone.
  - TTC-GAP 25 closes once T4 is built.
- **C1:** the Semen report's Tools row and his set.
- **BEFORE-LAUNCH:** the 5 CHECK lines, the LAUNCH line, and a two-phone CHECK for B1, Q1 and Q2, all on the user's word.
- **Recorded for later:** Ask Veda medication context (two repos), a follicle-size field, the extra semen numbers, Records feeding the checklist, the natural FET trigger-to-transfer order, a midnight rebuild of the round screen.

## As built
Built 2026-10-29, all three waves, in one terminal. The user confirmed Q3 at the start ("Yes, his own"). Every superseded line is commented out with "kept for revert". Migration **0127** is written and **not yet run**: the user runs it, and it has to run before this build is installed (see Backend below).

**Wave 1: data safety and sync**
- **B1** `ttc_treatment_store.dart`: `pullFromCloud` reads the row `ttcPickTreatmentRow` picks, never `rows.first`. Her phone takes her own row; his phone (partner mode) takes the row that is not his, decoded fresh on every pull. `pushToCloud` returns under partner mode. A row he wrote before this stays in the cloud and is ignored. Her phone with no row of its own takes nothing (the plan's "ignored", kept strict).
- **B2** `_rescheduleTrigger` cancels both alarms first, then returns under partner mode, so a phone that switches to his side drops any alarm it held.
- **B3** `ttc_records_store.dart`: `_cloudColumns` sends `'files': r.attachments` (always, an empty list included, so removing the last photo travels). `applyCloudRows` reads them through `ttcFilesFromCloud`; a null column (a row from before 0127) keeps this phone's list. The `attachments` comment no longer says "local-only". `ttc_schema_contract_test.dart` pins `files` and reads 0127.
- **Q2 in the push**: a dirty row whose owner is the other account is dropped from the queue rather than sent, because 0127 refuses it and it would otherwise retry for ever.
- **W6** `notification_service.dart`: the occurrence loop moved, unchanged, into the pure `NotificationService.medicationOccurrences(m, now, dueBody:)`, which returns nothing when `!m.isActive`. `scheduleMedicationAlarms` cancels, then schedules what it returns. This changes Pregnancy's Stop too, as decided; its tests ran (below).
- **W12** Records: `remove` queues a removed record's refs in a small ledger (`ttc_records_file_sweep` in prefs); `restore` takes them off. After each pull, `ttcFilesDueForSweep` picks removals older than `SyncRowBook.keepRemovals` (80 days, inside the server's 90-day purge) and `StorageService.remove` deletes their files. Remove and Undo leave the files alone, as decided. Only the phone that removed it sweeps, which is also the phone whose user owns the storage path.
- **W10** `ttc_records_v2.dart`: `ttcWhoseFor(forHim, partnerMode, {long})` is the one place "You / Partner" and "Yours / Your partner's" are decided. `ttcWhose` and `ttcWhoseLong` now delegate to it with `TtcPartnerMode`, so every existing caller reads from the phone's side. `ttcMineFlag()` is the `for_partner` value that means "mine". The add page's "Yours" writes it, and on his phone a new result defaults to his. The Semen report already filed `forPartner: true` (his) and is right as it stands.

**Wave 2: partner view and screens**
- **Q1, W1** `ttc_treatment_screen.dart`: under partner mode the screen returns `_HisRoundView`: title "Her round", his line as the intro (`ttcPartnerTreatmentIntro`), her dates on `TtcRoundTimeline(readOnly: true)`, the clinic as text, and one row, "Only she can change these dates. If something looks wrong, tell her.", whose tap toasts `kTtcHersToChange`. No edit, close, result or history is drawn. A closed round or "waiting to hear" shows no result.
- **Q2, W11** Records: `TtcRecordsStore.isMine(id)` (no owner noted, or the owner is this account). The result page and a test's trend page draw no Edit, Type the number, Add a photo, Change, Remove, Add a reading or Remove all on the other partner's rows. `TtcRecordReadOnlyNote` shows the words instead ("This is hers to change…" on his phone, "This is his to change…" on hers). The rule follows the row's owner, which is exactly what 0127 enforces.
- **Q3** `'medication'` is in `kTtcHisToolIds`. `MedicineStore` is own-row already, so his list is his own.
- **Q4** `kPrivateMedAlarmTitle` "Time for your medicine" and `kPrivateMedAlarmBody` "Open ParentVeda to see which." in `models/medication.dart`. The TTC sheet writes the title on the alarm it builds, and on an untouched schedule it gives the private title to any alarm with no title of its own. The scheduler drops the name from the body when the title is the private one. Pregnancy's own titles are untouched.
- **GAP 25** `ttcTreatmentTitle(round, store, now, partner:)` in `ttc_round_strings.dart`, one line per state as in the table. `_TodayCard` now leads with its "Today: …" line (or the next line), in the display face, and no longer repeats the step; the old "{step} · day N" title is commented out. **The door's panel and `_TodayCard` elsewhere are unchanged.**
- **W2** "Medicines and scans" in the phase name and the hero line. **W3** a null-kind round gets the neutral trigger body. **W4** the age read says "Scans and the trigger"; the IVF read says "shared with him to see". **W5** `ttcTriggerReminderLine`: the reminder row shows only while a reminder is still to come ("15 minutes before" alone when the 4-hour mark has passed), and "Taken. Reminders are off." once ticked. In Hindi the old bilingual line still shows while reminders are due.
- **W7** The sheet has an optional "First day", written as `startDateIso`, with "Reminders start on {date}." under it. **W9** `ttcMedRepeatLine`: "every day", "on Mondays and Thursdays", or "on the days you set", plus ", from {date}" for a future first day.
- **W13** The volume sentence names WHO 2021's 1.4 ml; the limits comment is corrected; the old pin in `ttc_his_side_test.dart` now expects "1.4 ml". The four lines stay four. **W14** The privacy line is commented out on the semen form; under the keep buttons: "Kept in your records, which you both can see."
- **K1** After a close, within 90 days, the tool shows the door's own `TtcIvfRoundPanel` (Between rounds or Positive test); a positive close adds "Start a new round".
- **K2** "Remove this round's dates" keeps the round. **This differs from the plan's "moves the round to history (outcome `cleared`)"**: `history` has nine readers (the home hero and situation, the calendar, the messages store another terminal has open, the undo card, the door), and every one of them would have read a mistake as a round she had. So a cleared round goes to its own `cleared` list in the same blob (an older app ignores the key), `undoClear` brings it back exactly, and the toast is "Dates removed." with Undo. Nothing is deleted, as the store's header promises. Undo on a closed round now toasts "Round reopened.", and every date save says what it set; a trigger save names both reminder times (`ttcTriggerSavedLine`).
- **K3** `kTtcOhssLine` shows as one fixed row from egg collection until the blood test (not for an IUI), and opens `ttc_read_ivf_ohss`. The rotating card's breathing line now matches. **Wording**: the plan said "go to A&E". The app says "go to hospital" for emergency routing everywhere else (about 40 places), and A&E is a UK word, so the line reads "If you're short of breath, go to hospital now." The route is the same.
- **K7** Remove has Undo (`restoreMed`, the ticked days too). An edit toasts what changed (`ttcMedChangeToast`). The sheet opens with drag off and a `PopScope` guard, because a drag-to-close calls `Navigator.pop` directly and never asks a `PopScope`; the back button and a tap outside ask "Discard this medicine?" first. `TtcMedAfterLossCard`, the mirror of P1's D3: after a loss (no current pregnancy, the last one ended in a loss), the medicines added during that pregnancy (`MedicineStore.addedDuring`, read from the id like `addedBefore`) are listed with Keep or Stop; Stop has Undo; answers are kept per loss on this phone. The checklist's count and `takesFolate` read `activeMeds`.
- **K9** `ttcRoundApptEntries()`: the open round's clinic visits (baseline scan, egg collection, IUI, transfer, the two blood tests, review, and monitoring scans; not home steps) appear on Appointments, tagged "From your treatment cycle", with no time, and open the round (`openTtcAppointment` sends a round date to `openTtcTreatment`). `ttcApptMatchesStep` matches a typed appointment to a step by its words; a match on the same day drops the round's line, on Appointments and on the Calendar (`ttcCalendarClinicLines`, open round only). Attended and missed ParentVeda bookings now reach Past (cancelled stay out). Quick names gain IUI, Egg collection and Embryo transfer. Saving a visit the other phone removed says "This visit was removed on the other phone." The home's visit-today card does not take round dates (`withRound` is false there), because the round has its own home card.
- **K12** Keep checks Records for the same test, date and numbers first and reuses that record ("Already in your reports."). Leaving the form with numbers typed asks first. The azoospermia reading carries `readId: 'ttc_read_azoospermia'` and the screen draws "Read it now" under the line. "…makes the most common male causes less likely". Morphology "4 per cent or above is in the usual range". The headline over an abstinence note: "These look in the usual range, but read the note first." Tests' row and the new `ttc_semen_report` surface say "Read your semen report".

**Wave 3: polish**
- **K4** `next` keeps a step dated today through the whole day (the trigger keeps its exact time). The collection note says the clinic will tell her when to stop eating. An IUI with a trigger and no IUI date reaches the wait two days after the trigger.
- **K5 (our files)** The surface label is "Treatment cycle"; You's row is "Treatment cycle" (its test pin updated); the body-conditions step now says what it opens ("Keep a treatment round in one place"). The start flow opened from the round screen pops back to it (`openTtcTreatmentStart(backToRound: true)`) instead of stacking a second screen. **The two route names are left as they are**: `ttc/treatment` is pinned by `ttc_treatment_round_screens_test.dart`, `ttc_treatment` is the surface router's id-as-name, and nothing reads either for a decision; unifying them is a rename with no behaviour behind it.
- **K10** Switching a visit's reminder off toasts "Reminder off for this visit."; a new visit's leave guard counts a picked date; the Calendar's "he never edits it" comment is corrected.
- **K11** The add-and-change result page has a leave guard ("Discard this result?") that deletes photos uploaded on that visit when she discards; the edit toast says what changed ("Date and note changed."). Route names: as K5.
- **One confirm**: the medicine sheet, the result page and the semen form ask through the existing `ttcConfirmRemove` with their own words, rather than three new dialogs.

**Tests**: new `test/ttc_t4_treatment_records_test.dart` (54 tests: B1, B2, B3, Q2's SQL and push, W12, W6, W7, Q4, W9, K7, W10, Q3, W11 as widgets, Q1 as a widget, GAP 25 per state and on his phone, W2 to W5, K1 as a widget, K2, K3, K4, K9 on the Calendar and Appointments, W13, W14, K12, and the wiring gate). Updated pins: `ttc_his_side_test.dart` (W13), `ttc_treatment_round_screens_test.dart` (You's "Treatment cycle"), `ttc_schema_contract_test.dart` (`files`, 0127).

**Not done here, on purpose**: the door files (W8's IVF tile, the door names, `doors/ttc_kind_cards.dart`'s "Read his semen report"), BEFORE-LAUNCH, the sync log, BACKEND-PATTERNS, STILL-OPEN §9.7 and TTC-GAP.md, all on the user's word. The Ask Veda check ("nothing in `parentveda-askveda` hard-codes this copy") needs access to that repo and was not run.
