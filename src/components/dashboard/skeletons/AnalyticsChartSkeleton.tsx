import React from "react";

const AnalyticsChartSkeleton = () => {
  return (
    <div className="bg-white rounded-lg h-full">
      <div className="p-4 flex items-center justify-between">
        <div className="space-y-2">
          <div className="h-4 w-44 bg-gray-200 rounded animate-pulse" />
          <div className="h-3 w-32 bg-gray-200 rounded animate-pulse" />
        </div>
        <div className="h-9 w-44 bg-gray-200 rounded animate-pulse" />
      </div>

      <div className="px-4 pb-4 h-full">
        <div className="h-[320px] w-full bg-gray-100 rounded" />
      </div>
    </div>
  );
};

export default AnalyticsChartSkeleton;
