import * as React from 'react';

export type PVIconName =
  | 'home'
  | 'calendar'
  | 'tools'
  | 'community'
  | 'profile'
  | 'book'
  | 'heart'
  | 'scan'
  | 'leaf'
  | 'bookmark'
  | 'bell'
  | 'search'
  | 'chevron'
  | 'plus';

export interface PVIconProps {
  name: PVIconName;
  /** Pixel box. 16 inside a button, 22 in the nav, 34 in a tile well. */
  size?: number;
  /** Defaults to `currentColor`, which is almost always what you want. */
  color?: string;
}

const PATHS: Record<PVIconName, React.ReactNode> = {
  home: <path d="M4 10.5 12 4l8 6.5V19a1 1 0 0 1-1 1h-4v-6H9v6H5a1 1 0 0 1-1-1z" />,
  calendar: (
    <>
      <rect x="3.5" y="5.5" width="17" height="15" rx="2.5" />
      <path d="M3.5 10.5h17M8 3.5v4M16 3.5v4" />
    </>
  ),
  tools: <path d="M14.5 3.5a4.5 4.5 0 0 0-4 6.6L3.8 16.8a2 2 0 0 0 2.8 2.8l6.7-6.7a4.5 4.5 0 0 0 5.6-5.9l-2.7 2.7-2.3-2.3 2.7-2.7a4.5 4.5 0 0 0-2.1-1.2z" />,
  community: (
    <>
      <circle cx="9" cy="9" r="3.2" />
      <path d="M3.5 19.5a5.5 5.5 0 0 1 11 0" />
      <path d="M16 6.6a3.2 3.2 0 0 1 0 5.6M17 14.4a5.5 5.5 0 0 1 3.5 5.1" />
    </>
  ),
  profile: (
    <>
      <circle cx="12" cy="8.5" r="3.6" />
      <path d="M4.8 20a7.2 7.2 0 0 1 14.4 0" />
    </>
  ),
  book: (
    <>
      <path d="M4 5.2A2.2 2.2 0 0 1 6.2 3H19v15H6.2A2.2 2.2 0 0 0 4 20.2z" />
      <path d="M4 18.4A2.2 2.2 0 0 1 6.2 16.2H19" />
    </>
  ),
  heart: <path d="M12 20s-7.4-4.6-7.4-9.4A4.1 4.1 0 0 1 12 8.2a4.1 4.1 0 0 1 7.4 2.4C19.4 15.4 12 20 12 20z" />,
  scan: (
    <>
      <path d="M4 8.5v-3A1.5 1.5 0 0 1 5.5 4h3M15.5 4h3A1.5 1.5 0 0 1 20 5.5v3M20 15.5v3a1.5 1.5 0 0 1-1.5 1.5h-3M8.5 20h-3A1.5 1.5 0 0 1 4 18.5v-3" />
      <path d="M7.5 12h9" />
    </>
  ),
  /* A leaf needs its midrib. Without it the outline alone reads as a crescent —
     which is exactly what the first version of this icon did on the tile. */
  leaf: (
    <>
      <path d="M6.8 17.2C6.8 10 11.3 5.5 18.8 5.5c0 7.5-4.5 12-12 11.7z" />
      <path d="M18.8 5.5 8.6 15.4M4.5 20l2.3-2.8" />
    </>
  ),
  bookmark: <path d="M6.5 3.5h11a1 1 0 0 1 1 1V20l-6.5-4.2L5.5 20V4.5a1 1 0 0 1 1-1z" />,
  bell: (
    <>
      <path d="M6.5 10a5.5 5.5 0 0 1 11 0c0 4 1.5 5.5 1.5 5.5H5S6.5 14 6.5 10z" />
      <path d="M10 18.5a2 2 0 0 0 4 0" />
    </>
  ),
  search: (
    <>
      <circle cx="10.8" cy="10.8" r="6.3" />
      <path d="m15.6 15.6 4 4" />
    </>
  ),
  chevron: <path d="m9.5 5.5 6.5 6.5-6.5 6.5" />,
  plus: <path d="M12 5.5v13M5.5 12h13" />,
};

/**
 * Line icons — the only icon vocabulary ParentVeda has.
 *
 * The rule behind it is short: **no decorative emoji in chrome.** Emoji carry
 * a platform's personality rather than ours, they render differently on every
 * device, and they read as childish in a product that is often being used by
 * someone frightened.
 *
 * Icons are drawn on a 24 box with a 1.6 stroke and no fill, so they sit at
 * the same visual weight as Manrope beside them. Colour defaults to
 * `currentColor` — an icon's job is recognition, and colour is reserved for
 * status, so a coloured icon should be a deliberate exception.
 */
export function PVIcon({ name, size = 22, color = 'currentColor' }: PVIconProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke={color}
      strokeWidth={1.6}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      focusable="false"
    >
      {PATHS[name]}
    </svg>
  );
}
