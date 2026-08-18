import * as React from 'react';

export interface PVScreenProps {
  children: React.ReactNode;
  /**
   * Constrain to the 390pt design width and centre it. Leave on for anything
   * that will become a phone screen — which, in this product, is everything.
   */
  phone?: boolean;
}

/**
 * The root wrapper. **Put this at the top of every ParentVeda screen.**
 *
 * It is not a provider in the React sense — there is no context, no theme
 * object, nothing to configure. What it does is apply `.pv-root`, which sets
 * the page ground, the base ink, and Manrope as the default family. Without
 * it the components still render, but they render on whatever ground the host
 * page has and in the browser's default serif, which looks like a bug and is
 * the single most common way a design comes back not looking like ParentVeda.
 *
 * The width matters too: ParentVeda is composed for a **390pt phone**, and a
 * layout that was only ever seen at desktop width will have spacing that falls
 * apart on the device it ships to.
 */
export function PVScreen({ children, phone = true }: PVScreenProps) {
  return (
    <div
      className="pv-root"
      style={
        phone
          ? { width: 390, margin: '0 auto', minHeight: 640, position: 'relative', overflow: 'hidden' }
          : undefined
      }
    >
      {children}
    </div>
  );
}
