import * as React from 'react';
import { PVEmptyState, PVButton, PVIcon } from '@parentveda/v3-kit';

export const AnInvitation = () => (
  <div style={{ width: 320 }}>
    <PVEmptyState
      art={<PVIcon name="book" size={34} />}
      title="Nothing saved yet"
      body="Write the first thing you want to remember about today. Two lines is plenty."
      action={<PVButton label="Start a note" icon={<PVIcon name="plus" size={16} />} />}
    />
  </div>
);

export const ForAFeatureNotYetUsed = () => (
  <div style={{ width: 320 }}>
    <PVEmptyState
      art={<PVIcon name="scan" size={34} />}
      title="No scans added"
      body="Add the dates your clinic gave you and we will tell you what each one looks for."
      action={<PVButton label="Add a scan" />}
    />
  </div>
);
