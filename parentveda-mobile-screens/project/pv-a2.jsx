// pv-a2.jsx — Direction A "Quiet Bloom" · screens 7–11

// 7 ── KICK COUNTER (tool detail) ───────────────────────────────
function KickA() {
  return (
    <Screen bg={PV.canvas} padBottom={28} scroll={false}>
      <Blobs items={[{ top: 80, right: -50, size: 200, color: PV.c100, opacity: 0.45, blur: 54 }]} />
      <div style={{ height: '100%', display: 'flex', flexDirection: 'column', padding: '0 24px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <Icon name="chevron-left" size={24} color={PV.n600} />
          <div style={{ fontFamily: PV.ui, fontWeight: 600, fontSize: 17, color: PV.p900 }}>Movement</div>
        </div>

        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
          <div style={{ ...A.label, color: PV.n300 }}>Today's session · 14 min</div>
          <div style={{ position: 'relative', marginTop: 26 }}>
            <Ring size={210} stroke={10} pct={0.7} color={PV.c500} track={PV.c100}>
              <div style={{ textAlign: 'center' }}>
                <div style={{ fontFamily: PV.serif, fontSize: 64, fontWeight: 500, color: PV.p900, lineHeight: 1 }}>7</div>
                <div style={{ fontFamily: PV.body, fontSize: 13, color: PV.n600, marginTop: 4 }}>kicks felt</div>
              </div>
            </Ring>
          </div>
          <div style={{ ...A.body, marginTop: 22, textAlign: 'center', maxWidth: 240 }}>
            Most babies reach 10 movements within 2 hours. Tap each time you feel one.
          </div>
          <div style={{ marginTop: 30, width: 132, height: 132, borderRadius: 99, background: `linear-gradient(150deg, ${PV.c500}, ${PV.c700})`, display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 14px 34px rgba(255,90,121,0.35)' }}>
            <div style={{ textAlign: 'center', color: '#fff' }}>
              <Icon name="hand" size={30} color="#fff" stroke={1.8} />
              <div style={{ fontFamily: PV.ui, fontWeight: 700, fontSize: 13, marginTop: 4 }}>I felt it</div>
            </div>
          </div>
        </div>

        <div style={{ display: 'flex', justifyContent: 'space-between', padding: '0 6px 8px' }}>
          {['9 am', '11 am', 'Now', '3 pm', '7 pm'].map((t, i) => (
            <div key={t} style={{ textAlign: 'center' }}>
              <div style={{ width: 8, height: i === 2 ? 30 : [16, 22, 0, 0, 0][i], background: i === 2 ? PV.c500 : PV.p200, borderRadius: 99, margin: '0 auto' }} />
              <div style={{ fontFamily: PV.body, fontSize: 10, color: PV.n300, marginTop: 6 }}>{t}</div>
            </div>
          ))}
        </div>
      </div>
    </Screen>
  );
}
window.KickA = KickA;

// 8 ── ARTICLES & RECIPES / NUSHKHE ─────────────────────────────
function ReadA() {
  const articles = [
    { t: 'The fourth trimester: postpartum care', cat: 'Recovery', read: '6 min', tone: 'lav' },
    { t: 'Eating for two, the calm way', cat: 'Nutrition', read: '4 min', tone: 'sage' },
    { t: 'Understanding your baby’s movements', cat: 'Week 24', read: '5 min', tone: 'coral' },
  ];
  return (
    <Screen bg={PV.canvas} padBottom={120}>
      <div style={{ padding: '0 24px' }}>
        <div style={A.label}>Read & nourish</div>
        <div style={{ ...A.h1, fontSize: 28, marginTop: 8 }}>Stories for<br />your stage</div>

        {/* tabs */}
        <div style={{ display: 'flex', gap: 22, marginTop: 22, borderBottom: '1px solid rgba(45,20,76,0.08)' }}>
          {['Articles & Guides', 'Recipes & Remedies'].map((t, i) => (
            <div key={t} style={{ paddingBottom: 12, fontFamily: PV.ui, fontWeight: 600, fontSize: 14, color: i === 0 ? PV.p900 : PV.n300, borderBottom: i === 0 ? `2px solid ${PV.p500}` : '2px solid transparent', marginBottom: -1 }}>{t}</div>
          ))}
        </div>

        {/* featured */}
        <div style={{ marginTop: 18, borderRadius: 22, overflow: 'hidden', boxShadow: PV.shadow, background: '#fff' }}>
          <Stripe label="article hero · postpartum" height={150} radius={0} tone="lav" />
          <div style={{ padding: '16px 18px 18px' }}>
            <div style={{ display: 'flex', gap: 8 }}><Chip>Featured</Chip><Chip bg="transparent" color={PV.n300} style={{ padding: '5px 0' }}>6 min read</Chip></div>
            <div style={{ fontFamily: PV.serif, fontSize: 20, fontWeight: 500, color: PV.p900, letterSpacing: -0.3, marginTop: 10, lineHeight: 1.2 }}>The fourth trimester: caring for you, too</div>
          </div>
        </div>

        {/* list */}
        <div style={{ marginTop: 18, display: 'flex', flexDirection: 'column', gap: 16 }}>
          {articles.map((a) => (
            <div key={a.t} style={{ display: 'flex', gap: 14, alignItems: 'center' }}>
              <Stripe label="thumb" height={68} radius={16} tone={a.tone} style={{ width: 68, flexShrink: 0 }} />
              <div style={{ flex: 1 }}>
                <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}><Chip style={{ fontSize: 10.5, padding: '3px 8px' }}>{a.cat}</Chip><span style={{ fontFamily: PV.body, fontSize: 11, color: PV.n300 }}>{a.read}</span></div>
                <div style={{ fontFamily: PV.ui, fontWeight: 600, fontSize: 14.5, color: PV.p900, marginTop: 6, lineHeight: 1.25 }}>{a.t}</div>
              </div>
            </div>
          ))}
        </div>
      </div>
      <TabBarA active={3} />
    </Screen>
  );
}
window.ReadA = ReadA;

// 9 ── ASK VEDA (AI chat) ───────────────────────────────────────
function VedaA() {
  return (
    <Screen bg="#faf6fd" padBottom={28} scroll={false}>
      <Blobs items={[{ top: -30, right: -30, size: 170, color: PV.p100, opacity: 0.5, blur: 48 }]} />
      <div style={{ height: '100%', display: 'flex', flexDirection: 'column', padding: '0 22px' }}>
        <div style={{ textAlign: 'center' }}>
          <div style={{ display: 'inline-flex', marginBottom: 10 }}><Chip bg={PV.c100} color={PV.c700}>✦ Coming soon</Chip></div>
          <div style={{ fontFamily: PV.serif, fontSize: 26, fontWeight: 500, color: PV.p900, letterSpacing: -0.5, lineHeight: 1.15 }}>Meet Ask Veda</div>
          <div style={{ ...A.body, fontSize: 13, marginTop: 6 }}>Your personal, bilingual pregnancy guide.</div>
        </div>

        {/* chat */}
        <div style={{ flex: 1, marginTop: 22, display: 'flex', flexDirection: 'column', gap: 12, overflow: 'hidden' }}>
          <div style={{ alignSelf: 'flex-end', maxWidth: '78%', background: PV.p500, color: '#fff', borderRadius: '18px 18px 4px 18px', padding: '11px 15px', fontFamily: PV.body, fontSize: 13.5, lineHeight: 1.45 }}>
            Can I eat papaya in my second trimester?
          </div>
          <div style={{ alignSelf: 'flex-start', maxWidth: '82%', background: '#fff', color: PV.n900, borderRadius: '18px 18px 18px 4px', padding: '13px 15px', fontFamily: PV.body, fontSize: 13.5, lineHeight: 1.5, boxShadow: PV.shadowSoft }}>
            Ripe papaya in small amounts is generally fine 💛 It's best to avoid raw or semi-ripe papaya. As always, check with your doctor for your specific case.
          </div>
          <div style={{ alignSelf: 'flex-end', maxWidth: '78%', background: PV.p500, color: '#fff', borderRadius: '18px 18px 4px 18px', padding: '11px 15px', fontFamily: PV.body, fontSize: 13.5, lineHeight: 1.45 }}>
            Can you suggest a gentle raga for tonight?
          </div>
          <div style={{ alignSelf: 'flex-start', background: '#fff', borderRadius: '18px 18px 18px 4px', padding: '13px 16px', boxShadow: PV.shadowSoft, display: 'flex', gap: 5 }}>
            {[0, 1, 2].map((i) => <div key={i} style={{ width: 7, height: 7, borderRadius: 99, background: PV.p300 }} />)}
          </div>
        </div>

        {/* get notified */}
        <div style={{ background: '#fff', borderRadius: 18, padding: '7px 7px 7px 18px', display: 'flex', alignItems: 'center', gap: 10, boxShadow: PV.shadowSoft, marginBottom: 4 }}>
          <span style={{ flex: 1, fontFamily: PV.body, fontSize: 13.5, color: PV.n300 }}>Get notified when ready</span>
          <div style={{ background: PV.p500, color: '#fff', fontFamily: PV.ui, fontWeight: 700, fontSize: 13, padding: '11px 18px', borderRadius: 13 }}>Notify me</div>
        </div>
        <div style={{ textAlign: 'center', fontFamily: PV.body, fontSize: 11, color: PV.n300, marginTop: 8 }}>Gentle guidance, not medical advice.</div>
      </div>
    </Screen>
  );
}
window.VedaA = VedaA;

// 10 ── COMMUNITY ───────────────────────────────────────────────
function CommunityA() {
  const posts = [
    { who: 'Meera · Week 26', ago: '2h', body: 'First time I felt the hiccups today 🥹 Such a strange, lovely flutter. Did anyone else cry?', hearts: 48, replies: 12, tone: PV.c100 },
    { who: 'Divya · Week 31', ago: '5h', body: "Sharing my grandmother's carom-seed water recipe for the bloating — it actually helped!", hearts: 96, replies: 23, tone: PV.lav2 },
  ];
  return (
    <Screen bg={PV.canvas} padBottom={120}>
      <div style={{ padding: '0 24px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <div style={A.label}>Community</div>
            <div style={{ ...A.h1, fontSize: 26, marginTop: 6 }}>Walking together</div>
          </div>
          <div style={{ width: 42, height: 42, borderRadius: 99, background: PV.lav1, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="search" size={20} color={PV.p500} /></div>
        </div>

        {/* circles */}
        <div style={{ display: 'flex', gap: 10, marginTop: 18 }}>
          {['Due in Sept', 'Week 24', 'Garbh Sanskar', 'First-time'].map((c, i) => (
            <Chip key={c} bg={i === 0 ? PV.p500 : '#fff'} color={i === 0 ? '#fff' : PV.n600} style={{ boxShadow: i === 0 ? 'none' : PV.shadowSoft, fontSize: 12, padding: '8px 13px' }}>{c}</Chip>
          ))}
        </div>

        <div style={{ marginTop: 20, display: 'flex', flexDirection: 'column', gap: 14 }}>
          {posts.map((p) => (
            <div key={p.who} style={{ background: '#fff', borderRadius: 22, padding: '18px 18px', boxShadow: PV.shadowSoft }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 11 }}>
                <div style={{ width: 38, height: 38, borderRadius: 99, background: p.tone, flexShrink: 0 }} />
                <div>
                  <div style={{ fontFamily: PV.ui, fontWeight: 600, fontSize: 13.5, color: PV.p900 }}>{p.who}</div>
                  <div style={{ fontFamily: PV.body, fontSize: 11, color: PV.n300 }}>{p.ago} ago</div>
                </div>
              </div>
              <div style={{ ...A.body, fontSize: 13.5, color: PV.n900, marginTop: 12 }}>{p.body}</div>
              <div style={{ display: 'flex', gap: 20, marginTop: 14 }}>
                <span style={{ display: 'flex', alignItems: 'center', gap: 6, fontFamily: PV.body, fontSize: 12.5, color: PV.c700, fontWeight: 600 }}><Icon name="heart" size={16} color={PV.c500} /> {p.hearts}</span>
                <span style={{ display: 'flex', alignItems: 'center', gap: 6, fontFamily: PV.body, fontSize: 12.5, color: PV.n600, fontWeight: 600 }}><Icon name="message-circle" size={16} color={PV.n600} /> {p.replies}</span>
              </div>
            </div>
          ))}
        </div>
      </div>
      <TabBarA active={4} />
    </Screen>
  );
}
window.CommunityA = CommunityA;

// 11 ── FATHER MODE ─────────────────────────────────────────────
function FatherA() {
  return (
    <Screen bg="#23282a" padBottom={28}>
      <Blobs items={[{ top: -30, right: -40, size: 180, color: 'rgba(224,146,28,0.35)', opacity: 0.6, blur: 54 }]} />
      <div style={{ padding: '0 24px' }}>
        <div style={{ display: 'inline-flex', marginBottom: 14 }}><Chip bg="rgba(224,146,28,0.18)" color={PV.amber}>Father Mode</Chip></div>
        <div style={{ fontFamily: PV.serif, fontSize: 30, fontWeight: 500, color: '#fff', letterSpacing: -0.6, lineHeight: 1.1 }}>Becoming a<br />father, gently</div>
        <div style={{ fontFamily: PV.body, fontSize: 14, lineHeight: 1.55, color: 'rgba(255,255,255,0.6)', marginTop: 12 }}>
          Your own journey, in parallel with Aanya's. Small ways to show up this week.
        </div>

        {/* week card */}
        <div style={{ marginTop: 22, background: 'rgba(255,255,255,0.06)', borderRadius: 22, padding: '20px 20px', border: '1px solid rgba(255,255,255,0.08)' }}>
          <div style={{ fontFamily: PV.body, fontSize: 11, fontWeight: 700, letterSpacing: 1.2, textTransform: 'uppercase', color: PV.amber }}>This week · 24</div>
          <div style={{ fontFamily: PV.ui, fontWeight: 600, fontSize: 17, color: '#fff', marginTop: 8 }}>She can hear you now</div>
          <div style={{ fontFamily: PV.body, fontSize: 13.5, lineHeight: 1.5, color: 'rgba(255,255,255,0.65)', marginTop: 6 }}>Baby recognises voices this week. Read aloud for a few minutes tonight — your voice matters.</div>
        </div>

        {/* action rows */}
        <div style={{ marginTop: 16, display: 'flex', flexDirection: 'column', gap: 10 }}>
          {[
            { n: 'book-open', t: 'Read a verse to baby', s: 'Tonight · 5 min' },
            { n: 'heart-handshake', t: 'A small act for Aanya', s: 'Foot rub & warm milk' },
            { n: 'briefcase', t: 'Pack one bag item', s: 'You: chargers & snacks' },
          ].map((r) => (
            <div key={r.t} style={{ display: 'flex', alignItems: 'center', gap: 14, background: 'rgba(255,255,255,0.05)', borderRadius: 16, padding: '13px 15px' }}>
              <div style={{ width: 38, height: 38, borderRadius: 11, background: 'rgba(224,146,28,0.16)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name={r.n} size={19} color={PV.amber} stroke={1.9} /></div>
              <div style={{ flex: 1 }}>
                <div style={{ fontFamily: PV.ui, fontWeight: 600, fontSize: 14, color: '#fff' }}>{r.t}</div>
                <div style={{ fontFamily: PV.body, fontSize: 12, color: 'rgba(255,255,255,0.5)' }}>{r.s}</div>
              </div>
              <Icon name="chevron-right" size={18} color="rgba(255,255,255,0.4)" />
            </div>
          ))}
        </div>
      </div>
    </Screen>
  );
}
window.FatherA = FatherA;
