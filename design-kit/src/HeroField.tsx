import * as React from 'react';

/** Design width. Everything in ParentVeda is composed for a 390pt phone. */
const W = 390;

function hsl(h: number, s: number, l: number, a = 1) {
  const hue = ((h % 360) + 360) % 360;
  return a === 1
    ? `hsl(${hue} ${s * 100}% ${l * 100}%)`
    : `hsl(${hue} ${s * 100}% ${l * 100}% / ${a})`;
}

export interface PVHeroFieldProps {
  /**
   * Base hue of the field, in degrees. 273 is the brand violet and the default.
   * A stage or a phase may shift it; the app moves it per trimester.
   */
  accentHue?: number;
  /**
   * 0–5. Moves the two arcs along their paths so consecutive weeks are not the
   * same picture. A hero that never changes is furniture by the second week.
   */
  variant?: number;
  /** Field height in px before the sheet begins. */
  height?: number;
  /** Chrome that sits ON the field — a back row, a spine chip, the week title. */
  children?: React.ReactNode;
  /** The page content. Renders as an opaque sheet lifted over the field. */
  sheet?: React.ReactNode;
}

/**
 * The top of every V3 screen: a chromatic field with the page riding over it
 * as an opaque sheet.
 *
 * **The field fills the page and does not scroll.** That is the structural
 * point, not a visual one — a header that scrolls away leaves a seam where the
 * page changes character, and the sheet-over-field arrangement is what removes
 * it. Content belongs in `sheet`; only chrome belongs in `children`.
 *
 * Three things in the painting are deliberate and worth not "simplifying":
 *
 * — **Two hues, 34° apart, not one.** A single-hue gradient is one colour at
 *   three lightnesses, which is a wash rather than a picture and reads exactly
 *   as flat as it is. The second hue gives the gradient somewhere to travel to.
 *
 * — **Arcs, not a blob.** These are the edges of very large circles, mostly
 *   off-canvas, so what you see is a long shallow curve — depth, rather than an
 *   object sitting on top of something. A soft round gradient floating in the
 *   middle is what every AI-built page has.
 *
 * — **A 3% dot grid.** Individually invisible; collectively it stops the
 *   gradient being perfectly smooth, which is the whole difference between "a
 *   colour" and "a surface". Every printed thing has tooth.
 *
 * ⚠️ Type on the field moves one ink tier darker than it would on the sheet —
 * a grey loses contrast against a chromatic ground much faster than against a
 * neutral one. Use `PVSectionEyebrow on="field"` rather than the sheet variant.
 */
export function PVHeroField({
  accentHue = 273,
  variant = 0,
  height = 300,
  children,
  sheet,
}: PVHeroFieldProps) {
  const shiftedHue = accentHue + 34;
  const deep = hsl(accentHue, 0.58, 0.62);
  const mid = hsl(shiftedHue, 0.52, 0.74);
  const pale = hsl(accentHue, 0.4, 0.9);
  const ground = 'var(--pv-ground)';

  const t = (((variant % 6) + 6) % 6) / 6;
  const c1 = { cx: W * (0.82 - t * 0.3), cy: -height * (0.22 + t * 0.16), r: W * (0.95 + t * 0.3) };
  const c2 = { cx: W * (0.1 + t * 0.5), cy: height * (0.74 - t * 0.14), r: W * (0.62 + (1 - t) * 0.26) };
  const arcFill = hsl(shiftedHue, 0.5, 0.84, 0.5);

  return (
    <div className="pv-hero">
      <svg
        className="pv-hero__field"
        style={{ height }}
        viewBox={`0 0 ${W} ${height}`}
        preserveAspectRatio="xMidYMid slice"
        aria-hidden="true"
      >
        <defs>
          <linearGradient id="pvField" gradientUnits="userSpaceOnUse" x1={W} y1={0} x2={0} y2={height * 0.62}>
            <stop offset="0" stopColor={deep} />
            <stop offset="0.34" stopColor={mid} />
            <stop offset="0.78" stopColor={pale} />
            <stop offset="1" stopColor={ground} />
          </linearGradient>
          <pattern id="pvTooth" width="9" height="18" patternUnits="userSpaceOnUse">
            <circle cx="6" cy="6" r="1.15" fill="#fff" opacity="0.03" />
            <circle cx="1.5" cy="15" r="1.15" fill="#fff" opacity="0.03" />
          </pattern>
        </defs>

        <rect width={W} height={height} fill="url(#pvField)" />
        <circle cx={c1.cx} cy={c1.cy} r={c1.r} fill="#fff" opacity="0.22" />
        <circle cx={c2.cx} cy={c2.cy} r={c2.r} fill={arcFill} />
        <rect width={W} height={height * 0.8} fill="url(#pvTooth)" />
      </svg>

      {/* Ends 44px BEFORE the field does, so the sheet always overlaps the
          field's bottom edge and there is no seam to see. */}
      <div className="pv-hero__chrome" style={{ minHeight: sheet ? Math.max(0, height - 44) : height }}>
        {children}
      </div>

      {sheet ? <div className="pv-hero__sheet">{sheet}</div> : null}
    </div>
  );
}

export interface PVSpineChipProps {
  /** "WEEK 20", "DAY 4", "CYCLE DAY 12" — where she is on the stage's spine. */
  children: React.ReactNode;
  onClick?: () => void;
}

/**
 * The small chip on the field naming where she is on the stage's spine, and
 * opening it.
 *
 * ⚠️ A hard-won detail: this chip is a *destination*, not a tab shortcut. It
 * pushes the spine screen. An earlier version reused the grid's tap handler,
 * which routed to a tab index, and week 40's chip quietly opened the classic
 * home instead. A callback named after a gesture says nothing about where it
 * goes — name the destination.
 */
export function PVSpineChip({ children, onClick }: PVSpineChipProps) {
  return (
    <button className="pv-spine-chip" onClick={onClick} type="button">
      {children}
    </button>
  );
}
