import { Outlet, NavLink, useLocation } from "react-router";
import {
  LayoutDashboard,
  Github,
  Code2,
  Target,
  User,
} from "lucide-react";
import { motion } from "motion/react";

const navItems = [
  { path: "/", icon: LayoutDashboard, label: "Home" },
  { path: "/github", icon: Github, label: "GitHub" },
  { path: "/leetcode", icon: Code2, label: "LeetCode" },
  { path: "/goals", icon: Target, label: "Goals" },
  { path: "/profile", icon: User, label: "Profile" },
];

export function MobileLayout() {
  const location = useLocation();

  return (
    <div
      className="flex justify-center w-full min-h-screen"
      style={{ backgroundColor: "var(--dp-bg)", transition: "background-color 0.3s ease" }}
    >
      <div
        className="relative w-full max-w-[430px] min-h-screen flex flex-col"
        style={{ backgroundColor: "var(--dp-bg)", transition: "background-color 0.3s ease" }}
      >
        {/* Main content */}
        <main className="flex-1 overflow-y-auto pb-24">
          <Outlet />
        </main>

        {/* Bottom Navigation */}
        <nav className="fixed bottom-0 left-1/2 -translate-x-1/2 w-full max-w-[430px] z-50">
          <div
            className="backdrop-blur-xl"
            style={{
              backgroundColor: "var(--dp-nav)",
              borderTop: "1px solid var(--dp-border-subtle)",
            }}
          >
            <div className="flex items-center justify-around px-4 pt-2.5 pb-1.5">
              {navItems.map((item) => {
                const isActive =
                  item.path === "/"
                    ? location.pathname === "/"
                    : location.pathname.startsWith(item.path);
                const Icon = item.icon;

                return (
                  <NavLink
                    key={item.path}
                    to={item.path}
                    className="relative flex flex-col items-center gap-1.5 px-3 py-1"
                  >
                    {isActive && (
                      <motion.div
                        layoutId="nav-dot"
                        className="absolute -top-2.5 w-4 h-[2px] rounded-full bg-[#8b72ff]"
                        transition={{ type: "spring", stiffness: 500, damping: 35 }}
                      />
                    )}
                    <Icon
                      size={20}
                      className="transition-colors duration-300"
                      style={{ color: isActive ? "var(--dp-nav-active)" : "var(--dp-nav-inactive)" }}
                      strokeWidth={isActive ? 1.8 : 1.5}
                    />
                    <span
                      className="text-[9px] tracking-[0.05em] uppercase transition-colors duration-300"
                      style={{
                        color: isActive ? "var(--dp-text-tertiary)" : "var(--dp-nav-inactive)",
                      }}
                    >
                      {item.label}
                    </span>
                  </NavLink>
                );
              })}
            </div>
            <div className="flex justify-center pb-1.5">
              <div
                className="w-[134px] h-[4px] rounded-full"
                style={{ backgroundColor: "var(--dp-home-indicator)" }}
              />
            </div>
          </div>
        </nav>
      </div>
    </div>
  );
}