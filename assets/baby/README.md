# Baby illustrations (per week)

The "How big am I?" card shows one illustration per week in **Baby** mode. Drop
image files here named by week and the app picks them up automatically. Any week
without an image falls back to the built-in vector drawing, so partial sets are
fine.

## File naming
- `week_04.jpg`, `week_05.jpg`, … `week_40.jpg`  (two-digit, zero-padded week)
- One file per week (weeks 4–40). Add as many as you have; missing weeks use the
  vector fallback.
- Source masters live in `lib/data/baby-images/` (named like `Week 20.jpeg`);
  they're copied + normalized into this folder as `week_NN.jpg`.

## Image specs
- **Format:** the current set is **JPEG with a soft-pink background baked in**
  (not transparent). The loader (`_BabyFigure` in
  `lib/widgets/week_cards/living_halo.dart`) **clips the image to a circle** so
  the square edges vanish and the image's own pink blends into the surrounding
  halo rings — the figure reads as floating in the ring. (A transparent PNG
  would also work; clipping is harmless on those.)
- **Content:** just the baby/fetus figure, centred, roughly filling the frame.
  Keep a consistent orientation across weeks (e.g. curled, facing left) so the
  progression reads smoothly. Keep the background pink in the same family as the
  app's `secondary` tones so the circular blend stays seamless.
- **Size:** square, ~**600×600 px** (renders crisp at the ~150 dp display size,
  `BoxFit.cover`). Same size for every week so they don't jump.
- **Style:** your call, but keep it consistent week to week.

## Licensing — important
Use only artwork you **own, commission, or have a commercial license for**
(e.g. royalty-free illustration packs, or an illustrator you hire). Do **not**
use screenshots or exported art from other apps — that's their copyright.

A "fetal development week by week" illustration set works perfectly here: even
small pose changes between adjacent weeks (a hand/leg shifted) read as growth.

## If you only have stage art (not all 37 weeks)
That's fine — name what you have (e.g. `week_06.png`, `week_12.png`, …) and tell
me which weeks each should cover; I'll map week ranges to the nearest image
instead of per-week files.
