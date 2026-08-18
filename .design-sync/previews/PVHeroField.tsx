import * as React from 'react';
import {
  PVHeroField,
  PVSpineChip,
  PVText,
  PVSectionEyebrow,
  PVBlockGrid,
  PVBlockTile,
  PVIcon,
  PV_HUES,
} from '@parentveda/v3-kit';

export const HomeScreen = () => (
  <div style={{ width: 390 }}>
    <PVHeroField
      accentHue={273}
      variant={2}
      height={280}
      sheet={
        <>
          <PVSectionEyebrow>Where to go</PVSectionEyebrow>
          <PVBlockGrid columns={3}>
            <PVBlockTile
              label="Scans & tests"
              hue={PV_HUES.scans}
              mark={<PVIcon name="scan" size={34} />}
            />
            <PVBlockTile
              label="Nutrition"
              hue={PV_HUES.practice}
              mark={<PVIcon name="leaf" size={34} />}
            />
            <PVBlockTile
              label="Read"
              hue={PV_HUES.read}
              mark={<PVIcon name="book" size={34} />}
            />
          </PVBlockGrid>
        </>
      }
    >
      <PVSpineChip>Week 20</PVSpineChip>
      <div style={{ height: 12 }} />
      <PVText role="display">Halfway</PVText>
    </PVHeroField>
  </div>
);

export const FieldOnly = () => (
  <div style={{ width: 390 }}>
    <PVHeroField accentHue={273} variant={0} height={240}>
      <PVSpineChip>Week 20</PVSpineChip>
    </PVHeroField>
  </div>
);

export const VariantsMoveTheArcs = () => (
  <div style={{ display: 'flex', flexDirection: 'column', gap: 10, width: 390 }}>
    {[0, 2, 4].map((v) => (
      <PVHeroField key={v} accentHue={273} variant={v} height={130} />
    ))}
  </div>
);

export const HueFollowsTheStage = () => (
  <div style={{ display: 'flex', flexDirection: 'column', gap: 10, width: 390 }}>
    {[273, 206, 26].map((h) => (
      <PVHeroField key={h} accentHue={h} variant={1} height={130} />
    ))}
  </div>
);
