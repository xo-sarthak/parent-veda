// pv-kit.jsx — ParentVeda shared design tokens, icons, and UI primitives.
// Exports everything to window for the screen files to consume.

// ── Brand tokens (from the ParentVeda brand system) ─────────────
const PV = {
  // purple ramp
  p50:'#F3EFF9', p100:'#E4DAF2', p200:'#CBB6E5', p300:'#AD8DD7', p400:'#8F64C8',
  p500:'#6A30B6', p600:'#5D2AA0', p700:'#502489', p800:'#401D6D', p900:'#2D144C',
  // coral / pink
  c100:'#FFDBE2', c300:'#FF9CAF', c500:'#FF5A79', c700:'#BF435B',
  // earthy brown
  brown:'#7A4600',
  // neutral warm grey
  n50:'#F4F3F5', n100:'#E4E2E5', n300:'#B2AEB5', n600:'#69636C', n900:'#2F2C30',
  // surfaces
  canvas:'#FBF9FE', surface:'#FFFFFF',
  lav1:'#F3EEF7', lav2:'#ECE5F2', lav3:'#E6DEED',
  // father mode
  slate:'#2D3436', amber:'#E0921C',
  whatsapp:'#25D366',
  // fonts
  serif:'"Fraunces", Georgia, serif',
  ui:'"Plus Jakarta Sans", system-ui, sans-serif',
  body:'"Manrope", system-ui, sans-serif',
  // soft shadow
  shadow:'0 1px 2px rgba(45,20,76,0.04), 0 8px 24px rgba(45,20,76,0.08)',
  shadowSoft:'0 2px 10px rgba(45,20,76,0.06)',
};
window.PV = PV;

// ── Icon (Lucide) ───────────────────────────────────────────────
// renders an <i data-lucide> placeholder; lucide.createIcons() swaps in SVG.
function Icon({ name, size = 22, color = 'currentColor', stroke = 1.75, style = {} }) {
  const setAttrs = (el) => {
    if (!el) return;
    el.setAttribute('width', size);
    el.setAttribute('height', size);
    el.setAttribute('stroke-width', stroke);
  };
  return (
    <i
      data-lucide={name}
      ref={setAttrs}
      style={{ color, width: size, height: size, display: 'inline-flex', flexShrink: 0, ...style }}
    />
  );
}
window.Icon = Icon;

// keep converting lucide placeholders as new content mounts (canvas + focus)
if (typeof window !== 'undefined' && !window.__pvLucide) {
  window.__pvLucide = true;
  const tick = () => { try { window.lucide && window.lucide.createIcons(); } catch (e) {} };
  setInterval(tick, 400);
  document.addEventListener('DOMContentLoaded', tick);
}

// ── Screen shell ────────────────────────────────────────────────
// Fills the iOS device content area; pads top for the status bar/island.
function Screen({ bg = PV.canvas, children, scroll = true, padTop = 54, padBottom = 28, style = {} }) {
  return (
    <div style={{ height: '100%', background: bg, position: 'relative', overflow: 'hidden', fontFamily: PV.body, color: PV.n900 }}>
      <div style={{
        height: '100%', overflow: scroll ? 'auto' : 'hidden',
        paddingTop: padTop, paddingBottom: padBottom, boxSizing: 'border-box',
        position: 'relative', zIndex: 1, ...style,
      }}>
        {children}
      </div>
    </div>
  );
}
window.Screen = Screen;

// ── Soft blurred decorative blobs ───────────────────────────────
function Blobs({ items = [] }) {
  return (
    <div style={{ position: 'absolute', inset: 0, overflow: 'hidden', zIndex: 0, pointerEvents: 'none' }}>
      {items.map((b, i) => (
        <div key={i} style={{
          position: 'absolute', top: b.top, left: b.left, right: b.right, bottom: b.bottom,
          width: b.size, height: b.size, borderRadius: '50%',
          background: b.color, filter: `blur(${b.blur || 48}px)`, opacity: b.opacity ?? 0.5,
        }} />
      ))}
    </div>
  );
}
window.Blobs = Blobs;

// ── Striped image placeholder w/ mono label ─────────────────────
function Stripe({ label, height = 120, radius = 18, tone = 'lav', style = {} }) {
  const palettes = {
    lav: ['#EFE7F6', '#E3D6EF'],
    coral: ['#FFE7EC', '#FFD3DC'],
    sage: ['#E7EFE7', '#D7E6D9'],
    sand: ['#F1E8DA', '#E7D9C2'],
    slate:['#E2E5E7', '#D2D8DB'],
  };
  const [a, b] = palettes[tone] || palettes.lav;
  return (
    <div style={{
      height, borderRadius: radius, position: 'relative', overflow: 'hidden',
      background: `repeating-linear-gradient(135deg, ${a} 0 11px, ${b} 11px 22px)`,
      display: 'flex', alignItems: 'center', justifyContent: 'center', ...style,
    }}>
      <span style={{
        fontFamily: 'ui-monospace, "SF Mono", Menlo, monospace', fontSize: 10.5, letterSpacing: 0.3,
        color: 'rgba(80,36,137,0.55)', background: 'rgba(255,255,255,0.7)', padding: '3px 8px',
        borderRadius: 99, textTransform: 'lowercase',
      }}>{label}</span>
    </div>
  );
}
window.Stripe = Stripe;

// ── Chip / pill ─────────────────────────────────────────────────
function Chip({ children, bg = PV.lav1, color = PV.p700, style = {} }) {
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 5,
      background: bg, color, fontFamily: PV.body, fontWeight: 600, fontSize: 11.5,
      padding: '5px 10px', borderRadius: 99, letterSpacing: 0.1, whiteSpace: 'nowrap', ...style,
    }}>{children}</span>
  );
}
window.Chip = Chip;

// ── Tab bars (two flavors) ──────────────────────────────────────
const TAB_ITEMS = [
  { name: 'home', label: 'Today' },
  { name: 'compass', label: 'Journey' },
  { name: 'flower-2', label: 'Sanskar' },
  { name: 'book-open', label: 'Read' },
  { name: 'users', label: 'Community' },
];

// A — minimal hairline bar, icons + tiny labels
function TabBarA({ active = 0 }) {
  return (
    <div style={{
      position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 30,
      paddingBottom: 22, paddingTop: 10, background: 'rgba(251,249,254,0.86)',
      backdropFilter: 'blur(18px)', WebkitBackdropFilter: 'blur(18px)',
      borderTop: '1px solid rgba(45,20,76,0.06)',
      display: 'flex', justifyContent: 'space-around', alignItems: 'center',
    }}>
      {TAB_ITEMS.map((t, i) => (
        <div key={t.name} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3 }}>
          <Icon name={t.name} size={22} stroke={i === active ? 2.1 : 1.7} color={i === active ? PV.p500 : PV.n300} />
          <span style={{ fontFamily: PV.body, fontSize: 9.5, fontWeight: i === active ? 700 : 500, color: i === active ? PV.p500 : PV.n300, letterSpacing: 0.2 }}>{t.label}</span>
        </div>
      ))}
    </div>
  );
}
window.TabBarA = TabBarA;

// B — floating rounded bar, active pill highlights
function TabBarB({ active = 0 }) {
  return (
    <div style={{ position: 'absolute', left: 14, right: 14, bottom: 24, zIndex: 30 }}>
      <div style={{
        background: '#fff', borderRadius: 28, padding: '9px 10px',
        boxShadow: '0 8px 28px rgba(45,20,76,0.16), 0 1px 0 rgba(255,255,255,0.6) inset',
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      }}>
        {TAB_ITEMS.map((t, i) => (
          <div key={t.name} style={{
            display: 'flex', alignItems: 'center', gap: 6,
            background: i === active ? PV.p500 : 'transparent',
            padding: i === active ? '9px 13px' : '9px 11px', borderRadius: 20, transition: 'all .2s',
          }}>
            <Icon name={t.name} size={21} stroke={2} color={i === active ? '#fff' : PV.n300} />
            {i === active && <span style={{ fontFamily: PV.body, fontSize: 12.5, fontWeight: 700, color: '#fff' }}>{t.label}</span>}
          </div>
        ))}
      </div>
    </div>
  );
}
window.TabBarB = TabBarB;

// ── Small helpers ───────────────────────────────────────────────
function Dots({ count, active, color = PV.p500, dim = PV.p200 }) {
  return (
    <div style={{ display: 'flex', gap: 6, alignItems: 'center', justifyContent: 'center' }}>
      {Array.from({ length: count }).map((_, i) => (
        <div key={i} style={{ width: i === active ? 20 : 6, height: 6, borderRadius: 99, background: i === active ? color : dim, transition: 'all .2s' }} />
      ))}
    </div>
  );
}
window.Dots = Dots;

// progress ring (svg circle — simple)
function Ring({ size = 64, stroke = 6, pct = 0.6, color = PV.p500, track = PV.p100, children }) {
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  return (
    <div style={{ position: 'relative', width: size, height: size }}>
      <svg width={size} height={size} style={{ transform: 'rotate(-90deg)' }}>
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke={track} strokeWidth={stroke} />
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke={color} strokeWidth={stroke} strokeLinecap="round" strokeDasharray={c} strokeDashoffset={c * (1 - pct)} />
      </svg>
      <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{children}</div>
    </div>
  );
}
window.Ring = Ring;
