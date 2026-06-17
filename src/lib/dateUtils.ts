// lib/dateUtils.ts
import type { DateRange } from "react-day-picker";

import {
  GetRevenueOverviewParams,
  RevenuePeriod,
} from "@/store/api/types/dashboard.types";

export const DURATIONS = ["daily", "weekly", "monthly"] as const;
export type Duration = (typeof DURATIONS)[number];

export const toUtcStartOfDayISO = (d: Date) => {
  return new Date(
    Date.UTC(d.getFullYear(), d.getMonth(), d.getDate(), 0, 0, 0, 0)
  ).toISOString();
};

export const toUtcEndOfDayISO = (d: Date) => {
  return new Date(
    Date.UTC(d.getFullYear(), d.getMonth(), d.getDate(), 23, 59, 59, 999)
  ).toISOString();
};

export const buildRevenueOverviewParams = (args: {
  period: RevenuePeriod;
  range?: DateRange;
}): GetRevenueOverviewParams => {
  const from = args.range?.from;
  const to = args.range?.to;

  return {
    period: args.period,
    ...(from && to
      ? {
          startDate: toUtcStartOfDayISO(from),
          endDate: toUtcEndOfDayISO(to),
        }
      : {}),
  };
};

export const buildTopSellingPlansParams = (range?: DateRange) => {
  const from = range?.from;
  const to = range?.to;

  return {
    ...(from && to
      ? { startDate: toUtcStartOfDayISO(from), endDate: toUtcEndOfDayISO(to) }
      : {}),
  };
};
