import * as React from 'react';

export interface PVButtonProps {
  /** The action, in the words of the person doing it. "Open your journal", not "Journal". */
  label: string;
  /** A 16px line icon. Never an emoji — the app bans decorative emoji in chrome. */
  icon?: React.ReactNode;
  /**
   * `default` is the ordinary button. `quiet` drops the label to ink3 for a
   * tertiary action sitting under something more important.
   */
  tone?: 'default' | 'quiet';
  /** Stretch to the container. Primary actions live in the lower third of the screen. */
  block?: boolean;
  disabled?: boolean;
  onClick?: () => void;
  type?: 'button' | 'submit';
}

/**
 * The ParentVeda button. There is exactly one.
 *
 * Outlined pill, transparent fill, 44 high, radius 999. **There is no filled
 * variant and no `variant` prop** — that is deliberate, not an omission. A
 * filled button is the loudest thing on a page, so it decides what the page is
 * for, and ParentVeda screens are almost never about their button: the content
 * is. The border is what says "button"; the fill was never carrying that job.
 *
 * If a design seems to need a big violet call-to-action, the screen is usually
 * asking the wrong question — check that the primary action is in the lower
 * third and that the section eyebrow above it is doing its work.
 */
export function PVButton({
  label,
  icon,
  tone = 'default',
  block = false,
  disabled = false,
  onClick,
  type = 'button',
}: PVButtonProps) {
  const cls = [
    'pv-button',
    tone === 'quiet' ? 'pv-button--quiet' : '',
    block ? 'pv-button--block' : '',
  ]
    .filter(Boolean)
    .join(' ');

  return (
    <button className={cls} onClick={onClick} disabled={disabled} type={type}>
      {icon ? <span className="pv-button__icon">{icon}</span> : null}
      {label}
    </button>
  );
}
