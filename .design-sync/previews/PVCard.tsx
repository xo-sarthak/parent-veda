import * as React from 'react';
import { PVCard, PVText, PVFactBlock, PVButton, PVIcon } from '@parentveda/v3-kit';

export const AReadCard = () => (
  <div style={{ width: 340 }}>
    <PVCard>
      <PVText role="cardTitle">Your anomaly scan</PVText>
      <div style={{ height: 8 }} />
      <PVText role="bodySm">
        The longest scan of the pregnancy, and the one that looks at how your baby is forming
        rather than how big they are.
      </PVText>
      <div style={{ height: 12 }} />
      <PVText role="meta">4 min · read</PVText>
    </PVCard>
  </div>
);

export const Tappable = () => (
  <div style={{ width: 340 }}>
    <PVCard onClick={() => {}}>
      <PVText role="cardTitle">Week 20 · what changed</PVText>
      <div style={{ height: 8 }} />
      <PVText role="bodySm">Three things are new since last week.</PVText>
    </PVCard>
  </div>
);

export const HoldingFacts = () => (
  <div style={{ width: 340 }}>
    <PVCard>
      <PVText role="cardTitle">Anomaly scan</PVText>
      <div style={{ height: 12 }} />
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        <PVFactBlock label="When" value="Weeks 18 – 22" />
        <PVFactBlock label="Typical cost" value="₹1,800 – ₹3,500" />
      </div>
      <div style={{ height: 20 }} />
      <PVButton label="Add to your calendar" icon={<PVIcon name="calendar" size={16} />} />
    </PVCard>
  </div>
);
