# ParentVeda V3 — how to build with this kit

ParentVeda is a calm, India-first companion for couples across four life stages:
trying to conceive, pregnancy, parenting, and skilling. It is often opened by
someone who is worried. Everything below follows from that.

The shipped app is **Flutter**; this kit is its React mirror, so designs made
here are read by humans and rebuilt in Dart. Compose freely — but do not invent
new visual vocabulary, because anything not in this kit has to be argued for
twice.

## 1. Wrap every screen in `PVScreen`

```jsx
<PVScreen>
  <PVHeroField
    accentHue={273}
    variant={2}
    height={230}
    sheet={
      <>
        <PVSectionEyebrow>Where to go</PVSectionEyebrow>
        <PVBlockGrid columns={3}>
          <PVBlockTile label="Scans & tests" hue={PV_HUES.scans} mark={<PVIcon name="scan" size={34} />} />
          <PVBlockTile label="Nutrition" hue={PV_HUES.practice} mark={<PVIcon name="leaf" size={34} />} />
          <PVBlockTile label="Read" hue={PV_HUES.read} mark={<PVIcon name="book" size={34} />} />
        </PVBlockGrid>
        <div style={{ height: 28 }} />
        <PVSectionEyebrow>What changed</PVSectionEyebrow>
        <PVCard>
          <PVText role="cardTitle">Your baby can hear you now</PVText>
          <div style={{ height: 8 }} />
          <PVText role="bodySm">Reading aloud is worth the five minutes.</PVText>
        </PVCard>
      </>
    }
  >
    <PVSpineChip>Week 20</PVSpineChip>
    <PVText role="display">Halfway</PVText>
  </PVHeroField>
</PVScreen>
```

`PVScreen` applies `.pv-root`, which sets the page ground, the base ink and
Manrope. **Without it the screen renders on the host page's background in the
browser's default serif** — the single most common way a design comes back not
looking like ParentVeda. It is not a context provider; there is nothing to
configure.

Compose for a **390pt phone**. Spacing tuned only at desktop width falls apart
on the device this ships to.

## 2. The styling idiom: tokens, not values

There is **no utility-class system here.** Style your own layout glue with
inline styles or your own CSS, and take every value from a token:

| Family | Tokens |
|---|---|
| Surface | `--pv-ground` `--pv-surface` `--pv-surface-alt` `--pv-line` |
| Ink | `--pv-ink-1` `--pv-ink-2` `--pv-ink-3` |
| Accent | `--pv-action` — and `--pv-danger` / `--pv-success` for semantics only |
| Spacing | `--pv-space-xs` `-sm` `-md` `-lg` `-xl` `-xxl` (4 · 8 · 12 · 20 · 28 · 40) |
| Radius | `--pv-radius-sheet` `-card` `-row` `-block` `-well` `-pill` |
| Page | `--pv-page-pad` (18, everywhere) · `--pv-nav-clearance` |
| Shadow | `--pv-shadow-card` `--pv-shadow-sheet` — tinted, never black |

Type never takes a raw size. Use `<PVText role="…">` with one of nine roles:
`display` `title1` `title2` `title3` `cardTitle` (Fraunces) and `body` `bodySm`
`label` `meta` (Manrope). **Nothing exists between them.** Body never goes
below 13 — mobile type is bigger than desktop type, not smaller.

## 3. Five rules that are not preferences

1. **No filled buttons.** `PVButton` is an outlined pill and has no `variant`
   prop. If a screen seems to need a big violet call-to-action, put the action
   in the lower third instead.
2. **`--pv-action` is spent at decision points only** — section eyebrows, links,
   the active nav tab, a focus ring. Never a background, never a card fill,
   never a chevron on every row. A violet chevron everywhere makes violet mean
   "row" instead of "the one thing worth doing".
3. **The ground is near-neutral (`#F5F3F6`), never cream.** A brand colour is
   not an interface colour. Cream + serif + terracotta is the generic default
   this system exists to avoid.
4. **No decorative emoji.** `PVIcon` is the whole icon vocabulary.
5. **A feature is never hidden.** An empty section renders `PVEmptyState`, not
   nothing. The empty state is the feature's advertisement.

Two more that catch people out: **type on the hero field moves one ink tier
darker** than on the sheet (use `<PVSectionEyebrow on="field">`), because a grey
loses contrast against a chromatic ground far faster than a neutral one. And
**no card inside a card** — reach for `PVFactBlock`.

## 4. Voice

Write as a calm, specific companion. Name a section for what the reader gets,
never for a content type — "WHERE TO GO" beats "LINKS", "WHAT CHANGED" beats
"ARTICLES". Placeholders state their value ("Once we have them verified for
your city") rather than faking a row, and are not tappable.

**Never a diagnosis, never a personalised probability.** Anything clinical routes
calmly to a doctor. `--pv-danger` means "this will delete something" — it is
never used for medical urgency, which stays calm and uncoloured.

## 5. Where the truth lives

Read these before styling anything: `styles.css` and its imports (the full token
set), and `components/<group>/<Name>/<Name>.prompt.md` for each component's own
usage notes and rationale.
