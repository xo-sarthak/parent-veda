import * as React from 'react';

export type PVTextRole =
  | 'display'
  | 'title1'
  | 'title2'
  | 'title3'
  | 'cardTitle'
  | 'body'
  | 'bodySm'
  | 'label'
  | 'meta';

export interface PVTextProps {
  /**
   * One of nine roles. There is nothing between them — if a size is not on
   * this list it does not exist in ParentVeda.
   *
   * Fraunces carries `display` → `cardTitle`; Manrope carries the rest.
   */
  role?: PVTextRole;
  children: React.ReactNode;
  /** Render as a different element. The role sets the look; this sets the semantics. */
  as?: 'p' | 'span' | 'div' | 'h1' | 'h2' | 'h3' | 'h4';
}

const ROLE_CLASS: Record<PVTextRole, string> = {
  display: 'pv-display',
  title1: 'pv-title1',
  title2: 'pv-title2',
  title3: 'pv-title3',
  cardTitle: 'pv-card-title',
  body: 'pv-body',
  bodySm: 'pv-body-sm',
  label: 'pv-label',
  meta: 'pv-meta',
};

/**
 * Type, restricted to the nine roles the design system defines.
 *
 * The reason this component exists rather than free-form CSS: the V3 screens
 * were measured and found to be running fourteen Fraunces sizes and ten
 * Manrope sizes. That is not a scale, it is an accumulation, and it happened
 * one screen at a time with nobody deciding it. Passing a role instead of a
 * size is what stops the eleventh.
 *
 * Two things baked in that are easy to get backwards:
 * — Large type gets NEGATIVE tracking and tight leading; body copy wants the
 *   opposite (1.45–1.55). Tightening large type is the single cheapest thing
 *   that makes typography look professional.
 * — Mobile type is BIGGER, not smaller. Body never goes below 13.
 */
export function PVText({ role = 'body', children, as }: PVTextProps) {
  const Tag = (as ?? (role.startsWith('title') || role === 'display' ? 'h2' : 'p')) as 'p';
  return <Tag className={ROLE_CLASS[role]}>{children}</Tag>;
}
