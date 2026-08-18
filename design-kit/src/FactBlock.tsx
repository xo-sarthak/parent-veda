import * as React from 'react';

export interface PVFactBlockProps {
  /** The upper-case caption. "NEXT SCAN", "TYPICAL COST". */
  label: string;
  /** The fact itself. Omit when using `placeholder`. */
  value?: string;
  /**
   * Turn the block into an honest placeholder: it says what will be here and
   * what it will be worth, in plain words, and it is NOT tappable.
   *
   * A placeholder that looks tappable and does nothing is worse than an empty
   * space — it teaches the reader that taps do nothing.
   */
  placeholder?: string;
  children?: React.ReactNode;
}

/**
 * The quiet block: one fact, or an honest statement that a fact is coming.
 *
 * This is the second surface (`surfaceAlt`) — a step down from a card, used
 * for facts, spec rows, disclosure strips and placeholders. It carries no
 * border and no shadow, which is what keeps it subordinate to the card it
 * usually sits inside.
 *
 * The placeholder form matters to this product specifically. A great deal of
 * ParentVeda is built ahead of its content, and the rule that keeps that
 * honest is: **state the value, do not fake the feature.** "Costs for your
 * city, once we have them verified" is a promise a reader can judge; a greyed
 * fake row is not.
 */
export function PVFactBlock({ label, value, placeholder, children }: PVFactBlockProps) {
  const isPlaceholder = placeholder != null && value == null;
  return (
    <div className={`pv-fact${isPlaceholder ? ' pv-fact--placeholder' : ''}`}>
      <span className="pv-fact__label">{label}</span>
      {value != null || placeholder != null ? (
        <span className="pv-fact__value">{value ?? placeholder}</span>
      ) : null}
      {children}
    </div>
  );
}
