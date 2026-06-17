"use client";

import { useGetRevenueOverviewQuery } from "@/store/api/dashboardApi";
import FiltersNav from "./FiltersNav";
import Chart from "./Chart";
import {
  DURATIONS,
  type Duration,
  buildRevenueOverviewParams,
} from "@/lib/dateUtils";
import type { DateRange } from "react-day-picker";
import { useMemo, useState } from "react";
import AnalyticsChartSkeleton from "../skeletons/AnalyticsChartSkeleton";
import Spinner from "@/components/ui/spinner";

export default function AnalyticsChart() {
  const defaultDuration: Duration = DURATIONS[0] ?? "daily";

  const [period, setPeriod] = useState<Duration>(defaultDuration);
  const [range, setRange] = useState<DateRange | undefined>(undefined);

  const params = useMemo(
    () => buildRevenueOverviewParams({ period, range }),
    [period, range]
  );

  const { data, isLoading, isFetching, isError } =
    useGetRevenueOverviewQuery(params);

  if (isError) {
    return (
      <div className="bg-white rounded-lg border p-4 text-sm text-red-600 flex items-center justify-center">
        Failed to load revenue overview.
      </div>
    );
  }

  const points = data?.data?.data ?? [];
  const labels = points.map((p) => p.label);
  const values = points.map((p) => p.revenue);

  return (
    <div className="bg-white rounded-lg border flex flex-col  relative">
      <div className="p-5 pb-3 flex-shrink-0">
        <FiltersNav
          duration={period}
          range={range}
          onChangeDuration={(d) => setPeriod(d)}
          onApplyRange={(r) => {
            setRange(r);
          }}
        />
      </div>

      <div className="flex-1 min-h-83 ">
        <Chart labels={labels} values={values} />
        {isLoading && (
          <div className="absolute top-0 start-0 h-full w-full">
            <AnalyticsChartSkeleton />
          </div>
        )}
        {!isLoading && isFetching && (
          <div className="absolute top-0 start-0 h-full w-full bg-gray-100/50 flex items-center justify-center">
            <Spinner />
          </div>
        )}
      </div>
    </div>
  );
}
