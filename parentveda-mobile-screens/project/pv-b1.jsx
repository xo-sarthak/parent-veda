// pv-b1.jsx — Direction B "Warm Nest" · screens 1–6
// Cozy & tactile: layered lavender panels, rounded chunky cards, more coral
// warmth, playful pills, floating tab bar, gradient hero cards.

const B = {
  kicker: { fontFamily: PV.body, fontSize: 12, fontWeight: 700, letterSpacing: 0.2, color: PV.p500 },
  title: { fontFamily: PV.ui, fontWeight: 700, letterSpacing: -0.3, color: PV.p900 },
  serif: { fontFamily: PV.serif, fontWeight: 500, letterSpacing: -0.5, color: PV.p900 },
  body: { fontFamily: PV.body, fontSize: 13.5, lineHeight: 1.5, color: PV.n600 },
  card: { background: '#fff', borderRadius: 24, boxShadow: '0 4px 18px rgba(45,20,76,0.07)' },
};

// 1 ── HOME / DAILY MOMENT ───────────────────────────────────────
function HomeB() {
  const rituals = [
    { n: 'leaf', t: 'Grow', bg: '#EAF1EA', fg: '#4f7a52', done: true },
    { n: 'book-open', t: 'Read', bg: PV.lav2, fg: PV.p600, done: true },
    { n: 'messages-square', t: 'Talk', bg: PV.c100, fg: PV.c700, done: false },
    { n: 'flower-2', t: 'Sanskar', bg: '#F1E8DA', fg: PV.brown, done: false },
    { n: 'heart', t: 'For you', bg: PV.lav2, fg: PV.p600, done: false },
  ];
  return (
    <Screen bg={PV.lav1} padBottom={120}>
      <div style={{ padding: '0 18px' }}>
        {/* brand header */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 16 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 9 }}>
            <img src="assets/pv-mark.png" alt="ParentVeda" style={{ height: 30, width: 'auto', display: 'block' }} />
            <span style={{ fontFamily: PV.ui, fontWeight: 800, fontSize: 19, color: PV.p600, letterSpacing: -0.5 }}>ParentVeda</span>
          </div>
          <div style={{ width: 40, height: 40, borderRadius: 99, background: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: PV.shadowSoft }}>
            <Icon name="bell" size={19} color={PV.p600} />
          </div>
        </div>
        {/* greeting card */}
        <div style={{ background: `linear-gradient(150deg, ${PV.p500} 0%, ${PV.p700} 100%)`, borderRadius: 28, padding: '20px 20px', color: '#fff', position: 'relative', overflow: 'hidden' }}>
          <div style={{ position: 'absolute', right: -36, top: -36, width: 150, height: 150, borderRadius: '50%', background: 'rgba(255,255,255,0.10)' }} />
          <div style={{ position: 'absolute', right: 30, bottom: -40, width: 100, height: 100, borderRadius: '50%', background: 'rgba(255,156,175,0.25)' }} />
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', position: 'relative' }}>
            <div>
              <div style={{ fontFamily: PV.body, fontSize: 12.5, opacity: 0.85 }}>Good morning, Aanya 🌸</div>
              <div style={{ fontFamily: PV.serif, fontSize: 27, fontWeight: 500, marginTop: 6, letterSpacing: -0.4 }}>Week 24, Day 3</div>
              <div style={{ fontFamily: PV.body, fontSize: 13, opacity: 0.85, marginTop: 6 }}>Your baby is a sweet corn 🌽</div>
            </div>
            <Ring size={62} stroke={6} pct={0.6} color="#fff" track="rgba(255,255,255,0.25)">
              <span style={{ fontFamily: PV.ui, fontWeight: 700, fontSize: 13, color: '#fff' }}>60%</span>
            </Ring>
          </div>
        </div>

        {/* daily moment ritual scroller */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginTop: 24 }}>
          <div style={{ ...B.title, fontSize: 18 }}>Today's moment</div>
          <span style={{ ...B.kicker }}>2 of 5 done</span>
        </div>
        <div style={{ display: 'flex', gap: 12, marginTop: 14, overflow: 'hidden' }}>
          {rituals.map((r) => (
            <div key={r.t} style={{ flexShrink: 0, width: 84, background: '#fff', borderRadius: 20, padding: '14px 10px', textAlign: 'center', boxShadow: '0 3px 12px rgba(45,20,76,0.06)', position: 'relative' }}>
              {r.done && <div style={{ position: 'absolute', top: 8, right: 8, width: 16, height: 16, borderRadius: 99, background: PV.p500, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="check" size={10} color="#fff" stroke={3} /></div>}
              <div style={{ width: 44, height: 44, borderRadius: 14, background: r.bg, display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto', opacity: r.done ? 0.5 : 1 }}>
                <Icon name={r.n} size={21} color={r.fg} stroke={1.9} />
              </div>
              <div style={{ fontFamily: PV.body, fontWeight: 600, fontSize: 11.5, color: r.done ? PV.n300 : PV.p900, marginTop: 8 }}>{r.t}</div>
            </div>
          ))}
        </div>

        {/* affirmation */}
        <div style={{ marginTop: 22, background: `linear-gradient(135deg, ${PV.c100}, #fff)`, borderRadius: 24, padding: '20px 20px', border: '1px solid rgba(255,90,121,0.12)' }}>
          <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
            <Icon name="sun" size={18} color={PV.c500} />
            <span style={{ ...B.kicker, color: PV.c700 }}>Today's affirmation</span>
          </div>
          <div style={{ fontFamily: PV.serif, fontSize: 19, fontStyle: 'italic', color: PV.p800, lineHeight: 1.4, marginTop: 10 }}>“Your calm is your baby's first home.”</div>
        </div>

        {/* quick row */}
        <div style={{ display: 'flex', gap: 12, marginTop: 16 }}>
          <div style={{ flex: 1, ...B.card, padding: '15px 16px', display: 'flex', alignItems: 'center', gap: 12 }}>
            <div style={{ width: 38, height: 38, borderRadius: 12, background: PV.c100, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="baby" size={19} color={PV.c700} /></div>
            <div><div style={{ fontFamily: PV.ui, fontWeight: 700, fontSize: 13, color: PV.p900 }}>Kicks</div><div style={{ fontFamily: PV.body, fontSize: 11, color: PV.n300 }}>7 today</div></div>
          </div>
          <div style={{ flex: 1, ...B.card, padding: '15px 16px', display: 'flex', alignItems: 'center', gap: 12 }}>
            <div style={{ width: 38, height: 38, borderRadius: 12, background: PV.lav2, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="droplet" size={19} color={PV.p600} /></div>
            <div><div style={{ fontFamily: PV.ui, fontWeight: 700, fontSize: 13, color: PV.p900 }}>Water</div><div style={{ fontFamily: PV.body, fontSize: 11, color: PV.n300 }}>5 glasses</div></div>
          </div>
        </div>
      </div>
      <TabBarB active={0} />
    </Screen>
  );
}
window.HomeB = HomeB;

// 2 ── WEEK-ON-WEEK JOURNEY (swipeable card) ────────────────────
function WeekB() {
  return (
    <Screen bg={PV.lav1} padBottom={28}>
      <div style={{ padding: '0 18px' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 16 }}>
          <div style={{ width: 40, height: 40, borderRadius: 99, background: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: PV.shadowSoft }}><Icon name="chevron-left" size={20} color={PV.p600} /></div>
          <div style={{ ...B.title, fontSize: 17 }}>Your Week</div>
          <div style={{ width: 40, height: 40, borderRadius: 99, background: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: PV.shadowSoft }}><Icon name="bookmark" size={18} color={PV.p600} /></div>
        </div>

        {/* week selector */}
        <div style={{ display: 'flex', gap: 8, marginBottom: 16 }}>
          {[22, 23, 24, 25, 26].map((w) => (
            <div key={w} style={{ flex: 1, textAlign: 'center', padding: '10px 0', borderRadius: 16, background: w === 24 ? PV.p500 : '#fff', boxShadow: w === 24 ? '0 6px 16px rgba(106,48,182,0.3)' : 'none' }}>
              <div style={{ fontFamily: PV.ui, fontWeight: 700, fontSize: 16, color: w === 24 ? '#fff' : PV.n300 }}>{w}</div>
            </div>
          ))}
        </div>

        {/* hero card */}
        <div style={{ ...B.card, overflow: 'hidden' }}>
          <div style={{ position: 'relative' }}>
            <Stripe label="baby · week 24" height={180} radius={0} tone="coral" />
            <div style={{ position: 'absolute', bottom: 14, left: 16, right: 16, display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end' }}>
              <div style={{ background: '#fff', borderRadius: 16, padding: '8px 12px', boxShadow: PV.shadowSoft }}>
                <div style={{ fontFamily: PV.body, fontSize: 10, color: PV.n300, fontWeight: 600 }}>SIZE</div>
                <div style={{ fontFamily: PV.ui, fontWeight: 700, fontSize: 14, color: PV.p900 }}>🌽 Sweet corn</div>
              </div>
              <div style={{ background: '#fff', borderRadius: 16, padding: '8px 12px', boxShadow: PV.shadowSoft }}>
                <div style={{ fontFamily: PV.body, fontSize: 10, color: PV.n300, fontWeight: 600 }}>LENGTH</div>
                <div style={{ fontFamily: PV.ui, fontWeight: 700, fontSize: 14, color: PV.p900 }}>~30 cm</div>
              </div>
            </div>
          </div>
          <div style={{ padding: '18px 18px 20px' }}>
            <span style={B.kicker}>Baby's development</span>
            <div style={{ ...B.serif, fontSize: 20, marginTop: 8, lineHeight: 1.2 }}>Tiny taste buds are forming</div>
            <div style={{ ...B.body, marginTop: 8 }}>Baby's inner ear is fully developed — they can sense balance and may startle at loud sounds.</div>
          </div>
        </div>

        {/* facet pills */}
        <div style={{ display: 'flex', gap: 10, marginTop: 16, flexWrap: 'wrap' }}>
          {[['heart-pulse', "Mom's body", PV.c100, PV.c700], ['apple', 'Nutrition', '#EAF1EA', '#4f7a52'], ['list-checks', 'Action plan', PV.lav2, PV.p600], ['sparkles', 'Bonding', '#F1E8DA', PV.brown]].map(([n, t, bg, fg]) => (
            <div key={t} style={{ display: 'flex', alignItems: 'center', gap: 8, background: '#fff', borderRadius: 16, padding: '12px 14px', boxShadow: PV.shadowSoft, flex: '1 1 44%' }}>
              <div style={{ width: 32, height: 32, borderRadius: 10, background: bg, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name={n} size={17} color={fg} stroke={1.9} /></div>
              <span style={{ fontFamily: PV.ui, fontWeight: 600, fontSize: 13, color: PV.p900 }}>{t}</span>
            </div>
          ))}
        </div>

        <div style={{ marginTop: 22, marginBottom: 6 }}><Dots count={5} active={2} /></div>
      </div>
    </Screen>
  );
}
window.WeekB = WeekB;

// 3 ── GARBH SANSKAR ────────────────────────────────────────────
function SanskarB() {
  return (
    <Screen bg={PV.lav1} padBottom={28}>
      <div style={{ padding: '0 18px' }}>
        <span style={B.kicker}>Garbh Sanskar · Day 12</span>
        <div style={{ ...B.serif, fontSize: 26, marginTop: 8 }}>Five gentle rituals</div>

        {/* breathing / raga hero */}
        <div style={{ marginTop: 18, background: `linear-gradient(160deg, ${PV.p400}, ${PV.p700})`, borderRadius: 28, padding: '26px 22px', color: '#fff', position: 'relative', overflow: 'hidden' }}>
          {[0, 1, 2].map((i) => <div key={i} style={{ position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%,-50%)', width: 110 + i * 60, height: 110 + i * 60, borderRadius: '50%', border: '1px solid rgba(255,255,255,0.12)' }} />)}
          <div style={{ position: 'relative', textAlign: 'center' }}>
            <div style={{ width: 92, height: 92, borderRadius: 99, background: 'rgba(255,255,255,0.16)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 16px' }}>
              <div style={{ width: 64, height: 64, borderRadius: 99, background: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="play" size={26} color={PV.p600} stroke={2} style={{ marginLeft: 3 }} /></div>
            </div>
            <div style={{ fontFamily: PV.serif, fontSize: 22, fontWeight: 500 }}>Raag Yaman</div>
            <div style={{ fontFamily: PV.body, fontSize: 13, opacity: 0.85, marginTop: 2 }}>For calm & connection · 8 min</div>
          </div>
        </div>

        {/* ritual tiles */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, marginTop: 16 }}>
          {[
            { n: 'sparkles', t: 'Affirmation', s: 'Speak softly, twice', bg: PV.c100, fg: PV.c700 },
            { n: 'utensils', t: 'Recipe', s: 'Saffron-almond milk', bg: '#F1E8DA', fg: PV.brown },
            { n: 'feather', t: 'Spoken lines', s: 'A blessing today', bg: PV.lav2, fg: PV.p600 },
            { n: 'heart', t: 'For you', s: '3 calm breaths', bg: '#EAF1EA', fg: '#4f7a52' },
          ].map((r) => (
            <div key={r.t} style={{ ...B.card, padding: '16px 16px' }}>
              <div style={{ width: 40, height: 40, borderRadius: 13, background: r.bg, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name={r.n} size={20} color={r.fg} stroke={1.9} /></div>
              <div style={{ fontFamily: PV.ui, fontWeight: 700, fontSize: 14, color: PV.p900, marginTop: 12 }}>{r.t}</div>
              <div style={{ fontFamily: PV.body, fontSize: 11.5, color: PV.n300, marginTop: 2 }}>{r.s}</div>
            </div>
          ))}
        </div>
      </div>
    </Screen>
  );
}
window.SanskarB = SanskarB;

// 4 ── PREGNANCY JOURNEY MAP ────────────────────────────────────
function MapB() {
  const stops = [
    { w: 'Birth', x: 72, y: 44, state: 'future', label: 'Welcome 👶' },
    { w: '32', x: 30, y: 150, state: 'future' },
    { w: '28', x: 66, y: 252, state: 'future' },
    { w: '24', x: 30, y: 352, state: 'current', label: "You're here" },
    { w: '20', x: 66, y: 452, state: 'done', label: 'Scan ✓' },
    { w: '12', x: 30, y: 548, state: 'done' },
    { w: '4', x: 60, y: 636, state: 'done', label: 'Start' },
  ];
  return (
    <Screen bg={`linear-gradient(180deg, ${PV.lav1}, #EAF1EA 90%)`} padBottom={28}>
      <div style={{ padding: '0 18px' }}>
        <div style={{ ...B.card, padding: '16px 18px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div>
            <span style={B.kicker}>Your trail to birth</span>
            <div style={{ ...B.title, fontSize: 19, marginTop: 3 }}>16 weeks to go</div>
          </div>
          <Ring size={54} stroke={6} pct={0.6} color={PV.c500} track={PV.c100}><span style={{ fontFamily: PV.ui, fontWeight: 700, fontSize: 12, color: PV.p900 }}>60%</span></Ring>
        </div>
      </div>

      <div style={{ position: 'relative', height: 700, marginTop: 6 }}>
        <svg width="100%" height="700" viewBox="0 0 360 700" preserveAspectRatio="none" style={{ position: 'absolute', inset: 0 }}>
          <path d="M226 44 C 130 100, 80 110, 100 150 C 130 220, 250 210, 230 252 C 205 305, 90 322, 108 352 C 130 405, 250 412, 238 452 C 220 502, 90 512, 108 548 C 130 595, 240 605, 216 636"
            fill="none" stroke="#fff" strokeWidth="20" strokeLinecap="round" />
          <path d="M226 44 C 130 100, 80 110, 100 150 C 130 220, 250 210, 230 252 C 205 305, 90 322, 108 352 C 130 405, 250 412, 238 452 C 220 502, 90 512, 108 548 C 130 595, 240 605, 216 636"
            fill="none" stroke={PV.p200} strokeWidth="4" strokeLinecap="round" strokeDasharray="1 16" />
        </svg>
        {stops.map((s, i) => {
          const cur = s.state === 'current', done = s.state === 'done';
          const dim = cur ? 60 : done ? 40 : 44;
          return (
            <div key={i} style={{ position: 'absolute', top: s.y, left: `${s.x}%`, transform: 'translate(-50%,-50%)', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6 }}>
              <div style={{
                width: dim, height: dim, borderRadius: 99, display: 'flex', alignItems: 'center', justifyContent: 'center',
                background: cur ? `linear-gradient(150deg, ${PV.c500}, ${PV.c700})` : done ? PV.p500 : '#fff',
                boxShadow: cur ? '0 10px 24px rgba(255,90,121,0.4)' : '0 4px 12px rgba(45,20,76,0.12)',
                fontFamily: PV.ui, fontWeight: 700, fontSize: cur ? 17 : 14,
                color: cur || done ? '#fff' : PV.n300,
              }}>{done ? <Icon name="check" size={16} color="#fff" stroke={2.8} /> : s.w}</div>
              {s.label && <div style={{ background: cur ? PV.p900 : '#fff', color: cur ? '#fff' : PV.p700, fontFamily: PV.body, fontWeight: 700, fontSize: 11, padding: '5px 10px', borderRadius: 99, boxShadow: PV.shadowSoft, whiteSpace: 'nowrap' }}>{s.label}</div>}
            </div>
          );
        })}
      </div>
    </Screen>
  );
}
window.MapB = MapB;

// 5 ── MILESTONE CELEBRATION ────────────────────────────────────
function MilestoneB() {
  return (
    <Screen bg={`linear-gradient(165deg, ${PV.c500} 0%, ${PV.p600} 70%, ${PV.p800} 100%)`} padBottom={28} scroll={false}>
      <Blobs items={[{ top: 50, right: -40, size: 180, color: 'rgba(255,219,226,0.55)', opacity: 0.7, blur: 48 }, { bottom: 90, left: -40, size: 180, color: 'rgba(255,255,255,0.4)', opacity: 0.5, blur: 50 }]} />
      <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 26px', textAlign: 'center', position: 'relative', zIndex: 2 }}>
        {[['14%','20%','#fff',2],['82%','24%',PV.c100,99],['20%','72%',PV.c100,99],['84%','68%','#fff',2],['48%','14%','#fff',99],['68%','80%','#fff',2]].map((c,i)=>(
          <div key={i} style={{ position:'absolute', left:c[0], top:c[1], width:10, height:10, borderRadius:c[3], background:c[2], opacity:.85, transform:`rotate(${i*35}deg)` }} />
        ))}
        <div style={{ width: 130, height: 130, borderRadius: 36, background: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 20px 50px rgba(45,20,76,0.3)', transform: 'rotate(-6deg)' }}>
          <Stripe label="memory photo" height={102} radius={26} tone="coral" style={{ width: 102 }} />
        </div>
        <div style={{ fontFamily: PV.body, fontSize: 12, fontWeight: 700, letterSpacing: 1.6, textTransform: 'uppercase', color: 'rgba(255,255,255,0.8)', marginTop: 30 }}>Milestone unlocked</div>
        <div style={{ fontFamily: PV.serif, fontSize: 32, fontWeight: 500, color: '#fff', letterSpacing: -0.6, lineHeight: 1.15, marginTop: 12 }}>Third trimester,<br />here we go!</div>
        <div style={{ fontFamily: PV.body, fontSize: 14, lineHeight: 1.55, color: 'rgba(255,255,255,0.85)', marginTop: 12, maxWidth: 290 }}>28 weeks of love, carried in your body. Tap to save this moment to your memory book.</div>
        <div style={{ display: 'flex', gap: 12, marginTop: 28, width: '100%' }}>
          <div style={{ flex: 1, background: '#fff', color: PV.p700, fontFamily: PV.ui, fontWeight: 700, fontSize: 14.5, padding: '15px 0', borderRadius: 18, textAlign: 'center' }}>Save memory</div>
          <div style={{ width: 52, background: 'rgba(255,255,255,0.18)', borderRadius: 18, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="share-2" size={20} color="#fff" /></div>
        </div>
      </div>
    </Screen>
  );
}
window.MilestoneB = MilestoneB;

// 6 ── CALM TOOLS (hub) ─────────────────────────────────────────
function ToolsB() {
  const big = { n: 'baby', t: 'Movement Tracker', s: '7 kicks felt today · keep going', bg: PV.c100, fg: PV.c700 };
  const tools = [
    { n: 'scale', t: 'Weight', s: '+8.2 kg', bg: PV.lav2, fg: PV.p600 },
    { n: 'activity', t: 'Kegel care', s: '3 min daily', bg: '#EAF1EA', fg: '#4f7a52' },
    { n: 'timer', t: 'Contractions', s: 'Not started', bg: '#F1E8DA', fg: PV.brown },
    { n: 'briefcase', t: 'Hospital bag', s: '6/18 packed', bg: PV.lav2, fg: PV.p600 },
  ];
  return (
    <Screen bg={PV.lav1} padBottom={28}>
      <div style={{ padding: '0 18px' }}>
        <span style={B.kicker}>Calm tools</span>
        <div style={{ ...B.serif, fontSize: 26, marginTop: 6 }}>Your gentle helpers</div>

        {/* big movement card */}
        <div style={{ marginTop: 18, ...B.card, padding: '20px 20px', display: 'flex', alignItems: 'center', gap: 16 }}>
          <Ring size={72} stroke={8} pct={0.7} color={PV.c500} track={PV.c100}>
            <span style={{ fontFamily: PV.serif, fontWeight: 600, fontSize: 24, color: PV.p900 }}>7</span>
          </Ring>
          <div style={{ flex: 1 }}>
            <div style={{ ...B.title, fontSize: 16 }}>{big.t}</div>
            <div style={{ ...B.body, fontSize: 12.5, marginTop: 3 }}>{big.s}</div>
          </div>
          <div style={{ width: 40, height: 40, borderRadius: 99, background: PV.c500, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="plus" size={20} color="#fff" stroke={2.4} /></div>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, marginTop: 14 }}>
          {tools.map((t) => (
            <div key={t.t} style={{ ...B.card, padding: '16px 16px' }}>
              <div style={{ width: 42, height: 42, borderRadius: 13, background: t.bg, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name={t.n} size={20} color={t.fg} stroke={1.9} /></div>
              <div style={{ fontFamily: PV.ui, fontWeight: 700, fontSize: 14.5, color: PV.p900, marginTop: 12 }}>{t.t}</div>
              <div style={{ fontFamily: PV.body, fontSize: 12, color: PV.n300, marginTop: 2 }}>{t.s}</div>
            </div>
          ))}
        </div>

        <div style={{ marginTop: 14, background: PV.lav2, borderRadius: 18, padding: '15px 16px', display: 'flex', alignItems: 'center', gap: 12 }}>
          <Icon name="shield-check" size={20} color={PV.p500} />
          <div style={{ fontFamily: PV.body, fontSize: 12, color: PV.p700, lineHeight: 1.4 }}>Supportive, never clinical — always check with your doctor.</div>
        </div>
      </div>
    </Screen>
  );
}
window.ToolsB = ToolsB;

// 0 ── SPLASH / LAUNCH ──────────────────────────────────────────
function SplashB() {
  return (
    <Screen bg={`linear-gradient(165deg, ${PV.lav2} 0%, ${PV.lav1} 55%, #FFE9EE 100%)`} scroll={false}>
      <Blobs items={[
        { top: 70, left: -50, size: 200, color: PV.c100, opacity: 0.55, blur: 56 },
        { bottom: 80, right: -50, size: 200, color: PV.p100, opacity: 0.6, blur: 58 },
      ]} />
      <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', position: 'relative', zIndex: 2, padding: '0 40px' }}>
        <div style={{ background: '#fff', borderRadius: 36, padding: '30px 30px', boxShadow: '0 20px 50px rgba(45,20,76,0.14)' }}>
          <img src="assets/pv-mark.png" alt="ParentVeda" style={{ width: 130, height: 'auto', display: 'block' }} />
        </div>
        <div style={{ fontFamily: PV.ui, fontWeight: 800, fontSize: 30, color: PV.p600, letterSpacing: -0.8, marginTop: 24 }}>ParentVeda</div>
        <div style={{ fontFamily: PV.serif, fontStyle: 'italic', fontSize: 17, color: PV.p700, marginTop: 6 }}>Nurturing wisdom</div>
      </div>
      <div style={{ position: 'absolute', bottom: 60, left: 0, right: 0, textAlign: 'center', zIndex: 2, fontFamily: PV.body, fontSize: 12, color: PV.n300, fontWeight: 600 }}>
        Your calm companion 💜
      </div>
    </Screen>
  );
}
window.SplashB = SplashB;
