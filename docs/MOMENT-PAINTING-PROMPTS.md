# Celebration-page paintings: one ChatGPT prompt per moment

For the five celebration pages (`PvCelebrationScreen`, `lib/screens/v2/pv_celebration.dart`, 2026-10-26).
Each prompt is complete on its own. Paste one, generate, and save the image under the name given. Claude converts
it to `assets/moments/<name>.webp` (1024 square, lossy WebP, like `assets/phases/`) and adds the moment to
`kMomentPaintings` in `lib/screens/v2/pv_moment_paintings.dart`. Until then each page shows the phase painting it
borrowed (phase 1, phase 20, or the child's phase for a milestone).
House style: the phase paintings (`docs/PHASE-PAINTING-PROMPTS.md`). The positive test keeps its own page and has
no painting here.

| Moment | File | Page |
|---|---|---|
| Birth | `birth` | `openBirthCelebration` |
| Trying again | `try_again` | `pv_try_again.dart` |
| A new pregnancy | `new_pregnancy` | `pv_add_pregnancy.dart` |
| Turning six | `turning_six` | `sk_turning_six.dart` |
| A milestone | `milestone` | `pp_milestones_screen.dart` (DOOR-CONTENT-OWED DV2) |

## Birth -> birth

```
Soft hand-painted gouache illustration on lightly textured paper, the same house style as a warm Indian parenting app: flat matte brush strokes, gentle grain, muted earthy palette, no hard outlines, soft shading. A large pale cream circle sits behind the figures like a soft sun, on a flat solid warm apricot background that fills the frame. An Indian mother with long dark wavy hair, in a soft cotton kurta with a small leaf print, sits propped on pillows holding a newborn swaddled in a cream cotton cloth against her chest; the baby's tiny hand is curled around her finger. The father, with short dark hair and a neat beard, in a sage-green kurta, sits close beside her with one arm around her shoulders, looking down at the baby. Faces calm and tender, the mother's eyes closed in quiet relief. Square 1:1 frame, figures centred with generous space around them, the scene readable at a small round crop. No text, no letters, no logos, no watermark, no borders, no extra people.
```

## Trying again -> try_again

```
Soft hand-painted gouache illustration on lightly textured paper, the same house style as a warm Indian parenting app: flat matte brush strokes, gentle grain, muted earthy palette, no hard outlines, soft shading. A large pale cream circle sits behind the figures like a soft sun, on a flat solid pale sage green background that fills the frame. An Indian couple sit side by side on a low floor cushion, shoulders touching: the mother has long dark wavy hair and wears a soft cotton kurta with a small leaf print; the father has short dark hair and a neat beard and wears a sage-green kurta. Between them a gender-neutral toddler with short dark hair, in plain cream cotton clothes, leans on the mother's knee. Together the three of them look at a small terracotta pot in the mother's hands with one new green seedling in it. Faces calm and hopeful, eyes lowered. Square 1:1 frame, figures centred with generous space around them, the scene readable at a small round crop. No text, no letters, no logos, no watermark, no borders, no extra people.
```

## A new pregnancy -> new_pregnancy

```
Soft hand-painted gouache illustration on lightly textured paper, the same house style as a warm Indian parenting app: flat matte brush strokes, gentle grain, muted earthy palette, no hard outlines, soft shading. A large pale cream circle sits behind the figures like a soft sun, on a flat solid dusty rose pink background that fills the frame. An Indian mother with long dark wavy hair, in a soft cotton kurta with a small leaf print and a gently rounded early bump, sits cross-legged on the floor. A gender-neutral child of about three, with short dark hair and plain soft mustard cotton clothes, kneels beside her and rests a small hand and one cheek against her bump, eyes closed, listening. The mother's hand rests on the child's back. The father, with short dark hair and a neat beard, in a sage-green kurta, sits just behind them, smiling softly. Faces calm and tender. Square 1:1 frame, figures centred with generous space around them, the scene readable at a small round crop. No text, no letters, no logos, no watermark, no borders, no extra people.
```

## Turning six -> turning_six

```
Soft hand-painted gouache illustration on lightly textured paper, the same house style as a warm Indian parenting app: flat matte brush strokes, gentle grain, muted earthy palette, no hard outlines, soft shading. A large pale cream circle sits behind the figures like a soft sun, on a flat solid soft sky blue background that fills the frame. A gender-neutral Indian child of about six, with short dark hair and plain cream and sage cotton clothes, a small cloth satchel across one shoulder, stands holding an open picture book and points at a page with quiet delight. The mother, with long dark wavy hair, in a soft cotton kurta with a small leaf print, kneels beside the child at the same height, one arm around them, reading along. Faces calm and proud, eyes on the book. Square 1:1 frame, figures centred with generous space around them, the scene readable at a small round crop. No text on the book or anywhere, no letters, no logos, no watermark, no borders, no extra people.
```

## A milestone -> milestone

```
Soft hand-painted gouache illustration on lightly textured paper, the same house style as a warm Indian parenting app: flat matte brush strokes, gentle grain, muted earthy palette, no hard outlines, soft shading. A large pale cream circle sits behind the figures like a soft sun, on a flat solid soft mustard yellow background that fills the frame. A gender-neutral Indian toddler with short dark hair, in plain cream cotton clothes, stands with both small arms raised high in delight. The mother, with long dark wavy hair, in a soft cotton kurta with a small leaf print, kneels facing the child with her hands together in a soft clap, smiling. A few small marigold petals drift in the air between them. Faces joyful but calm. Square 1:1 frame, figures centred with generous space around them, the scene readable at a small round crop. No text, no letters, no logos, no watermark, no borders, no extra people.
```
