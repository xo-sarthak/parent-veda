# TTC fixes after build 27 (the user, 2026-09-30)

The user's list after walking build 27, split into what is done now and what waits for its own pass.

## Now (small changes; tick as done)

- [x] 1. **Today › Daily insights › Today's pick:** only products ParentVeda recommends, never the ones we rate low.
- [x] 2. **More › "Groups" → "Cohorts":** the section sells cohort programmes, not a community, and "Groups" read as a
      community.
- [x] 3. **The "saved" pop-up after logging** (a symptom, then Done): it lands abruptly in the lower middle of the
      screen. Make it smooth, fixed at the bottom, the standard way.
- [x] 4. **Cycle report graphs:** "62" and "kg" draw over each other on the weight graph, and the temperature graph
      has the same problem. Label the axes (the x axis has none) and say in plain words what each graph shows.
- [x] 5. **Daily insight cards:** Myth vs fact, Today's movement, Cycle report and the others have a mark that
      overlaps their text. Make them like "Chance of pregnancy today" and "Day of your cycle": one solid colour, no
      mark, the text always readable.
- [later] 6. **Can I…? has very few questions:** answer why, then fill it from the Flo and What to Expect crawls.
- [x] 7. **Saved (from the profile):** remove the old look (purple bookmarks, outdated icons, a community saved
      section). Show only this stage's saved things (articles, videos, recipes, products), never pregnancy items; comment
      out the kinds that do not belong here yet (read to your baby and similar).
- [x] 8. **Products › "Other stages":** it sits at an odd spot. Remove it (commented out); the store opens on trying
      to conceive.
- [x] 9. **More › All videos:** a red block sits behind each video. Remove it, and give every video a centred circle
      with a play triangle (the pregnancy "This week explained" look), coming soon or not.
- [x] 10. **More › Talk to an expert:** "See all consults" sits badly beside the heading. Move it to the row below, on
      the right, level with "Private video calls with a specialist", in a smaller size if needed.
- [x] 11. **More › Your journey (Journey map, Your chapter):** the user cannot see what they are for, and the screens
      are text-heavy ("Family timeline" with "Log your period" inside a journey map, a "Me / Ask / What's next"
      toggle). Research them against the Flo and What to Expect data. If they earn their place, make them clear and
      inviting; if not, propose taking them out.

## Later (each needs its own pass; do not start without the user)

- **Can I…? grown from 12 to about 40 questions** (a clinical writing pass; the user: later).

- **Ask Veda as the universal search** for the whole app, TTC first (its button is hidden for now).
- **His side** of trying to conceive as its own experience for the male partner.
- **Every tool against the WH questions** (what, why, how, when, who) for relevance and usability, from her point of
  view. Includes Partner's health: all grey and monotonous, logging hours of sleep and alcohol with no reason to come
  back; the "past four weeks" view is a good feature with poor execution.
- **What to Expect pregnancy re-crawl** of pages that lost a quoted line (the crawler quote bug).
- **More Fertile window door changes:** the user brings these.

## Notes on what was done (2026-09-30)

- 1: the pick rotates through the Highly recommended and Recommended bands only (folic acid, a pregnancy test, the
  book), still never the rail's own product that day.
- 3: the logger closes first; the note slides up once on the screen she returns to, just above the bar.
- 4: one painter draws both graphs. The unit has its own line ("Weight (kg)", "Temp (°C)"), values are right-aligned,
  the first date names its month, the two dot rows are named (Period, Logged), and a plain line says what the dots are.
- 5: `PvInsightTile.showArt` (default true); the TTC home passes false, so every card is one clean colour.
- 7: `SavedScreen(stage: 'trying')` from the TTC profile: that stage's saves, four kinds (`kTtcSavedKinds`), no stage
  chips, ink bookmark and labels, our drawn marks. Other stages open it as before.
- 9: All videos draws the door's shelf card wide (16:9), the door's own colour, the veil, a black play circle.
- 6 (answered): 12 questions, hand-written in the voice guide with limits and Indian context. Neither Flo nor What to
  Expect has a trying-to-conceive "can I" tool; the crawls hold about a dozen such questions scattered through
  articles, while What to Expect's big "Is it safe" library is pregnancy-only. Growing it is a writing pass with
  clinical care (each answer needs a verdict, a limit and a reason), proposed as its own step.
- 11: neither competitor has a journey map or a "chapter" for trying to conceive; the map's family timeline repeats the
  calendar and logger, and the chapter's content is on the doors and home. On the user's word both left More (commented
  out, screens kept; his partner screen still links them, for the his-side pass). The journey map also left Tools'
  moved-to-More list, so a Tools search no longer points at a section that is gone.
- 1 (follow-up): the "ParentVeda recommends" rail holds every recommended product, so the pick is chosen first
  (`ttcHomeTodaysPick`) and the rail leaves it out that day.
- 6: the user said do it later, as its own step.
