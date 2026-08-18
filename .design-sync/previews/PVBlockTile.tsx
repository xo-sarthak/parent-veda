import * as React from 'react';
import { PVBlockTile, PVBlockGrid, PVIcon, PV_HUES } from '@parentveda/v3-kit';

export const SixDoors = () => (
  <div style={{ width: 354 }}>
    <PVBlockGrid columns={3}>
      <PVBlockTile label="Scans & tests" hue={PV_HUES.scans} mark={<PVIcon name="scan" size={34} />} />
      <PVBlockTile label="Nutrition" hue={PV_HUES.practice} mark={<PVIcon name="leaf" size={34} />} />
      <PVBlockTile label="Read" hue={PV_HUES.read} mark={<PVIcon name="book" size={34} />} />
      <PVBlockTile label="Symptoms" hue={PV_HUES.watch} mark={<PVIcon name="heart" size={34} />} />
      <PVBlockTile label="This week" hue={PV_HUES.week} mark={<PVIcon name="calendar" size={34} />} />
      <PVBlockTile label="Ask Veda" hue={PV_HUES.ask} mark={<PVIcon name="search" size={34} />} />
    </PVBlockGrid>
  </div>
);

export const NotReadyStaysVisible = () => (
  <div style={{ width: 234 }}>
    <PVBlockGrid columns={2}>
      <PVBlockTile label="Labour prep" hue={PV_HUES.week} mark={<PVIcon name="calendar" size={34} />} />
      <PVBlockTile
        label="Mind & mood"
        hue={PV_HUES.watch}
        mark={<PVIcon name="heart" size={34} />}
        state="notReady"
      />
    </PVBlockGrid>
  </div>
);

export const OneDoor = () => (
  <div style={{ width: 110 }}>
    <PVBlockTile label="Scans & tests" hue={PV_HUES.scans} mark={<PVIcon name="scan" size={34} />} />
  </div>
);
