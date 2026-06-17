"use client";

import React, { useMemo } from "react";
import { formatCurrencyDashboard, keyToLabel } from "@/lib/common";
import { useGetDashboardStatsQuery } from "@/store/api/dashboardApi";
import type { DashboardStats } from "@/store/api/types/dashboard.types";
import { StatsCardsSkeleton } from "./skeletons/StatsCardsSkeleton";
import StatsGrid, { StatItem } from "../common/StatsGrid";
import { useSidebar } from "@/providers/sidebarState";

type StatValue = {
  value: number;
  change: {
    percentage: number;
    isPositive: boolean;
  };
};

export default function StatsCards() {
  const { data: statsData, isLoading: stateLoading } =
    useGetDashboardStatsQuery();

  const { expanded } = useSidebar();

  const statsList: StatItem[] = useMemo(() => {
    const rawStats = statsData?.data?.stats;
    if (!rawStats) return [];

    const keys = Object.keys(rawStats) as Array<keyof DashboardStats>;

    return keys.map((key) => {
      const stat = rawStats[key] as StatValue;

      return {
        key: key,
        label: keyToLabel(key),
        value:
          key === "totalRevenue"
            ? formatCurrencyDashboard(stat.value)
            : new Intl.NumberFormat("en-US").format(stat.value),
        changePercentage: stat.change.percentage,
        isPositive: stat.change.isPositive,
      };
    });
  }, [statsData]);

  if (stateLoading) return <StatsCardsSkeleton />;

  return (
    <StatsGrid
      data={statsList}
      isLoading={stateLoading}
      cols={5}
      cols3xl={statsList?.length > 5 ? (expanded ? 5 : 7) : 5}
    />
  );
}
