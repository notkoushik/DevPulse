import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import {
  Github,
  Code2,
  Calendar,
  Bell,
  Moon,
  Sun,
  Shield,
  HelpCircle,
  LogOut,
  ChevronRight,
  ExternalLink,
  Flame,
  GitCommit,
  Target,
  X,
  TrendingUp,
  TrendingDown,
  Lightbulb,
  Share2,
  Lock,
} from "lucide-react";
import { GlassCard } from "../shared/GlassCard";
import { useTheme } from "../shared/ThemeProvider";
import { userData, leetcodeStats, badges, weeklyReport } from "../shared/mockData";

function SettingRow({
  icon: Icon,
  label,
  value,
  color = "var(--dp-text-muted)",
  danger = false,
  onClick,
  trailing,
}: {
  icon: typeof Bell;
  label: string;
  value?: string;
  color?: string;
  danger?: boolean;
  onClick?: () => void;
  trailing?: React.ReactNode;
}) {
  return (
    <button
      onClick={onClick}
      className="flex items-center justify-between py-3.5 w-full active:opacity-60 transition-opacity"
      style={{ borderBottom: "1px solid var(--dp-border-subtle)" }}
    >
      <div className="flex items-center gap-3">
        <Icon size={15} style={{ color }} strokeWidth={1.5} />
        <span
          className="text-[13px]"
          style={{ color: danger ? "#e8646a" : "var(--dp-text-tertiary)" }}
        >
          {label}
        </span>
      </div>
      <div className="flex items-center gap-2">
        {trailing}
        {value && <span className="text-[11px]" style={{ color: "var(--dp-text-dim)" }}>{value}</span>}
        <ChevronRight size={14} style={{ color: "var(--dp-text-faint)" }} strokeWidth={1.5} />
      </div>
    </button>
  );
}

export function ProfileScreen() {
  const [showReport, setShowReport] = useState(false);
  const { theme, toggleTheme } = useTheme();

  const joinDate = new Date(userData.joinedDate).toLocaleDateString("en-US", {
    month: "long",
    year: "numeric",
  });

  const commitDiff = weeklyReport.totalCommits - weeklyReport.lastWeekCommits;
  const goalPct = Math.round((weeklyReport.goalsCompleted / weeklyReport.goalsTotal) * 100);

  return (
    <div className="px-6 pt-14 pb-4 space-y-5">
      {/* Profile Header */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.6 }}
        className="flex flex-col items-center text-center pt-2"
      >
        <div className="w-[68px] h-[68px] rounded-2xl bg-[#8b72ff] flex items-center justify-center mb-4">
          <span className="font-serif text-[28px] text-white italic">
            {userData.name.charAt(0)}
          </span>
        </div>
        <h1 className="font-serif text-[24px] italic" style={{ color: "var(--dp-text)" }}>
          {userData.name}
        </h1>
        <p className="text-[12px] mt-1" style={{ color: "var(--dp-text-muted)" }}>
          @{userData.username}
        </p>
        <div className="flex items-center gap-1.5 mt-2">
          <Calendar size={11} style={{ color: "var(--dp-text-dim)" }} strokeWidth={1.5} />
          <span className="text-[10px]" style={{ color: "var(--dp-text-dim)" }}>
            Joined {joinDate}
          </span>
        </div>
      </motion.div>

      {/* Stats */}
      <div className="grid grid-cols-4 gap-2">
        {[
          { icon: Flame, value: userData.streak, label: "Streak", color: "#e8646a" },
          { icon: GitCommit, value: userData.totalCommits.toLocaleString(), label: "Commits", color: "#8b72ff" },
          { icon: Code2, value: leetcodeStats.totalSolved, label: "Solved", color: "#f0c95c" },
          { icon: Target, value: 12, label: "Goals", color: "#34d1a0" },
        ].map((stat, index) => (
          <GlassCard key={stat.label} className="py-3 px-2 text-center" delay={0.05 + index * 0.04}>
            <stat.icon size={13} className="mx-auto mb-2" style={{ color: stat.color }} strokeWidth={1.5} />
            <p className="font-mono text-[16px] tracking-tight" style={{ color: "var(--dp-text)", lineHeight: 1 }}>
              {stat.value}
            </p>
            <p className="text-[8px] mt-1.5 tracking-[0.12em] uppercase" style={{ color: "var(--dp-text-dim)" }}>
              {stat.label}
            </p>
          </GlassCard>
        ))}
      </div>

      {/* Weekly Report Card */}
      <GlassCard className="p-5" delay={0.18}>
        <div className="flex items-center justify-between mb-4">
          <p className="text-[10px] tracking-[0.15em] uppercase" style={{ color: "var(--dp-text-muted)" }}>
            Weekly Report
          </p>
          <button
            onClick={() => setShowReport(true)}
            className="flex items-center gap-1 text-[10px] active:opacity-60 transition-opacity"
            style={{ color: "var(--dp-text-muted)" }}
          >
            Expand <ChevronRight size={10} />
          </button>
        </div>
        <div className="grid grid-cols-3 gap-3">
          <div>
            <p className="font-mono text-[20px] tracking-tight" style={{ color: "var(--dp-text)", lineHeight: 1 }}>
              {weeklyReport.totalCommits}
            </p>
            <div className="flex items-center gap-1 mt-1.5">
              {commitDiff >= 0 ? (
                <TrendingUp size={9} className="text-[#34d1a0]" strokeWidth={1.5} />
              ) : (
                <TrendingDown size={9} className="text-[#e8646a]" strokeWidth={1.5} />
              )}
              <span className={`text-[9px] ${commitDiff >= 0 ? "text-[#34d1a0]" : "text-[#e8646a]"}`}>
                {commitDiff >= 0 ? "+" : ""}{commitDiff}
              </span>
            </div>
            <p className="text-[8px] mt-0.5 tracking-[0.08em] uppercase" style={{ color: "var(--dp-text-dim)" }}>Commits</p>
          </div>
          <div>
            <p className="font-mono text-[20px] tracking-tight" style={{ color: "var(--dp-text)", lineHeight: 1 }}>
              {weeklyReport.lcSolved.total}
            </p>
            <p className="text-[9px] mt-1.5" style={{ color: "var(--dp-text-muted)" }}>
              {weeklyReport.lcSolved.easy}E · {weeklyReport.lcSolved.medium}M · {weeklyReport.lcSolved.hard}H
            </p>
            <p className="text-[8px] mt-0.5 tracking-[0.08em] uppercase" style={{ color: "var(--dp-text-dim)" }}>LC Solved</p>
          </div>
          <div>
            <p className="font-mono text-[20px] tracking-tight" style={{ color: "var(--dp-text)", lineHeight: 1 }}>
              {goalPct}%
            </p>
            <p className="text-[9px] mt-1.5" style={{ color: "var(--dp-text-muted)" }}>
              {weeklyReport.goalsCompleted}/{weeklyReport.goalsTotal}
            </p>
            <p className="text-[8px] mt-0.5 tracking-[0.08em] uppercase" style={{ color: "var(--dp-text-dim)" }}>Goals</p>
          </div>
        </div>
      </GlassCard>

      {/* Connected Accounts */}
      <GlassCard className="p-5" delay={0.22}>
        <p className="text-[10px] tracking-[0.15em] uppercase mb-4" style={{ color: "var(--dp-text-muted)" }}>
          Connected
        </p>
        {[
          { icon: Github, name: "GitHub", user: `@${userData.username}`, color: "var(--dp-text)" },
          { icon: Code2, name: "LeetCode", user: `@${userData.username}`, color: "#f0c95c" },
        ].map((account) => (
          <div
            key={account.name}
            className="flex items-center justify-between py-3"
            style={{ borderBottom: "1px solid var(--dp-border-subtle)" }}
          >
            <div className="flex items-center gap-3">
              <account.icon size={16} style={{ color: account.color }} strokeWidth={1.5} />
              <div>
                <p className="text-[13px]" style={{ color: "var(--dp-text-tertiary)" }}>{account.name}</p>
                <p className="text-[10px]" style={{ color: "var(--dp-text-dim)" }}>{account.user}</p>
              </div>
            </div>
            <div className="flex items-center gap-2.5">
              <span className="text-[9px] text-[#34d1a0] tracking-wide">Connected</span>
              <ExternalLink size={12} style={{ color: "var(--dp-text-ghost)" }} strokeWidth={1.5} />
            </div>
          </div>
        ))}
      </GlassCard>

      {/* Achievements */}
      <GlassCard className="p-5" delay={0.26}>
        <div className="flex items-center justify-between mb-4">
          <p className="text-[10px] tracking-[0.15em] uppercase" style={{ color: "var(--dp-text-muted)" }}>
            Achievements
          </p>
          <span className="text-[10px]" style={{ color: "var(--dp-text-dim)" }}>
            {badges.filter((b) => b.unlocked).length}/{badges.length}
          </span>
        </div>
        <div className="space-y-2.5">
          {badges.map((badge, index) => (
            <motion.div
              key={badge.id}
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.3 + index * 0.04 }}
              className="flex items-center gap-3.5"
            >
              <div
                className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 ${
                  badge.unlocked ? "" : "opacity-30"
                }`}
                style={{
                  backgroundColor: `${badge.color}12`,
                  border: `1px solid ${badge.color}${badge.unlocked ? "25" : "10"}`,
                }}
              >
                {badge.unlocked ? (
                  <span className="font-serif text-[17px] italic" style={{ color: badge.color }}>
                    {badge.label.charAt(0)}
                  </span>
                ) : (
                  <Lock size={13} style={{ color: "var(--dp-text-dim)" }} strokeWidth={1.5} />
                )}
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <p className="text-[12px]" style={{ color: badge.unlocked ? "var(--dp-text-tertiary)" : "var(--dp-text-dim)" }}>
                    {badge.label}
                  </p>
                  {badge.unlocked && (
                    <span className="text-[8px] text-[#34d1a0] tracking-wider uppercase">Unlocked</span>
                  )}
                </div>
                <p className="text-[10px]" style={{ color: "var(--dp-text-dim)" }}>{badge.condition}</p>
                {!badge.unlocked && (
                  <div
                    className="mt-1.5 h-[2px] rounded-full overflow-hidden w-24"
                    style={{ backgroundColor: "var(--dp-fill)" }}
                  >
                    <div className="h-full rounded-full" style={{ width: `${badge.progress}%`, backgroundColor: badge.color }} />
                  </div>
                )}
              </div>
              {!badge.unlocked && (
                <span className="font-mono text-[11px] shrink-0" style={{ color: "var(--dp-text-dim)" }}>
                  {badge.progress}%
                </span>
              )}
            </motion.div>
          ))}
        </div>
      </GlassCard>

      {/* Settings */}
      <GlassCard className="px-5 py-2" delay={0.3}>
        <SettingRow icon={Bell} label="Notifications" value="On" color="#f0c95c" />
        <SettingRow
          icon={theme === "dark" ? Moon : Sun}
          label="Appearance"
          color="#8b72ff"
          onClick={toggleTheme}
          trailing={
            <div
              className="flex items-center rounded-full px-2 py-0.5"
              style={{ backgroundColor: "var(--dp-fill)" }}
            >
              <span className="text-[10px]" style={{ color: "var(--dp-text-muted)" }}>
                {theme === "dark" ? "Dark" : "Light"}
              </span>
            </div>
          }
        />
        <SettingRow icon={Target} label="Daily Target" value="5 goals" color="#34d1a0" />
        <SettingRow icon={Shield} label="Privacy" color="#6ab8e8" />
        <SettingRow icon={HelpCircle} label="Help" color="var(--dp-text-muted)" />
        <SettingRow icon={LogOut} label="Sign Out" danger />
      </GlassCard>

      {/* Footer */}
      <motion.p
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.5 }}
        className="text-center text-[10px] pb-2 tracking-wider"
        style={{ color: "var(--dp-text-invisible)" }}
      >
        DevPulse v1.0.0
      </motion.p>

      {/* Weekly Report Modal */}
      <AnimatePresence>
        {showReport && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-[60] flex items-center justify-center p-6"
          >
            <div
              className="absolute inset-0"
              style={{ backgroundColor: "var(--dp-overlay-heavy)" }}
              onClick={() => setShowReport(false)}
            />
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
              transition={{ type: "spring", damping: 25, stiffness: 300 }}
              className="relative w-full max-w-[380px] rounded-2xl p-6 overflow-auto max-h-[85vh]"
              style={{
                backgroundColor: "var(--dp-surface)",
                border: "1px solid var(--dp-border)",
              }}
            >
              {/* Report Header */}
              <div className="flex items-center justify-between mb-5">
                <div>
                  <p className="text-[9px] tracking-[0.15em] uppercase" style={{ color: "var(--dp-text-dim)" }}>Weekly Report</p>
                  <p className="text-[14px] mt-0.5" style={{ color: "var(--dp-text-secondary)" }}>{weeklyReport.weekRange}</p>
                </div>
                <button
                  onClick={() => setShowReport(false)}
                  className="w-7 h-7 rounded-full flex items-center justify-center"
                  style={{ backgroundColor: "var(--dp-fill)" }}
                >
                  <X size={14} style={{ color: "var(--dp-text-muted)" }} strokeWidth={1.5} />
                </button>
              </div>

              {/* Streak */}
              <div className="flex items-center gap-3 mb-5 pb-5" style={{ borderBottom: "1px solid var(--dp-border)" }}>
                <Flame size={18} className="text-[#e8646a]" strokeWidth={1.5} />
                <div>
                  <span className="font-mono text-[28px] tracking-tighter" style={{ color: "var(--dp-text)", lineHeight: 1 }}>
                    {weeklyReport.streak}
                  </span>
                  <span className="text-[12px] ml-2" style={{ color: "var(--dp-text-dim)" }}>day streak</span>
                </div>
              </div>

              {/* Stats Grid */}
              <div className="grid grid-cols-2 gap-4 mb-5 pb-5" style={{ borderBottom: "1px solid var(--dp-border)" }}>
                <div>
                  <p className="text-[9px] tracking-[0.12em] uppercase" style={{ color: "var(--dp-text-dim)" }}>Total Commits</p>
                  <div className="flex items-baseline gap-2 mt-1">
                    <span className="font-mono text-[24px] tracking-tight" style={{ color: "var(--dp-text)", lineHeight: 1 }}>
                      {weeklyReport.totalCommits}
                    </span>
                    <span className={`text-[10px] flex items-center gap-0.5 ${commitDiff >= 0 ? "text-[#34d1a0]" : "text-[#e8646a]"}`}>
                      {commitDiff >= 0 ? <TrendingUp size={9} /> : <TrendingDown size={9} />}
                      {commitDiff >= 0 ? "+" : ""}{commitDiff}
                    </span>
                  </div>
                </div>
                <div>
                  <p className="text-[9px] tracking-[0.12em] uppercase" style={{ color: "var(--dp-text-dim)" }}>LC Solved</p>
                  <span className="font-mono text-[24px] tracking-tight" style={{ color: "var(--dp-text)", lineHeight: 1 }}>
                    {weeklyReport.lcSolved.total}
                  </span>
                  <p className="text-[9px] mt-1" style={{ color: "var(--dp-text-muted)" }}>
                    {weeklyReport.lcSolved.easy} Easy · {weeklyReport.lcSolved.medium} Med · {weeklyReport.lcSolved.hard} Hard
                  </p>
                </div>
                <div>
                  <p className="text-[9px] tracking-[0.12em] uppercase" style={{ color: "var(--dp-text-dim)" }}>Goals Done</p>
                  <div className="flex items-baseline gap-1.5 mt-1">
                    <span className="font-mono text-[24px] tracking-tight" style={{ color: "var(--dp-text)", lineHeight: 1 }}>
                      {weeklyReport.goalsCompleted}
                    </span>
                    <span className="text-[12px]" style={{ color: "var(--dp-text-dim)" }}>/ {weeklyReport.goalsTotal}</span>
                  </div>
                  <p className="text-[9px] text-[#34d1a0] mt-1">{goalPct}% success rate</p>
                </div>
              </div>

              {/* Best / Weakest Day */}
              <div className="space-y-3 mb-5 pb-5" style={{ borderBottom: "1px solid var(--dp-border)" }}>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <TrendingUp size={12} className="text-[#34d1a0]" strokeWidth={1.5} />
                    <span className="text-[12px]" style={{ color: "var(--dp-text-tertiary)" }}>Best day</span>
                  </div>
                  <span className="text-[11px]" style={{ color: "var(--dp-text-muted)" }}>
                    {weeklyReport.bestDay.day} — {weeklyReport.bestDay.commits} commits, {weeklyReport.bestDay.lc} LC
                  </span>
                </div>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <TrendingDown size={12} className="text-[#e8646a]" strokeWidth={1.5} />
                    <span className="text-[12px]" style={{ color: "var(--dp-text-tertiary)" }}>Weakest day</span>
                  </div>
                  <span className="text-[11px]" style={{ color: "var(--dp-text-muted)" }}>
                    {weeklyReport.weakestDay.day} — {weeklyReport.weakestDay.commits} commits, {weeklyReport.weakestDay.lc} LC
                  </span>
                </div>
              </div>

              {/* Tip */}
              <div className="flex items-start gap-2.5 mb-5">
                <Lightbulb size={14} className="text-[#f0c95c] shrink-0 mt-0.5" strokeWidth={1.5} />
                <p className="text-[11px]" style={{ color: "var(--dp-text-muted)" }}>{weeklyReport.tip}</p>
              </div>

              {/* Share */}
              <button
                className="w-full py-2.5 rounded-xl text-[12px] flex items-center justify-center gap-2 active:scale-[0.98] transition-all"
                style={{
                  border: "1px solid var(--dp-border)",
                  color: "var(--dp-text-muted)",
                }}
              >
                <Share2 size={13} strokeWidth={1.5} />
                Share Report Card
              </button>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}