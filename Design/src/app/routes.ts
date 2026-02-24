import { createBrowserRouter } from "react-router";
import { MobileLayout } from "./components/layout/MobileLayout";
import { DashboardScreen } from "./components/screens/DashboardScreen";
import { GitHubScreen } from "./components/screens/GitHubScreen";
import { LeetCodeScreen } from "./components/screens/LeetCodeScreen";
import { GoalsScreen } from "./components/screens/GoalsScreen";
import { ProfileScreen } from "./components/screens/ProfileScreen";

export const router = createBrowserRouter([
  {
    path: "/",
    Component: MobileLayout,
    children: [
      { index: true, Component: DashboardScreen },
      { path: "github", Component: GitHubScreen },
      { path: "leetcode", Component: LeetCodeScreen },
      { path: "goals", Component: GoalsScreen },
      { path: "profile", Component: ProfileScreen },
    ],
  },
]);
