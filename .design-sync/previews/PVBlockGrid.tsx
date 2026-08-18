import * as React from 'react';
import { PVBlockGrid, PVBlockTile, PVIcon, PV_HUES } from '@parentveda/v3-kit';

export const ThreeColumns = () => (
  <div style={{ width: 354 }}>
    <PVBlockGrid columns={3}>
      <PVBlockTile label="Scans & tests" hue={PV_HUES.scans} mark={<PVIcon name="scan" size={34} />} />
      <PVBlockTile label="Nutrition" hue={PV_HUES.practice} mark={<PVIcon name="leaf" size={34} />} />
      <PVBlockTile label="Read" hue={PV_HUES.read} mark={<PVIcon name="book" size={34} />} />
    </PVBlockGrid>
  </div>
);

export const FourColumnsTwelveDoors = () => (
  <div style={{ width: 354 }}>
    <PVBlockGrid columns={4}>
      <PVBlockTile label="Scans" hue={PV_HUES.scans} mark={<PVIcon name="scan" size={28} />} />
      <PVBlockTile label="Nutrition" hue={PV_HUES.practice} mark={<PVIcon name="leaf" size={28} />} />
      <PVBlockTile label="Symptoms" hue={PV_HUES.watch} mark={<PVIcon name="heart" size={28} />} />
      <PVBlockTile label="Read" hue={PV_HUES.read} mark={<PVIcon name="book" size={28} />} />
      <PVBlockTile label="This week" hue={PV_HUES.week} mark={<PVIcon name="calendar" size={28} />} />
      <PVBlockTile label="Ask Veda" hue={PV_HUES.ask} mark={<PVIcon name="search" size={28} />} />
      <PVBlockTile label="Sleep" hue={PV_HUES.sleep} mark={<PVIcon name="bell" size={28} />} state="notReady" />
      <PVBlockTile label="Health" hue={PV_HUES.health} mark={<PVIcon name="scan" size={28} />} state="notReady" />
    </PVBlockGrid>
  </div>
);
