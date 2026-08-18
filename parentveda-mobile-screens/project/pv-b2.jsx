// pv-b2.jsx — Direction B "Warm Nest" · screens 7–11

// 7 ── KICK COUNTER (tool detail) ───────────────────────────────
function KickB() {
  return (
    <Screen bg={`linear-gradient(180deg, ${PV.c100}, ${PV.lav1} 60%)`} padBottom={28} scroll={false}>
      <div style={{ height: '100%', display: 'flex', flexDirection: 'column', padding: '0 18px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{ width: 40, height: 40, borderRadius: 99, background: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: PV.shadowSoft }}><Icon name="chevron-left" size={20} color={PV.p600} /></div>
          <div style={{ ...B.title, fontSize: 17 }}>Movement Tracker</div>
        </div>

        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
          <div style={{ ...B.card, padding: '8px', borderRadius: 99 }}>
            <Ring size={196} stroke={12} pct={0.7} color={PV.c500} track="#fff">
              <div style={{ textAlign: 'center' }}>
                <div style={{ fontFamily: PV.serif, fontSize: 60, fontWeight: 600, color: PV.p900, lineHeight: 1 }}>7</div>
                <div style={{ fontFamily: PV.body, fontSize: 12.5, color: PV.n600, marginTop: 2, fontWeight: 600 }}>of 10 kicks</div>
              </div>
            </Ring>
          </div>
          <div style={{ ...B.body, marginTop: 20, textAlign: 'center', maxWidth: 250, color: PV.p700 }}>
            You're almost there 💛 Tap the heart each time your little one moves.
          </div>
          <div style={{ marginTop: 26, width: 120, height: 120, borderRadius: 99, background: `linear-gradient(150deg, ${PV.c500}, ${PV.c700})`, display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 16px 36px rgba(255,90,121,0.4)' }}>
            <Icon name="heart" size={42} color="#fff" stroke={1.6} />
          </div>
          <div style={{ fontFamily: PV.body, fontSize: 12, color: PV.n600, marginTop: 12, fontWeight: 600 }}>Started 14 min ago</div>
        </div>

        <div style={{ ...B.card, padding: '14px 16px', display: 'flex', justifyContent: 'space-around', marginBottom: 6 }}>
          {[['Today', '7'], ['Avg', '9'], ['Sessions', '3']].map(([l, v]) => (
            <div key={l} style={{ textAlign: 'center' }}>
              <div style={{ fontFamily: PV.serif, fontWeight: 600, fontSize: 22, color: PV.p900 }}>{v}</div>
              <div style={{ fontFamily: PV.body, fontSize: 11, color: PV.n300, fontWeight: 600 }}>{l}</div>
            </div>
          ))}
        </div>
      </div>
    </Screen>
  );
}
window.KickB = KickB;

// 8 ── ARTICLES & RECIPES / NUSHKHE ─────────────────────────────
function ReadB() {
  const recipes = [
    { t: 'Moong dal khichdi with curd', cat: 'Trimester 2', read: '20 min', tone: 'sand' },
    { t: 'Lemon-ginger water + soaked almonds', cat: 'Morning', read: '5 min', tone: 'sage' },
    { t: 'Soothing nighttime remedy', cat: 'Remedy', read: '3 min', tone: 'lav' },
  ];
  return (
    <Screen bg={PV.lav1} padBottom={120}>
      <div style={{ padding: '0 18px' }}>
        <span style={B.kicker}>Read & nourish</span>
        <div style={{ ...B.serif, fontSize: 25, marginTop: 6 }}>Recipes & Remedies</div>

        {/* segmented */}
        <div style={{ display: 'flex', background: '#fff', borderRadius: 16, padding: 4, marginTop: 16, boxShadow: PV.shadowSoft }}>
          {['Articles', 'Recipes & Remedies'].map((t, i) => (
            <div key={t} style={{ flex: 1, textAlign: 'center', padding: '10px 0', borderRadius: 12, fontFamily: PV.ui, fontWeight: 700, fontSize: 13, background: i === 1 ? PV.p500 : 'transparent', color: i === 1 ? '#fff' : PV.n300 }}>{t}</div>
          ))}
        </div>

        {/* featured recipe */}
        <div style={{ marginTop: 16, ...B.card, overflow: 'hidden' }}>
          <div style={{ position: 'relative' }}>
            <Stripe label="recipe · khichdi" height={150} radius={0} tone="sand" />
            <div style={{ position: 'absolute', top: 12, left: 12 }}><Chip bg="rgba(255,255,255,0.9)" color={PV.brown}>🍲 Comfort food</Chip></div>
          </div>
          <div style={{ padding: '16px 18px 18px' }}>
            <div style={{ ...B.title, fontSize: 17 }}>Moong dal khichdi with curd</div>
            <div style={{ ...B.body, fontSize: 12.5, marginTop: 6 }}>Light, warm, easy to digest — perfect for the second trimester.</div>
            <div style={{ display: 'flex', gap: 14, marginTop: 12 }}>
              <span style={{ display: 'flex', alignItems: 'center', gap: 5, fontFamily: PV.body, fontSize: 12, color: PV.n600, fontWeight: 600 }}><Icon name="clock" size={14} color={PV.n600} /> 20 min</span>
              <span style={{ display: 'flex', alignItems: 'center', gap: 5, fontFamily: PV.body, fontSize: 12, color: PV.n600, fontWeight: 600 }}><Icon name="flame" size={14} color={PV.n600} /> Easy</span>
            </div>
          </div>
        </div>

        {/* list */}
        <div style={{ marginTop: 16, display: 'flex', flexDirection: 'column', gap: 12 }}>
          {recipes.map((r) => (
            <div key={r.t} style={{ ...B.card, padding: 12, display: 'flex', gap: 14, alignItems: 'center', borderRadius: 20 }}>
              <Stripe label="" height={62} radius={14} tone={r.tone} style={{ width: 62, flexShrink: 0 }} />
              <div style={{ flex: 1 }}>
                <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}><Chip style={{ fontSize: 10.5, padding: '3px 8px' }}>{r.cat}</Chip><span style={{ fontFamily: PV.body, fontSize: 11, color: PV.n300 }}>{r.read}</span></div>
                <div style={{ fontFamily: PV.ui, fontWeight: 600, fontSize: 14, color: PV.p900, marginTop: 6, lineHeight: 1.25 }}>{r.t}</div>
              </div>
            </div>
          ))}
        </div>
      </div>
      <TabBarB active={3} />
    </Screen>
  );
}
window.ReadB = ReadB;

// 9 ── ASK VEDA (AI chat) ───────────────────────────────────────
function VedaB() {
  return (
    <Screen bg={`linear-gradient(180deg, ${PV.lav2}, ${PV.lav1})`} padBottom={28} scroll={false}>
      <div style={{ height: '100%', display: 'flex', flexDirection: 'column', padding: '0 18px' }}>
        {/* header */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{ width: 46, height: 46, borderRadius: 99, background: `linear-gradient(150deg, ${PV.p400}, ${PV.p700})`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="sparkles" size={22} color="#fff" /></div>
          <div style={{ flex: 1 }}>
            <div style={{ ...B.title, fontSize: 18 }}>Ask Veda</div>
            <div style={{ fontFamily: PV.body, fontSize: 11.5, color: PV.n300 }}>Your bilingual pregnancy guide</div>
          </div>
          <Chip bg={PV.c100} color={PV.c700}>Coming soon</Chip>
        </div>

        {/* chat */}
        <div style={{ flex: 1, marginTop: 20, display: 'flex', flexDirection: 'column', gap: 12, overflow: 'hidden' }}>
          <div style={{ alignSelf: 'flex-end', maxWidth: '80%', background: `linear-gradient(150deg, ${PV.p500}, ${PV.p600})`, color: '#fff', borderRadius: '20px 20px 6px 20px', padding: '12px 16px', fontFamily: PV.body, fontSize: 13.5, lineHeight: 1.45 }}>Can I eat papaya in my second trimester?</div>
          <div style={{ alignSelf: 'flex-start', maxWidth: '85%', background: '#fff', color: PV.n900, borderRadius: '20px 20px 20px 6px', padding: '14px 16px', fontFamily: PV.body, fontSize: 13.5, lineHeight: 1.5, boxShadow: PV.shadowSoft }}>
            Ripe papaya in small amounts is generally fine 💛 Best to avoid raw or semi-ripe papaya, which can be stimulating. Always check with your doctor too.
          </div>
          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', justifyContent: 'flex-end' }}>
            {['Suggest a raga 🎵', 'Is this safe?', 'Foods for week 24'].map((s) => (
              <span key={s} style={{ background: '#fff', border: `1px solid ${PV.p100}`, color: PV.p600, fontFamily: PV.body, fontWeight: 600, fontSize: 12, padding: '8px 13px', borderRadius: 99 }}>{s}</span>
            ))}
          </div>
        </div>

        {/* notify */}
        <div style={{ background: '#fff', borderRadius: 20, padding: '16px 18px', boxShadow: PV.shadowSoft, marginBottom: 6 }}>
          <div style={{ fontFamily: PV.ui, fontWeight: 700, fontSize: 14, color: PV.p900 }}>Be first to meet Veda</div>
          <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
            <div style={{ flex: 1, background: PV.lav1, borderRadius: 13, padding: '12px 14px', fontFamily: PV.body, fontSize: 13, color: PV.n300 }}>your@email.com</div>
            <div style={{ background: PV.p500, color: '#fff', fontFamily: PV.ui, fontWeight: 700, fontSize: 13, padding: '12px 18px', borderRadius: 13 }}>Notify</div>
          </div>
        </div>
      </div>
    </Screen>
  );
}
window.VedaB = VedaB;

// 10 ── COMMUNITY ───────────────────────────────────────────────
function CommunityB() {
  return (
    <Screen bg={PV.lav1} padBottom={120}>
      <div style={{ padding: '0 18px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div><span style={B.kicker}>Community</span><div style={{ ...B.serif, fontSize: 24, marginTop: 4 }}>Walking together</div></div>
          <div style={{ width: 44, height: 44, borderRadius: 99, background: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: PV.shadowSoft }}><Icon name="plus" size={22} color={PV.p500} stroke={2.2} /></div>
        </div>

        {/* circles */}
        <div style={{ display: 'flex', gap: 12, marginTop: 18, overflow: 'hidden' }}>
          {[['Due in Sept', PV.c100, PV.c700], ['Week 24', PV.lav2, PV.p600], ['First-time moms', '#EAF1EA', '#4f7a52'], ['Sanskar', '#F1E8DA', PV.brown]].map(([t, bg, fg]) => (
            <div key={t} style={{ flexShrink: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <div style={{ width: 58, height: 58, borderRadius: 20, background: bg, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="users" size={24} color={fg} /></div>
              <span style={{ fontFamily: PV.body, fontWeight: 600, fontSize: 10.5, color: PV.n600, maxWidth: 64, textAlign: 'center' }}>{t}</span>
            </div>
          ))}
        </div>

        {/* posts */}
        <div style={{ marginTop: 22, display: 'flex', flexDirection: 'column', gap: 14 }}>
          <div style={{ ...B.card, padding: '18px', borderRadius: 22 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 11 }}>
              <div style={{ width: 40, height: 40, borderRadius: 99, background: PV.c100, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><span style={{ fontFamily: PV.ui, fontWeight: 700, color: PV.c700 }}>M</span></div>
              <div style={{ flex: 1 }}><div style={{ fontFamily: PV.ui, fontWeight: 700, fontSize: 13.5, color: PV.p900 }}>Meera</div><div style={{ fontFamily: PV.body, fontSize: 11, color: PV.n300 }}>Week 26 · 2h ago</div></div>
              <Chip bg={PV.lav1} style={{ fontSize: 10.5 }}>Week 26</Chip>
            </div>
            <div style={{ fontFamily: PV.body, fontSize: 14, lineHeight: 1.5, color: PV.n900, marginTop: 12 }}>First time I felt the hiccups today 🥹 Such a strange, lovely flutter. Did anyone else cry?</div>
            <Stripe label="ultrasound photo" height={120} radius={16} tone="lav" style={{ marginTop: 12 }} />
            <div style={{ display: 'flex', gap: 18, marginTop: 14 }}>
              <span style={{ display: 'flex', alignItems: 'center', gap: 6, fontFamily: PV.body, fontSize: 13, color: PV.c700, fontWeight: 700 }}><Icon name="heart" size={17} color={PV.c500} /> 48</span>
              <span style={{ display: 'flex', alignItems: 'center', gap: 6, fontFamily: PV.body, fontSize: 13, color: PV.n600, fontWeight: 700 }}><Icon name="message-circle" size={17} color={PV.n600} /> 12</span>
              <span style={{ marginLeft: 'auto' }}><Icon name="bookmark" size={17} color={PV.n300} /></span>
            </div>
          </div>
          <div style={{ ...B.card, padding: '18px', borderRadius: 22 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 11 }}>
              <div style={{ width: 40, height: 40, borderRadius: 99, background: PV.lav2, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><span style={{ fontFamily: PV.ui, fontWeight: 700, color: PV.p600 }}>D</span></div>
              <div style={{ flex: 1 }}><div style={{ fontFamily: PV.ui, fontWeight: 700, fontSize: 13.5, color: PV.p900 }}>Divya</div><div style={{ fontFamily: PV.body, fontSize: 11, color: PV.n300 }}>Week 31 · 5h ago</div></div>
            </div>
            <div style={{ fontFamily: PV.body, fontSize: 14, lineHeight: 1.5, color: PV.n900, marginTop: 12 }}>Sharing my grandmother's carom-seed water recipe for the bloating — it actually helped! 🙏</div>
            <div style={{ display: 'flex', gap: 18, marginTop: 14 }}>
              <span style={{ display: 'flex', alignItems: 'center', gap: 6, fontFamily: PV.body, fontSize: 13, color: PV.c700, fontWeight: 700 }}><Icon name="heart" size={17} color={PV.c500} /> 96</span>
              <span style={{ display: 'flex', alignItems: 'center', gap: 6, fontFamily: PV.body, fontSize: 13, color: PV.n600, fontWeight: 700 }}><Icon name="message-circle" size={17} color={PV.n600} /> 23</span>
            </div>
          </div>
        </div>
      </div>
      <TabBarB active={4} />
    </Screen>
  );
}
window.CommunityB = CommunityB;

// 11 ── FATHER MODE ─────────────────────────────────────────────
function FatherB() {
  return (
    <Screen bg={PV.slate} padBottom={28}>
      <Blobs items={[{ top: 60, left: -40, size: 170, color: 'rgba(224,146,28,0.3)', opacity: 0.6, blur: 52 }]} />
      <div style={{ padding: '0 18px' }}>
        {/* hero card */}
        <div style={{ background: `linear-gradient(150deg, #34403f, #232a2b)`, borderRadius: 28, padding: '22px 20px', border: '1px solid rgba(255,255,255,0.08)', position: 'relative', overflow: 'hidden' }}>
          <div style={{ position: 'absolute', right: -30, top: -30, width: 120, height: 120, borderRadius: '50%', background: 'rgba(224,146,28,0.18)', filter: 'blur(20px)' }} />
          <div style={{ display: 'inline-flex', marginBottom: 14, position: 'relative' }}><Chip bg="rgba(224,146,28,0.18)" color={PV.amber}>Father Mode · Week 24</Chip></div>
          <div style={{ fontFamily: PV.serif, fontSize: 26, fontWeight: 500, color: '#fff', letterSpacing: -0.4, lineHeight: 1.1, position: 'relative' }}>She can hear<br />your voice now</div>
          <div style={{ fontFamily: PV.body, fontSize: 13.5, lineHeight: 1.5, color: 'rgba(255,255,255,0.6)', marginTop: 10, position: 'relative' }}>Baby recognises voices this week. A few minutes of reading aloud tonight goes a long way.</div>
          <div style={{ marginTop: 16, display: 'inline-flex', alignItems: 'center', gap: 8, background: PV.amber, color: '#2a2017', fontFamily: PV.ui, fontWeight: 700, fontSize: 13.5, padding: '12px 18px', borderRadius: 14, position: 'relative' }}>
            <Icon name="play" size={16} color="#2a2017" stroke={2.2} /> Start tonight's reading
          </div>
        </div>

        {/* this week's actions */}
        <div style={{ fontFamily: PV.body, fontWeight: 700, fontSize: 12, letterSpacing: 0.4, color: PV.amber, marginTop: 22 }}>SHOW UP THIS WEEK</div>
        <div style={{ marginTop: 12, display: 'flex', flexDirection: 'column', gap: 10 }}>
          {[
            { n: 'heart-handshake', t: 'A small act for Aanya', s: 'Foot rub & warm milk tonight', done: true },
            { n: 'book-open', t: 'Read a verse to baby', s: '5 min · your voice matters', done: false },
            { n: 'briefcase', t: 'Pack your bag item', s: 'Chargers, snacks, documents', done: false },
          ].map((r) => (
            <div key={r.t} style={{ display: 'flex', alignItems: 'center', gap: 14, background: 'rgba(255,255,255,0.05)', borderRadius: 18, padding: '14px 16px', border: '1px solid rgba(255,255,255,0.06)' }}>
              <div style={{ width: 24, height: 24, borderRadius: 99, border: r.done ? 'none' : '2px solid rgba(255,255,255,0.25)', background: r.done ? PV.amber : 'transparent', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                {r.done && <Icon name="check" size={14} color="#2a2017" stroke={3} />}
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontFamily: PV.ui, fontWeight: 600, fontSize: 14, color: '#fff', textDecoration: r.done ? 'line-through' : 'none', opacity: r.done ? 0.6 : 1 }}>{r.t}</div>
                <div style={{ fontFamily: PV.body, fontSize: 12, color: 'rgba(255,255,255,0.5)' }}>{r.s}</div>
              </div>
              <Icon name={r.n} size={20} color={PV.amber} stroke={1.9} />
            </div>
          ))}
        </div>
      </div>
    </Screen>
  );
}
window.FatherB = FatherB;
