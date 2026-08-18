import * as React from 'react';
import { PVSectionEyebrow, PVText } from '@parentveda/v3-kit';

export const AboveASection = () => (
  <div style={{ width: 320 }}>
    <PVSectionEyebrow>Where to go</PVSectionEyebrow>
    <PVText role="title2">Start anywhere</PVText>
    <div style={{ height: 8 }} />
    <PVText role="bodySm">
      Every door stays open, whether or not there is anything behind it yet.
    </PVText>
  </div>
);

export const NamedForWhatSheGets = () => (
  <div style={{ width: 320, display: 'flex', flexDirection: 'column', gap: 28 }}>
    <div>
      <PVSectionEyebrow>What changed</PVSectionEyebrow>
      <PVText role="title3">Three things are new</PVText>
    </div>
    <div>
      <PVSectionEyebrow>Before you go</PVSectionEyebrow>
      <PVText role="title3">What to carry to the scan</PVText>
    </div>
    <div>
      <PVSectionEyebrow>If something feels wrong</PVSectionEyebrow>
      <PVText role="title3">When to call, not wait</PVText>
    </div>
  </div>
);
