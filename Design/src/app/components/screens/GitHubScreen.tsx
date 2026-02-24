import { motion } from "motion/react";
import {
  GitCommit,
  GitPullRequest,
  AlertCircle,
  Star,
  ArrowUpRight,
} from "lucide-react";
import { GlassCard } from "../shared/GlassCard";
import { ContributionGrid } from "../shared/ContributionGrid";
import { githubStats, userData } from "../shared/mockData";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  ResponsiveContainer,
  CartesianGrid,
} from "recharts";

export function GitHubScreen() {
  const weekTotal = githubStats.weeklyCommits.reduce((a, b) => a + b.commits, 0);

  return (
    <div className="px-6 pt-14 pb-4 space-y-5">
      {/* Header */}
      <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ duration: 0.6 }}>
        <p className="text-[11px] tracking-[0.12em] uppercase" style={{ color: "var(--dp-text-muted)" }}>
          @{userData.username}
        </p>
        <h1 className="font-serif text-[28px] mt-1 tracking-[-0.01em] italic" style={{ color: "var(--dp-text)" }}>
          GitHub
        </h1>
      </motion.div>

      {/* Key Numbers */}
      <div className="grid grid-cols-2 gap-3">
        <GlassCard className="p-5" delay={0.05}>
          <p className="text-[9px] tracking-[0.15em] uppercase" style={{ color: "var(--dp-text-dim)" }}>Today</p>
          <div className="flex items-baseline gap-1.5 mt-2">
            <span className="font-mono text-[34px] tracking-tighter" style={{ color: "var(--dp-text)", lineHeight: 1 }}>
              {githubStats.todayCommits}
            </span>
            <span className="text-[11px]" style={{ color: "var(--dp-text-dim)" }}>commits</span>
          </div>
          <p className="text-[10px] text-[#34d1a0] mt-2 flex items-center gap-1">
            <ArrowUpRight size={10} /> +3 vs yesterday
          </p>
        </GlassCard>

        <GlassCard className="p-5" delay={0.1}>
          <p className="text-[9px] tracking-[0.15em] uppercase" style={{ color: "var(--dp-text-dim)" }}>This Week</p>
          <div className="flex items-baseline gap-1.5 mt-2">
            <span className="font-mono text-[34px] tracking-tighter" style={{ color: "var(--dp-text)", lineHeight: 1 }}>
              {weekTotal}
            </span>
            <span className="text-[11px]" style={{ color: "var(--dp-text-dim)" }}>total</span>
          </div>
          <p className="text-[10px] mt-2" style={{ color: "var(--dp-text-muted)" }}>
            {Math.round(weekTotal / 7)}/day avg
          </p>
        </GlassCard>
      </div>

      {/* PR & Issues */}
      <div className="flex items-center justify-between px-1">
        <div className="flex items-center gap-5">
          <div className="flex items-center gap-2">
            <GitPullRequest size={13} className="text-[#6ab8e8]" strokeWidth={1.5} />
            <span className="text-[11px]" style={{ color: "var(--dp-text-muted)" }}>
              <span style={{ color: "var(--dp-text-secondary)" }}>{githubStats.pullRequests.merged}</span> merged
            </span>
          </div>
          <div className="flex items-center gap-2">
            <AlertCircle size={13} className="text-[#e8646a]" strokeWidth={1.5} />
            <span className="text-[11px]" style={{ color: "var(--dp-text-muted)" }}>
              <span style={{ color: "var(--dp-text-secondary)" }}>{githubStats.issues.closed}</span> closed
            </span>
          </div>
        </div>
        <span className="text-[11px]" style={{ color: "var(--dp-text-muted)" }}>
          <span className="text-[#f0c95c]">{githubStats.pullRequests.open}</span> open PRs
        </span>
      </div>

      {/* Weekly Chart */}
      <GlassCard className="p-5 pt-6" delay={0.15}>
        <p className="text-[10px] tracking-[0.15em] uppercase mb-5" style={{ color: "var(--dp-text-muted)" }}>
          Weekly Activity
        </p>
        <div className="h-[170px]">
          <ResponsiveContainer width="100%" height="100%" minWidth={200} minHeight={100}>
            <BarChart data={githubStats.weeklyCommits} barCategoryGap="30%">
              <CartesianGrid strokeDasharray="3 3" stroke="var(--dp-fill)" vertical={false} />
              <XAxis
                dataKey="day"
                axisLine={false}
                tickLine={false}
                tick={{ fill: "var(--dp-text-dim)", fontSize: 10, fontFamily: "Sora" }}
              />
              <YAxis
                axisLine={false}
                tickLine={false}
                tick={{ fill: "var(--dp-text-dim)", fontSize: 10, fontFamily: "Sora" }}
                width={22}
              />
              <Bar dataKey="commits" fill="#8b72ff" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </GlassCard>

      {/* Contributions */}
      <GlassCard className="p-5 pt-6" delay={0.2}>
        <div className="flex items-center justify-between mb-5">
          <p className="text-[10px] tracking-[0.15em] uppercase" style={{ color: "var(--dp-text-muted)" }}>
            Contributions
          </p>
          <p className="text-[10px]" style={{ color: "var(--dp-text-dim)" }}>90 days</p>
        </div>
        <ContributionGrid contributions={githubStats.monthlyContributions} />
      </GlassCard>

      {/* Repositories */}
      <div>
        <p className="text-[10px] tracking-[0.15em] uppercase px-1 mb-4" style={{ color: "var(--dp-text-muted)" }}>
          Repositories
        </p>
        {githubStats.recentRepos.map((repo, index) => (
          <motion.div
            key={repo.name}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.25 + index * 0.05 }}
            className="flex items-center justify-between py-3.5"
            style={{ borderBottom: "1px solid var(--dp-border-subtle)" }}
          >
            <div className="min-w-0">
              <p className="text-[13px] truncate" style={{ color: "var(--dp-text-secondary)" }}>
                {repo.name}
              </p>
              <div className="flex items-center gap-3 mt-1.5">
                <div className="flex items-center gap-1.5">
                  <div className="w-2 h-2 rounded-full" style={{ backgroundColor: repo.languageColor }} />
                  <span className="text-[10px]" style={{ color: "var(--dp-text-muted)" }}>{repo.language}</span>
                </div>
                <div className="flex items-center gap-1">
                  <Star size={10} className="text-[#f0c95c]" strokeWidth={1.5} />
                  <span className="text-[10px]" style={{ color: "var(--dp-text-muted)" }}>{repo.stars}</span>
                </div>
                <span className="text-[10px]" style={{ color: "var(--dp-text-dim)" }}>
                  {repo.commits} commits
                </span>
              </div>
            </div>
            <span className="text-[10px] shrink-0 ml-3" style={{ color: "var(--dp-text-ghost)" }}>
              {repo.lastActive}
            </span>
          </motion.div>
        ))}
      </div>
    </div>
  );
}