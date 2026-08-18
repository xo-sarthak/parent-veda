// pv-a1.jsx — Direction A "Quiet Bloom" · screens 1–6
// Airy, editorial, Fraunces-forward, restrained purple, generous whitespace.

const A = {
  label: { fontFamily: PV.body, fontSize: 11, fontWeight: 700, letterSpacing: 1.4, textTransform: 'uppercase', color: PV.n300 },
  h1: { fontFamily: PV.serif, fontWeight: 500, letterSpacing: -0.8, lineHeight: 1.08, color: PV.p900 },
  body: { fontFamily: PV.body, fontSize: 14, lineHeight: 1.55, color: PV.n600 },
};

// 1 ── HOME / DAILY MOMENT ───────────────────────────────────────
function HomeA() {
  const rituals = [
    { name: 'leaf', t: 'Grow', s: 'A breath of calm to begin', done: true },
    { name: 'book-open', t: 'Read to your baby', s: 'A short verse, softly aloud', done: true },
    { name: 'messages-square', t: 'Talk to your baby', s: 'Tell them about your day', done: false },
    { name: 'flower-2', t: 'Garbh Sanskar', s: "Today's raga & affirmation", done: false },
    { name: 'heart', t: 'A moment for you', s: 'Rest. You are doing enough.', done: false },
  ];
  return (
    <Screen bg={PV.canvas} padBottom={120}>
      <Blobs items={[
        { top: -50, right: -40, size: 210, color: PV.c100, opacity: 0.55, blur: 52 },
        { top: 90, left: -60, size: 180, color: PV.p100, opacity: 0.6, blur: 56 },
      ]} />
      <div style={{ padding: '0 24px' }}>
        {/* brand header */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 22 }}>
          <img src="assets/pv-mark.png" alt="ParentVeda" style={{ height: 26, width: 'auto', display: 'block' }} />
          <span style={{ fontFamily: PV.ui, fontWeight: 700, fontSize: 17, color: PV.p600, letterSpacing: -0.4 }}>ParentVeda</span>
        </div>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <div>
            <div style={A.label}>Tuesday · Week 24</div>
            <div style={{ ...A.h1, fontSize: 30, marginTop: 10 }}>Good morning,<br />Aanya</div>
          </div>
          <div style={{ width: 44, height: 44, borderRadius: 99, background: PV.lav2, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
            <span style={{ fontFamily: PV.ui, fontWeight: 700, color: PV.p600, fontSize: 16 }}>A</span>
          </div>
        </div>

        {/* baby size note */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 14, marginTop: 26, paddingBottom: 22, borderBottom: '1px solid rgba(45,20,76,0.07)' }}>
          <div style={{ width: 52, height: 52, borderRadius: 99, background: `repeating-linear-gradient(135deg,#FFE7EC 0 9px,#FFD3DC 9px 18px)`, flexShrink: 0 }} />
          <div>
            <div style={{ fontFamily: PV.ui, fontWeight: 600, fontSize: 14.5, color: PV.p900 }}>Your baby is a sweet corn 🌽</div>
            <div style={{ ...A.body, fontSize: 12.5 }}>About 30 cm · gaining soft round cheeks</div>
          </div>
        </div>

        {/* daily moment */}
        <div style={{ marginTop: 26, display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
          <div style={A.label}>Your daily moment</div>
          <div style={{ fontFamily: PV.body, fontWeight: 700, fontSize: 11.5, color: PV.p500 }}>2 of 5</div>
        </div>

        <div style={{ marginTop: 14, display: 'flex', flexDirection: 'column', gap: 2 }}>
          {rituals.map((r) => (
            <div key={r.t} style={{ display: 'flex', alignItems: 'center', gap: 14, padding: '13px 0', borderBottom: '1px solid rgba(45,20,76,0.05)' }}>
              <div style={{
                width: 38, height: 38, borderRadius: 99, flexShrink: 0,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                background: r.done ? PV.p500 : PV.lav1,
              }}>
                {r.done ? <Icon name="check" size={18} color="#fff" stroke={2.6} /> : <Icon name={r.name} size={18} color={PV.p500} stroke={1.9} />}
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontFamily: PV.ui, fontWeight: 600, fontSize: 14.5, color: r.done ? PV.n300 : PV.p900, textDecoration: r.done ? 'line-through' : 'none' }}>{r.t}</div>
                <div style={{ ...A.body, fontSize: 12 }}>{r.s}</div>
              </div>
              {!r.done && <Icon name="chevron-right" size={18} color={PV.n300} />}
            </div>
          ))}
        </div>

        {/* affirmation pull quote */}
        <div style={{ marginTop: 26, background: PV.lav1, borderRadius: 22, padding: '22px 22px' }}>
          <Icon name="quote" size={20} color={PV.c500} />
          <div style={{ fontFamily: PV.serif, fontSize: 19, fontStyle: 'italic', fontWeight: 400, lineHeight: 1.4, color: PV.p800, marginTop: 8 }}>
            “Your calm is your baby's first home.”
          </div>
          <div style={{ ...A.body, fontSize: 12, marginTop: 8 }}>A gentle reminder for today.</div>
        </div>
      </div>
      <TabBarA active={0} />
    </Screen>
  );
}
window.HomeA = HomeA;

// 2 ── WEEK-ON-WEEK JOURNEY (swipeable card) ────────────────────
function WeekA() {
  return (
    <Screen bg={PV.canvas} padBottom={28}>
      <Blobs items={[{ top: -40, left: -50, size: 200, color: PV.p100, opacity: 0.5, blur: 54 }]} />
      <div style={{ padding: '0 24px' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <Icon name="chevron-left" size={24} color={PV.n600} />
          <div style={{ textAlign: 'center' }}>
            <div style={A.label}>Week-on-week</div>
            <div style={{ fontFamily: PV.serif, fontWeight: 600, fontSize: 22, color: PV.p900, letterSpacing: -0.4 }}>Week 24</div>
          </div>
          <Icon name="chevron-right" size={24} color={PV.n600} />
        </div>

        {/* big card */}
        <div style={{ marginTop: 20, background: '#fff', borderRadius: 26, boxShadow: PV.shadow, overflow: 'hidden' }}>
          <div style={{ position: 'relative', height: 168, background: `radial-gradient(120% 120% at 30% 20%, ${PV.lav1} 0%, #fff 75%)` }}>
            <Stripe label="baby illustration · week 24" height={168} radius={0} tone="lav" />
            <div style={{ position: 'absolute', top: 14, left: 14 }}><Chip bg="rgba(255,255,255,0.85)" color={PV.c700}>🌽 size of sweet corn</Chip></div>
          </div>
          <div style={{ padding: '18px 20px 20px' }}>
            <div style={A.label}>Baby's development</div>
            <div style={{ fontFamily: PV.serif, fontSize: 21, fontWeight: 500, color: PV.p900, letterSpacing: -0.4, marginTop: 8, lineHeight: 1.2 }}>
              Tiny taste buds are forming
            </div>
            <div style={{ ...A.body, marginTop: 8 }}>
              This week your baby's inner ear is fully developed — they can sense balance and may startle at loud sounds. Their face is almost fully formed, just waiting to fill out.
            </div>
          </div>
        </div>

        {/* facet tabs */}
        <div style={{ display: 'flex', gap: 8, marginTop: 16, flexWrap: 'wrap' }}>
          {['Mom', 'Nutrition', 'Action plan', 'Bonding', 'Reflect'].map((t, i) => (
            <Chip key={t} bg={i === 0 ? PV.p500 : '#fff'} color={i === 0 ? '#fff' : PV.n600} style={{ boxShadow: i === 0 ? 'none' : PV.shadowSoft, fontSize: 12, padding: '8px 13px' }}>{t}</Chip>
          ))}
        </div>

        <div style={{ marginTop: 18, display: 'flex', gap: 12, alignItems: 'flex-start' }}>
          <div style={{ width: 36, height: 36, borderRadius: 99, background: PV.c100, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
            <Icon name="sparkles" size={18} color={PV.c700} />
          </div>
          <div>
            <div style={{ fontFamily: PV.ui, fontWeight: 600, fontSize: 14.5, color: PV.p900 }}>This week's bonding ritual</div>
            <div style={{ ...A.body, marginTop: 3 }}>Play a soft raga at dusk and rest your hand on your belly. Notice if baby responds.</div>
          </div>
        </div>

        <div style={{ marginTop: 24, marginBottom: 8 }}><Dots count={5} active={0} /></div>
        <div style={{ textAlign: 'center', fontFamily: PV.body, fontSize: 11.5, color: PV.n300 }}>Swipe through your week →</div>
      </div>
    </Screen>
  );
}
window.WeekA = WeekA;

// 3 ── GARBH SANSKAR ────────────────────────────────────────────
function SanskarA() {
  const rituals = [
    { n: 'music', t: "Today's raga", s: 'Raag Yaman · 8 min', tone: PV.p500 },
    { n: 'sparkles', t: 'Affirmation', s: 'Spoken softly, twice', tone: PV.c500 },
    { n: 'utensils', t: 'Recommended recipe', s: 'Saffron-almond milk', tone: PV.brown },
    { n: 'feather', t: 'Spoken lines', s: 'A blessing for your baby', tone: PV.p500 },
    { n: 'heart', t: 'A moment for you', s: '3 calming breaths', tone: PV.c500 },
  ];
  return (
    <Screen bg="#faf6fd" padBottom={28}>
      <Blobs items={[
        { top: -30, right: -30, size: 180, color: PV.p100, opacity: 0.6, blur: 50 },
        { bottom: 40, left: -50, size: 200, color: PV.c100, opacity: 0.45, blur: 56 },
      ]} />
      <div style={{ padding: '0 24px' }}>
        <div style={A.label}>Garbh Sanskar · Day 12</div>
        <div style={{ ...A.h1, fontSize: 30, marginTop: 10 }}>Nurturing<br />wisdom</div>
        <div style={{ ...A.body, marginTop: 10 }}>Five gentle rituals, rooted in tradition — to nourish you and your baby today.</div>

        {/* raga player hero */}
        <div style={{ marginTop: 22, background: `linear-gradient(150deg, ${PV.p500}, ${PV.p700})`, borderRadius: 24, padding: '22px 22px', color: '#fff', position: 'relative', overflow: 'hidden' }}>
          <div style={{ position: 'absolute', right: -30, top: -30, width: 150, height: 150, borderRadius: '50%', background: 'rgba(255,255,255,0.08)' }} />
          <div style={{ fontFamily: PV.body, fontWeight: 700, fontSize: 11, letterSpacing: 1.2, textTransform: 'uppercase', opacity: 0.8 }}>Now playing</div>
          <div style={{ fontFamily: PV.serif, fontSize: 24, fontWeight: 500, marginTop: 8, letterSpacing: -0.3 }}>Raag Yaman</div>
          <div style={{ fontFamily: PV.body, fontSize: 13, opacity: 0.85, marginTop: 2 }}>For calm & deep connection</div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 16, marginTop: 18 }}>
            <div style={{ width: 48, height: 48, borderRadius: 99, background: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon name="play" size={22} color={PV.p600} stroke={2} style={{ marginLeft: 2 }} />
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ height: 4, borderRadius: 99, background: 'rgba(255,255,255,0.25)' }}>
                <div style={{ width: '35%', height: 4, borderRadius: 99, background: '#fff' }} />
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 7, fontFamily: PV.body, fontSize: 11, opacity: 0.8 }}><span>2:48</span><span>8:00</span></div>
            </div>
          </div>
        </div>

        {/* ritual list */}
        <div style={{ marginTop: 18, display: 'flex', flexDirection: 'column', gap: 2 }}>
          {rituals.map((r, i) => (
            <div key={r.t} style={{ display: 'flex', alignItems: 'center', gap: 14, padding: '13px 0', borderBottom: i < rituals.length - 1 ? '1px solid rgba(45,20,76,0.06)' : 'none' }}>
              <Icon name={r.n} size={20} color={r.tone} stroke={1.9} />
              <div style={{ flex: 1 }}>
                <div style={{ fontFamily: PV.ui, fontWeight: 600, fontSize: 14.5, color: PV.p900 }}>{r.t}</div>
                <div style={{ ...A.body, fontSize: 12 }}>{r.s}</div>
              </div>
              <Icon name="chevron-right" size={18} color={PV.n300} />
            </div>
          ))}
        </div>
      </div>
    </Screen>
  );
}
window.SanskarA = SanskarA;

// 4 ── PREGNANCY JOURNEY MAP ────────────────────────────────────
function MapA() {
  // winding checkpoints
  const stops = [
    { w: 'Birth', x: 70, y: 40, state: 'future', label: 'Welcome, little one' },
    { w: '32', x: 28, y: 150, state: 'future' },
    { w: '28', x: 64, y: 250, state: 'future' },
    { w: '24', x: 30, y: 350, state: 'current', label: 'You are here' },
    { w: '20', x: 66, y: 450, state: 'done', label: 'Anatomy scan ✓' },
    { w: '12', x: 30, y: 545, state: 'done' },
    { w: '4', x: 60, y: 632, state: 'done', label: 'The journey began' },
  ];
  const px = (p) => `${p}%`;
  return (
    <Screen bg={PV.canvas} padBottom={28} scroll>
      <div style={{ padding: '0 24px' }}>
        <div style={A.label}>Your journey map</div>
        <div style={{ ...A.h1, fontSize: 27, marginTop: 8 }}>Week 4 to Birth</div>
        <div style={{ ...A.body, marginTop: 8 }}>A winding trail to your due date — one gentle checkpoint at a time.</div>
      </div>

      <div style={{ position: 'relative', height: 700, marginTop: 18 }}>
        {/* the path */}
        <svg width="100%" height="700" viewBox="0 0 360 700" preserveAspectRatio="none" style={{ position: 'absolute', inset: 0 }}>
          <path d="M216 40 C 120 90, 80 110, 100 150 C 130 210, 250 210, 230 250 C 205 300, 90 320, 108 350 C 130 400, 250 410, 238 450 C 220 500, 90 510, 108 545 C 130 590, 240 600, 216 632"
            fill="none" stroke={PV.p100} strokeWidth="14" strokeLinecap="round" strokeDasharray="2 22" />
        </svg>
        {stops.map((s, i) => {
          const cur = s.state === 'current', done = s.state === 'done';
          const dim = cur ? 56 : done ? 36 : 40;
          return (
            <div key={i} style={{ position: 'absolute', top: s.y, left: px(s.x), transform: 'translate(-50%,-50%)', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6 }}>
              <div style={{
                width: dim, height: dim, borderRadius: 99, display: 'flex', alignItems: 'center', justifyContent: 'center',
                background: cur ? PV.p500 : done ? '#fff' : PV.lav1,
                border: done ? `2px solid ${PV.p300}` : 'none',
                boxShadow: cur ? '0 8px 22px rgba(106,48,182,0.35)' : PV.shadowSoft,
                fontFamily: PV.ui, fontWeight: 700, fontSize: cur ? 17 : 13,
                color: cur ? '#fff' : done ? PV.p500 : PV.n300,
              }}>{done ? <Icon name="check" size={16} color={PV.p500} stroke={2.6} /> : s.w}</div>
              {s.label && (
                <div style={{ background: cur ? PV.c500 : '#fff', color: cur ? '#fff' : PV.n600, fontFamily: PV.body, fontWeight: 600, fontSize: 11, padding: '4px 9px', borderRadius: 99, boxShadow: PV.shadowSoft, whiteSpace: 'nowrap' }}>{s.label}</div>
              )}
            </div>
          );
        })}
      </div>
    </Screen>
  );
}
window.MapA = MapA;

// 5 ── MILESTONE CELEBRATION ────────────────────────────────────
function MilestoneA() {
  return (
    <Screen bg={`linear-gradient(170deg, ${PV.p600}, ${PV.p800})`} padBottom={28} scroll={false}>
      <Blobs items={[
        { top: 60, left: -40, size: 180, color: 'rgba(255,156,175,0.5)', opacity: 0.7, blur: 50 },
        { bottom: 100, right: -50, size: 200, color: 'rgba(173,141,215,0.6)', opacity: 0.6, blur: 56 },
      ]} />
      <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 30px', textAlign: 'center', position: 'relative', zIndex: 2 }}>
        {/* confetti dots */}
        {[['12%','18%',PV.c300],['80%','22%','#fff'],['18%','70%','#fff'],['86%','66%',PV.c300],['50%','12%',PV.c100]].map((c,i)=>(
          <div key={i} style={{ position:'absolute', left:c[0], top:c[1], width:8, height:8, borderRadius:i%2?99:2, background:c[2], opacity:.8, transform:`rotate(${i*40}deg)` }} />
        ))}
        <div style={{ width: 96, height: 96, borderRadius: 99, background: 'rgba(255,255,255,0.14)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 28 }}>
          <div style={{ width: 70, height: 70, borderRadius: 99, background: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="party-popper" size={34} color={PV.c500} stroke={1.8} />
          </div>
        </div>
        <div style={{ fontFamily: PV.body, fontSize: 11, fontWeight: 700, letterSpacing: 2, textTransform: 'uppercase', color: 'rgba(255,255,255,0.7)' }}>Milestone reached</div>
        <div style={{ fontFamily: PV.serif, fontSize: 34, fontWeight: 500, color: '#fff', letterSpacing: -0.8, lineHeight: 1.12, marginTop: 14 }}>
          Hello, third<br />trimester
        </div>
        <div style={{ fontFamily: PV.body, fontSize: 14.5, lineHeight: 1.55, color: 'rgba(255,255,255,0.82)', marginTop: 14, maxWidth: 280 }}>
          You've carried your baby through 28 beautiful weeks. The final stretch begins — gently, one week at a time.
        </div>
        <div style={{ marginTop: 30, background: '#fff', color: PV.p700, fontFamily: PV.ui, fontWeight: 700, fontSize: 15, padding: '15px 30px', borderRadius: 16 }}>
          Save this memory
        </div>
        <div style={{ marginTop: 16, fontFamily: PV.body, fontSize: 13, color: 'rgba(255,255,255,0.7)', display: 'flex', alignItems: 'center', gap: 6 }}>
          <Icon name="share-2" size={15} color="rgba(255,255,255,0.7)" /> Share with your partner
        </div>
      </div>
    </Screen>
  );
}
window.MilestoneA = MilestoneA;

// 6 ── CALM TOOLS (hub) ─────────────────────────────────────────
function ToolsA() {
  const tools = [
    { n: 'baby', t: 'Movement', s: 'Count kicks', tone: 'coral' },
    { n: 'scale', t: 'Weight', s: '+8.2 kg', tone: 'lav' },
    { n: 'activity', t: 'Kegel care', s: 'Daily 3 min', tone: 'sage' },
    { n: 'timer', t: 'Contractions', s: 'Time them', tone: 'sand' },
    { n: 'briefcase', t: 'Hospital bag', s: '6 of 18 packed', tone: 'lav' },
    { n: 'droplet', t: 'Hydration', s: '5 glasses', tone: 'coral' },
  ];
  const toneMap = { coral: [PV.c100, PV.c700], lav: [PV.lav2, PV.p600], sage: ['#E7EFE7', '#4f7a52'], sand: ['#F1E8DA', PV.brown] };
  return (
    <Screen bg={PV.canvas} padBottom={28}>
      <div style={{ padding: '0 24px' }}>
        <div style={A.label}>Calm tools</div>
        <div style={{ ...A.h1, fontSize: 28, marginTop: 8 }}>Gentle, never clinical</div>
        <div style={{ ...A.body, marginTop: 8 }}>Quiet helpers for the everyday — track what matters, skip what doesn't.</div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, marginTop: 22 }}>
          {tools.map((t) => {
            const [bg, fg] = toneMap[t.tone];
            return (
              <div key={t.t} style={{ background: '#fff', borderRadius: 20, padding: '18px 16px', boxShadow: PV.shadowSoft }}>
                <div style={{ width: 42, height: 42, borderRadius: 13, background: bg, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  <Icon name={t.n} size={21} color={fg} stroke={1.9} />
                </div>
                <div style={{ fontFamily: PV.ui, fontWeight: 600, fontSize: 15, color: PV.p900, marginTop: 14 }}>{t.t}</div>
                <div style={{ ...A.body, fontSize: 12.5, marginTop: 2 }}>{t.s}</div>
              </div>
            );
          })}
        </div>

        <div style={{ marginTop: 16, background: PV.lav1, borderRadius: 20, padding: '18px 18px', display: 'flex', alignItems: 'center', gap: 14 }}>
          <Icon name="shield-check" size={22} color={PV.p500} />
          <div style={{ ...A.body, fontSize: 12.5, color: PV.p700 }}>These tools support you — they're never a substitute for your doctor's care.</div>
        </div>
      </div>
    </Screen>
  );
}
window.ToolsA = ToolsA;

// 0 ── SPLASH / LAUNCH ──────────────────────────────────────────
function SplashA() {
  return (
    <Screen bg={PV.canvas} scroll={false}>
      <Blobs items={[
        { top: -30, right: -30, size: 210, color: PV.c100, opacity: 0.4, blur: 56 },
        { bottom: 40, left: -50, size: 210, color: PV.p100, opacity: 0.5, blur: 58 },
      ]} />
      <div style={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', position: 'relative', zIndex: 2, padding: '0 40px' }}>
        <img src="assets/pv-lockup.png" alt="ParentVeda" style={{ width: 224, maxWidth: '72%', height: 'auto', display: 'block' }} />
        <div style={{ fontFamily: PV.serif, fontStyle: 'italic', fontWeight: 400, fontSize: 18, color: PV.p700, marginTop: 14 }}>Nurturing wisdom</div>
        <div style={{ ...A.body, fontSize: 12.5, textAlign: 'center', marginTop: 6 }}>From week 4 to your baby's first cry.</div>
      </div>
      <div style={{ position: 'absolute', bottom: 64, left: 0, right: 0, display: 'flex', justifyContent: 'center', gap: 7, zIndex: 2 }}>
        {[0, 1, 2].map((i) => <div key={i} style={{ width: 7, height: 7, borderRadius: 99, background: i === 0 ? PV.p500 : PV.p200 }} />)}
      </div>
    </Screen>
  );
}
window.SplashA = SplashA;
