import * as React from 'react';

export interface PVCardProps {
  children: React.ReactNode;
  /** Makes the whole card the tap target. Rows inside it then need no chevron each. */
  onClick?: () => void;
}

/**
 * A white surface on the page ground. Radius 20, one hairline border, and a
 * shadow tinted to the ground rather than black.
 *
 * The tinted shadow is not a refinement, it is the rule: a grey or black
 * shadow on a tinted ground clashes and reads as jarring, while a shadow
 * carrying the ground's own hue blends. Only the colour changes — same offset,
 * same blur.
 *
 * ⚠️ **No card inside a card.** Nesting is the fastest way a calm screen turns
 * busy, because each border and shadow claims the same "I am a thing" signal.
 * The stylesheet flattens a nested card automatically, but the composition is
 * still usually wrong: reach for PVFactBlock inside a card, not another card.
 */
export function PVCard({ children, onClick }: PVCardProps) {
  if (onClick) {
    return (
      <button className="pv-card pv-card--tappable" onClick={onClick} type="button">
        {children}
      </button>
    );
  }
  return <div className="pv-card">{children}</div>;
}
