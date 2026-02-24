import { motion } from "motion/react";
import type { ReactNode } from "react";

interface GlassCardProps {
  children: ReactNode;
  className?: string;
  delay?: number;
  onClick?: () => void;
}

export function GlassCard({
  children,
  className = "",
  delay = 0,
  onClick,
}: GlassCardProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 12 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5, delay, ease: [0.23, 1, 0.32, 1] }}
      onClick={onClick}
      className={`rounded-2xl ${
        onClick ? "cursor-pointer active:scale-[0.985] transition-transform duration-200" : ""
      } ${className}`}
      style={{
        backgroundColor: "var(--dp-surface)",
        borderWidth: 1,
        borderStyle: "solid",
        borderColor: "var(--dp-border)",
        boxShadow: "var(--dp-card-shadow)",
        transition: "background-color 0.3s ease, border-color 0.3s ease, box-shadow 0.3s ease",
      }}
    >
      {children}
    </motion.div>
  );
}