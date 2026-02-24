import { motion } from "motion/react";

interface ContributionGridProps {
  contributions: { date: string; count: number; level: number }[];
}

const levelColors = [
  "var(--dp-grid-empty)",
  "rgba(52, 209, 160, 0.25)",
  "rgba(52, 209, 160, 0.45)",
  "rgba(52, 209, 160, 0.65)",
  "rgba(52, 209, 160, 0.90)",
];

export function ContributionGrid({ contributions }: ContributionGridProps) {
  const data = contributions.slice(-91);

  const weeks: typeof data[] = [];
  for (let i = 0; i < data.length; i += 7) {
    weeks.push(data.slice(i, i + 7));
  }

  return (
    <div className="w-full">
      <div className="flex gap-[3px] justify-center">
        {weeks.map((week, weekIndex) => (
          <div key={weekIndex} className="flex flex-col gap-[3px]">
            {week.map((day) => (
              <motion.div
                key={day.date}
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{
                  duration: 0.3,
                  delay: weekIndex * 0.025,
                }}
                className="w-[9px] h-[9px] rounded-[2.5px]"
                style={{ backgroundColor: levelColors[day.level] }}
              />
            ))}
          </div>
        ))}
      </div>
      <div className="flex items-center justify-end gap-1.5 mt-4">
        <span className="text-[9px] tracking-wide" style={{ color: "var(--dp-text-dim)" }}>Less</span>
        {levelColors.map((color, i) => (
          <div key={i} className="w-[9px] h-[9px] rounded-[2.5px]" style={{ backgroundColor: color }} />
        ))}
        <span className="text-[9px] tracking-wide" style={{ color: "var(--dp-text-dim)" }}>More</span>
      </div>
    </div>
  );
}
