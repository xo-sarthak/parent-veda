import * as React from 'react';

/**
 * The six hues of the pregnancy grid, in grid order.
 *
 * Assigned by MEANING, not by prettiness — clinical things take the cool end,
 * bodily and warm things the warm end. That is why Scans is the only blue on
 * the grid, and why it is the one tile a mother finds without reading.
 */
export const PV_HUES = {
  practice: 104, // sage — calm, ritual
  week: 26, // peach — growth
  scans: 206, // blue-grey — clinical, the only cool tile
  read: 42, // sand
  watch: 344, // dusty rose
  ask: 268, // soft violet, tying back to the brand
  sleep: 232,
  feeding: 104,
  health: 186,
} as const;

export interface PVBlockTileProps {
  /** Two words at most — the wells are ~73px wide on a 360dp phone. */
  label: string;
  /**
   * Hue in degrees, 0–360. Saturation and lightness are FIXED by token and
   * cannot be passed: that is the whole mechanism by which twelve tiles read
   * as one family rather than twelve opinions. Never hand-pick a tint.
   *
   * Use `PV_HUES` where a subject already owns one. A hue belongs to a subject
   * and stays with it everywhere, and two doors never share a hue on one screen.
   */
  hue: number;
  /** A drawn mark, usually `<PVIcon size={34} />`. */
  mark?: React.ReactNode;
  /**
   * `notReady` is a door that will exist and does not yet. It stays visible and
   * says so — a feature is never hidden, because the empty state is the
   * feature's advertisement.
   */
  state?: 'live' | 'notReady';
  /** Shown under the label when `state` is `notReady`. */
  soonLabel?: string;
  onClick?: () => void;
}

/**
 * One door on the grid: a pastel well with a drawn mark, and a label under it.
 *
 * The wells all come from one controlled wheel — fixed saturation (32%) and
 * lightness (91%), only the hue varying. Hand-picking a "nicer" tint for one
 * tile is the thing that breaks the set, because the eye reads the outlier as
 * an error rather than as emphasis.
 *
 * The mark is drawn line art, never an emoji or a photo. Marks are verified at
 * their real rendered size before shipping — several of ours read fine at
 * 200px and turned into mush at 34, which is the only size that matters.
 */
export function PVBlockTile({
  label,
  hue,
  mark,
  state = 'live',
  soonLabel = 'Soon',
  onClick,
}: PVBlockTileProps) {
  const notReady = state === 'notReady';
  return (
    <button
      className={`pv-tile${notReady ? ' pv-tile--not-ready' : ''}`}
      onClick={onClick}
      type="button"
      style={{ ['--pv-tile-hue' as string]: `${hue}deg` }}
    >
      <span className="pv-tile__well">{mark}</span>
      <span className="pv-tile__label">{label}</span>
      {notReady ? <span className="pv-tile__soon">{soonLabel}</span> : null}
    </button>
  );
}

export interface PVBlockGridProps {
  children: React.ReactNode;
  /** 3 for the six-door home, 4 when a stage has up to twelve brackets. */
  columns?: 3 | 4;
}

/** The grid the doors sit in. Everything is visible — there is no "See more". */
export function PVBlockGrid({ children, columns = 3 }: PVBlockGridProps) {
  return (
    <div className="pv-grid" style={{ gridTemplateColumns: `repeat(${columns}, 1fr)` }}>
      {children}
    </div>
  );
}
