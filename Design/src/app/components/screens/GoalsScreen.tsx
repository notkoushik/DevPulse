import { useState } from "react";
import { motion, AnimatePresence, useMotionValue, useTransform, PanInfo } from "motion/react";
import {
  Plus,
  Check,
  Circle,
  Trash2,
  Flame,
  X,
  BookOpen,
  Code2,
  Github,
  Sparkles,
  Target,
  Timer,
} from "lucide-react";
import { GlassCard } from "../shared/GlassCard";
import { ProgressRing } from "../shared/ProgressRing";
import { PomodoroTimer } from "../shared/PomodoroTimer";
import { weeklyGoalStats, goalTemplates, categoryStreaks } from "../shared/mockData";

interface Goal {
  id: string;
  title: string;
  completed: boolean;
  category: string;
}

const categoryConfig: Record<string, { icon: typeof Code2; color: string; label: string }> = {
  leetcode: { icon: Code2, color: "#f0c95c", label: "LeetCode" },
  github: { icon: Github, color: "#8b72ff", label: "GitHub" },
  learning: { icon: BookOpen, color: "#6ab8e8", label: "Learning" },
};

const initialGoals: Goal[] = [
  { id: "1", title: "Solve 3 LeetCode problems", completed: true, category: "leetcode" },
  { id: "2", title: "Push DevPulse backend API", completed: true, category: "github" },
  { id: "3", title: "Review Flutter WebSocket docs", completed: false, category: "learning" },
  { id: "4", title: "Write unit tests for services", completed: false, category: "github" },
  { id: "5", title: "Study system design patterns", completed: false, category: "learning" },
];

function SwipeableGoal({
  goal,
  onToggle,
  onDelete,
}: {
  goal: Goal;
  onToggle: () => void;
  onDelete: () => void;
}) {
  const x = useMotionValue(0);
  const deleteOpacity = useTransform(x, [-120, -60, 0], [1, 0.8, 0]);
  const cat = categoryConfig[goal.category] || categoryConfig.learning;

  const handleDragEnd = (_: any, info: PanInfo) => {
    if (info.offset.x < -100) {
      onDelete();
    }
  };

  return (
    <div className="relative overflow-hidden rounded-2xl">
      <motion.div
        style={{ opacity: deleteOpacity }}
        className="absolute inset-0 bg-[#e8646a]/10 flex items-center justify-end pr-5 rounded-2xl"
      >
        <Trash2 size={16} className="text-[#e8646a]" strokeWidth={1.5} />
      </motion.div>

      <motion.div
        drag="x"
        dragConstraints={{ left: -120, right: 0 }}
        dragElastic={0.1}
        onDragEnd={handleDragEnd}
        style={{ x }}
        className="relative z-10"
      >
        <GlassCard className="px-4 py-3.5">
          <div className="flex items-center gap-3.5">
            <button onClick={onToggle} className="shrink-0 active:scale-90 transition-transform">
              {goal.completed ? (
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  className="w-[20px] h-[20px] rounded-full bg-[#34d1a0] flex items-center justify-center"
                >
                  <Check size={11} className="text-white" strokeWidth={2.5} />
                </motion.div>
              ) : (
                <Circle size={20} style={{ color: "var(--dp-text-faint)" }} strokeWidth={1.5} />
              )}
            </button>
            <div className="flex-1 min-w-0">
              <p
                className="text-[13px] transition-all duration-300"
                style={{
                  color: goal.completed ? "var(--dp-text-dim)" : "var(--dp-text-secondary)",
                  textDecoration: goal.completed ? "line-through" : "none",
                }}
              >
                {goal.title}
              </p>
              <span className="text-[9px] tracking-[0.05em]" style={{ color: cat.color }}>
                {cat.label}
              </span>
            </div>
          </div>
        </GlassCard>
      </motion.div>
    </div>
  );
}

export function GoalsScreen() {
  const [goals, setGoals] = useState<Goal[]>(initialGoals);
  const [showAdd, setShowAdd] = useState(false);
  const [showPomodoro, setShowPomodoro] = useState(false);
  const [newTitle, setNewTitle] = useState("");
  const [newCategory, setNewCategory] = useState("learning");

  const done = goals.filter((g) => g.completed).length;
  const total = goals.length;
  const pct = total > 0 ? Math.round((done / total) * 100) : 0;

  const toggleGoal = (id: string) =>
    setGoals((prev) => prev.map((g) => (g.id === id ? { ...g, completed: !g.completed } : g)));

  const deleteGoal = (id: string) =>
    setGoals((prev) => prev.filter((g) => g.id !== id));

  const addGoal = (title?: string, category?: string) => {
    const t = title || newTitle.trim();
    if (!t) return;
    setGoals((prev) => [
      ...prev,
      { id: Date.now().toString(), title: t, completed: false, category: category || newCategory },
    ]);
    setNewTitle("");
    if (!title) setShowAdd(false);
  };

  return (
    <div className="px-6 pt-14 pb-4 space-y-5">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.6 }}
        className="flex items-center justify-between"
      >
        <div>
          <p className="text-[11px] tracking-[0.12em] uppercase" style={{ color: "var(--dp-text-muted)" }}>
            Daily Tracker
          </p>
          <h1 className="font-serif text-[28px] mt-1 tracking-[-0.01em] italic" style={{ color: "var(--dp-text)" }}>
            Goals
          </h1>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={() => setShowPomodoro(true)}
            className="w-9 h-9 rounded-xl flex items-center justify-center active:scale-95 transition-transform"
            style={{ backgroundColor: "var(--dp-fill-2)" }}
          >
            <Timer size={16} className="text-[#8b72ff]" strokeWidth={1.5} />
          </button>
          <button
            onClick={() => setShowAdd(true)}
            className="w-9 h-9 rounded-xl bg-[#8b72ff] flex items-center justify-center active:scale-95 transition-transform"
          >
            <Plus size={18} className="text-white" strokeWidth={1.8} />
          </button>
        </div>
      </motion.div>

      {/* Progress */}
      <GlassCard className="p-5" delay={0.05}>
        <div className="flex items-center justify-between">
          <div>
            <p className="text-[9px] tracking-[0.15em] uppercase" style={{ color: "var(--dp-text-dim)" }}>
              Today
            </p>
            <div className="flex items-baseline gap-1.5 mt-2">
              <span className="font-mono text-[38px] tracking-tighter" style={{ color: "var(--dp-text)", lineHeight: 1 }}>
                {done}
              </span>
              <span className="text-[14px]" style={{ color: "var(--dp-text-dim)" }}>/ {total}</span>
            </div>
            <div className="flex items-center gap-1.5 mt-3">
              <Flame size={12} className="text-[#e8646a]" strokeWidth={1.5} />
              <span className="text-[11px]" style={{ color: "var(--dp-text-muted)" }}>12 day streak</span>
            </div>
          </div>
          <ProgressRing progress={pct} size={72} strokeWidth={3.5} color="#34d1a0">
            <span className="font-mono text-[14px]" style={{ color: "var(--dp-text)" }}>{pct}%</span>
          </ProgressRing>
        </div>
      </GlassCard>

      {/* Category Streaks */}
      <div className="grid grid-cols-3 gap-3">
        {Object.entries(categoryStreaks).map(([key, data], index) => {
          const config = categoryConfig[key];
          if (!config) return null;
          return (
            <GlassCard key={key} className="p-3.5 text-center" delay={0.08 + index * 0.03}>
              <config.icon size={13} className="mx-auto mb-2" style={{ color: config.color }} strokeWidth={1.5} />
              <p className="font-mono text-[18px] tracking-tight" style={{ color: "var(--dp-text)", lineHeight: 1 }}>
                {data.current}
              </p>
              <p className="text-[8px] mt-1 tracking-[0.1em] uppercase" style={{ color: "var(--dp-text-dim)" }}>
                {config.label}
              </p>
              <p className="text-[8px] mt-0.5" style={{ color: "var(--dp-text-ghost)" }}>
                best: {data.best}
              </p>
            </GlassCard>
          );
        })}
      </div>

      {/* Week */}
      <GlassCard className="p-5 pt-6" delay={0.12}>
        <p className="text-[10px] tracking-[0.15em] uppercase mb-4" style={{ color: "var(--dp-text-muted)" }}>
          This Week
        </p>
        <div className="flex items-end justify-between gap-2">
          {weeklyGoalStats.map((day, index) => {
            const dayPct = day.total > 0 ? (day.completed / day.total) * 100 : 0;
            const isToday = index === weeklyGoalStats.length - 1;
            const allDone = dayPct === 100;

            return (
              <div key={day.day} className="flex flex-col items-center gap-2 flex-1">
                <div className="relative h-[52px] w-full flex items-end justify-center">
                  <motion.div
                    initial={{ height: 0 }}
                    animate={{ height: `${Math.max(dayPct, 6)}%` }}
                    transition={{ duration: 0.7, delay: 0.15 + index * 0.05, ease: [0.23, 1, 0.32, 1] }}
                    className="w-full max-w-[18px] rounded-md"
                    style={{
                      backgroundColor: allDone
                        ? "#34d1a0"
                        : isToday
                        ? "#8b72ff"
                        : "var(--dp-bar-inactive)",
                    }}
                  />
                </div>
                <span
                  className="text-[9px] tracking-wide"
                  style={{ color: isToday ? "var(--dp-text-muted)" : "var(--dp-text-ghost)" }}
                >
                  {day.day}
                </span>
              </div>
            );
          })}
        </div>
      </GlassCard>

      {/* Quick Templates */}
      <GlassCard className="p-5" delay={0.16}>
        <div className="flex items-center gap-2 mb-3.5">
          <Sparkles size={12} className="text-[#f0c95c]" strokeWidth={1.5} />
          <p className="text-[10px] tracking-[0.15em] uppercase" style={{ color: "var(--dp-text-muted)" }}>
            Quick Add
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          {goalTemplates.map((template) => (
            <button
              key={template.title}
              onClick={() => addGoal(template.title, template.category)}
              className="px-3 py-1.5 rounded-lg text-[11px] active:scale-95 transition-all"
              style={{
                border: "1px solid var(--dp-border)",
                color: "var(--dp-text-muted)",
              }}
            >
              {template.title}
            </button>
          ))}
        </div>
      </GlassCard>

      {/* Goal List */}
      <div>
        <div className="flex items-center justify-between px-1 mb-3">
          <p className="text-[10px] tracking-[0.15em] uppercase" style={{ color: "var(--dp-text-muted)" }}>
            Today's Goals
          </p>
          <p className="text-[9px]" style={{ color: "var(--dp-text-ghost)" }}>swipe to delete</p>
        </div>
        <div className="space-y-2">
          <AnimatePresence>
            {goals.length === 0 ? (
              <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="py-12 text-center">
                <Target size={28} style={{ color: "var(--dp-text-faint)" }} className="mx-auto mb-3" strokeWidth={1.5} />
                <p className="text-[13px]" style={{ color: "var(--dp-text-dim)" }}>No goals yet</p>
                <button onClick={() => setShowAdd(true)} className="mt-3 text-[12px] text-[#8b72ff]">
                  Tap + to add your first
                </button>
              </motion.div>
            ) : (
              goals.map((goal) => (
                <motion.div
                  key={goal.id}
                  initial={{ opacity: 0, y: 8 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, x: -200, height: 0, marginBottom: 0 }}
                  layout
                  transition={{ duration: 0.3 }}
                >
                  <SwipeableGoal goal={goal} onToggle={() => toggleGoal(goal.id)} onDelete={() => deleteGoal(goal.id)} />
                </motion.div>
              ))
            )}
          </AnimatePresence>
        </div>
      </div>

      {/* Add Goal Sheet */}
      <AnimatePresence>
        {showAdd && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-[60] flex items-end justify-center"
          >
            <div
              className="absolute inset-0"
              style={{ backgroundColor: "var(--dp-overlay)" }}
              onClick={() => setShowAdd(false)}
            />
            <motion.div
              initial={{ y: "100%" }}
              animate={{ y: 0 }}
              exit={{ y: "100%" }}
              transition={{ type: "spring", damping: 28, stiffness: 300 }}
              className="relative w-full max-w-[430px] rounded-t-2xl p-6 pb-10"
              style={{
                backgroundColor: "var(--dp-surface)",
                borderTop: "1px solid var(--dp-border)",
              }}
            >
              <div className="flex items-center justify-between mb-6">
                <h3 className="font-serif text-[20px] italic" style={{ color: "var(--dp-text)" }}>New Goal</h3>
                <button
                  onClick={() => setShowAdd(false)}
                  className="w-7 h-7 rounded-full flex items-center justify-center"
                  style={{ backgroundColor: "var(--dp-fill)" }}
                >
                  <X size={14} style={{ color: "var(--dp-text-muted)" }} strokeWidth={1.5} />
                </button>
              </div>

              <input
                type="text"
                placeholder="What do you want to achieve?"
                value={newTitle}
                onChange={(e) => setNewTitle(e.target.value)}
                onKeyDown={(e) => e.key === "Enter" && addGoal()}
                className="w-full bg-transparent pb-3 text-[14px] outline-none transition-colors"
                style={{
                  borderBottom: "1px solid var(--dp-border)",
                  color: "var(--dp-text-secondary)",
                }}
                autoFocus
              />

              <div className="mt-5">
                <p className="text-[9px] tracking-[0.15em] uppercase mb-3" style={{ color: "var(--dp-text-dim)" }}>
                  Category
                </p>
                <div className="flex gap-2">
                  {Object.entries(categoryConfig).map(([key, config]) => {
                    const isSelected = newCategory === key;
                    return (
                      <button
                        key={key}
                        onClick={() => setNewCategory(key)}
                        className="px-4 py-2 rounded-lg text-[12px] transition-all"
                        style={{
                          border: `1px solid ${isSelected ? "var(--dp-fill-3)" : "var(--dp-border-subtle)"}`,
                          color: isSelected ? "var(--dp-text-secondary)" : "var(--dp-text-dim)",
                          backgroundColor: isSelected ? "var(--dp-fill)" : "transparent",
                        }}
                      >
                        {config.label}
                      </button>
                    );
                  })}
                </div>
              </div>

              <button
                onClick={() => addGoal()}
                disabled={!newTitle.trim()}
                className="w-full mt-6 py-3 rounded-xl bg-[#8b72ff] text-white text-[13px] tracking-wide disabled:opacity-20 active:scale-[0.98] transition-all"
              >
                Add Goal
              </button>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      <PomodoroTimer isOpen={showPomodoro} onClose={() => setShowPomodoro(false)} />
    </div>
  );
}
