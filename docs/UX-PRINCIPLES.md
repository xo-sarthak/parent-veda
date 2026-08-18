# ParentVeda — UX principles and the reasoning behind them

**Read this before designing anything. Feed it into a fresh session before the
first discussion.**

This is the *understanding* layer. `DESIGN-SYSTEM.md` is the *implementation*
layer — tokens, components, exact values. This file is why those values are what
they are, who we are building for, and what we learned from studying real
material so nobody has to study it again.

**It exists because context gets compacted and reasoning is the first thing
lost.** Values survive in code; the argument behind them does not.

---

# PART 0 — WHO WE ARE BUILDING FOR

**Every principle below is filtered through this. Generic UI advice assumes a
generic user, and ours is not.**

## 0.1 The audience

**Indian couples**, across four stages of one continuous life event:

| Stage | Who is using it |
|---|---|
| Trying to conceive | a couple, together — partner missions, shared cycle context |
| Pregnancy | mostly her, with him alongside (father mode is a real product) |
| Parenting 0–5 | both parents, often at different hours of the night |
| Skilling | the parents, on behalf of a child |

Reading in **English or Hindi (Devanagari)**.

⚠️ **This is a couples product that acquires a child, not a mother's app.** A
screen that only ever says "you" is missing half the audience, and the TTC and
parenting stages are where that shows first.

| Trait | What it changes |
|---|---|
| **Often anxious.** Anxiety is the baseline emotional state, not an edge case | Calm beats exciting. **Never** urgency, scarcity, countdowns, streak-breaking guilt |
| **Often exhausted.** Reading one-handed, at 2am, while holding a baby | Bigger targets, bigger type, fewer choices per screen, thumb-reachable actions |
| **Often a first-timer.** Does not know the vocabulary yet | Explain the word before using it. Never assume a scan name is understood |
| **Marketed at constantly**, and good at spotting it | Disclose commercial relationships plainly. One wrong-feeling upsell costs more trust than the paid layer earns |
| **Very wide digital literacy** | **Always label nav icons.** Never rely on an icon alone for navigation |
| **Very wide device and bandwidth range** | Drawn marks over photographs is a performance decision as well as a design one |
| **Reads Devanagari** | Devanagari runs **~30% wider** than the same English string and needs more line-height. Every label must survive it without reflowing |
| **May share the phone** | Health data is sensitive. Nothing personal in a notification preview |

## 0.2 The three things that follow

**(a) Calm is a feature, not a style.** A red banner, a countdown, a "you missed
3 days" — each is standard engagement design and each is harmful here.

**(b) We are never the authority.** A clinician outranks us. Every clinical
screen ends by routing calmly to a person, and never contradicts one.

**(c) We do not score anyone.** No percentage match, no ranked child, no
personalised probability. This is a hard product rule and it has already forced
two redesigns.

---

# PART 1 — THE SOURCES

Studied 2026-08-16. Transcripts pulled in full; key frames watched, because the
before/afters do not survive transcription.

| # | Video | What it gave us |
|---|---|---|
| 1 | 7 UI/UX mistakes that scream beginner | flow-first, effect restraint, spacing, component consistency, icons, redundancy, feedback |
| 2 | Every UI/UX concept in under 10 minutes | signifiers, hierarchy, whitespace over grids, 4pt, type, colour ramps, dark mode, shadows, states, micro-interactions, overlays |
| 3 | UX psychology principles | smart defaults, goal gradient, reciprocity, IKEA/endowment, loss aversion, anchoring |
| 4 | Everything about mobile app UIs | bottom bar, mobile type is bigger, one direction per section, four building blocks, one screen one job, bottom sheets, gestures, empty states |
| 5 | Top 5 UI tips, part 1 | differentiate with size/weight/colour, value over label, soft shadows, **shadow tinted to background** |
| 6 | Top 5 UI tips, part 2 | cards over lists, interaction cost, thumb zone, **empty-state anatomy**, visual cues |
| 7 | 5 advanced UX/UI tips | personalise by user stage, smarter search, **category screens**, input method by frequency |
| 8 | Mobbin MCP | *(largely a tooling ad. One usable idea: study shipped patterns before designing. Nothing else taken.)* |
| 9 | **How to design a great bottom navigation bar** | the whole nav spec — see Part 4 |
| 10 | **The 7 colour mistakes that ruin your UI** | 60/30/10, neutral balance, tinted neutrals, less black/white, dark mode ≠ inverse, semantic red |

Plus **68 Flo screenshots** in `~/Downloads/flo-screens`, which is where the
"information is the hero, not an illustration" conclusion came from.

---

# PART 2 — WHAT WE GOT RIGHT INDEPENDENTLY

Worth recording, because it is evidence the V3 instincts are sound and should
not be re-litigated.

| We do | The reference says |
|---|---|
| Drawn marks in tinted wells instead of stock photos | The endorsed category screen is exactly this. The version it calls junior work is **photo overlays with mismatched light** — "doesn't feel like these images belong to the same product" |
| Lavender-tinted neutrals rather than pure grey | "Take our neutral gray and add a hint of purple." Headspace does it |
| `ink1` = `#201C24`, not pure black | "Most of the text is light gray or dark purple, not even black… getting comfortable with more gray and less black is what differentiates mediocre designers from professional ones" |
| One controlled-pastel wheel, fixed S and L | Rotate the brand hue for analogous colours; use complementary across the wheel |
| Day 1, never Day 0 | The goal-gradient effect. "Never start a user at zero" |
| Outlined pill buttons, borders not fills | Ghost buttons; and neutral navigation so colour is reserved for what matters |
| Cards with a hairline border and no shadow | "Sometimes maintaining neutral balance means removing backgrounds altogether — a simple border is the best solution" |
| Empty sections render an invitation | "Turn empty states into opportunities" |

---

# PART 3 — THE PRINCIPLES

## 3.1 Design for the next question, not the inventory

Having an article, tool, product or consult **does not mean it must be shown**.
Surface something only when it helps the current job.

> **Show less, but make everything shown useful.**

The test, before adding anything: *if I remove this, does she lose something for
what she is doing right now?* If no, remove it.

## 3.2 One screen does one thing

Settings is settings. The only exception is a home screen. When you need to add
something, reach for a different **page**, not a denser layout.

## 3.3 Hierarchy is contrast, and the value beats the label

The difference between big and small, colourful and not, is what creates
hierarchy. The classic failure is styling the **label** at 24 and the **number**
at 14 — putting the emphasis on the word "Sales" rather than on 591.

> Label small and above. Value large and below.

## 3.4 Whitespace over grids

Grids matter for repeating content and responsiveness. Far more important is
letting things breathe. **Mobile needs more space than you think**, and the
4-point base exists so everything can always be halved.

## 3.5 Mobile type is bigger, not smaller

iOS base is 17px against macOS's 13px. The instinct to shrink on a small screen
is backwards. **For our audience, one step larger again.**

## 3.6 One direction per section

Desktop lays out in two directions at once. Mobile picks one per section — a
vertical stack or a horizontal rail, never both.

## 3.7 Do not double-nest cards

A bordered card inside a bordered card is padding on padding. Group with
whitespace instead.

## 3.8 Reduce interaction cost — expose, do not announce

A banner reading "Discover 100+ recipes" that must be tapped is a wall between
her and the value. Show three actual recipes.

## 3.9 Progressive disclosure

```
primary need → answer → likely next question → useful next action → optional deeper help
```

Someone who wants to understand a scan does not need five articles, three
videos, three tools, a product and a consult on one screen.

## 3.10 Every action gets a response

Press, loading, success, error. **If she taps and nothing changes, the app looks
broken** — a grey-out on tap is enough to say "it is coming".

## 3.11 Signifiers over instructions

A container means "these belong together". A filled container means "selected".
Grey means inactive. Get these right and you never write instructions.

## 3.12 Adapt to where she is

A new user, a returning user and a deeply engaged user should not get the same
screen. **Use `if` statements over state we already hold** — what is booked,
which week, what she logged. Do not build an intent engine; three conditions get
most of the value.

## 3.13 Search is never a blank box

Tapping search is a moment of intent. Offer **recent searches** and
**suggestions matched to her stage**. She can ignore them and type.

⚠️ **We do NOT show "popular" or "trending" searches**, which is what the generic
advice recommends. On a health app the popular queries are *miscarriage*,
*ectopic*, *is my baby okay* — and putting those in front of someone who was
looking for something else plants a fear she did not arrive with. Social proof is
a fine mechanic for a shopping app and an actively harmful one here.

## 3.14 Input method follows frequency

Sliders and wheels for one-time, low-precision setup. Text fields and steppers
for anything repeated or precise. *Logging food daily with a slider is
punishment.*

## 3.15 Empty states are the feature's advertisement

**Anatomy, from the reference:**

1. an illustration in a soft tinted circle *(ours: a drawn mark in a hue well)*
2. **a statement of value, not of absence** — "Start managing your projects and
   stay organised", never "You have no projects"
3. two or three actionable tips with small icons
4. one CTA

Two kinds: **nothing yet** (say what this will hold) and **no results**
(acknowledge the query, suggest a fix, offer a way out).

## 3.16 Effects: restraint

Gradients only between variations of the same hue — or none at all. Shadows soft
and **tinted to the background**. *If the shadow is the first thing you notice,
it is wrong.*

## 3.17 Icons

Sized to the **line-height of the text beside them**. One library, one stroke
weight, one complexity level. Different families may coexist **only in visually
separate areas doing different jobs**. Familiar over clever — a magnifying glass,
not binoculars.

⚠️ **Icons need no colour by default.** Their job is recognition. Colour is
reserved for status.

---

# PART 4 — THE BOTTOM NAVIGATION

Its own part because **it is on nearly every screen**, it is the most-tapped area
in the app, and it must be right from day one.

## 4.1 What belongs in it

**Good:** home/dashboard · search or discover · create/add · messages or
notifications · profile.
**Bad:** help · log out · legal · anything rarely used.
**Never:** back/forward buttons or a logo — those are top-navigation elements,
and moving them down violates what users already expect from every other app.

**A central CTA is a smart move — but not for us.** The reference recommends
breaking the primary action out into a raised centre button. We already have the
Ask Veda FAB in that region, with tests holding its clearance
(`global_fab_layout_test`, `ttc_fab_clearance_test`). Two floating actions
competing in the thumb zone is worse than either alone.

> **Our nav is destinations only. The one floating action is Ask Veda.**

## 4.2 Numbers

| | |
|---|---|
| Tabs | **3–5**, absolute max 6. Fewer means more breathing room and fewer mis-taps |
| Icon | **24px** |
| Label | **10–12px**, single line, short. Never wraps to two lines |
| Tap target | **≥ 44×44** — based on an actual thumb |
| Home indicator | **~34px. Never overlap it, never hide it.** Sit above the safe area, or she triggers the home gesture reaching for a tab |

## 4.3 The active state — reasoned, not quoted

**At least TWO visual changes.** Colour alone is not enough; text alone is not
enough. That part of the reference is sound and we keep it.

### ⚠️ Where I over-applied the reference, and the honest position

The nav video puts two versions side by side and marks **a container behind the
active icon** as wrong — "boxes around your tabs create visual noise". I wrote
that into these files as a rule.

**On reflection that is a stylistic opinion presented as a law, and it is not
one.** Material 3's navigation bar — the current Android standard — uses exactly
that: a pill behind the active icon. Millions of apps ship it and it is not a
defect.

So the correct reasoning for us is not "a video said no boxes". It is:

1. **Our labels are always on** (§4.10). That already gives a strong second
   signal, so a container becomes a *third* redundant one.
2. **`action` is the only saturated colour we spend** (`DESIGN-SYSTEM.md` §2.1).
   A filled violet pill is a third violet on a screen that has already spent its
   budget on hue wells.
3. **Calm over emphasis.** The nav should recede; it is not the content.

> **Our answer: filled icon + `action` colour + label at w700 in `ink1`. No
> container.**
>
> We land where the video landed, but because of our palette rule and our
> always-on labels — not because it was asserted.

**And what is actually wrong with ours today is the saturation, not the
container.** Both stages ship a *filled violet* pill/circle. Even if we later
wanted an indicator, it would be a soft tint, never a saturated fill.

## 4.4 Inactive state

**Reduce opacity rather than switching to a different colour** — it keeps the
scheme coherent. Minimum contrast **3:1** for UI components; poor contrast on
inactive items is a common accessibility failure.

## 4.5 Colour

**Neutral.** White, grey or dark. **Never a colour per tab** — that turns
navigation into a guessing game and pulls attention from the content. Reserve
brighter colour for key actions on the screen itself. Keep top and bottom
navigation consistent with each other.

## 4.6 Separating nav from content — "the mistake even pros make"

The nav must be visually distinct from the content behind it. Three valid ways:

1. a subtle 1px border
2. a different background from the page
3. **a small soft shadow above it**, giving a floating effect — keep it subtle

*(Ours floats with a shadow already — correct, and it needs the tint fix from
`DESIGN-SYSTEM.md` §2.5.)*

## 4.7 Badges — mostly not for us

The reference recommends badges freely. See §6.3: for this audience a badge is an
anxiety mechanic more often than an information one.

**Permitted:** a reply from a clinician · an appointment today · a partner's
message. **Not permitted:** new content, new articles, new products, anything
whose purpose is to bring her back.

When one does appear: small, top-right of the icon, `surface` outline, readable
numeral.

## 4.8 ⚠️ Conventional, deliberately

The reference encourages experimenting with unconventional nav shapes and
arrangements for a "distinctive edge".

**We decline.** Jakob's law cuts harder for our audience than for most: a parent
with mixed digital literacy, reading one-handed at 2am, benefits from navigation
that works exactly like every other app she uses. **Distinctiveness belongs in
the content and the drawn art, never in the navigation.**

## 4.9 Micro-interactions

Tap feedback (colour change, scale, ripple) · a sliding indicator between tabs
rather than a snap · a soft fade or slide between screens so navigation feels
connected rather than teleported.

## 4.10 ⚠️ The audience clause

> "If your audience is younger and tech-savvy you might get away with icons
> only. **If your users are older and less familiar with apps, labels below icons
> make navigation clearer and help them feel confident.**"

**Our audience is the second.** Labels are **always on**. This is not
negotiable and it is not a style choice.

---

# PART 5 — COLOUR THINKING

## 5.0 ⚠️ BRAND COLOUR IS NOT INTERFACE COLOUR

**The most important colour idea in this document, and the one the original app
got wrong.**

Look at the apps that have solved this. **Zepto** is purple — the logo, the
riders, the packaging, the splash. **Zomato** is red the same way. **Blinkit** is
yellow. Each is *unmistakably* that colour as a brand.

Now open any of them. **The interface is not painted that colour.** It is
near-white with dark text, and the brand colour appears only where a decision
happens: the primary button, the active tab, a price, a badge. Zepto is a purple
company with an almost colourless app, and that is not an accident or a
compromise — it is the correct answer.

### Why this is functional, not stylistic

1. **Colour only signals when its surroundings are quiet.** Paint the page
   purple and a purple button stops standing out. You spend the accent and get
   nothing for it.
2. **Content needs a neutral stage.** Baby renders, read covers, product
   photographs, a scan image — every one of them is contaminated by a tinted
   ground. A photograph on lilac looks wrong and no amount of art direction
   fixes it.
3. **A painted app restricts you.** Once the page is purple you cannot introduce
   twelve category hues, or a semantic red, or a warm illustration, without
   something clashing. **This is the real cost, and it is the one the user
   identified.** The palette becomes a cage.
4. **Contrast headroom.** Text on a tinted ground has less room before it fails
   accessibility.
5. **The brand can move.** Re-tune a brand colour and you repaint a logo, not an
   application.

### Where the accent IS allowed

`action` appears at **decision points and state**, nowhere else:

- section eyebrows *(our signature — this is the one "decorative" exception, and
  it earns it because it is what identifies a screen as ours)*
- links and inline text actions
- the active navigation tab
- a focus ring
- a single primary commit button, where one exists

**Not** as a page background. **Not** as a card fill. **Not** as a chevron on
every row. **Not** as a default icon colour.

### ⚠️ We were guilty of this, and the numbers proved it — FIXED 2026-08-16

| Token | Hue | **Saturation** | Lightness | |
|---|---|---|---|---|
| `ink1` | 270 | **12%** | 13% | ✅ always was |
| `ink2` | 266 | **9%** | 36% | ✅ |
| `ink3` | 266 | **7%** | 55% | ✅ |
| `ground` | 273 → 280 | **36% → 16%** | 95% → 96% | fixed |
| `surfaceAlt` | 272 → 280 | **33% → 16%** | 92% → 93% | fixed |

**Our inks were always right** — 7–12% saturation is a genuine whisper of violet,
exactly the Zepto move. **Our surfaces were three to five times more saturated.**
At S 36% a colour is not a neutral carrying a hint of brand; it is lilac, and it
reads as "the app is purple".

The inks proved we already knew how to do this. The surfaces simply never got the
same treatment — which is the ordinary way this goes wrong. Nobody decides to
paint the app; someone picks a tint for one screen, it works, it gets copied, and
four years later it is the definition of a neutral.

> **The rule: a neutral may carry the brand hue, but not the brand saturation.**
> Match the surfaces to the inks — same hue family, single-digit-to-low-teens
> saturation.

Shipped as `#F5F3F6` / `#EDEAF0` in `_baseline`. The three candidates and the
reasoning behind picking the middle one are in `DESIGN-SYSTEM.md` §2.1(0).

### The counter-intuitive part

Quietening the page does **not** make the app less colourful. The V3 hero field
is a saturated violet gradient that was sitting on a lilac page — **it was
competing with its own background.** On a near-neutral page the same field reads
as *more* vivid, because contrast is what creates presence. The twelve category
hues gain the same benefit.

### ⚠️ And the trap on the other side of it

"Don't make it dull" is the correct instinct and it points at the wrong dial.
The reflex fix is to raise **lightness** — push the ground toward white. That is
the one move that breaks this system, because we draw elevation as a *line, not a
blur*: the only thing separating a white card from the page is the few lightness
points between them. Spend those on brightness and every card in the app goes
flat.

**Dull and flat look alike in a screenshot and are opposite faults.** Dull is too
little colour, and the fix is saturation — somewhere that isn't the page. Flat is
too little separation, and the fix is lightness distance. Reaching for the second
dial to solve the first is how a quiet interface becomes a washed-out one.

## 5.1 60 / 30 / 10

60% dominant neutral · 30% secondary · 10% accent.

**Ours:** `ground` + `surface` are the 60, the pastel wells and `surfaceAlt` the
30, `action` the 10.

⚠️ **§5.0 is why our 60 used to be wrong.** The dominant 60 is supposed to be the
*neutral*. Ours was a saturated lilac, so the rule was broken at the largest
surface on every screen — and a rule broken at the largest surface is not really
in force anywhere. Closed 2026-08-16 for V3; still open in the other three token
systems (`AppTheme`, `pp_common`, `ttc_common`), which is a migration item, not a
second opinion.

## 5.2 Neutral balance

Backgrounds stay in the background. **Almost never a bright background.** Start
from a neutral, then **add a hint of the brand hue to the neutral** rather than
adding a colourful background.

That is precisely why our neutrals are lavender-tinted, and it is a large part of
why V3 looks considered rather than default.

## 5.3 Less black, less white

Pure black and pure white are not banned, but there is usually something better.
Secondary information takes a grey; borders take a lighter one. **Comfort with
grey over black is the professional tell.**

## 5.4 Deriving more colour from one brand colour

Rotate the brand hue slightly for **analogous** colours; go across the wheel for
a **complementary** one. If a brand colour fails contrast, darken it or use the
complement — adapting the brand colour to serve the design is normal, not
heresy.

## 5.5 ⚠️ Semantic colour — our gap

**Red and green belong in a palette even when they are not brand colours.** A
destructive action rendered in the brand colour "doesn't illustrate its
destructive nature".

> **We have no danger colour and no success colour.** Every delete in this app
> is currently violet. That is a real gap — see `DESIGN-SYSTEM.md` §2.1.

⚠️ **But the urgent strip stays calm and is NOT red.** That is a deliberate
exception for this audience: a red banner frightens the frightened and numbs
everyone else. **Red is for destructive confirmation; it is not for medical
urgency in a pregnancy app.** These are two different jobs and conflating them is
how a calm product becomes an alarming one.

## 5.6 Dark mode is not an inverse

Ours does not exist yet. When it does:

- lighter card than background creates depth — **there are no shadows in dark
  mode**
- brighten borders; dark colours need more separation than light ones to read
- **light greys, not pure white**, for most text; reserve white for the most
  important
- desaturate chips, logos and accents
- build the palette *with dark mode in mind* rather than flipping the light one

## 5.7 State colour

Hover lighter · pressed darker · disabled desaturated. **Mobile has no hover**,
so the press state carries it: a slightly darker fill makes it feel like pressing
into something.

---

# PART 6 — PSYCHOLOGY: ADOPTED, ADAPTED, REJECTED

The psychology material is the part of the reference set that needs the most
filtering, because **almost all of it was written for conversion**, and we are
not optimising a funnel — we are helping someone through pregnancy.

The deciding question for every one of them:

> **Would this still be right if she were frightened?**

## 6.1 ADOPTED

**Goal gradient — never start at zero.** Progress that begins at zero reads as
"you have not started". This is already why it is Day 1, not Day 0.

**Give real value before asking for anything.** Never gate the first useful thing
behind a signup. *(The reference frames this as reciprocity and a conversion
lever; for us it is simply how a trustworthy app behaves, and the framing is
worth dropping.)*

## 6.2 ADAPTED — right idea, wrong shape for us

### Smart defaults — **only outside the health record**

The reference says pre-fill every field with the most common choice, because
70–90% never change a default.

⚠️ **That statistic is exactly why this is dangerous for us.** If we pre-fill a
due date, a weight, a symptom or a medication, most people will accept it — and
we will have written fabricated clinical data into her record and then reasoned
from it. Our own rule is *derive, never ask; only ask for what is genuinely
unknowable*, and `Inferable` is default-deny.

> **Defaults are fine for preferences, filters, sort orders, reminder times.**
> **Never for anything that becomes part of her health record.**

### Anchoring — **honest context only**

Legitimate: "₹800–2,500 at a private lab", so she can recognise being
overcharged. **Never** placing a high number nearby to make our own price feel
small. Same mechanic, opposite intent.

### Personalisation — **for usefulness, not for stickiness**

The reference's version of the IKEA effect is explicit that the goal is to make
leaving *feel* like abandoning something she built. That is engineered sunk cost.

> We ask for what genuinely makes the app more useful — her stage, her week, her
> child's age — because it **is** more useful. We do not ask for things whose
> only purpose is to raise the cost of leaving.

## 6.3 REJECTED

**Loss aversion framing.** "Your files will be deleted", a countdown, an "I'll
risk it" dismiss button. It works, it is twice as motivating as gain framing, and
it is fear-based marketing aimed at someone whose baseline emotional state is
already anxiety. **No.**

**Urgency and scarcity of any kind.** No countdowns to an outcome, no "only 2
slots left", no streak-breaking guilt. This audience is marketed at constantly
and is good at spotting it.

**Notification badges as an engagement mechanic.** The nav reference recommends
badges freely. A red dot telling a sleep-deprived parent there are "3 new things"
manufactures compulsion, and the content behind it is almost never urgent.

> **Badges only for something time-sensitive and personal** — a reply from a
> clinician, an appointment today. **Never for content, never for marketing.**

**"Popular" and "trending".** See §3.13.

---

# PART 6b — WHAT WE DELIBERATELY DID NOT TAKE

Recorded so nobody re-imports it later thinking it was an oversight.

| From the references | Why not |
|---|---|
| **Loss-aversion framing** | fear marketing at an anxious audience |
| **Urgency, scarcity, countdowns, streaks** | same |
| **Smart defaults on clinical fields** | 70–90% accept a default; that would write fabricated health data into her record |
| **Personalisation to raise the cost of leaving** | engineered sunk cost. We personalise for usefulness |
| **"Popular"/"trending" searches** | on a health app the popular queries are frightening ones |
| **Free-flowing notification badges** | manufactured compulsion; content is almost never urgent |
| **A raised centre CTA in the nav** | collides with the Ask Veda FAB, which has clearance tests |
| **Unconventional / "distinctive" nav layouts** | familiarity beats distinctiveness for mixed digital literacy |
| **Anchoring to flatter our own prices** | the honest half — real price ranges — is kept; the persuasion half is not |
| **"Only ever one font family"** | a display serif plus a text sans is why V3 reads as editorial. We keep two and dropped the redundant third |
| **"Boxes behind active tabs are wrong"** | asserted, not argued; Material 3 does it. We reach the same conclusion by our own palette rule instead — §4.3 |
| **Chart-design advice** | we have almost no charts, and the ones we might have are banned from looking like scores |
| **Dark-mode detail** | correct, but we have no dark mode. Kept as a short "when we do", not as a spec |
| **Conversion framing throughout** | most of this material optimises funnels. We are helping someone through pregnancy |

---

# PART 7 — THE COSTLY LESSONS

Ours, learned the expensive way. Each has cost real time.

1. **Two flat regions meeting always show a seam.** Three attempts to blend a
   hero failed. Real apps do not blend — one surface, and content overlaps.
2. **A gradient that ends washes out at its own seam.** The field must belong to
   the *page*.
3. **A grey calibrated for a neutral ground collapses on a chromatic one.**
   Shipped twice.
4. **`const` on a widget showing store state silently stales the UI.** Dart
   canonicalises it, Flutter short-circuits the rebuild. **Five occurrences.**
5. **A callback named after a gesture says nothing about its destination.**
   Reusing an `onTap` made a chip reading WEEK 40 open the classic home.
6. **A wrong photograph is worse than an honest tint.** A duffel bag shipped
   under "Drowsy but awake: the hardest skill".
7. **Overlapping shapes at 92% alpha composite twice and show a seam.** A brain
   came out quilted; a book came out folded. One `Path`, several sub-paths.
8. **Marks must be verified at real size, offline, before shipping.** Caught: a
   leaf that should have been a brain, a settings-slider that should have been an
   abacus, a dial that should have been an eye, a wifi symbol that should have
   been a figure, a YouTube logo, a handbag.
9. **A category heading is our filing system, not her language.** Nobody has ever
   thought "I need the tools layer".
10. **Asking "what do you need?" and then showing categories asks twice.**

---

# PART 8 — THE TEST

Before any screen:

1. **Who is she and what is she doing right now?**
2. **What is the next thing she naturally needs?**
3. **Do we already have something that solves it?** → reuse it.
4. **Does this element genuinely help *this* journey?** → if no, it does not
   appear here, even if it exists.
5. **Would this still be right if she were frightened?**
6. **Could she tell this screen was built at a different time from the V3 home?**

> **The inventory tells us what we CAN use. Her journey tells us what we SHOULD.**
>
> She should never feel she is navigating our database of features. She should
> feel the app understood what she came to do.
