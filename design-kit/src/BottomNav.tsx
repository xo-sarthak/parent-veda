import * as React from 'react';

export interface PVBottomNavItem {
  /** One word. It is always visible, so it must survive being read every time. */
  label: string;
  icon: React.ReactNode;
}

export interface PVBottomNavProps {
  items: PVBottomNavItem[];
  activeIndex: number;
  onSelect?: (index: number) => void;
}

/**
 * The bottom bar. It is on every screen, so it is the single most-seen
 * component in the product.
 *
 * **Two changes on the active tab, and no container.** The active tab changes
 * colour (to `action`) and weight (to 800). It does NOT get a pill, a box, or
 * a filled background behind it.
 *
 * The reasoning is worth keeping, because "no box" is not a law — Material 3
 * ships a pill indicator and it is perfectly good design. It is wrong *here*
 * for our own reasons: our labels are always visible, so the label already
 * says which tab you are on, and colour already says it again. A container is
 * a redundant third signal. And `action` is the only saturated colour we
 * spend — putting a violet shape on every screen at all times is exactly how
 * an accent stops meaning "you can act on this".
 *
 * **Labels are never hidden**, including on the inactive tabs. Icon-only
 * navigation asks a frightened person to decode pictograms, and this app is
 * often opened by someone who is worried.
 */
export function PVBottomNav({ items, activeIndex, onSelect }: PVBottomNavProps) {
  return (
    <nav className="pv-nav">
      {items.map((item, i) => (
        <button
          key={item.label}
          className={`pv-nav__item${i === activeIndex ? ' pv-nav__item--active' : ''}`}
          onClick={() => onSelect?.(i)}
          type="button"
          aria-current={i === activeIndex ? 'page' : undefined}
        >
          {item.icon}
          <span className="pv-nav__label">{item.label}</span>
        </button>
      ))}
    </nav>
  );
}
