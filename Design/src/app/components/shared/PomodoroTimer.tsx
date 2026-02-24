import { useState, useEffect, useRef, useCallback } from "react";
import { motion, AnimatePresence } from "motion/react";
import { X, Play, Pause, RotateCcw, Coffee, Brain, Zap } from "lucide-react";

type PomodoroMode = "work" | "shortBreak" | "longBreak";

const MODES: Record<PomodoroMode, { label: string; duration: number; color: string; icon: typeof Brain }> = {
  work: { label: "Focus", duration: 25 * 60, color: "#8b72ff", icon: Brain },
  shortBreak: { label: "Short Break", duration: 5 * 60, color: "#34d1a0", icon: Coffee },
  longBreak: { label: "Long Break", duration: 15 * 60, color: "#6ab8e8", icon: Zap },
};

interface PomodoroTimerProps {
  isOpen: boolean;
  onClose: () => void;
}

export function PomodoroTimer({ isOpen, onClose }: PomodoroTimerProps) {
  const [mode, setMode] = useState<PomodoroMode>("work");
  const [timeLeft, setTimeLeft] = useState(MODES.work.duration);
  const [isRunning, setIsRunning] = useState(false);
  const [sessionsCompleted, setSessions] = useState(0);
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

  const currentMode = MODES[mode];
  const totalDuration = currentMode.duration;
  const progress = ((totalDuration - timeLeft) / totalDuration) * 100;
  const minutes = Math.floor(timeLeft / 60);
  const seconds = timeLeft % 60;

  const clearTimer = useCallback(() => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
      intervalRef.current = null;
    }
  }, []);

  useEffect(() => {
    if (isRunning && timeLeft > 0) {
      intervalRef.current = setInterval(() => {
        setTimeLeft((prev) => prev - 1);
      }, 1000);
    } else if (timeLeft === 0) {
      clearTimer();
      setIsRunning(false);
      // Auto-advance
      if (mode === "work") {
        const newSessions = sessionsCompleted + 1;
        setSessions(newSessions);
        if (newSessions % 4 === 0) {
          switchMode("longBreak");
        } else {
          switchMode("shortBreak");
        }
      } else {
        switchMode("work");
      }
    }
    return clearTimer;
  }, [isRunning, timeLeft, mode, sessionsCompleted, clearTimer]);

  const switchMode = (newMode: PomodoroMode) => {
    clearTimer();
    setIsRunning(false);
    setMode(newMode);
    setTimeLeft(MODES[newMode].duration);
  };

  const toggleTimer = () => setIsRunning((prev) => !prev);

  const resetTimer = () => {
    clearTimer();
    setIsRunning(false);
    setTimeLeft(totalDuration);
  };

  const ringSize = 240;
  const strokeWidth = 4;
  const radius = (ringSize - strokeWidth) / 2;
  const circumference = radius * 2 * Math.PI;
  const strokeDashoffset = circumference - (progress / 100) * circumference;

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 z-[70] flex items-center justify-center"
        >
          <motion.div
            className="absolute inset-0"
            style={{ backgroundColor: "var(--dp-overlay-heavy)" }}
            onClick={onClose}
          />
          <motion.div
            initial={{ scale: 0.9, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            exit={{ scale: 0.9, opacity: 0 }}
            transition={{ type: "spring", damping: 25, stiffness: 300 }}
            className="relative w-full max-w-[380px] mx-6 rounded-2xl p-6 overflow-hidden"
            style={{
              backgroundColor: "var(--dp-surface)",
              border: "1px solid var(--dp-border)",
            }}
          >
            {/* Header */}
            <div className="flex items-center justify-between mb-6">
              <div>
                <p
                  className="text-[9px] tracking-[0.15em] uppercase"
                  style={{ color: "var(--dp-text-dim)" }}
                >
                  Pomodoro
                </p>
                <h3 className="font-serif text-[20px] italic" style={{ color: "var(--dp-text)" }}>
                  Focus Timer
                </h3>
              </div>
              <button
                onClick={onClose}
                className="w-7 h-7 rounded-full flex items-center justify-center"
                style={{ backgroundColor: "var(--dp-fill)" }}
              >
                <X size={14} style={{ color: "var(--dp-text-muted)" }} strokeWidth={1.5} />
              </button>
            </div>

            {/* Mode Tabs */}
            <div
              className="flex rounded-xl p-1 mb-8 gap-1"
              style={{ backgroundColor: "var(--dp-fill)" }}
            >
              {(Object.entries(MODES) as [PomodoroMode, typeof MODES.work][]).map(([key, cfg]) => {
                const isActive = mode === key;
                return (
                  <button
                    key={key}
                    onClick={() => switchMode(key)}
                    className="flex-1 py-2 rounded-lg text-[11px] tracking-wide transition-all relative"
                    style={{
                      color: isActive ? "var(--dp-text)" : "var(--dp-text-dim)",
                      backgroundColor: isActive ? "var(--dp-surface)" : "transparent",
                      boxShadow: isActive ? "0 1px 3px rgba(0,0,0,0.1)" : "none",
                    }}
                  >
                    {cfg.label}
                  </button>
                );
              })}
            </div>

            {/* Timer Ring */}
            <div className="flex flex-col items-center mb-8">
              <div className="relative" style={{ width: ringSize, height: ringSize }}>
                <svg width={ringSize} height={ringSize} className="-rotate-90">
                  <circle
                    cx={ringSize / 2}
                    cy={ringSize / 2}
                    r={radius}
                    fill="none"
                    stroke="var(--dp-ring-track)"
                    strokeWidth={strokeWidth}
                  />
                  <motion.circle
                    cx={ringSize / 2}
                    cy={ringSize / 2}
                    r={radius}
                    fill="none"
                    stroke={currentMode.color}
                    strokeWidth={strokeWidth}
                    strokeLinecap="round"
                    strokeDasharray={circumference}
                    initial={{ strokeDashoffset: circumference }}
                    animate={{ strokeDashoffset }}
                    transition={{ duration: 0.5, ease: "easeOut" }}
                  />
                </svg>
                <div className="absolute inset-0 flex flex-col items-center justify-center">
                  <span
                    className="font-mono text-[56px] tracking-tighter"
                    style={{ color: "var(--dp-text)", lineHeight: 1 }}
                  >
                    {String(minutes).padStart(2, "0")}
                    <span style={{ color: "var(--dp-text-dim)" }}>:</span>
                    {String(seconds).padStart(2, "0")}
                  </span>
                  <span
                    className="text-[10px] tracking-[0.1em] uppercase mt-2"
                    style={{ color: currentMode.color }}
                  >
                    {currentMode.label}
                  </span>
                </div>
              </div>
            </div>

            {/* Controls */}
            <div className="flex items-center justify-center gap-4 mb-6">
              <button
                onClick={resetTimer}
                className="w-11 h-11 rounded-xl flex items-center justify-center active:scale-90 transition-transform"
                style={{ backgroundColor: "var(--dp-fill)" }}
              >
                <RotateCcw size={18} style={{ color: "var(--dp-text-muted)" }} strokeWidth={1.5} />
              </button>
              <button
                onClick={toggleTimer}
                className="w-16 h-16 rounded-2xl flex items-center justify-center active:scale-95 transition-transform"
                style={{ backgroundColor: currentMode.color }}
              >
                {isRunning ? (
                  <Pause size={24} className="text-white" strokeWidth={2} />
                ) : (
                  <Play size={24} className="text-white ml-0.5" strokeWidth={2} />
                )}
              </button>
              <div className="w-11 h-11 rounded-xl flex flex-col items-center justify-center"
                style={{ backgroundColor: "var(--dp-fill)" }}
              >
                <span className="font-mono text-[14px]" style={{ color: "var(--dp-text)", lineHeight: 1 }}>
                  {sessionsCompleted}
                </span>
                <span className="text-[7px] tracking-wider uppercase" style={{ color: "var(--dp-text-dim)" }}>
                  done
                </span>
              </div>
            </div>

            {/* Session dots */}
            <div className="flex items-center justify-center gap-2">
              {[0, 1, 2, 3].map((i) => (
                <div
                  key={i}
                  className="w-2 h-2 rounded-full transition-colors"
                  style={{
                    backgroundColor:
                      i < sessionsCompleted % 4
                        ? currentMode.color
                        : "var(--dp-fill-2)",
                  }}
                />
              ))}
              <span
                className="text-[9px] ml-2"
                style={{ color: "var(--dp-text-dim)" }}
              >
                until long break
              </span>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}