"use client";

import React, { useMemo } from "react";
import StatsGrid, { StatItem } from "../common/StatsGrid";
import { useGetCouponStatsQuery } from "@/store/api/couponApi";
import type { CouponStats } from "@/store/api/types/coupon.types";
import { StatsCardsSkeleton } from "../dashboard/skeletons/StatsCardsSkeleton";
import { formatCurrencyDashboard, keyToLabel } from "@/lib/common";

const getExpiringSoonLabel = (
  count: number
): { label: string; variant: "default" | "warning" | "danger" } => {
  if (count === 0) {
    return { label: "No coupons expiring", variant: "default" };
  }

  if (count <= 7) {
    return { label: "Within 7 days", variant: "danger" };
  }

  if (count <= 15) {
    return { label: `${count} expiring soon`, variant: "warning" };
  }

  return { label: "Within 30 days", variant: "default" };
};

export default function CouponStatsCards() {
  const {
    data: statsData,
    isLoading: stateLoading,
    isFetching: stateFetching,
  } = useGetCouponStatsQuery();

  const statsList: StatItem[] = useMemo(() => {
    const rawStats = statsData?.data?.stats;
    if (!rawStats) return [];

    const keys = Object.keys(rawStats) as Array<keyof CouponStats>;

    return keys.map((key) => {
      const stat = rawStats[key];

      if (key === "totalDiscountedAmount") {
        const amountStat = stat as CouponStats["totalDiscountedAmount"];
        return {
          key,
          label: keyToLabel(key),
          value: formatCurrencyDashboard(
            amountStat.amount,
            amountStat.currency
          ),
          changePercentage: amountStat.change.vsLastMonth.percentage,
          isPositive: amountStat.change.vsLastMonth.isPositive,
          subLabel: "vs last month",
        };
      }

      if (key === "expiringSoon") {
        const expiringStat = stat as CouponStats["expiringSoon"];
        const expiringSoonInfo = getExpiringSoonLabel(expiringStat.count);
        return {
          key,
          label: keyToLabel(key),
          value: new Intl.NumberFormat("en-US").format(expiringStat.count),
          changePercentage: 0,
          isPositive: true,
          hideChange: true,
          customLabel: expiringSoonInfo.label,
          customLabelVariant: expiringSoonInfo.variant,
        };
      }

      const countStat = stat as CouponStats["activeCoupons"];
      return {
        key,
        label: keyToLabel(key),
        value: new Intl.NumberFormat("en-US").format(countStat.value),
        changePercentage: countStat.change.vsLastMonth.percentage,
        isPositive: countStat.change.vsLastMonth.isPositive,
        subLabel: "vs last month",
      };
    });
  }, [statsData]);

  if (stateLoading || stateFetching) return <StatsCardsSkeleton />;

  return <StatsGrid data={statsList} isLoading={stateLoading} cols={4} />;
}
