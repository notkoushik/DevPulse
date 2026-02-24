import { motion } from "motion/react";
import {
  Trophy,
  TrendingUp,
  Clock,
  CheckCircle2,
  XCircle,
  Award,
  ArrowRight,
} from "lucide-react";
import { GlassCard } from "../shared/GlassCard";
import { ProgressRing } from "../shared/ProgressRing";
import { leetcodeStats } from "../shared/mockData";
import {
  BarChart,
  Bar,
  XAxis,
  ResponsiveContainer,
  CartesianGrid,
} from "recharts";

const difficultyColors: Record<string, string> = {
  Easy: "#34d1a0",
  Medium: "#f0c95c",
  Hard: "#e8646a",
};

export function LeetCodeScreen() {
  const totalProgress = Math.round(
    (leetcodeStats.totalSolved / leetcodeStats.totalQuestions) * 100
  );

  return (
    <div className="px-6 pt-14 pb-4 space-y-5">
      {/* Header */}
      <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ duration: 0.6 }}>
        <p className="text-[11px] tracking-[0.12em] uppercase" style={{ color: "var(--dp-text-muted)" }}>
          Problem Solving
        </p>
        <h1 className="font-serif text-[28px] mt-1 tracking-[-0.01em] italic" style={{ color: "var(--dp-text)" }}>
          LeetCode
        </h1>
      </motion.div>

      {/* Total Solved */}
      <GlassCard className="p-6" delay={0.05}>
        <div className="flex items-center justify-between">
          <div>
            <p className="text-[9px] tracking-[0.15em] uppercase" style={{ color: "var(--dp-text-dim)" }}>
              Total Solved
            </p>
            <div className="flex items-baseline gap-2 mt-2">
              <motion.span
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3, duration: 0.5 }}
                className="font-mono text-[42px] tracking-tighter"
                style={{ color: "var(--dp-text)", lineHeight: 1 }}
              >
                {leetcodeStats.totalSolved}
              </motion.span>
              <span className="text-[13px]" style={{ color: "var(--dp-text-dim)" }}>
                / {leetcodeStats.totalQuestions}
              </span>
            </div>
            <div className="flex items-center gap-1.5 mt-3">
              <Trophy size={12} className="text-[#f0c95c]" strokeWidth={1.5} />
              <span className="text-[11px]" style={{ color: "var(--dp-text-muted)" }}>
                #{leetcodeStats.ranking.toLocaleString()}
              </span>
            </div>
          </div>
          <ProgressRing progress={totalProgress} size={76} strokeWidth={3.5} color="#f0c95c">
            <span className="font-mono text-[14px]" style={{ color: "var(--dp-text)" }}>{totalProgress}%</span>
          </ProgressRing>
        </div>
      </GlassCard>

      {/* Difficulty Breakdown */}
      <div className="grid grid-cols-3 gap-3">
        {(["Easy", "Medium", "Hard"] as const).map((diff, index) => {
          const data =
            diff === "Easy"
              ? leetcodeStats.easy
              : diff === "Medium"
              ? leetcodeStats.medium
              : leetcodeStats.hard;
          const color = difficultyColors[diff];
          const pct = Math.round((data.solved / data.total) * 100);

          return (
            <GlassCard key={diff} className="p-4" delay={0.1 + index * 0.04}>
              <p className="font-mono text-[22px] tracking-tight" style={{ color: "var(--dp-text)", lineHeight: 1 }}>
                {data.solved}
              </p>
              <p className="text-[10px] mt-1" style={{ color: "var(--dp-text-dim)" }}>/ {data.total}</p>
              <div
                className="mt-3 h-[3px] rounded-full overflow-hidden"
                style={{ backgroundColor: "var(--dp-fill)" }}
              >
                <motion.div
                  initial={{ width: 0 }}
                  animate={{ width: `${pct}%` }}
                  transition={{ duration: 1, delay: 0.3 + index * 0.1, ease: [0.23, 1, 0.32, 1] }}
                  className="h-full rounded-full"
                  style={{ backgroundColor: color }}
                />
              </div>
              <p className="text-[9px] mt-2 tracking-[0.1em] uppercase" style={{ color }}>
                {diff}
              </p>
            </GlassCard>
          );
        })}
      </div>

      {/* Metrics */}
      <div className="flex items-center justify-between px-1">
        <div className="flex items-center gap-2">
          <TrendingUp size={12} className="text-[#34d1a0]" strokeWidth={1.5} />
          <span className="text-[11px]" style={{ color: "var(--dp-text-muted)" }}>
            <span style={{ color: "var(--dp-text-tertiary)" }}>{leetcodeStats.acceptanceRate}%</span> acceptance
          </span>
        </div>
        <div className="flex items-center gap-2">
          <Award size={12} className="text-[#8b72ff]" strokeWidth={1.5} />
          <span className="text-[11px]" style={{ color: "var(--dp-text-muted)" }}>
            <span style={{ color: "var(--dp-text-tertiary)" }}>{leetcodeStats.contestRating}</span> rating
          </span>
        </div>
        <span className="text-[11px]" style={{ color: "var(--dp-text-muted)" }}>
          <span style={{ color: "var(--dp-text-tertiary)" }}>{leetcodeStats.badges}</span> badges
        </span>
      </div>

      {/* Weekly Progress */}
      <GlassCard className="p-5 pt-6" delay={0.2}>
        <p className="text-[10px] tracking-[0.15em] uppercase mb-5" style={{ color: "var(--dp-text-muted)" }}>
          This Week
        </p>
        <div className="h-[140px]">
          <ResponsiveContainer width="100%" height="100%" minWidth={200} minHeight={100}>
            <BarChart data={leetcodeStats.weeklyProgress} barCategoryGap="30%">
              <CartesianGrid strokeDasharray="3 3" stroke="var(--dp-fill)" vertical={false} />
              <XAxis
                dataKey="day"
                axisLine={false}
                tickLine={false}
                tick={{ fill: "var(--dp-text-dim)", fontSize: 10, fontFamily: "Sora" }}
              />
              <Bar dataKey="solved" fill="#f0c95c" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </GlassCard>

      {/* Recent Submissions */}
      <div>
        <div className="flex items-center justify-between px-1 mb-4">
          <p className="text-[10px] tracking-[0.15em] uppercase" style={{ color: "var(--dp-text-muted)" }}>
            Submissions
          </p>
          <button className="flex items-center gap-1 text-[10px]" style={{ color: "var(--dp-text-muted)" }}>
            All <ArrowRight size={10} />
          </button>
        </div>
        {leetcodeStats.recentSubmissions.map((sub, index) => {
          const isAccepted = sub.status === "Accepted";
          const diffColor = difficultyColors[sub.difficulty] || "#5c5c6f";

          return (
            <motion.div
              key={sub.id}
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.3 + index * 0.05 }}
              className="flex items-center justify-between py-3"
              style={{ borderBottom: "1px solid var(--dp-border-subtle)" }}
            >
              <div className="flex items-center gap-3 min-w-0">
                {isAccepted ? (
                  <CheckCircle2 size={13} className="text-[#34d1a0] shrink-0" strokeWidth={1.5} />
                ) : (
                  <XCircle size={13} className="text-[#e8646a] shrink-0" strokeWidth={1.5} />
                )}
                <div className="min-w-0">
                  <p className="text-[12px] truncate" style={{ color: "var(--dp-text-tertiary)" }}>{sub.title}</p>
                  <div className="flex items-center gap-2 mt-0.5">
                    <span className="text-[9px]" style={{ color: diffColor }}>{sub.difficulty}</span>
                    {isAccepted && (
                      <>
                        <span className="text-[9px]" style={{ color: "var(--dp-text-ghost)" }}>·</span>
                        <span className="text-[9px] flex items-center gap-0.5" style={{ color: "var(--dp-text-dim)" }}>
                          <Clock size={8} strokeWidth={1.5} /> {sub.runtime}
                        </span>
                      </>
                    )}
                  </div>
                </div>
              </div>
              <span className="text-[9px] shrink-0 ml-2" style={{ color: "var(--dp-text-ghost)" }}>{sub.time}</span>
            </motion.div>
          );
        })}
      </div>
    </div>
  );
}