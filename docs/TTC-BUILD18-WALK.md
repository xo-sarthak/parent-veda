# TTC build 18 walk (partial, stopped early)

- **Date:** 2026-09-28, about 11:38 to 11:45 on the phone clock.
- **Build:** com.parentveda.app versionCode 18 (versionName 1.0.0), on the S21 FE over wireless adb, trying to conceive stage.
- **State seen:** cycle day 10, in the fertile window ("Your fertile days are today and 4 more days", 27 Sep to 2 Oct). Sex was already logged for today, and there were 5 supplements, 2 medicines and 1 record from before.
- **Stopped early.** The user asked to review the app themselves, so the walk stopped partway through check 1/2. Checks 5 to 9 were not reached. Everything below is what was seen before the stop.

Screenshots are in the session scratchpad, `scratchpad\walk18\`. `*_s.png` is a 540-wide copy, and `M_*.png` are side-by-side strips. `rec_tools_learn.mp4` and its `_strip.png` are a screen recording of one tab switch.

## Findings

| ID | Where (tap path) | What I saw | Why it matters | Suggested fix | Sev | Screenshot |
|---|---|---|---|---|---|---|
| W18-01 | More, identity card | The line under the name is cut off with an ellipsis: "with ParentVeda since Aug 2..." It runs into "Edit name". | Check 2 asks for no cut-off text. The date she joined is the part that gets lost. | Put "Edit name" on its own line or make it an icon, or shorten the line to "Since Aug 2026". | P | bar_More_end_s.png |
| W18-02 | More, "Your health" tile (the tall tile) | The icon sits at the top and the text at the bottom, with about a third of the tile's height left empty between them. The other tiles are filled. | The biggest tile looks the least finished, and the eye goes there first. | Give the space a job: show the next visit, or a count of the doctor questions. Or make the tile shorter. | P | bar_More_end_s.png |
| W18-03 | Tools, search "expert" | The note "Talk to an expert is under More, in Experts and courses." is plain text and cannot be tapped. | She is told where the expert is but has to go there herself. The note is right, it just does not take her there. | Make the note a row that opens More, Experts and courses. | P | tools_expert_s.png |
| W18-04 | Tools, search "expert" | The only library result is "PCOS and your cycle", which has nothing obvious to do with experts. | A result that does not fit the search makes search look broken. | Look at why it matches (probably a word in the body). Rank on title and summary, or drop matches found only in the body. | P | tools_expert_s.png |
| W18-05 | Tools, search "journal" | Two reads come back: "Coping when month after month doesn't work" and "Preconception garbh sanskar, honestly". There is no journal tool, which is correct. | Check 4. The reads probably mention journaling in their body text. I did not open them, so I cannot say whether either one points to the removed journal. | Open both reads and make sure neither links to or promises an in-app journal. | P (to verify) | tools_journal_s.png |
| W18-06 | Products, the category row under the hero | "Pregnancy tests" is an icon on a tinted square, while Supplements, Ovulation kits and Books are photos. | One of four tiles looks unfinished. | Give it a photo like the other three. | P | bar_Products_end_s.png |
| W18-07 | Learn, the first open after launch | "Pick up where you left off" cards draw for a moment with no picture, then the picture appears. The Products category tiles do the same. | A small flash on the first switch. Once loaded, it does not happen again. | Pre-cache the first thumbnails, or fade the picture in. | P | M_learn.png, M_prod.png |
| W18-08 | Tools, the text under the title | "Tools to track your cycle, check a worry and keep your records. Tap one to open it. None of them are required." | Check 7: "Tap one to open it" is vague filler that every list could say. | Drop that sentence. The first and last sentences carry the meaning. | P | tools0_s.png |
| W18-09 | Tools, the rows "Can I...?" and "Medical tests" | "Can I...?" is quick answers, and "Medical tests" is "What each fertility test tells you". Both are things to read, not tools she uses. | Check 3 says Tools holds only tools. These two are closer to reads. This is the user's call, not a clear bug. | Leave them, or move them to Learn and keep a search pointer like the one for experts. | P (decision) | M_toolslist.png |

No blockers (B) and no clear problems (C) were found in what was walked. There were no crashes, no red error screens and no overflow stripes on the screens seen.

## Pass / fail per check

1. **Bottom bar: PASS for the parts walked, two parts not checked.**
   - **The switch is one fade: PASS.** A recording of Tools to Learn (`rec_tools_learn_strip.png`) shows Tools fading out, then Learn fading in with a slight settle, and nothing sliding. Frame grabs of all five switches agree (`M_learn`, `M_prod`, `M_tools`, `M_more`, `M_today`).
   - **The bar's position is identical: PASS.** uiautomator gave the same bounds on all five tabs: Today [60,2100][252,2223], Learn [252..444], Products [444..636], Tools [636..828], More [828..1020], all at y 2100 to 2223.
   - **Tapping the lit tab scrolls to the top: PASS on Tools.** It was scrolled two screens down and landed at the top. The other tabs were not tried.
   - **Back lands on Today: PASS** from Learn, Products, Tools and More.
   - **A tool slides in as a page: NOT PROVEN.** Tools, Cycle companion opens as a full page without the bar, but the frame grabs were too slow to catch the motion, and the stop came before a recording could be made.
   - **The keyboard hides the bar: PASS in Tools search.** Search opens as its own page and the bar is gone. Learn search was not checked.
2. **More: PARTIAL.** It is a bento. Seen: the identity card, Your health, Your things (11 saved), Your app, Your journey (its text names "your journey map with its family timeline", so the map is under Your journey), Family, and a tile beginning "Book a video call with a specialist, your free...". The "Experts and courses" title was below the fold and not read. No tile was opened. Cut-off text: **FAIL** (W18-01).
3. **Tools: PASS.** There are 19 rows in four groups (Your body 7, Both of you 1, Care and medicines 8, Plan and check 3), and Treatment cycle is the last row of Care and medicines. Searching "expert" shows the note pointing to More (W18-03 and W18-04 are polish). See W18-09 for two rows that may not be tools.
4. **Journal gone: PARTIAL, pass so far.** There is no journal row in Tools, and Tools search for "journal" finds no tool, only two reads (W18-05). No journal appears on the top of Today or the top of More. Every door, the timeline, the journey map and the lower part of More were not checked.
5. **Doctor questions: NOT REACHED.** Nothing was added.
6. **Fertile window door kind cards: NOT REACHED.**
7. **Labels: PARTIAL.** Only Today (top), Tools, More (top), Learn (top) and Products (top) were scanned; see W18-08 and W18-09. No repetition was seen on those screens.
8. **Mind & body, sound cues and Sanskar intro: NOT REACHED.**
9. **Decision 2: NOT REACHED.** See below.
10. **Regressions: PARTIAL.** These looked fine, with no crash or overflow: Today top to "Explore by topic", Learn top, Products top (the hero band is whole, not cut off), Cycle companion top (the ring and legend are whole). Symptoms and mood, the cycle report, the Fertile window tool, messages and his side were not reached.

## Decision 2 evidence

Not seen. The phone was on cycle day 10 in the fertile window, so the hero read "Your fertile days are today and 4 more days" with the pill "27 Sep to 2 Oct". The "Time to test" / "Should I test?" pairing only shows when she is late. I did not change dates to reach that state, and I did not tap the hero or the pill in this state before the stop.

## Added and deleted

- **App data: nothing added, nothing removed.** No doctor question, log, period or date was touched, and nothing in the developer section was changed.
- **Files left on the phone's shared storage** (not app data; not deleted because the stop order said no more adb commands): `/sdcard/ui18.xml`, `/sdcard/m1.png`, `/sdcard/m2.png`, `/sdcard/m3.png` and `/sdcard/rec18.mp4`. To remove them:
  `adb -s adb-RZCX50ZKLBA-OzrzHP._adb-tls-connect._tcp shell rm /sdcard/ui18.xml /sdcard/m1.png /sdcard/m2.png /sdcard/m3.png /sdcard/rec18.mp4`
- **The phone was left** in ParentVeda on the Learn tab. During the Back test one extra Back sent the app to the home screen, and it was reopened from the launcher. No other app was touched.
