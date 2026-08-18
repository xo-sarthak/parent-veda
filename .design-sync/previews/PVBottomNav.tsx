import * as React from 'react';
import { PVBottomNav, PVIcon } from '@parentveda/v3-kit';

const items = [
  { label: 'Today', icon: <PVIcon name="home" /> },
  { label: 'Week', icon: <PVIcon name="calendar" /> },
  { label: 'Tools', icon: <PVIcon name="tools" /> },
  { label: 'Circle', icon: <PVIcon name="community" /> },
  { label: 'You', icon: <PVIcon name="profile" /> },
];

export const FiveTabs = () => (
  <div style={{ width: 354 }}>
    <PVBottomNav items={items} activeIndex={0} />
  </div>
);

export const ActiveMovesWithoutABox = () => (
  <div style={{ width: 354, display: 'flex', flexDirection: 'column', gap: 12 }}>
    <PVBottomNav items={items} activeIndex={0} />
    <PVBottomNav items={items} activeIndex={2} />
    <PVBottomNav items={items} activeIndex={4} />
  </div>
);
