// app.jsx — assembles both directions onto the design canvas.

const SCREENS = [
  { id: 'splash',    label: '00 · Splash / Launch',         a: SplashA,    b: SplashB },
  { id: 'home',      label: '01 · Home / Daily Moment',     a: HomeA,      b: HomeB },
  { id: 'week',      label: '02 · Week-on-Week Journey',    a: WeekA,      b: WeekB },
  { id: 'sanskar',   label: '03 · Garbh Sanskar',           a: SanskarA,   b: SanskarB },
  { id: 'map',       label: '04 · Pregnancy Journey Map',   a: MapA,       b: MapB },
  { id: 'milestone', label: '05 · Milestone Celebration',   a: MilestoneA, b: MilestoneB },
  { id: 'tools',     label: '06 · Calm Tools',              a: ToolsA,     b: ToolsB },
  { id: 'kick',      label: '07 · Movement / Kick Counter', a: KickA,      b: KickB },
  { id: 'read',      label: '08 · Articles & Recipes',      a: ReadA,      b: ReadB },
  { id: 'veda',      label: '09 · Ask Veda',                a: VedaA,      b: VedaB },
  { id: 'community', label: '10 · Community',               a: CommunityA, b: CommunityB },
  { id: 'father',    label: '11 · Father Mode',             a: FatherA,    b: FatherB },
];

// Direct DCArtboard child (must be a direct child of DCSection, not wrapped).
function makeBoard(id, label, Comp) {
  return (
    <DCArtboard key={id} id={id} label={label} width={402} height={874}
      style={{ background: 'transparent', boxShadow: 'none', borderRadius: 48, overflow: 'visible' }}>
      <IOSDevice>{React.createElement(Comp)}</IOSDevice>
    </DCArtboard>
  );
}

function App() {
  return (
    <DesignCanvas>
      <DCSection id="dir-a" title="Direction A — Quiet Bloom"
        subtitle="Airy & editorial · big Fraunces moments, restrained purple, lots of negative space">
        {SCREENS.map((s) => makeBoard(`a-${s.id}`, s.label, s.a))}
      </DCSection>

      <DCSection id="dir-b" title="Direction B — Warm Nest"
        subtitle="Cozy & tactile · layered lavender panels, rounded cards, more coral warmth, floating tab bar">
        {SCREENS.map((s) => makeBoard(`b-${s.id}`, s.label, s.b))}
      </DCSection>
    </DesignCanvas>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
setTimeout(() => { try { window.lucide && window.lucide.createIcons(); } catch (e) {} }, 200);
