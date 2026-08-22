# S01 Sleep - VERBATIM build prompt from 'Feedback on parenting Section (3).xlsx', row 1
# Read this ONLY when the doc file for this section says to check the prompt.

# ParentVeda — Sleep Section (Parenting App): End-to-End Build Prompt

This is a complete build spec for the Sleep section of the ParentVeda parenting app (birth onward). Build the entire section end to end: screens, navigation, data, content pages in their correct formats, the tools, the Sleep Sounds player, the safe-sleep pages, and consultation booking. The only thing you do NOT build is the actual video files and the actual audio files. Everywhere a video or audio track belongs, put a labelled placeholder component we will plug real files into later.

The app is built in Flutter. Reuse the existing ParentVeda design system, components, and routing. Do not invent new primitives where existing card, tab, chart, and page components already exist.

---

## 0. Context you must respect

ParentVeda is an India-first parenting app. Calm, evidence-first, anti-anxiety, no misinformation, never fear-driven.

This section is India-focused sleep, and that changes the whole shape. Do NOT build it around the Western sleep-training vs co-sleeping debate. Our own market research shows near-zero India demand for sleep training and that Indian families co-sleep by default with no decision-anxiety. So:
- No cry-it-out, no "sleep training," no ferberizing framing anywhere.
- Everything gentle and co-sleeping-compatible.
- Safe-sleep content is harm-reduction, not abstinence. Telling Indian parents "never bed-share" gets ignored; "here is how to bed-share more safely" gets used and keeps babies safer.

Hard rules across everything you build here:
- Tone is simple, warm, plain-English (and Hinglish where noted). Short sentences. No jargon.
- Never diagnose. Reassure and, where a red flag exists, route to a doctor.
- No gamification: no streaks, no scores, no "you missed a day" on any tracker.
- India-first: malish (oil massage), joint family and shared rooms, lori (lullabies), Indian climate, no separate nursery assumed.
- No em dashes anywhere in UI copy or content.
- Reading content and every tool are FREE. Only the human sleep consultation is paid. Never gate an article, chart, tool, or the Sleep Sounds player.
- Every major area gets its own explainer video placeholder. No area is text-only.
- Do NOT write filler. Each page must be genuinely useful on its own. If a page would only exist to look complete, drop it.

Each content page follows a consistent template unless noted: a short warm intro (2 to 3 lines), the actual usable content in the format specified below, a callout box for the one key point, a practical "when / how much / what age" line, an India-home adaptation note where relevant, and soft links to the related tool or page. Do not render any page as one long undifferentiated paragraph.

The FORMAT of each page is specified in brackets and is mandatory: build it as that type (chart-card, comparison table, step-list, cards, short article, flagged callout, or tool), not as generic prose.

---

## 1. Structure

Sleep is one of the parenting app's main sections. Build it as a landing screen leading to seven content areas plus the tools. Existing elements to reuse are tagged [HAVE]; new ones [NEW].

Landing: soft one-line intro ("Helping your little one, and you, sleep better"), entry tiles for the seven areas, and the three tools (quick check, sleep log, Sleep Sounds player).

---

## 2. Area 1: How much sleep by age

- **Sleep-by-age cards** [CHART-CARD, one per age band: newborn 0-3m, 3-6m, 6-12m, toddler 1-3y, preschooler 3-5y] — each renders as a clean visual data card, not prose: total 24h sleep, number and length of day naps, night sleep hours, the honest range, and a one-line "what's normal at this age" note. These cards are the data source for the quick-check tool, so model them as structured data.
- **How baby sleep differs from adult sleep** [SHORT ARTICLE + simple diagram] — light-sleep cycles, why they stir. Video placeholder here: expert explainer on sleep needs by age.

---

## 3. Area 2: Night waking and gentle settling

- **Why babies wake** [CARDS, one per cause] — hunger, needing contact, developmental phase, sleep-association/habit, wet nappy, gas or tummy, teething, too hot or cold. Each card: one line on the cause, one line on what to do.
- **What's normal night waking by age** [COMPARISON TABLE] — age band down the side; typical wakes-per-night and why, across. A scan-and-relax page.
- **Gentle settling methods** [STEP-LIST CARDS, one per method] — patting and shushing, feeding back to sleep, contact/cuddle settling, dream feed, gradually reducing help. Each: quick steps, when to use it. All co-sleeping-compatible, no cry-it-out. Video placeholder: gentle-settling demo.
- **What to do at 3am** [SHORT TEXT, practical quick-reference].
- **Gentle night weaning** [ARTICLE] — for older babies, when and how.
- **When night waking needs a doctor** [FLAGGED CALLOUT, short] — pain, poor weight gain, breathing pauses, sudden change. Deliberately brief and clear, not buried.
- Soft link to the paid sleep consult surfaces on this area.

---

## 4. Area 3: Sleep regressions

- **What is a sleep regression** [SHORT ARTICLE + small timeline visual] of when they typically hit.
- **4-month / 8-to-10-month / toddler regression** [ARTICLE, one per regression, identical template] — what's happening and why (the developmental leap), when it starts, how long it lasts, signs you're in one, how to cope without building habits you'll fight later, and a "this passes" reassurance line. One video placeholder for the set: expert on regressions.
- Soft link to the paid sleep consult surfaces on this area.

---

## 5. Area 4: Getting to sleep (Indian-home realities)

- **Calming bedtime routine** [STEP-LIST + callout] — the ordered steps (dim lights, bath or wipe-down, malish, night clothes and nappy, feed but not as the only sleep cue, quiet story or lullaby, lights off with the same cue nightly), a "keep it the same every night" callout, a "20 to 40 min, same time nightly, from what age" line, and an adapt-to-shared-room note. Video placeholder: bedtime routine plus malish follow-along.
- **Wind-down before bed** [SHORT ARTICLE] — light, screens, activity level.
- **Malish (oil massage) before sleep** [STEP-LIST] — how and why; links to the routine.
- **Feeding to sleep** [ARTICLE] — is it a problem, how to think about it.
- **Day-night confusion in newborns** [ARTICLE] — why it happens, how to fix it.
- **Dropping naps by age** [CHART] — nap transitions age by age (how many naps, when they drop).
- **Sleep in a joint family / shared room** [ARTICLE] — late household bedtime, noise, no separate nursery.

---

## 6. Area 5: Safe sleep (the safety job)

Handle this area with care. State each safe practice plainly; on bed-sharing, lead with harm-reduction.

- **Safer bed-sharing** [ARTICLE, harm-reduction framed] — how to co-sleep more safely, what raises risk, what lowers it. Leads with "here is how," never "never do this." Video placeholder: expert on safe sleep.
- **Back to sleep** [SHORT ARTICLE].
- **Swaddling** [STEP-LIST] — how, and when to stop.
- **Sleep surface and surroundings** [CARDS / CHECKLIST] — firm, flat, clear of loose items.
- **Overheating and room temperature** [SHORT ARTICLE].
- **SIDS explained calmly** [ARTICLE] — facts without fear.

---

## 7. Area 6: Common sleep worries

- **Only sleeps on me / catnapping and short naps / early morning waking / sleeping too much / moving to their own space when ready** [SHORT ARTICLE, one per worry, same template] — what's going on, is it normal, what helps.
- **Noisy or snoring breathing** [SHORT ARTICLE + see-a-doctor CALLOUT] — reassurance plus a clear when-to-ask-a-doctor line.

---

## 8. Area 7: Music and sleep

- **Does music actually help babies sleep?** [HONEST ARTICLE] — what genuinely helps (white noise for newborns, consistent routine, calm sounds), what's myth, and a clear "keep the volume low, use a timer, do not play loud all night next to the baby" safety note. This page introduces and links to the Sleep Sounds player.

---

## 9. Tools

- **Sleep-need-by-age quick check** [TOOL, NEW] — she enters the baby's age, it returns the normal sleep range. Reads from the Area 1 card data. Small, reassuring.
- **Nap / sleep log** [TOOL, NEW, optional, non-gamified] — a light way to see the baby's pattern over a few days. No scores, no streaks, no judgment. Keep it simple; it must never become an anxiety tool.
- **Sleep Sounds player** [TOOL / FEATURE, NEW] — categories: lullabies and lori, white noise and womb sounds, nature and calm sounds, soft ragas, bedtime stories. Controls: sleep timer (default ON), loop, offline play, and a safe default volume that is not loud. Every track is an audio placeholder with a title, category, length, and slot id to map a real file later.

  DECISION FLAGGED FOR ISHAAN / DEEPTI (build the recommended default, leave it easy to change): build the Sleep Sounds player as a REUSABLE app-wide ParentVeda Audio player component, and surface it here in Sleep, rather than locking it inside the Sleep section only, so it can also be used for a fussy baby, travel, or the car later. Also decide whether its library is fresh or extends the existing Garbh Sanskar audio library. Default assumption for this build: a reusable player with its own new baby-sleep library, kept separate from the Garbh Sanskar (pregnancy, baby-connection) library so the two do not blur. Mark the library source as REQUIRED-CONFIRM in the data so it is easy to repoint.

---

## 10. Videos (do NOT build videos)

One explainer video placeholder per major area, each with a title, intended length, and slot id, rendered to look intentional in the layout:
- Sleep needs by age (Area 1).
- Regressions (Area 3).
- Bedtime routine plus malish follow-along (Area 4).
- Gentle settling demo (Area 2).
- Safe sleep (Area 5).
- Optional real-parent "night waking is normal, here is what helped" clip (Area 2 or 6).

---

## 11. Paid layer

Only the human help: the **gentle infant-sleep consultation [HAVE]**, positioned as gentle and co-sleeping-compatible, NOT sleep training. Surface it only on the night-waking area (Area 2) and the regressions area (Area 3), with a short "who this is for" line and a 2-tap booking flow wired to a placeholder scheduling hook. Everything readable and every tool stays free.

---

## 12. Build output expected

- A complete, navigable Sleep section: landing screen, all seven areas, and the three tools.
- Every page built in its specified FORMAT (chart-card, comparison table, step-list, cards, short article, flagged callout), never as generic prose, and never as filler. Real, plain, warm placeholder copy following the tone rules and the page template. No lorem ipsum. Drop any page that would only exist to look complete.
- Safe-sleep pages built as specified, bed-sharing harm-reduction framed, the doctor red-flag callouts (night waking, noisy breathing) visible and not buried.
- The three tools working: quick check (reads Area 1 data), non-gamified sleep log, and the reusable Sleep Sounds player with sleep timer on by default and a safe default volume.
- Clean data models for the age cards, articles, comparison tables, and audio tracks so content can be added or edited without touching layout code.
- Video placeholders on every major area and audio placeholders for every Sleep Sounds track, each with title, length, and slot id.
- Free content and tools fully open; the paid sleep consult gated and wired to a placeholder booking flow, surfaced only on Areas 2 and 3.
- The Sleep Sounds player built as a reusable app-wide audio component per the flagged default, with the library source marked REQUIRED-CONFIRM.
- Reuse the existing Flutter design system, components, and routing.

Build it area by area in the order above, so each screen is complete and reviewable as you go.
