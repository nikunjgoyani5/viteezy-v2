"use client";

import React, { useMemo } from "react";
import { keyToLabel } from "@/lib/common";
import { useGetOrderStatsQuery } from "@/store/api/orderApi";
import type { OrderStatsData } from "@/store/api/types/order.types";
import { StatsCardsSkeleton } from "../dashboard/skeletons/StatsCardsSkeleton";
import StatsGrid, { StatItem } from "../common/StatsGrid";
import { useSidebar } from "@/providers/sidebarState";

export default function OrderCards() {
  const { data: statsData, isLoading: stateLoading } = useGetOrderStatsQuery();

  const { expanded } = useSidebar();

  const statsList: StatItem[] = useMemo(() => {
    const rawStats = statsData?.data?.stats;
    if (!rawStats) return [];

    // Define the order and labels for the stats
    const statsConfig: Array<{
      key: keyof OrderStatsData["stats"];
      label: string;
    }> = [
        { key: "totalOrders", label: "Total" },
        { key: "shipped", label: "Ready for shipment" },
        { key: "processing", label: "Processing" },
        { key: "delivered", label: "Delivered" },
        { key: "cancelled", label: "Cancelled" },
      ];

    return statsConfig.map(({ key, label }) => {
      const stat = rawStats[key];

      return {
        key: key,
        label: label,
        value: new Intl.NumberFormat("en-US").format(stat.count),
        changePercentage: stat.changePercentage,
        isPositive: stat.changePercentage >= 0,
        subLabel: "vs last month",
      };
    });
  }, [statsData]);

  if (stateLoading) return <StatsCardsSkeleton />;

  return (
    <StatsGrid
      data={statsList}
      isLoading={stateLoading}
      cols={5}
      cols3xl={expanded ? 5 : 6}
    />
  );
}
