# -*- coding: utf-8 -*-
"""Build launcher icons for both flavours from the real ParentVeda mark.

Two outputs per density:

  ic_launcher.png            legacy square tile, pre-masked with rounded
                             corners (pre-Android-8 launchers apply no mask)
  ic_launcher_foreground.png adaptive foreground, transparent, mark held well
                             inside the safe zone

ADAPTIVE SAFE ZONE, since it is the thing that gets this wrong: the canvas is
108dp but a launcher may mask it down to a ~66dp circle. Anything outside that
can be clipped on somebody's phone. So the mark sits at 50% of the canvas and
the doctor badge stays inside the same circle rather than in a corner.

The doctor build differs by one element: a purple "+" disc, which is what the
app is actually called (ParentVeda+). Not a recolour — a hospital-teal version
of a family logo would read as a different company, and it is the same company.
"""
import os
from PIL import Image, ImageDraw

SRC = 'assets/brand/pv-mark.png'
PARENT_RES = 'android/app/src/main/res'
DOCTOR_RES = 'android/app/src/doctor/res'

WHITE = (255, 255, 255, 255)
PURPLE = (0x6A, 0x30, 0xB6, 255)

LEGACY = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}
ADAPTIVE = {'mdpi': 108, 'hdpi': 162, 'xhdpi': 216, 'xxhdpi': 324, 'xxxhdpi': 432}

# Render at 8x and downsample: PIL's resize on a hard-edged logo alias badly at
# 48px otherwise, and a launcher icon is mostly judged at exactly that size.
SS = 8


def mark():
    im = Image.open(SRC).convert('RGBA')
    return im.crop(im.getbbox())      # trim the transparent margin first


MARK = mark()


def fitted(box):
    """The mark scaled to fit a square of `box` px, aspect kept."""
    w, h = MARK.size
    s = box / max(w, h)
    return MARK.resize((max(1, round(w * s)), max(1, round(h * s))),
                       Image.LANCZOS)


def badge(img, canvas, plus_frac, centre_frac):
    """The '+' disc, placed inside the safe circle rather than at a corner.

    THE ARITHMETIC THAT MATTERS, because eyeballing it put the badge outside
    the mask on the first attempt. The safe circle has radius 0.305 of the
    canvas (66/108/2). A badge on the diagonal sits (centre_frac - 0.5) * sqrt2
    away from the middle, so what has to hold is:

        (centre_frac - 0.5) * 1.414 + plus_frac  <=  0.305

    A corner placement fails this even when each axis looks comfortably inside,
    which is exactly how it got missed.
    """
    d = ImageDraw.Draw(img)
    r = canvas * plus_frac
    cx = canvas * centre_frac
    cy = canvas * centre_frac
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=PURPLE)
    # White plus. Bar thickness ~28% of the disc reads at 48px; thinner vanishes.
    arm, th = r * 0.52, r * 0.28
    d.rounded_rectangle([cx - arm, cy - th / 2, cx + arm, cy + th / 2],
                        radius=th / 2, fill=WHITE)
    d.rounded_rectangle([cx - th / 2, cy - arm, cx + th / 2, cy + arm],
                        radius=th / 2, fill=WHITE)


def legacy(size, doctor):
    c = size * SS
    img = Image.new('RGBA', (c, c), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([0, 0, c - 1, c - 1], radius=c * 0.22, fill=WHITE)
    m = fitted(c * 0.68)
    img.paste(m, ((c - m.width) // 2, (c - m.height) // 2), m)
    if doctor:
        # Legacy tiles are shown as drawn on pre-Android-8, so the badge can
        # sit further out and read bigger.
        badge(img, c, 0.155, 0.70)
    return img.resize((size, size), Image.LANCZOS)


def foreground(size, doctor):
    c = size * SS
    img = Image.new('RGBA', (c, c), (0, 0, 0, 0))
    # Mark a shade smaller than the parent's, to buy the badge room without
    # pushing it past the mask. The two icons still read as the same size
    # because the launcher masks both to the same circle.
    m = fitted(c * (0.47 if doctor else 0.50))
    img.paste(m, ((c - m.width) // 2, (c - m.height) // 2), m)
    if doctor:
        # (0.645-0.5)*1.414 + 0.082 = 0.287 <= 0.305. Verified by rendering
        # the mask, not by inspection.
        badge(img, c, 0.082, 0.645)
    return img.resize((size, size), Image.LANCZOS)


def write(res, doctor):
    for dens, px in LEGACY.items():
        p = os.path.join(res, f'mipmap-{dens}')
        os.makedirs(p, exist_ok=True)
        legacy(px, doctor).save(os.path.join(p, 'ic_launcher.png'))
    for dens, px in ADAPTIVE.items():
        p = os.path.join(res, f'mipmap-{dens}')
        foreground(px, doctor).save(
            os.path.join(p, 'ic_launcher_foreground.png'))
    print(('doctor ' if doctor else 'parent ') + res, '->', len(LEGACY) * 2,
          'files')


write(PARENT_RES, False)
write(DOCTOR_RES, True)
