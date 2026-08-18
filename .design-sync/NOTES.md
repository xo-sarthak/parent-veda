# design-sync notes — ParentVeda

## What this repo actually is, and why the sync is unusual

**ParentVeda ships in Flutter/Dart. There is no JS design system to convert.**
The skill's converter expects a React package with a compiled `dist/`; this repo
has none, and the one JSX folder present (`parentveda-mobile-screens/`) is a
Claude Design *export* from 22 June 2026 (the Warm Nest direction), not a
library. It predates V3 and is not a sync input.

So `design-kit/` was created for this purpose: **a React mirror of the V3 design
language**, written from `docs/DESIGN-SYSTEM.md`. That file is the source of
truth. The mirror follows it; when they disagree, the doc is right and the
mirror is stale.

⚠️ **This deliberately breaks the skill's "ship what the customer already built,
never a reimplementation" principle, and it has to.** claude.ai/design renders
React; the app is Dart. A faithful port is impossible by construction, and the
usual justification for shipping real components — designs map 1:1 onto code
engineers ship — does not apply here either. What the kit buys instead is that
the rules become *unbreakable*: `PVButton` has no filled variant, so a design
agent cannot produce the filled violet button the house style bans.

The scope was chosen on that basis: 13 components that between them cover almost
every screen, not a full port. Adding a component is only worth it if it stops a
specific mistake.

## Setup facts a re-sync needs

- Build the kit first: `cd design-kit && npm run build` (tsup → `dist/index.js`
  + `.d.ts`, then `copy-css.mjs` concatenates `src/tokens.css` +
  `src/components.css` into `dist/kit.css`). `cfg.buildCmd` records it.
- Converter invocation, **from the repo root** (paths in the config are
  package-relative, and running it from inside `design-kit/` fails):
  ```
  node .ds-sync/package-build.mjs --config .design-sync/config.json \
    --node-modules ./design-kit/node_modules --entry ./design-kit/dist/index.js --out ./ds-bundle
  ```
- **Chromium: do not download Playwright's 200MB browser.** This machine has
  Chrome at `C:\Program Files\Google\Chrome\Application\chrome.exe`.
  `npm i playwright` in `.ds-sync/` with `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1`,
  then prefix every validate/capture with
  `DS_CHROMIUM_PATH="C:\Program Files\Google\Chrome\Application\chrome.exe"`.
  Without that env var the render check fails `[RENDER_SKIPPED]`.
- Fonts are `@fontsource` **latin-subset** css files listed in `cfg.extraFonts`
  (Fraunces 600; Manrope 400/600/700/800). The Flutter app fetches these at
  runtime via the `google_fonts` package, so there are no font files in the repo
  to point at — the npm packages are the only local source.
- `dist/kit.css` is one concatenated file rather than an `@import` chain, on
  purpose: the converter checks that every import in the `styles.css` closure
  resolves on disk, and a chain that resolves in the repo but not after copying
  is a silently unstyled bundle.
- `cfg.provider` is `PVScreen` (with `phone: false`). It is not a React context
  provider — it applies `.pv-root`. Without it every card renders on the host
  background in the browser's default serif.
- Almost every component carries `cardMode: "column"`. These are 390pt phone
  compositions and they overflow a multi-column grid cell; `column` is the
  documented remedy, not a workaround.

## Defects found while verifying, and what caused them

Worth keeping, because two of them are the kind that would silently return.

- **The hero field was being zoomed.** `.pv-hero__field` was `inset: 0`, so the
  SVG was scaled to cover the whole hero *including the sheet* — several times
  its design height — and `preserveAspectRatio: slice` cropped the deep corner
  off the gradient. The field is now pinned to the top at its own height.
- **The field left a visible seam.** With the sheet starting after the field,
  the field's bottom edge showed as a hard horizontal line wherever the gradient
  had not yet reached its final (ground) stop. The chrome now ends 44px before
  the field does, so the sheet always laps over that edge — which is also how
  the Flutter version behaves.
- **The leaf icon read as a crescent** at 34px. An outline alone is not a leaf;
  it needed its midrib. Consistent with the app's own repeated lesson that a
  drawn mark must be checked at its real rendered size, never at 200px.

**How the hero was verified:** `V3HeroField` was rendered straight from the Dart
into a PNG (a throwaway `flutter test` using `toImageSync` + `runAsync`) and
compared against the SVG port. That is the only true reference available, and it
settled a wrong call — the field genuinely is that pale, and the deep violet
survives only as a wedge at the top-right where the white arc cuts across. Use
the same technique before "correcting" the field again. `pumpAndSettle` +
`boundary.toImage()` hangs; `toImageSync` inside `tester.runAsync` works.

## Known render warns

None outstanding. The three `[RENDER_THIN]` and six `[GRID_OVERFLOW]` warns seen
during the run were all resolved (previews authored; `cardMode: column`), and
the final validate is clean. **A warn on a future run is therefore new** — look
at it rather than assuming it is background noise.

One informational line is expected and is not a defect:
`tokens: 56 defined, 53 referenced (1 missing, below threshold)` — that is
`--pv-tile-hue`, which `PVBlockTile` sets inline per tile rather than declaring
in `:root`.

## Re-sync risks — what can go stale silently

- ⚠️ **The mirror can drift from the Dart and nothing will tell you.** These are
  two hand-maintained copies of one design language. The specific values most
  likely to diverge: the palette in `lib/screens/v2/v2_palette.dart` (`_baseline`)
  vs `design-kit/src/tokens.css`, and the field recipe in
  `lib/screens/v2/v3_hero_field.dart` vs `HeroField.tsx`. **Diff those two pairs
  before every re-sync.**
- The ground and surfaceAlt were desaturated on 2026-08-16 (`#F3EEF7` → `#F5F3F6`,
  `#ECE5F2` → `#EDEAF0`). **Only `_baseline` changed in Dart.** The three older
  token systems (`AppTheme`, `pp_common`, `ttc_common`, ~35 hardcoded sites)
  still ship the old lilac, so the app and this kit currently disagree outside
  V3. That is a known migration item, not mirror drift.
- `--pv-shadow-card` is tinted here. **The Flutter side is still on
  `Colors.black.withValues(alpha: 0.10)`** and is known-wrong. The mirror is
  ahead of the app on purpose; do not "fix" the mirror to match.
- Toolchain assumed: Node 22.19, npm 11, tsup 8.5, and Chrome present at the
  path above. The font woff2s come from npm at install time, not from git.
- Nothing was verified on a real device — no Android device was attached during
  this run (the connected phone was an iPhone, charging only).
