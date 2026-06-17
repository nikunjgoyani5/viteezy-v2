"use client";

import { useGetTopSellingPlansQuery } from "@/store/api/dashboardApi";
import HalfDonutChartSkeleton from "../skeletons/HalfDonutChartSkeleton";
import HalfDonutChart from "./HalfDonutChart";
import { useMemo, useState } from "react";
import { DateRange } from "react-day-picker";
import { buildTopSellingPlansParams } from "@/lib/dateUtils";
import TopSellingPlansFilters from "./TopSellingPlansFilters";
import Spinner from "@/components/ui/spinner";

const SellingPlansChart = () => {
  const [range, setRange] = useState<DateRange | undefined>(undefined);
  const params = useMemo(() => buildTopSellingPlansParams(range), [range]);

  const {
    data: sellingData,
    isLoading,
    isFetching,
    isError,
  } = useGetTopSellingPlansQuery(params);

  if (isLoading) return <HalfDonutChartSkeleton />;
  if (isError || !sellingData?.success) {
    return (
      <div className="w-full bg-white rounded-lg border p-5 text-sm text-red-600 flex items-center justify-center">
        Failed to load top selling plans.
      </div>
    );
  }

  const top = sellingData.data.plans;
  const labels = top.map((p) => p.name);
  const series = top.map((p) => Number(p.percentage.toFixed(1)));

  return (
    <div className="w-full bg-white rounded-lg border p-5 relative">
      <TopSellingPlansFilters range={range} onApplyRange={(r) => setRange(r)} />
      <HalfDonutChart labels={labels} series={series} />
      {!isLoading && isFetching && (
        <div className="absolute top-0 start-0 h-full w-full bg-gray-100/50 flex items-center justify-center">
          <Spinner />
        </div>
      )}
    </div>
  );
};

export default SellingPlansChart;
