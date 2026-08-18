import * as React from 'react';
import { PVFactBlock } from '@parentveda/v3-kit';

export const AFact = () => (
  <div style={{ width: 320 }}>
    <PVFactBlock label="Typical cost" value="₹1,800 – ₹3,500" />
  </div>
);

export const AStack = () => (
  <div style={{ width: 320, display: 'flex', flexDirection: 'column', gap: 8 }}>
    <PVFactBlock label="When" value="Weeks 18 – 22" />
    <PVFactBlock label="How long" value="About 40 minutes" />
    <PVFactBlock label="Typical cost" value="₹1,800 – ₹3,500" />
  </div>
);

export const AnHonestPlaceholder = () => (
  <div style={{ width: 320 }}>
    <PVFactBlock
      label="Costs near you"
      placeholder="Once we have them verified for your city."
    />
  </div>
);
