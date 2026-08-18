import * as React from 'react';
import { PVIcon } from '@parentveda/v3-kit';
import type { PVIconName } from '@parentveda/v3-kit';

const ALL: PVIconName[] = [
  'home', 'calendar', 'tools', 'community', 'profile', 'book', 'heart',
  'scan', 'leaf', 'bookmark', 'bell', 'search', 'chevron', 'plus',
];

export const TheSet = () => (
  <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: 18, width: 360 }}>
    {ALL.map((n) => (
      <div key={n} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6 }}>
        <PVIcon name={n} size={24} />
        <span style={{ fontSize: 9, color: 'var(--pv-ink-3)' }}>{n}</span>
      </div>
    ))}
  </div>
);

export const Sizes = () => (
  <div style={{ display: 'flex', alignItems: 'flex-end', gap: 20 }}>
    <PVIcon name="scan" size={16} />
    <PVIcon name="scan" size={22} />
    <PVIcon name="scan" size={34} />
  </div>
);

export const InheritsColour = () => (
  <div style={{ display: 'flex', gap: 20 }}>
    <span style={{ color: 'var(--pv-ink-1)' }}>
      <PVIcon name="heart" size={28} />
    </span>
    <span style={{ color: 'var(--pv-ink-3)' }}>
      <PVIcon name="heart" size={28} />
    </span>
    <span style={{ color: 'var(--pv-action)' }}>
      <PVIcon name="heart" size={28} />
    </span>
  </div>
);
