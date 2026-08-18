import * as React from 'react';
import {
  PVScreen,
  PVHeroField,
  PVSpineChip,
  PVText,
  PVSectionEyebrow,
  PVBlockGrid,
  PVBlockTile,
  PVCard,
  PVBottomNav,
  PVIcon,
  PV_HUES,
} from '@parentveda/v3-kit';

export const AWholeScreen = () => (
  <PVScreen>
    <PVHeroField
      accentHue={273}
      variant={2}
      height={230}
      sheet={
        <>
          <PVSectionEyebrow>Where to go</PVSectionEyebrow>
          <PVBlockGrid columns={3}>
            <PVBlockTile label="Scans & tests" hue={PV_HUES.scans} mark={<PVIcon name="scan" size={34} />} />
            <PVBlockTile label="Nutrition" hue={PV_HUES.practice} mark={<PVIcon name="leaf" size={34} />} />
            <PVBlockTile label="Read" hue={PV_HUES.read} mark={<PVIcon name="book" size={34} />} />
          </PVBlockGrid>
          <div style={{ height: 28 }} />
          <PVSectionEyebrow>What changed</PVSectionEyebrow>
          <PVCard>
            <PVText role="cardTitle">Your baby can hear you now</PVText>
            <div style={{ height: 8 }} />
            <PVText role="bodySm">Reading aloud is worth the five minutes.</PVText>
          </PVCard>
        </>
      }
    >
      <PVSpineChip>Week 20</PVSpineChip>
      <div style={{ height: 12 }} />
      <PVText role="display">Halfway</PVText>
    </PVHeroField>
    <div style={{ position: 'absolute', left: 18, right: 18, bottom: 18 }}>
      <PVBottomNav
        activeIndex={0}
        items={[
          { label: 'Today', icon: <PVIcon name="home" /> },
          { label: 'Week', icon: <PVIcon name="calendar" /> },
          { label: 'Tools', icon: <PVIcon name="tools" /> },
          { label: 'Circle', icon: <PVIcon name="community" /> },
          { label: 'You', icon: <PVIcon name="profile" /> },
        ]}
      />
    </div>
  </PVScreen>
);
