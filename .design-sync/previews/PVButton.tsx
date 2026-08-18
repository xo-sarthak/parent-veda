import * as React from 'react';
import { PVButton, PVIcon } from '@parentveda/v3-kit';

export const Default = () => <PVButton label="Open your journal" />;

export const WithIcon = () => (
  <PVButton label="Read this week" icon={<PVIcon name="book" size={16} />} />
);

export const Quiet = () => <PVButton label="Not now" tone="quiet" />;

export const Block = () => (
  <div style={{ width: 320 }}>
    <PVButton label="Save this week to your journal" block />
  </div>
);

export const Disabled = () => <PVButton label="Costs coming soon" disabled />;
