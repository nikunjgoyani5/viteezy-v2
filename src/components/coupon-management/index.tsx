import React from "react";
import CouponStatsCards from "./CouponStatsCards";
import CouponTable from "./CouponTable";
import CouponUsage from "./CouponUsage";

const CouponManagementPage = () => {
  return (
    <div className="w-full min-w-0">
      <CouponStatsCards />
      <div className="mt-4 sm:mt-5 flex flex-col xl:flex-row gap-4 sm:gap-5">
        <div className="w-full min-w-0 xl:flex-1 xl:min-w-0">
          <CouponTable />
        </div>
        <div className="w-full min-w-0 xl:shrink-0 xl:w-[320px] 3xl:w-[420px]">
          <CouponUsage />
        </div>
      </div>
    </div>
  );
};

export default CouponManagementPage;
