import { useState } from "react";
import { motion } from "motion/react";
import {
  Flame,
  GitCommit,
  Code2,
  Target,
  ArrowRight,
  GitPullRequest,
  CheckCircle2,
  Zap,
  Star,
  Package,
  Sun,
  Timer,
} from "lucide-react";
import { useNavigate } from "react-router";
import { GlassCard } from "../shared/GlassCard";
import { ProgressRing } from "../shared/ProgressRing";
import { PomodoroTimer } from "../shared/PomodoroTimer";
import {
  userData,
  githubStats,
  leetcodeStats,
  goals,
  activityFeed,
} from "../shared/mockData";

function getMotivation(streak: number, best: number) {
  const gap = best - streak;
  if (gap <= 0) return "You're on your longest streak ever!";
  if (gap <= 3) return `${gap} day${gap === 1 ? "" : "s"} to beat your record!`;
  if (gap <= 10) return `Only ${gap} days to your personal best.`;
  return `Keep going — ${gap} days to your all-time best.`;
}

export function DashboardScreen() {
  const navigate = useNavigate();
  const [showPomodoro, setShowPomodoro] = useState(false);
  const completedGoals = goals.filter((g) => g.completed).length;
  const totalGoals = goals.length;
  const goalProgress = Math.round((completedGoals / totalGoals) * 100);
  const streakProgress = Math.round(
    (userData.streak / userData.longestStreak) * 100
  );
  const lcTodaySolved = leetcodeStats.weeklyProgress[6]?.solved ?? 0;
  const yesterdayCommits = githubStats.weeklyCommits[5]?.commits ?? 0;

  return (
    <div className="px-6 pt-14 pb-4 space-y-5">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.6 }}
      >
        <p
          className="text-[11px] tracking-[0.12em] uppercase"
          style={{ color: "var(--dp-text-muted)" }}
        >
          Sunday, Feb 22
        </p>
        <h1
          className="text-[28px] mt-1 tracking-[-0.01em] italic font-[K2D]"
          style={{ color: "var(--dp-text)" }}
        >
          Good evening, {userData.name}
        </h1>
      </motion.div>

      {/* Daily Briefing Banner */}
      <GlassCard className="relative overflow-hidden px-5 py-4" delay={0.03}>
        <div
          className="absolute top-0 left-0 w-full h-[1px]"
          style={{ background: "var(--dp-gradient-accent)" }}
        />
        <div className="flex items-start gap-3">
          <div className="w-7 h-7 rounded-lg bg-[#f0c95c]/10 flex items-center justify-center shrink-0 mt-0.5">
            <Sun size={14} className="text-[#f0c95c]" strokeWidth={1.5} />
          </div>
          <div className="space-y-1 min-w-0">
            <p className="text-[12px]" style={{ color: "var(--dp-text-secondary)" }}>
              Yesterday: {yesterdayCommits} commits · {leetcodeStats.weeklyProgress[5]?.solved ?? 0} LC solved
            </p>
            <p className="text-[11px]" style={{ color: "var(--dp-text-muted)" }}>
              Suggestion: Solve 1 Medium problem today
            </p>
            <p className="text-[11px] text-[#e8646a]">
              Your streak is at {userData.streak} days — don't break it!
            </p>
          </div>
        </div>
      </GlassCard>

      {/* Streak Card */}
      <GlassCard className="p-5" delay={0.05}>
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <p
              className="text-[10px] tracking-[0.15em] uppercase"
              style={{ color: "var(--dp-text-muted)" }}
            >
              Current Streak
            </p>
            <div className="flex items-baseline gap-2 mt-1.5">
              <motion.span
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3, duration: 0.5 }}
                className="font-mono text-[42px] tracking-tighter"
                style={{ color: "var(--dp-text)", lineHeight: 1 }}
              >
                {userData.streak}
              </motion.span>
              <span className="text-[12px]" style={{ color: "var(--dp-text-dim)" }}>
                days
              </span>
            </div>
            <div className="mt-3.5 space-y-1.5">
              <div
                className="h-[3px] rounded-full overflow-hidden"
                style={{ backgroundColor: "var(--dp-fill)" }}
              >
                <motion.div
                  initial={{ width: 0 }}
                  animate={{ width: `${Math.min(streakProgress, 100)}%` }}
                  transition={{ duration: 1.2, delay: 0.4, ease: [0.23, 1, 0.32, 1] }}
                  className="h-full rounded-full bg-gradient-to-r from-[#e8646a] to-[#f0c95c]"
                />
              </div>
              <p className="text-[10px]" style={{ color: "var(--dp-text-muted)" }}>
                {getMotivation(userData.streak, userData.longestStreak)}
              </p>
            </div>
          </div>
          <div className="flex flex-col items-end gap-2 ml-4">
            <motion.div
              animate={{ scale: [1, 1.15, 1] }}
              transition={{ duration: 2, repeat: Infinity, repeatDelay: 3 }}
            >
              <Flame size={22} className="text-[#e8646a]" strokeWidth={1.5} />
            </motion.div>
            <div className="text-right">
              <p
                className="text-[9px] tracking-[0.1em] uppercase"
                style={{ color: "var(--dp-text-dim)" }}
              >
                Best
              </p>
              <p className="font-mono text-[18px]" style={{ color: "var(--dp-text-muted)" }}>
                {userData.longestStreak}
              </p>
            </div>
          </div>
        </div>
      </GlassCard>

      {/* Stat Tiles — 4 cards, horizontally scrollable */}
      <div className="flex gap-3 overflow-x-auto pb-1 -mx-6 px-6 scrollbar-hide">
        <GlassCard className="p-4 min-w-[110px] shrink-0" delay={0.1} onClick={() => navigate("/github")}>
          <Zap size={13} className="text-[#8b72ff] mb-2.5" strokeWidth={1.5} />
          <p className="font-mono text-[24px] tracking-tight" style={{ color: "var(--dp-text)", lineHeight: 1 }}>
            {githubStats.todayCommits}
            <span className="text-[14px]" style={{ color: "var(--dp-text-dim)" }}>+{lcTodaySolved}</span>
          </p>
          <p
            className="text-[9px] mt-1.5 tracking-[0.1em] uppercase"
            style={{ color: "var(--dp-text-dim)" }}
          >
            Today
          </p>
        </GlassCard>

        <GlassCard className="p-4 min-w-[110px] shrink-0" delay={0.13} onClick={() => navigate("/leetcode")}>
          <Code2 size={13} className="text-[#f0c95c] mb-2.5" strokeWidth={1.5} />
          <p className="font-mono text-[24px] tracking-tight" style={{ color: "var(--dp-text)", lineHeight: 1 }}>
            {leetcodeStats.totalSolved}
          </p>
          <p className="text-[9px] mt-1.5 tracking-[0.1em] uppercase" style={{ color: "var(--dp-text-dim)" }}>
            LC Solved
          </p>
        </GlassCard>

        <GlassCard className="p-4 min-w-[110px] shrink-0" delay={0.16} onClick={() => navigate("/github")}>
          <Package size={13} className="text-[#6ab8e8] mb-2.5" strokeWidth={1.5} />
          <p className="font-mono text-[24px] tracking-tight" style={{ color: "var(--dp-text)", lineHeight: 1 }}>
            {userData.totalRepos}
          </p>
          <div className="flex items-center gap-1 mt-1.5">
            <Star size={8} className="text-[#f0c95c]" strokeWidth={1.5} />
            <span className="text-[9px] tracking-[0.1em] uppercase" style={{ color: "var(--dp-text-dim)" }}>
              {userData.totalStars}
            </span>
          </div>
        </GlassCard>

        <GlassCard className="p-4 min-w-[110px] shrink-0" delay={0.19} onClick={() => navigate("/goals")}>
          <Target size={13} className="text-[#34d1a0] mb-2.5" strokeWidth={1.5} />
          <p className="font-mono text-[24px] tracking-tight" style={{ color: "var(--dp-text)", lineHeight: 1 }}>
            {completedGoals}
            <span className="text-[14px]" style={{ color: "var(--dp-text-dim)" }}>/{totalGoals}</span>
          </p>
          <p className="text-[9px] mt-1.5 tracking-[0.1em] uppercase" style={{ color: "var(--dp-text-dim)" }}>
            Goals
          </p>
        </GlassCard>
      </div>

      {/* Pomodoro Quick Access */}
      <GlassCard className="px-5 py-4" delay={0.21} onClick={() => setShowPomodoro(true)}>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-[#8b72ff]/10 flex items-center justify-center">
              <Timer size={16} className="text-[#8b72ff]" strokeWidth={1.5} />
            </div>
            <div>
              <p className="text-[13px]" style={{ color: "var(--dp-text-secondary)" }}>
                Focus Timer
              </p>
              <p className="text-[10px]" style={{ color: "var(--dp-text-dim)" }}>
                25 min Pomodoro session
              </p>
            </div>
          </div>
          <ArrowRight size={14} style={{ color: "var(--dp-text-ghost)" }} strokeWidth={1.5} />
        </div>
      </GlassCard>

      {/* Today's Progress */}
      <GlassCard className="p-5" delay={0.24}>
        <p
          className="text-[10px] tracking-[0.15em] uppercase mb-5"
          style={{ color: "var(--dp-text-muted)" }}
        >
          Today's Progress
        </p>
        <div className="flex items-center justify-around">
          <div className="flex flex-col items-center gap-2">
            <ProgressRing progress={goalProgress} size={60} strokeWidth={3} color="#34d1a0">
              <span className="font-mono text-[13px]" style={{ color: "var(--dp-text)" }}>{goalProgress}%</span>
            </ProgressRing>
            <span className="text-[9px] tracking-[0.1em] uppercase" style={{ color: "var(--dp-text-dim)" }}>Goals</span>
          </div>
          <div className="w-px h-10" style={{ backgroundColor: "var(--dp-fill)" }} />
          <div className="flex flex-col items-center gap-2">
            <ProgressRing progress={(githubStats.todayCommits / 10) * 100} size={60} strokeWidth={3} color="#8b72ff">
              <span className="font-mono text-[13px]" style={{ color: "var(--dp-text)" }}>{githubStats.todayCommits}</span>
            </ProgressRing>
            <span className="text-[9px] tracking-[0.1em] uppercase" style={{ color: "var(--dp-text-dim)" }}>Commits</span>
          </div>
          <div className="w-px h-10" style={{ backgroundColor: "var(--dp-fill)" }} />
          <div className="flex flex-col items-center gap-2">
            <ProgressRing progress={(lcTodaySolved / 5) * 100} size={60} strokeWidth={3} color="#f0c95c">
              <span className="font-mono text-[13px]" style={{ color: "var(--dp-text)" }}>{lcTodaySolved}</span>
            </ProgressRing>
            <span className="text-[9px] tracking-[0.1em] uppercase" style={{ color: "var(--dp-text-dim)" }}>LC</span>
          </div>
        </div>
      </GlassCard>

      {/* 7-Day Activity Graph */}
      <GlassCard className="p-5" delay={0.28}>
        <div className="flex items-center justify-between mb-5">
          <p className="text-[10px] tracking-[0.15em] uppercase" style={{ color: "var(--dp-text-muted)" }}>
            7-Day Activity
          </p>
          <button
            onClick={() => navigate("/github")}
            className="flex items-center gap-1 text-[11px] hover:opacity-80 transition-opacity"
            style={{ color: "var(--dp-text-muted)" }}
          >
            Details <ArrowRight size={12} />
          </button>
        </div>
        <div className="flex items-end justify-between gap-2 h-[90px]">
          {githubStats.weeklyCommits.map((item, index) => {
            const lcVal = leetcodeStats.weeklyProgress[index]?.solved ?? 0;
            const maxTotal = Math.max(
              ...githubStats.weeklyCommits.map(
                (c, i) => c.commits + (leetcodeStats.weeklyProgress[i]?.solved ?? 0)
              )
            );
            const commitH = (item.commits / maxTotal) * 72;
            const lcH = (lcVal / maxTotal) * 72;
            const isToday = index === githubStats.weeklyCommits.length - 1;

            return (
              <div key={item.day} className="flex flex-col items-center gap-2 flex-1">
                <div className="flex flex-col-reverse items-center gap-[2px]" style={{ height: 72 }}>
                  <motion.div
                    initial={{ height: 0 }}
                    animate={{ height: commitH }}
                    transition={{ duration: 0.8, delay: 0.32 + index * 0.05, ease: [0.23, 1, 0.32, 1] }}
                    className={`w-full max-w-[16px] rounded-t-sm ${isToday ? "bg-[#8b72ff]" : "bg-[#8b72ff]/30"}`}
                    style={{ minHeight: 2 }}
                  />
                  <motion.div
                    initial={{ height: 0 }}
                    animate={{ height: lcH }}
                    transition={{ duration: 0.8, delay: 0.36 + index * 0.05, ease: [0.23, 1, 0.32, 1] }}
                    className={`w-full max-w-[16px] rounded-t-sm ${isToday ? "bg-[#f0c95c]" : "bg-[#f0c95c]/30"}`}
                    style={{ minHeight: 1 }}
                  />
                </div>
                <span
                  className="text-[9px] tracking-wide"
                  style={{ color: isToday ? "var(--dp-text-muted)" : "var(--dp-text-ghost)" }}
                >
                  {item.day}
                </span>
              </div>
            );
          })}
        </div>
        <div className="flex items-center gap-4 mt-3.5">
          <div className="flex items-center gap-1.5">
            <div className="w-2 h-2 rounded-sm bg-[#8b72ff]" />
            <span className="text-[9px]" style={{ color: "var(--dp-text-dim)" }}>Commits</span>
          </div>
          <div className="flex items-center gap-1.5">
            <div className="w-2 h-2 rounded-sm bg-[#f0c95c]" />
            <span className="text-[9px]" style={{ color: "var(--dp-text-dim)" }}>LeetCode</span>
          </div>
        </div>
      </GlassCard>

      {/* Activity Feed */}
      <div className="space-y-1">
        <p
          className="text-[10px] tracking-[0.15em] uppercase px-1 mb-3"
          style={{ color: "var(--dp-text-muted)" }}
        >
          Recent Activity
        </p>
        {activityFeed.slice(0, 4).map((item, index) => (
          <motion.div
            key={item.id}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.4 + index * 0.06 }}
            className="flex items-center gap-3.5 py-3"
            style={{ borderBottom: "1px solid var(--dp-border-subtle)" }}
          >
            <div className="shrink-0">
              {item.type === "commit" && <GitCommit size={14} className="text-[#8b72ff]" strokeWidth={1.5} />}
              {item.type === "leetcode" && <Code2 size={14} className="text-[#f0c95c]" strokeWidth={1.5} />}
              {item.type === "goal" && <CheckCircle2 size={14} className="text-[#34d1a0]" strokeWidth={1.5} />}
              {item.type === "pr" && <GitPullRequest size={14} className="text-[#6ab8e8]" strokeWidth={1.5} />}
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-[12px] truncate" style={{ color: "var(--dp-text-tertiary)" }}>
                {item.message}
              </p>
            </div>
            <span className="text-[10px] shrink-0" style={{ color: "var(--dp-text-ghost)" }}>
              {item.time}
            </span>
          </motion.div>
        ))}
      </div>

      <PomodoroTimer isOpen={showPomodoro} onClose={() => setShowPomodoro(false)} />
    </div>
  );
}
