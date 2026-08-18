import * as React from 'react';
import { PVText } from '@parentveda/v3-kit';

export const TheScale = () => (
  <div style={{ display: 'flex', flexDirection: 'column', gap: 20, width: 340 }}>
    <PVText role="display">Twenty weeks</PVText>
    <PVText role="title1">Halfway, and the scan is close</PVText>
    <PVText role="title2">What is happening this week</PVText>
    <PVText role="title3">Your anomaly scan</PVText>
    <PVText role="cardTitle">Anomaly scan · weeks 18–22</PVText>
    <PVText role="body">
      This is the longest scan of the pregnancy, and the one that looks at how your baby is
      forming rather than how big they are. It usually takes around forty minutes.
    </PVText>
    <PVText role="bodySm">
      Bring your earlier reports. If the sonographer cannot see everything, being called back
      is routine and does not mean something is wrong.
    </PVText>
    <PVText role="label">Typical cost in a metro</PVText>
    <PVText role="meta">4 min · read</PVText>
  </div>
);

export const Display = () => <PVText role="display">Twenty weeks</PVText>;

export const BodyCopy = () => (
  <div style={{ width: 320 }}>
    <PVText role="body">
      Your baby is about the length of a banana this week, and can hear your voice through the
      wall of your belly — which is the reason reading aloud is worth the five minutes.
    </PVText>
  </div>
);
