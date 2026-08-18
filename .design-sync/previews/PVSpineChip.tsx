import * as React from 'react';
import { PVHeroField, PVSpineChip } from '@parentveda/v3-kit';

export const OnTheField = () => (
  <div style={{ width: 390 }}>
    <PVHeroField accentHue={273} variant={1} height={180}>
      <PVSpineChip>Week 20</PVSpineChip>
    </PVHeroField>
  </div>
);

export const EveryStageHasOne = () => (
  <div style={{ width: 390 }}>
    <PVHeroField accentHue={273} variant={3} height={180}>
      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
        <PVSpineChip>Week 20</PVSpineChip>
        <PVSpineChip>Cycle day 12</PVSpineChip>
        <PVSpineChip>Leap 5</PVSpineChip>
      </div>
    </PVHeroField>
  </div>
);
