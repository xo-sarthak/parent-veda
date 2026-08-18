import * as React from 'react';

export interface PVEmptyStateProps {
  /** What this section will hold, in her words. Never "No data". */
  title: string;
  /** One sentence on why it is worth filling — the invitation, not an apology. */
  body: string;
  /** The way in. An empty state without a way in is a dead end. */
  action?: React.ReactNode;
  /** A drawn mark, held quiet. */
  art?: React.ReactNode;
}

/**
 * What a section renders when it holds nothing yet.
 *
 * **A feature is never hidden.** An empty section does not disappear and does
 * not collapse — it renders an invitation, and only the copy changes. The
 * empty state IS the feature's advertisement, and it is often the first thing
 * a new user sees of a feature she has not tried.
 *
 * This is also the rule personalisation is not allowed to break. Personalising
 * *content, ranking and order* is right; personalising which features exist is
 * not. Everyone learns one ParentVeda, and a mother who never used the journal
 * still needs to be able to find out what it is.
 *
 * Write the copy as an invitation. "No entries yet" states a fact about the
 * database; "Write the first thing you want to remember about today" states
 * what she would get.
 */
export function PVEmptyState({ title, body, action, art }: PVEmptyStateProps) {
  return (
    <div className="pv-empty">
      {art ? <div className="pv-empty__art">{art}</div> : null}
      <h3 className="pv-card-title">{title}</h3>
      <p className="pv-body-sm">{body}</p>
      {action}
    </div>
  );
}
