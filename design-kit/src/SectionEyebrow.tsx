import * as React from 'react';

export interface PVSectionEyebrowProps {
  /** Two or three words, upper-cased by the component. "WHERE TO GO", "THIS WEEK". */
  children: React.ReactNode;
  /**
   * Which ground it sits on. `sheet` is the page; `field` is the hero gradient.
   *
   * This matters more than it looks. On a chromatic ground a grey loses
   * contrast far faster than on a neutral one, because the eye is separating
   * two signals rather than one — so type on the field moves one tier in.
   * Shipping an eyebrow in grey on the field is a real bug this app has hit.
   */
  on?: 'sheet' | 'field';
}

/**
 * The small upper-case label above a section. This is ParentVeda's signature —
 * more than any other single element, it is what makes a screen read as ours.
 *
 * It is also the app's only routine use of the brand violet. `action` means
 * "you can act on this" and is spent at decision points: eyebrows, links, the
 * active nav tab, a focus ring. Never a background, never a card fill, never a
 * chevron on every row — a violet chevron everywhere makes violet mean "row"
 * instead of "the one thing worth doing".
 *
 * Name the section after what the reader gets, never after a content type:
 * "WHERE TO GO" beats "LINKS", "WHAT CHANGED" beats "ARTICLES".
 */
export function PVSectionEyebrow({ children, on = 'sheet' }: PVSectionEyebrowProps) {
  return (
    <span className={`pv-eyebrow${on === 'field' ? ' pv-eyebrow--on-field' : ''}`}>
      {children}
    </span>
  );
}
