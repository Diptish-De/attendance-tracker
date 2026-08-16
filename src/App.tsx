import { useState, useEffect, useCallback, useRef } from 'react'

// ─── Types ────────────────────────────────────────────────────────────────────
type Tab = 'home' | 'subjects' | 'calendar' | 'simulator' | 'profile'
type Risk = 'safe' | 'caution' | 'danger' | 'critical'

interface Subject {
  id: string; name: string; icon: string; faculty: string
  attended: number; total: number
}

interface Toast { id: number; text: string; color: string; icon: string }

// ─── Initial Data ─────────────────────────────────────────────────────────────
const INITIAL_SUBJECTS: Subject[] = [
  { id: 'dsa',  name: 'DSA',   icon: '🌐', faculty: 'Prof. Sharma', attended: 34, total: 40 },
  { id: 'oop',  name: 'OOP',   icon: '🧩', faculty: 'Dr. Mehta',   attended: 28, total: 37 },
  { id: 'dm',   name: 'DM',    icon: '∑',  faculty: 'Prof. Gupta', attended: 29, total: 33 },
  { id: 'dsco', name: 'DSCO',  icon: '⚙️', faculty: 'Dr. Verma',  attended: 17, total: 23 },
  { id: 'dbms', name: 'DBMS',  icon: '🗄️', faculty: 'Dr. Nair',   attended: 15, total: 22 },
]

const INITIAL_ACHIEVEMENTS = [
  { id: 'lab',      icon: '🔬', title: 'Lab Guardian',    desc: '100% lab attendance',          unlocked: true  },
  { id: 'week',     icon: '⚡', title: 'Perfect Week',    desc: 'All classes for one week',     unlocked: true  },
  { id: 'bunker',   icon: '🎯', title: 'Pro Bunker',      desc: 'Maintained 75%+ all semester', unlocked: false },
  { id: 'recovery', icon: '💪', title: 'Recovery Master', desc: 'Recovered from below 70%',     unlocked: false },
  { id: 'streak',   icon: '🔥', title: '10-Day Streak',   desc: '10 days attended in a row',    unlocked: true  },
  { id: 'ghost',    icon: '👻', title: 'Ghost Mode',      desc: '5 strategic skips in a week',  unlocked: false },
]

const LEAVE_HISTORY_INIT = [
  { id: 1, type: 'Annual Leave', dates: 'May 05 – May 07, 2026', days: 3, status: 'Approved' as const },
  { id: 2, type: 'Sick Leave',   dates: 'Apr 21, 2026',          days: 1, status: 'Pending'  as const },
  { id: 3, type: 'Casual Leave', dates: 'Mar 14, 2026',          days: 2, status: 'Approved' as const },
]

// ─── Helpers ──────────────────────────────────────────────────────────────────
const pct  = (s: Subject) => Math.round((s.attended / s.total) * 100)
const risk = (p: number): Risk => p >= 80 ? 'safe' : p >= 75 ? 'caution' : p >= 70 ? 'danger' : 'critical'

const RISK_COLOR: Record<Risk, string> = { safe: '#22c55e', caution: '#f59e0b', danger: '#f97316', critical: '#ef4444' }
const RISK_LABEL: Record<Risk, string> = { safe: 'SAFE', caution: 'CAUTION', danger: 'RISKY', critical: 'CRITICAL' }
const RISK_BG:    Record<Risk, string> = { safe: '#dcfce7', caution: '#fef9c3', danger: '#ffedd5', critical: '#fee2e2' }

function safeSkips(s: Subject) {
  const min = Math.ceil(0.75 * (s.total + 8))
  return Math.max(0, s.attended - min + 8)
}

// ─── Toast system ─────────────────────────────────────────────────────────────
function ToastContainer({ toasts }: { toasts: Toast[] }) {
  return (
    <div style={{ position: 'absolute', top: 60, left: 12, right: 12, zIndex: 200, display: 'flex', flexDirection: 'column', gap: 8, pointerEvents: 'none' }}>
      {toasts.map(t => (
        <div key={t.id} className="pop-in" style={{
          background: '#fff', borderRadius: 14, padding: '12px 16px',
          boxShadow: '0 4px 24px #0003', display: 'flex', alignItems: 'center', gap: 10,
          borderLeft: `4px solid ${t.color}`,
        }}>
          <span style={{ fontSize: 18 }}>{t.icon}</span>
          <span style={{ fontSize: 13, fontWeight: 700, color: '#1a1a2e' }}>{t.text}</span>
        </div>
      ))}
    </div>
  )
}

// ─── Semi-circle gauge ────────────────────────────────────────────────────────
function SemiGauge({ value, size = 190 }: { value: number; size?: number }) {
  const [anim, setAnim] = useState(0)
  useEffect(() => { const t = setTimeout(() => setAnim(value), 250); return () => clearTimeout(t) }, [value])
  const r = (size - 24) / 2
  const cx = size / 2; const cy = size / 2 - 10
  const circ = Math.PI * r
  const fill = (anim / 100) * circ
  const rk = risk(anim)
  const trackD = `M ${cx - r},${cy} A ${r},${r} 0 0 1 ${cx + r},${cy}`
  return (
    <div style={{ position: 'relative', width: size, height: size / 2 + 28 }}>
      <svg width={size} height={size / 2 + 10} style={{ overflow: 'visible' }}>
        <path d={trackD} fill="none" stroke="#e2e8f0" strokeWidth={16} strokeLinecap="round" />
        <path d={trackD} fill="none" stroke={RISK_COLOR[rk]} strokeWidth={16} strokeLinecap="round"
          strokeDasharray={`${fill} ${circ}`}
          style={{ transition: 'stroke-dasharray 1.2s cubic-bezier(.4,0,.2,1)', filter: `drop-shadow(0 0 6px ${RISK_COLOR[rk]}80)` }} />
      </svg>
      <div style={{ position: 'absolute', bottom: 0, left: 0, right: 0, textAlign: 'center' }}>
        <div style={{ fontSize: 42, fontWeight: 900, color: '#1a1a2e', lineHeight: 1 }}>
          {anim}<span style={{ fontSize: 20, fontWeight: 700 }}>%</span>
        </div>
        <div style={{ display: 'inline-flex', alignItems: 'center', gap: 5, marginTop: 6, background: RISK_BG[rk], borderRadius: 99, padding: '5px 12px' }}>
          <div style={{ width: 8, height: 8, borderRadius: '50%', background: RISK_COLOR[rk] }} />
          <span style={{ fontSize: 12, fontWeight: 800, color: RISK_COLOR[rk] }}>{rk === 'safe' ? 'SAFE ZONE' : RISK_LABEL[rk]}</span>
        </div>
        <div style={{ fontSize: 11, color: '#94a3b8', marginTop: 4 }}>Minimum Required: 75%</div>
      </div>
    </div>
  )
}

// ─── Donut ────────────────────────────────────────────────────────────────────
function Donut({ value, size = 72, color }: { value: number; size?: number; color: string }) {
  const r = (size - 10) / 2; const circ = 2 * Math.PI * r; const dash = (value / 100) * circ
  return (
    <svg width={size} height={size}>
      <circle cx={size/2} cy={size/2} r={r} fill="none" stroke="#e2e8f0" strokeWidth={7} />
      <circle cx={size/2} cy={size/2} r={r} fill="none" stroke={color} strokeWidth={7}
        strokeLinecap="round" strokeDasharray={`${dash} ${circ}`} strokeDashoffset={circ / 4}
        style={{ transition: 'stroke-dasharray 1s ease' }} />
      <text x="50%" y="50%" textAnchor="middle" dominantBaseline="central"
        style={{ fontSize: 14, fontWeight: 800, fill: '#1a1a2e', fontFamily: 'Nunito, sans-serif' }}>{value}%</text>
    </svg>
  )
}

// ─── Bar ──────────────────────────────────────────────────────────────────────
function Bar({ value, color, height = 8 }: { value: number; color: string; height?: number }) {
  return (
    <div style={{ background: '#e2e8f0', borderRadius: 99, height, overflow: 'hidden' }}>
      <div style={{ height: '100%', width: `${value}%`, background: color, borderRadius: 99, transition: 'width 0.8s ease' }} />
    </div>
  )
}

// ─── Card ─────────────────────────────────────────────────────────────────────
function Card({ children, style }: { children: React.ReactNode; style?: React.CSSProperties }) {
  return <div style={{ background: '#fff', borderRadius: 20, boxShadow: '0 2px 16px #0000000d', padding: 16, ...style }}>{children}</div>
}

// ─── Modal ────────────────────────────────────────────────────────────────────
function Modal({ title, onClose, children }: { title: string; onClose: () => void; children: React.ReactNode }) {
  return (
    <div style={{ position: 'absolute', inset: 0, background: '#0006', zIndex: 100, display: 'flex', alignItems: 'flex-end' }} onClick={onClose}>
      <div className="slide-up" style={{ background: '#fff', borderRadius: '24px 24px 0 0', width: '100%', padding: '20px 20px 40px', maxHeight: '85%', overflowY: 'auto' }} onClick={e => e.stopPropagation()}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 18 }}>
          <h2 style={{ margin: 0, fontSize: 18, fontWeight: 800 }}>{title}</h2>
          <button onClick={onClose} style={{ background: '#f1f5f9', border: 'none', borderRadius: 10, width: 32, height: 32, cursor: 'pointer', fontSize: 16 }}>✕</button>
        </div>
        {children}
      </div>
    </div>
  )
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────
function HomeIcon()     { return <svg viewBox="0 0 24 24" fill="currentColor" width="22" height="22"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg> }
function SubjectsIcon() { return <svg viewBox="0 0 24 24" fill="currentColor" width="22" height="22"><path d="M4 6h16v2H4zm0 5h16v2H4zm0 5h16v2H4z"/></svg> }
function CalIcon()      { return <svg viewBox="0 0 24 24" fill="currentColor" width="22" height="22"><path d="M19 3h-1V1h-2v2H8V1H6v2H5a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2V5a2 2 0 00-2-2zm0 16H5V8h14v11z"/></svg> }
function SimIcon()      { return <svg viewBox="0 0 24 24" fill="currentColor" width="22" height="22"><path d="M21 6H3a1 1 0 00-1 1v10a1 1 0 001 1h18a1 1 0 001-1V7a1 1 0 00-1-1zm-1 10H4V8h16v8zM6 10h2v2H6zm0 3h2v2H6zm3-3h6v2H9zm0 3h6v2H9zm7-3h2v2h-2zm0 3h2v2h-2z"/></svg> }
function UserIcon()     { return <svg viewBox="0 0 24 24" fill="currentColor" width="22" height="22"><path d="M12 12c2.7 0 4.8-2.1 4.8-4.8S14.7 2.4 12 2.4 7.2 4.5 7.2 7.2 9.3 12 12 12zm0 2.4c-3.2 0-9.6 1.6-9.6 4.8v2.4h19.2v-2.4c0-3.2-6.4-4.8-9.6-4.8z"/></svg> }

const NAV_ITEMS: { id: Tab; label: string; icon: React.ReactNode }[] = [
  { id: 'home',      label: 'Home',      icon: <HomeIcon /> },
  { id: 'subjects',  label: 'Subjects',  icon: <SubjectsIcon /> },
  { id: 'calendar',  label: 'Calendar',  icon: <CalIcon /> },
  { id: 'simulator', label: 'Simulator', icon: <SimIcon /> },
  { id: 'profile',   label: 'Profile',   icon: <UserIcon /> },
]

function BottomNav({ active, onChange }: { active: Tab; onChange: (t: Tab) => void }) {
  return (
    <div style={{ position: 'absolute', bottom: 0, left: 0, right: 0, height: 70, background: '#fff', borderTop: '1px solid #f1f5f9', display: 'flex', alignItems: 'center', justifyContent: 'space-around', boxShadow: '0 -4px 20px #0000000a', zIndex: 50 }}>
      {NAV_ITEMS.map(item => {
        const on = item.id === active
        return (
          <button key={item.id} onClick={() => onChange(item.id)} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3, background: 'none', border: 'none', cursor: 'pointer', color: on ? '#22c55e' : '#94a3b8', padding: '6px 12px', borderRadius: 14, transition: 'color 0.2s', fontFamily: 'Nunito, sans-serif' }}>
            {item.icon}
            <span style={{ fontSize: 10, fontWeight: 700 }}>{item.label}</span>
            {on && <div style={{ width: 4, height: 4, borderRadius: '50%', background: '#22c55e' }} />}
          </button>
        )
      })}
    </div>
  )
}

// ─── Sparkline ────────────────────────────────────────────────────────────────
function Sparkline({ trend, color }: { trend: 'up' | 'down' | 'flat'; color: string }) {
  const points = { up: '0,30 10,25 20,20 30,18 40,12 50,8', down: '0,8 10,12 20,18 30,22 40,26 50,30', flat: '0,18 10,17 20,19 30,16 40,18 50,17' }
  return <svg width={52} height={32} style={{ display: 'block' }}><polyline points={points[trend]} fill="none" stroke={color} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" /></svg>
}

// ─── Notifications panel ──────────────────────────────────────────────────────
function NotificationsPanel({ subjects, onClose }: { subjects: Subject[]; onClose: () => void }) {
  const alerts = subjects.map(s => {
    const p = pct(s); const r = risk(p); const sk = safeSkips(s)
    if (r === 'safe' && sk > 2) return { icon: '✅', text: `You can safely skip ${sk} more ${s.name} classes.`, color: '#22c55e', bg: '#dcfce7' }
    if (r === 'caution') return { icon: '⚠️', text: `${s.name} is at ${p}% — one more miss puts you at risk.`, color: '#f59e0b', bg: '#fef9c3' }
    if (r === 'danger')  return { icon: '🔥', text: `${s.name} danger zone! Only ${sk} skip${sk !== 1 ? 's' : ''} left.`, color: '#f97316', bg: '#ffedd5' }
    if (r === 'critical') return { icon: '💀', text: `${s.name} critical! Do NOT skip any more classes.`, color: '#ef4444', bg: '#fee2e2' }
    return null
  }).filter(Boolean) as { icon: string; text: string; color: string; bg: string }[]

  alerts.push({ icon: '🎉', text: 'Durga Puja detected. Teaching days reduced. Attendance budget recalculated.', color: '#f97316', bg: '#ffedd5' })

  return (
    <Modal title="🔔 Notifications" onClose={onClose}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {alerts.map((a, i) => (
          <div key={i} style={{ background: a.bg, borderRadius: 14, padding: '12px 14px', display: 'flex', gap: 10, alignItems: 'flex-start', borderLeft: `4px solid ${a.color}` }}>
            <span style={{ fontSize: 18 }}>{a.icon}</span>
            <p style={{ margin: 0, fontSize: 13, fontWeight: 600, color: '#374151', lineHeight: 1.5 }}>{a.text}</p>
          </div>
        ))}
      </div>
    </Modal>
  )
}

// ─── Streak modal ─────────────────────────────────────────────────────────────
function StreakModal({ onClose }: { onClose: () => void }) {
  const days = ['Mon','Tue','Wed','Thu','Fri','Mon','Tue','Wed','Thu','Fri','Mon','Tue','Wed','Thu','Fri']
  return (
    <Modal title="🔥 Your Streak" onClose={onClose}>
      <div style={{ textAlign: 'center', marginBottom: 20 }}>
        <p style={{ margin: 0, fontSize: 56, fontWeight: 900, color: '#22c55e' }}>15</p>
        <p style={{ margin: '4px 0 0', fontSize: 14, color: '#94a3b8' }}>consecutive days attended</p>
      </div>
      <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap', justifyContent: 'center', marginBottom: 20 }}>
        {days.map((d, i) => (
          <div key={i} style={{ width: 38, height: 38, borderRadius: 10, background: '#dcfce7', border: '2px solid #22c55e', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ fontSize: 16 }}>✓</span>
            <span style={{ fontSize: 8, color: '#22c55e', fontWeight: 700 }}>{d}</span>
          </div>
        ))}
      </div>
      <div style={{ background: '#f0fdf4', borderRadius: 14, padding: 14, textAlign: 'center' }}>
        <p style={{ margin: 0, fontSize: 13, fontWeight: 700, color: '#16a34a' }}>🏆 Keep going! 5 more days to unlock <strong>Perfect Month</strong> badge.</p>
      </div>
    </Modal>
  )
}

// ─── History modal ────────────────────────────────────────────────────────────
function HistoryModal({ subject, onClose }: { subject: Subject; onClose: () => void }) {
  const entries = [
    { date: 'Aug 14', status: 'present' }, { date: 'Aug 13', status: 'present' },
    { date: 'Aug 12', status: 'absent'  }, { date: 'Aug 09', status: 'present' },
    { date: 'Aug 08', status: 'present' }, { date: 'Aug 07', status: 'holiday' },
    { date: 'Aug 06', status: 'present' }, { date: 'Aug 05', status: 'absent'  },
  ]
  const colors: Record<string,string> = { present: '#22c55e', absent: '#ef4444', holiday: '#f59e0b' }
  const icons:  Record<string,string> = { present: '✓', absent: '✗', holiday: '🎉' }
  return (
    <Modal title={`${subject.icon} ${subject.name} History`} onClose={onClose}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        {entries.map((e, i) => (
          <div key={i} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: `${colors[e.status]}10`, borderRadius: 12, padding: '12px 14px', borderLeft: `3px solid ${colors[e.status]}` }}>
            <span style={{ fontSize: 14, fontWeight: 700 }}>{e.date}, 2026</span>
            <span style={{ fontSize: 13, fontWeight: 800, color: colors[e.status] }}>{icons[e.status]} {e.status.charAt(0).toUpperCase() + e.status.slice(1)}</span>
          </div>
        ))}
      </div>
    </Modal>
  )
}

// ─── Apply Leave modal ────────────────────────────────────────────────────────
function ApplyLeaveModal({ onClose, onApply }: { onClose: () => void; onApply: (type: string, days: number) => void }) {
  const [type, setType] = useState('Annual Leave')
  const [days, setDays] = useState(1)
  const [reason, setReason] = useState('')
  const types = ['Annual Leave', 'Casual Leave', 'Sick Leave', 'Medical Leave']
  return (
    <Modal title="Apply for Leave" onClose={onClose}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
        <div>
          <label style={{ fontSize: 11, color: '#94a3b8', fontWeight: 700, display: 'block', marginBottom: 6 }}>LEAVE TYPE</label>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
            {types.map(t => (
              <button key={t} onClick={() => setType(t)} style={{ padding: '10px 8px', borderRadius: 12, border: `2px solid ${type === t ? '#22c55e' : '#e2e8f0'}`, background: type === t ? '#dcfce7' : '#fff', color: type === t ? '#16a34a' : '#64748b', fontSize: 12, fontWeight: 700, cursor: 'pointer', fontFamily: 'Nunito, sans-serif', transition: 'all 0.15s' }}>{t}</button>
            ))}
          </div>
        </div>
        <div>
          <label style={{ fontSize: 11, color: '#94a3b8', fontWeight: 700, display: 'block', marginBottom: 6 }}>NUMBER OF DAYS: <span style={{ color: '#22c55e' }}>{days}</span></label>
          <input type="range" min={1} max={10} value={days} onChange={e => setDays(Number(e.target.value))} style={{ width: '100%' }} />
        </div>
        <div>
          <label style={{ fontSize: 11, color: '#94a3b8', fontWeight: 700, display: 'block', marginBottom: 6 }}>REASON</label>
          <textarea value={reason} onChange={e => setReason(e.target.value)} placeholder="Enter reason for leave..." style={{ width: '100%', padding: '10px 12px', borderRadius: 12, border: '1.5px solid #e2e8f0', fontSize: 13, fontFamily: 'Nunito, sans-serif', resize: 'none', outline: 'none', height: 80, boxSizing: 'border-box', color: '#1a1a2e' }} />
        </div>
        <button onClick={() => onApply(type, days)} style={{ background: '#22c55e', border: 'none', borderRadius: 14, padding: '15px', color: '#fff', fontSize: 14, fontWeight: 800, cursor: 'pointer', fontFamily: 'Nunito, sans-serif', boxShadow: '0 4px 16px #22c55e40' }}>
          Submit Application
        </button>
      </div>
    </Modal>
  )
}

// ─── HOME ─────────────────────────────────────────────────────────────────────
function Home({ subjects, onNav, onToast, onShowNotifs, onShowStreak }: {
  subjects: Subject[]; onNav: (t: Tab) => void
  onToast: (text: string, color: string, icon: string) => void
  onShowNotifs: () => void; onShowStreak: () => void
}) {
  const overall = Math.round(subjects.reduce((a, s) => a + pct(s), 0) / subjects.length)

  return (
    <div style={{ overflowY: 'auto', height: '100%', paddingBottom: 80, background: '#f8fafc' }}>
      <div style={{ background: '#fff', padding: '52px 20px 20px', borderBottom: '1px solid #f1f5f9' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <div style={{ width: 46, height: 46, borderRadius: '50%', background: 'linear-gradient(135deg, #a3e635, #22c55e)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 22 }}>🎓</div>
            <div>
              <p style={{ margin: 0, fontSize: 15, fontWeight: 800 }}>Hi, Arjun 👋</p>
              <p style={{ margin: 0, fontSize: 11, color: '#94a3b8' }}>Keep attending, keep winning!</p>
            </div>
          </div>
          <button onClick={onShowNotifs} style={{ position: 'relative', width: 40, height: 40, borderRadius: '50%', background: '#f1f5f9', border: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
            <svg viewBox="0 0 24 24" fill="#64748b" width="20" height="20"><path d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.9 2 2 2zm6-6v-5c0-3.07-1.64-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.63 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z"/></svg>
            <div style={{ position: 'absolute', top: 2, right: 2, width: 10, height: 10, background: '#ef4444', borderRadius: '50%', border: '2px solid #fff' }} />
          </button>
        </div>
      </div>

      <div style={{ padding: '16px 16px 0' }}>
        <Card style={{ marginBottom: 12 }}>
          <p style={{ margin: '0 0 4px', fontSize: 12, color: '#94a3b8', fontWeight: 700, letterSpacing: '0.06em' }}>Overall Attendance</p>
          <div style={{ display: 'flex', alignItems: 'flex-end', gap: 16 }}>
            <SemiGauge value={overall} size={190} />
            <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 8, paddingBottom: 4 }}>
              {[
                { label: 'Safe Skips Remaining', value: `${subjects.reduce((a,s) => a + safeSkips(s), 0)}`, color: '#22c55e', bg: '#dcfce7', icon: '🎯' },
                { label: 'Teaching Days Left',   value: '58',                                                color: '#3b82f6', bg: '#dbeafe', icon: '📅' },
                { label: 'Semester Progress',    value: '46%',                                               color: '#f97316', bg: '#ffedd5', icon: '📈' },
              ].map(c => (
                <div key={c.label} style={{ background: c.bg, borderRadius: 14, padding: '10px 12px' }}>
                  <p style={{ margin: 0, fontSize: 9, color: c.color, fontWeight: 700, letterSpacing: '0.06em' }}>{c.label.toUpperCase()}</p>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 2 }}>
                    <span style={{ fontSize: 20, fontWeight: 900, color: c.color }}>{c.value}</span>
                    <span style={{ fontSize: 18 }}>{c.icon}</span>
                  </div>
                </div>
              ))}
              <div style={{ background: '#fce7f3', borderRadius: 14, padding: '10px 12px' }}>
                <p style={{ margin: 0, fontSize: 9, color: '#ec4899', fontWeight: 700, letterSpacing: '0.06em' }}>UPCOMING HOLIDAY</p>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 2 }}>
                  <div>
                    <p style={{ margin: 0, fontSize: 13, fontWeight: 800, color: '#1a1a2e' }}>Durga Puja</p>
                    <p style={{ margin: 0, fontSize: 10, color: '#ec4899' }}>9 days to go</p>
                  </div>
                  <span style={{ fontSize: 18 }}>🎉</span>
                </div>
              </div>
            </div>
          </div>
        </Card>

        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', margin: '4px 0 10px' }}>
          <span style={{ fontSize: 15, fontWeight: 800 }}>Subject Overview</span>
          <button onClick={() => onNav('subjects')} style={{ background: 'none', border: 'none', fontSize: 12, color: '#22c55e', fontWeight: 700, cursor: 'pointer', fontFamily: 'Nunito, sans-serif' }}>See All</button>
        </div>

        <div style={{ display: 'flex', gap: 10, overflowX: 'auto', paddingBottom: 8 }}>
          {subjects.map(s => {
            const p = pct(s); const r = risk(p); const col = RISK_COLOR[r]; const sk = safeSkips(s)
            return (
              <button key={s.id} onClick={() => onNav('subjects')} style={{ flexShrink: 0, background: '#fff', borderRadius: 20, boxShadow: '0 2px 12px #0000000d', padding: '14px 12px', textAlign: 'center', width: 100, border: 'none', cursor: 'pointer', fontFamily: 'Nunito, sans-serif' }}>
                <Donut value={p} size={72} color={col} />
                <p style={{ margin: '8px 0 2px', fontSize: 13, fontWeight: 800, color: '#1a1a2e' }}>{s.name}</p>
                <p style={{ margin: 0, fontSize: 10, color: col, fontWeight: 700, background: RISK_BG[r], borderRadius: 99, padding: '1px 8px', display: 'inline-block' }}>
                  {sk} skip{sk !== 1 ? 's' : ''} left
                </p>
              </button>
            )
          })}
        </div>

        <Card style={{ marginTop: 12, display: 'flex', alignItems: 'center', gap: 14 }}>
          <span style={{ fontSize: 38 }}>🏆</span>
          <div style={{ flex: 1 }}>
            <p style={{ margin: 0, fontSize: 14, fontWeight: 800 }}>{"You're doing great! 🚀"}</p>
            <p style={{ margin: '2px 0 10px', fontSize: 11, color: '#94a3b8' }}>Keep it up to maintain your streak.</p>
            <button onClick={onShowStreak} style={{ background: '#22c55e', border: 'none', borderRadius: 99, color: '#fff', padding: '7px 16px', fontSize: 12, fontWeight: 700, cursor: 'pointer', fontFamily: 'Nunito, sans-serif' }}>
              View Streak
            </button>
          </div>
          <div style={{ textAlign: 'center' }}>
            <p style={{ margin: 0, fontSize: 28, fontWeight: 900, color: '#22c55e' }}>15</p>
            <p style={{ margin: 0, fontSize: 10, color: '#94a3b8' }}>days</p>
          </div>
        </Card>
      </div>
    </div>
  )
}

// ─── SUBJECTS ─────────────────────────────────────────────────────────────────
function SubjectsScreen({ subjects, updateSubject, onNav, setSimSubject, onToast }: {
  subjects: Subject[]; updateSubject: (id: string, fn: (s: Subject) => Subject) => void
  onNav: (t: Tab) => void; setSimSubject: (id: string) => void
  onToast: (text: string, color: string, icon: string) => void
}) {
  const [selId, setSelId] = useState<string | null>(null)
  const [showHistory, setShowHistory] = useState(false)
  const subject = subjects.find(s => s.id === selId)

  const markPresent = (s: Subject) => {
    updateSubject(s.id, x => ({ ...x, attended: x.attended + 1, total: x.total + 1 }))
    onToast(`${s.name}: marked present ✓`, '#22c55e', '✅')
  }
  const markAbsent = (s: Subject) => {
    updateSubject(s.id, x => ({ ...x, total: x.total + 1 }))
    onToast(`${s.name}: marked absent`, '#ef4444', '❌')
  }
  const simulateSkip = (s: Subject) => {
    setSimSubject(s.id)
    onNav('simulator')
  }

  if (subject) {
    const p = pct(subject); const r = risk(p); const col = RISK_COLOR[r]; const sk = safeSkips(subject)
    return (
      <div style={{ overflowY: 'auto', height: '100%', paddingBottom: 80, background: '#f8fafc' }}>
        {showHistory && <HistoryModal subject={subject} onClose={() => setShowHistory(false)} />}
        <div style={{ background: '#fff', padding: '52px 20px 20px', display: 'flex', alignItems: 'center', gap: 12, borderBottom: '1px solid #f1f5f9' }}>
          <button onClick={() => setSelId(null)} style={{ width: 36, height: 36, borderRadius: 12, background: '#f1f5f9', border: 'none', cursor: 'pointer', fontSize: 18, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>←</button>
          <div>
            <h2 style={{ margin: 0, fontSize: 18, fontWeight: 800 }}>{subject.name}</h2>
            <p style={{ margin: 0, fontSize: 11, color: '#94a3b8' }}>{subject.faculty}</p>
          </div>
        </div>
        <div style={{ padding: '16px' }}>
          <Card style={{ textAlign: 'center', marginBottom: 12 }}>
            <Donut value={p} size={120} color={col} />
            <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, marginTop: 10, background: RISK_BG[r], borderRadius: 99, padding: '6px 16px' }}>
              <div style={{ width: 8, height: 8, borderRadius: '50%', background: col }} />
              <span style={{ fontSize: 13, fontWeight: 800, color: col }}>{RISK_LABEL[r]}</span>
            </div>
            <p style={{ margin: '8px 0 0', fontSize: 12, color: '#94a3b8' }}>
              {sk > 0 ? `Safe to skip ${sk} more class${sk > 1 ? 'es' : ''}.` : 'Do NOT skip any more classes!'}
            </p>
          </Card>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10, marginBottom: 12 }}>
            {[
              { label: 'Attended', val: subject.attended, color: '#22c55e', bg: '#dcfce7' },
              { label: 'Missed',   val: subject.total - subject.attended, color: '#ef4444', bg: '#fee2e2' },
              { label: 'Skips',    val: sk, color: '#3b82f6', bg: '#dbeafe' },
            ].map(st => (
              <Card key={st.label} style={{ textAlign: 'center', padding: '14px 8px', background: st.bg }}>
                <p style={{ margin: 0, fontSize: 22, fontWeight: 900, color: st.color }}>{st.val}</p>
                <p style={{ margin: '3px 0 0', fontSize: 10, color: st.color, fontWeight: 700 }}>{st.label}</p>
              </Card>
            ))}
          </div>
          <Card style={{ marginBottom: 12 }}>
            <p style={{ margin: '0 0 10px', fontSize: 12, color: '#94a3b8', fontWeight: 700 }}>HEALTH METER</p>
            <Bar value={p} color={col} height={12} />
            <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 6 }}>
              <span style={{ fontSize: 10, color: '#94a3b8' }}>{subject.attended}/{subject.total} classes</span>
              <span style={{ fontSize: 10, fontWeight: 700, color: col }}>{p}%</span>
            </div>
          </Card>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            {[
              { label: 'Mark Present',  color: '#22c55e', bg: '#dcfce7', fn: () => markPresent(subject) },
              { label: 'Mark Absent',   color: '#ef4444', bg: '#fee2e2', fn: () => markAbsent(subject) },
              { label: 'View History',  color: '#7c3aed', bg: '#ede9fe', fn: () => setShowHistory(true) },
              { label: 'Simulate Skip', color: '#f97316', bg: '#ffedd5', fn: () => simulateSkip(subject) },
            ].map(b => (
              <button key={b.label} onClick={b.fn} style={{ background: b.bg, border: 'none', borderRadius: 14, padding: '14px 12px', color: b.color, fontSize: 13, fontWeight: 700, cursor: 'pointer', fontFamily: 'Nunito, sans-serif', transition: 'opacity 0.15s' }}>
                {b.label}
              </button>
            ))}
          </div>
        </div>
      </div>
    )
  }

  return (
    <div style={{ overflowY: 'auto', height: '100%', paddingBottom: 80, background: '#f8fafc' }}>
      <div style={{ background: '#fff', padding: '52px 20px 20px', borderBottom: '1px solid #f1f5f9' }}>
        <h1 style={{ margin: 0, fontSize: 20, fontWeight: 800 }}>My Subjects</h1>
        <p style={{ margin: '3px 0 0', fontSize: 12, color: '#94a3b8' }}>Tap a subject to manage it</p>
      </div>
      <div style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: 10 }}>
        {subjects.map(s => {
          const p = pct(s); const r = risk(p); const col = RISK_COLOR[r]; const sk = safeSkips(s)
          return (
            <button key={s.id} onClick={() => setSelId(s.id)} style={{ background: '#fff', border: 'none', borderRadius: 20, boxShadow: '0 2px 12px #0000000d', padding: '16px', display: 'flex', alignItems: 'center', gap: 14, cursor: 'pointer', textAlign: 'left', fontFamily: 'Nunito, sans-serif' }}>
              <div style={{ flexShrink: 0 }}><Donut value={p} size={68} color={col} /></div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                  <div>
                    <p style={{ margin: 0, fontSize: 15, fontWeight: 800, color: '#1a1a2e' }}>{s.name}</p>
                    <p style={{ margin: '1px 0 8px', fontSize: 11, color: '#94a3b8' }}>{s.faculty}</p>
                  </div>
                  <span style={{ fontSize: 10, fontWeight: 800, color: col, background: RISK_BG[r], padding: '3px 10px', borderRadius: 99 }}>{RISK_LABEL[r]}</span>
                </div>
                <Bar value={p} color={col} height={7} />
                <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 5 }}>
                  <span style={{ fontSize: 10, color: '#94a3b8' }}>{s.attended}/{s.total} attended</span>
                  <span style={{ fontSize: 10, color: col, fontWeight: 700 }}>{sk} skip{sk !== 1 ? 's' : ''} left</span>
                </div>
              </div>
            </button>
          )
        })}
      </div>
    </div>
  )
}

// ─── CALENDAR ─────────────────────────────────────────────────────────────────
const LEAVE_TYPES_DATA = [
  { name: 'Annual Leave', icon: '🌴', color: '#22c55e', bg: '#dcfce7', available: 12, used: 3,  total: 15 },
  { name: 'Casual Leave', icon: '☕', color: '#3b82f6', bg: '#dbeafe', available: 6,  used: 4,  total: 10 },
  { name: 'Sick Leave',   icon: '🩺', color: '#ef4444', bg: '#fee2e2', available: 5,  used: 5,  total: 10 },
  { name: 'Medical Leave',icon: '💊', color: '#7c3aed', bg: '#ede9fe', available: 4,  used: 6,  total: 10 },
]
const MONTHS = ['January','February','March','April','May','June','July','August','September','October','November','December']

function CalendarScreen({ onToast }: { onToast: (text: string, color: string, icon: string) => void }) {
  const [monthIdx, setMonthIdx] = useState(7) // August
  const [showApply, setShowApply] = useState(false)
  const nextId = useRef(100)
  const [history, setHistory] = useState(LEAVE_HISTORY_INIT)
  const [showAll, setShowAll] = useState(false)
  const STATUS_COLOR: Record<string,string> = { Approved: '#22c55e', Pending: '#f97316', Rejected: '#ef4444' }
  const STATUS_BG:    Record<string,string> = { Approved: '#dcfce7', Pending: '#ffedd5', Rejected: '#fee2e2' }

  const handleApply = (type: string, days: number) => {
    const newEntry = { id: nextId.current++, type, dates: `Aug 18 – Aug ${18 + days - 1}, 2026`, days, status: 'Pending' as const }
    setHistory(h => [newEntry, ...h])
    setShowApply(false)
    onToast(`${type} application submitted!`, '#22c55e', '📋')
  }

  const displayed = showAll ? history : history.slice(0, 3)

  return (
    <div style={{ overflowY: 'auto', height: '100%', paddingBottom: 80, background: '#f8fafc' }}>
      {showApply && <ApplyLeaveModal onClose={() => setShowApply(false)} onApply={handleApply} />}
      <div style={{ background: '#fff', padding: '52px 20px 20px', borderBottom: '1px solid #f1f5f9', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end' }}>
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <h1 style={{ margin: 0, fontSize: 18, fontWeight: 800 }}>Leave Management</h1>
          </div>
          <p style={{ margin: '3px 0 0', fontSize: 11, color: '#94a3b8' }}>Manage your leaves and applications</p>
        </div>
        <div style={{ display: 'flex', gap: 6 }}>
          <button onClick={() => setMonthIdx(i => Math.max(0, i - 1))} style={{ width: 32, height: 32, background: '#f1f5f9', border: 'none', borderRadius: 10, cursor: 'pointer', fontSize: 16 }}>‹</button>
          <button onClick={() => setMonthIdx(i => Math.min(11, i + 1))} style={{ width: 32, height: 32, background: '#f1f5f9', border: 'none', borderRadius: 10, cursor: 'pointer', fontSize: 16 }}>›</button>
        </div>
      </div>

      <div style={{ padding: '16px' }}>
        <p style={{ margin: '0 0 12px', fontSize: 13, fontWeight: 800, color: '#94a3b8' }}>{MONTHS[monthIdx]} 2026</p>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginBottom: 16 }}>
          {LEAVE_TYPES_DATA.map(lt => (
            <Card key={lt.name}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 10 }}>
                <div style={{ width: 38, height: 38, borderRadius: 12, background: lt.bg, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 20 }}>{lt.icon}</div>
                <p style={{ margin: 0, fontSize: 13, fontWeight: 800 }}>{lt.name}</p>
              </div>
              <div style={{ display: 'flex', alignItems: 'baseline', gap: 6, marginBottom: 6 }}>
                <span style={{ fontSize: 28, fontWeight: 900 }}>{String(lt.available).padStart(2,'0')}</span>
                <span style={{ fontSize: 11, color: '#94a3b8', fontWeight: 600 }}>Available</span>
              </div>
              <Bar value={(lt.available / lt.total) * 100} color={lt.color} height={8} />
              <p style={{ margin: '5px 0 0', fontSize: 10, color: '#94a3b8' }}>{lt.used} Used / {lt.total} Total</p>
            </Card>
          ))}
        </div>

        <button onClick={() => setShowApply(true)} style={{ width: '100%', background: '#22c55e', border: 'none', borderRadius: 16, padding: '16px', color: '#fff', fontSize: 15, fontWeight: 800, cursor: 'pointer', fontFamily: 'Nunito, sans-serif', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, boxShadow: '0 4px 16px #22c55e40', marginBottom: 20 }}>
          <span style={{ fontSize: 18 }}>+</span> Apply for Leave
        </button>

        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
          <span style={{ fontSize: 15, fontWeight: 800 }}>Leave History</span>
          <button onClick={() => setShowAll(v => !v)} style={{ background: 'none', border: 'none', fontSize: 12, color: '#22c55e', fontWeight: 700, cursor: 'pointer', fontFamily: 'Nunito, sans-serif' }}>{showAll ? 'Show Less' : 'See All'}</button>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {displayed.map(h => (
            <Card key={h.id}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                <div>
                  <p style={{ margin: 0, fontSize: 14, fontWeight: 800 }}>{h.type}</p>
                  <p style={{ margin: '2px 0 0', fontSize: 11, color: '#94a3b8' }}>{h.dates}</p>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <span style={{ fontSize: 11, fontWeight: 800, color: STATUS_COLOR[h.status], background: STATUS_BG[h.status], padding: '3px 10px', borderRadius: 99, display: 'block', marginBottom: 4 }}>{h.status}</span>
                  <span style={{ fontSize: 11, color: '#94a3b8' }}>{h.days} day{h.days > 1 ? 's' : ''}</span>
                </div>
              </div>
            </Card>
          ))}
        </div>
      </div>
    </div>
  )
}

// ─── SIMULATOR ────────────────────────────────────────────────────────────────
function SimulatorScreen({ subjects, initialSubId }: { subjects: Subject[]; initialSubId: string }) {
  const [subId, setSubId] = useState(initialSubId)
  const [skips, setSkips] = useState(1)
  useEffect(() => { setSubId(initialSubId) }, [initialSubId])

  const sub  = subjects.find(s => s.id === subId) ?? subjects[0]
  const cur  = pct(sub)
  const after = Math.max(0, Math.round((sub.attended / (sub.total + skips)) * 100))
  const ar    = risk(after)

  const VERDICTS: Record<Risk, { text: string; sub: string; color: string; bg: string; icon: string }> = {
    safe:     { text: 'VERDICT: SAFE',    sub: "You can skip! Attendance stays above 75%.",          color: '#22c55e', bg: '#dcfce7', icon: '✅' },
    caution:  { text: 'VERDICT: RISKY',   sub: 'Borderline. One more miss could hurt you.',          color: '#f59e0b', bg: '#fef9c3', icon: '⚠️' },
    danger:   { text: 'VERDICT: DANGER',  sub: 'Dangerously close to the 75% limit.',               color: '#f97316', bg: '#ffedd5', icon: '🔥' },
    critical: { text: "DON'T DO IT",      sub: 'You will drop below 75%. Professor will notice.',    color: '#ef4444', bg: '#fee2e2', icon: '💀' },
  }
  const verdict = VERDICTS[ar]

  const scenarios = [
    { label: 'Skip Tomorrow',       skips: 1 },
    { label: 'Skip Next 2 Classes', skips: 2 },
    { label: 'Skip Every Monday',   skips: 4 },
  ]

  return (
    <div style={{ overflowY: 'auto', height: '100%', paddingBottom: 80, background: '#f8fafc' }}>
      <div style={{ background: '#fff', padding: '52px 20px 20px', borderBottom: '1px solid #f1f5f9' }}>
        <h1 style={{ margin: 0, fontSize: 18, fontWeight: 800 }}>Bunk Simulator</h1>
        <p style={{ margin: '3px 0 0', fontSize: 11, color: '#94a3b8' }}>Simulate and plan your strategy</p>
      </div>

      <div style={{ padding: '16px' }}>
        <Card style={{ background: '#f0fdf4', border: '1px solid #bbf7d0', marginBottom: 12 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div style={{ flex: 1 }}>
              <p style={{ margin: '0 0 14px', fontSize: 16, fontWeight: 800 }}>What if you skip this class?</p>
              <div style={{ marginBottom: 10 }}>
                <label style={{ fontSize: 10, color: '#94a3b8', fontWeight: 700, display: 'block', marginBottom: 4 }}>Subject</label>
                <select value={subId} onChange={e => setSubId(e.target.value)} style={{ width: '100%', padding: '10px 12px', borderRadius: 12, border: '1.5px solid #e2e8f0', background: '#fff', fontSize: 13, fontWeight: 700, fontFamily: 'Nunito, sans-serif', color: '#1a1a2e', cursor: 'pointer', outline: 'none' }}>
                  {subjects.map(s => <option key={s.id} value={s.id}>{s.name} – {s.faculty}</option>)}
                </select>
              </div>
              <div>
                <label style={{ fontSize: 10, color: '#94a3b8', fontWeight: 700, display: 'block', marginBottom: 4 }}>Date</label>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: '#fff', borderRadius: 12, border: '1.5px solid #e2e8f0', padding: '10px 12px' }}>
                  <span style={{ fontSize: 13, fontWeight: 700 }}>Tomorrow, 17 Aug 2026</span>
                  <svg viewBox="0 0 24 24" fill="#94a3b8" width="18" height="18"><path d="M19 3h-1V1h-2v2H8V1H6v2H5a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2V5a2 2 0 00-2-2zm0 16H5V8h14v11z"/></svg>
                </div>
              </div>
            </div>
            <div style={{ fontSize: 52, marginLeft: 8, marginTop: -4, flexShrink: 0 }}>🤔</div>
          </div>
        </Card>

        <Card style={{ marginBottom: 12 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
            <p style={{ margin: 0, fontSize: 12, color: '#94a3b8', fontWeight: 700 }}>CLASSES TO SKIP</p>
            <span style={{ fontSize: 16, fontWeight: 900, color: '#22c55e' }}>{skips}</span>
          </div>
          <input type="range" min={1} max={10} value={skips} onChange={e => setSkips(Number(e.target.value))} style={{ width: '100%' }} />
        </Card>

        <p style={{ margin: '0 0 10px', fontSize: 13, fontWeight: 800 }}>Simulation Result</p>
        <Card style={{ marginBottom: 12 }}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr auto 1fr', alignItems: 'center', gap: 8, marginBottom: 14 }}>
            <div style={{ textAlign: 'center' }}>
              <p style={{ margin: '0 0 4px', fontSize: 10, color: '#94a3b8', fontWeight: 700 }}>Current Attendance</p>
              <p style={{ margin: 0, fontSize: 32, fontWeight: 900, color: RISK_COLOR[risk(cur)] }}>{cur}%</p>
            </div>
            <div style={{ width: 28, height: 28, borderRadius: '50%', background: '#f1f5f9', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 14 }}>→</div>
            <div style={{ textAlign: 'center' }}>
              <p style={{ margin: '0 0 4px', fontSize: 10, color: '#94a3b8', fontWeight: 700 }}>After Skipping</p>
              <p style={{ margin: 0, fontSize: 32, fontWeight: 900, color: RISK_COLOR[ar] }}>{after}%</p>
            </div>
          </div>
          <div style={{ background: verdict.bg, borderRadius: 14, padding: '12px 14px', display: 'flex', alignItems: 'flex-start', gap: 10 }}>
            <div style={{ width: 28, height: 28, borderRadius: '50%', background: verdict.color, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, fontSize: 14 }}>{verdict.icon}</div>
            <div>
              <p style={{ margin: 0, fontSize: 13, fontWeight: 900, color: verdict.color }}>{verdict.text}</p>
              <p style={{ margin: '2px 0 0', fontSize: 11, color: verdict.color, opacity: 0.8 }}>{verdict.sub}</p>
            </div>
          </div>
        </Card>

        <p style={{ margin: '0 0 10px', fontSize: 13, fontWeight: 800 }}>What if you skip more?</p>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8 }}>
          {scenarios.map(sc => {
            const p2 = Math.max(0, Math.round((sub.attended / (sub.total + sc.skips)) * 100))
            const r2 = risk(p2); const col = RISK_COLOR[r2]
            return (
              <Card key={sc.label} style={{ padding: 12, textAlign: 'center', cursor: 'pointer', border: `2px solid ${skips === sc.skips ? col : 'transparent'}`, transition: 'border-color 0.2s' }} onClick={() => setSkips(sc.skips)}>
                <p style={{ margin: '0 0 4px', fontSize: 9, color: '#94a3b8', fontWeight: 700, lineHeight: 1.3 }}>{sc.label}</p>
                <p style={{ margin: '0 0 4px', fontSize: 20, fontWeight: 900, color: col }}>{p2}%</p>
                <Sparkline trend={p2 < cur ? 'down' : 'up'} color={col} />
                <p style={{ margin: '2px 0 0', fontSize: 9, fontWeight: 800, color: col }}>{RISK_LABEL[r2]}</p>
              </Card>
            )
          })}
        </div>
      </div>
    </div>
  )
}

// ─── PROFILE ──────────────────────────────────────────────────────────────────
function ProfileScreen({ subjects, onToast }: { subjects: Subject[]; onToast: (text: string, color: string, icon: string) => void }) {
  const [achievements, setAchievements] = useState(INITIAL_ACHIEVEMENTS)
  const overall = Math.round(subjects.reduce((a, s) => a + pct(s), 0) / subjects.length)

  const toggleAchievement = (id: string) => {
    const target = achievements.find(a => a.id === id)
    if (!target || target.unlocked) return
    onToast(`Achievement unlocked: ${target.title}!`, '#f59e0b', '⭐')
    setAchievements(prev => prev.map(a => a.id === id ? { ...a, unlocked: true } : a))
  }

  return (
    <div style={{ overflowY: 'auto', height: '100%', paddingBottom: 80, background: '#f8fafc' }}>
      <div style={{ background: '#fff', padding: '52px 20px 20px', borderBottom: '1px solid #f1f5f9' }}>
        <h1 style={{ margin: 0, fontSize: 20, fontWeight: 800 }}>Profile</h1>
      </div>
      <div style={{ padding: '16px' }}>
        <Card style={{ textAlign: 'center', marginBottom: 12 }}>
          <div style={{ width: 80, height: 80, borderRadius: '50%', background: 'linear-gradient(135deg, #a3e635, #22c55e)', margin: '0 auto 12px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 40 }}>🎓</div>
          <h2 style={{ margin: '0 0 2px', fontSize: 20, fontWeight: 900 }}>Arjun Sharma</h2>
          <p style={{ margin: '0 0 16px', fontSize: 12, color: '#94a3b8' }}>B.Tech CSE · Semester 3</p>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8 }}>
            {[['Overall', `${overall}%`, '#22c55e', '#dcfce7'], ['Credits', '13', '#3b82f6', '#dbeafe'], ['Badges', `${achievements.filter(a=>a.unlocked).length}/${achievements.length}`, '#f59e0b', '#fef9c3']].map(([l,v,c,bg]) => (
              <div key={l} style={{ background: bg as string, borderRadius: 14, padding: '10px 6px', textAlign: 'center' }}>
                <p style={{ margin: 0, fontSize: 18, fontWeight: 900, color: c as string }}>{v}</p>
                <p style={{ margin: '2px 0 0', fontSize: 9, color: c as string, fontWeight: 700 }}>{l}</p>
              </div>
            ))}
          </div>
        </Card>

        <p style={{ margin: '0 0 10px', fontSize: 13, fontWeight: 800 }}>Semester Campaign</p>
        <Card style={{ marginBottom: 12 }}>
          {[
            { month: 'August',    title: 'Base Camp',      icon: '⛺', done: true,  active: false },
            { month: 'September', title: 'Regular Season', icon: '📚', done: false, active: true  },
            { month: 'October',   title: 'Festival Arc',   icon: '🎉', done: false, active: false },
            { month: 'November',  title: 'Survival Mode',  icon: '⚔️', done: false, active: false },
            { month: 'December',  title: 'Final Boss',     icon: '💀', done: false, active: false },
          ].map((s, i, arr) => (
            <div key={s.month} style={{ display: 'flex', gap: 14, alignItems: 'flex-start', marginBottom: i < arr.length - 1 ? 12 : 0, position: 'relative' }}>
              {i < arr.length - 1 && <div style={{ position: 'absolute', left: 20, top: 42, width: 2, height: 20, background: s.done ? '#22c55e' : '#e2e8f0' }} />}
              <div style={{ width: 40, height: 40, borderRadius: 14, flexShrink: 0, background: s.done ? '#22c55e' : s.active ? '#dcfce7' : '#f1f5f9', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 20, border: s.active ? '2px solid #22c55e' : '2px solid transparent', zIndex: 1 }}>{s.icon}</div>
              <div style={{ flex: 1, paddingTop: 4 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <p style={{ margin: 0, fontSize: 13, fontWeight: 800, color: s.done ? '#22c55e' : s.active ? '#1a1a2e' : '#94a3b8' }}>{s.title}</p>
                  {s.done   && <span style={{ fontSize: 10, color: '#22c55e', fontWeight: 800 }}>DONE ✓</span>}
                  {s.active && <span style={{ fontSize: 10, color: '#22c55e', fontWeight: 800, background: '#dcfce7', padding: '2px 8px', borderRadius: 99 }}>NOW</span>}
                </div>
                <p style={{ margin: '1px 0 0', fontSize: 10, color: '#94a3b8' }}>{s.month}</p>
              </div>
            </div>
          ))}
        </Card>

        <p style={{ margin: '0 0 10px', fontSize: 13, fontWeight: 800 }}>Achievements</p>
        <p style={{ margin: '-4px 0 10px', fontSize: 11, color: '#94a3b8' }}>Tap a locked badge to unlock it</p>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginBottom: 16 }}>
          {achievements.map(ach => (
            <button key={ach.id} onClick={() => toggleAchievement(ach.id)} style={{ background: '#fff', border: ach.unlocked ? '2px solid #fbbf24' : '2px solid #e2e8f0', borderRadius: 20, padding: '14px 12px', textAlign: 'left', cursor: ach.unlocked ? 'default' : 'pointer', fontFamily: 'Nunito, sans-serif', opacity: ach.unlocked ? 1 : 0.6, filter: ach.unlocked ? 'none' : 'grayscale(0.6)', transition: 'all 0.2s', boxShadow: '0 2px 12px #0000000d' }}>
              <span style={{ fontSize: 30 }}>{ach.icon}</span>
              <p style={{ margin: '8px 0 2px', fontSize: 13, fontWeight: 800, color: '#1a1a2e' }}>{ach.title}</p>
              <p style={{ margin: 0, fontSize: 10, color: '#94a3b8', lineHeight: 1.4 }}>{ach.desc}</p>
              {ach.unlocked && <p style={{ margin: '6px 0 0', fontSize: 9, color: '#f59e0b', fontWeight: 800 }}>★ UNLOCKED</p>}
              {!ach.unlocked && <p style={{ margin: '6px 0 0', fontSize: 9, color: '#94a3b8', fontWeight: 700 }}>Tap to unlock</p>}
            </button>
          ))}
        </div>

        <p style={{ margin: '0 0 10px', fontSize: 13, fontWeight: 800 }}>Smart Alerts</p>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {[
            { icon: '✅', text: "You can safely skip tomorrow's OOP class.", color: '#22c55e', bg: '#dcfce7' },
            { icon: '⚠️', text: 'One more absence in DSA drops you below 75%.', color: '#f59e0b', bg: '#fef9c3' },
            { icon: '🎉', text: 'Durga Puja detected. Budget recalculated.', color: '#f97316', bg: '#ffedd5' },
          ].map((n, i) => (
            <div key={i} style={{ background: n.bg, borderRadius: 14, padding: '12px 14px', display: 'flex', gap: 10, alignItems: 'center', borderLeft: `4px solid ${n.color}` }}>
              <span style={{ fontSize: 18 }}>{n.icon}</span>
              <p style={{ margin: 0, fontSize: 12, fontWeight: 600, color: '#374151', lineHeight: 1.5 }}>{n.text}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}

// ─── APP ROOT ─────────────────────────────────────────────────────────────────
export default function App() {
  const [tab, setTab]           = useState<Tab>('home')
  const [subjects, setSubjects] = useState<Subject[]>(INITIAL_SUBJECTS)
  const [toasts, setToasts]     = useState<Toast[]>([])
  const [simSubId, setSimSubId] = useState('dsa')
  const [showNotifs, setShowNotifs] = useState(false)
  const [showStreak, setShowStreak] = useState(false)

  const toast = useCallback((text: string, color: string, icon: string) => {
    const id = Date.now()
    setToasts(prev => [...prev, { id, text, color, icon }])
    setTimeout(() => setToasts(prev => prev.filter(t => t.id !== id)), 3000)
  }, [])

  const updateSubject = useCallback((id: string, fn: (s: Subject) => Subject) => {
    setSubjects(prev => prev.map(s => s.id === id ? fn(s) : s))
  }, [])

  const goToSimulator = useCallback((id: string) => {
    setSimSubId(id)
    setTab('simulator')
  }, [])

  return (
    <div style={{ width: '100%', height: '100vh', background: '#e2e8f0', display: 'flex', justifyContent: 'center', alignItems: 'center', fontFamily: 'Nunito, sans-serif' }}>
      <div style={{ width: '100%', maxWidth: 430, height: '100%', maxHeight: '100vh', position: 'relative', background: '#f8fafc', overflow: 'hidden' }}>
        <ToastContainer toasts={toasts} />
        {showNotifs && <NotificationsPanel subjects={subjects} onClose={() => setShowNotifs(false)} />}
        {showStreak && <StreakModal onClose={() => setShowStreak(false)} />}

        <div key={tab} className="slide-up" style={{ position: 'absolute', inset: 0, zIndex: 1 }}>
          {tab === 'home'      && <Home subjects={subjects} onNav={setTab} onToast={toast} onShowNotifs={() => setShowNotifs(true)} onShowStreak={() => setShowStreak(true)} />}
          {tab === 'subjects'  && <SubjectsScreen subjects={subjects} updateSubject={updateSubject} onNav={setTab} setSimSubject={goToSimulator} onToast={toast} />}
          {tab === 'calendar'  && <CalendarScreen onToast={toast} />}
          {tab === 'simulator' && <SimulatorScreen subjects={subjects} initialSubId={simSubId} />}
          {tab === 'profile'   && <ProfileScreen subjects={subjects} onToast={toast} />}
        </div>

        <BottomNav active={tab} onChange={setTab} />
      </div>
    </div>
  )
}
