import StatsCards from "./StatsCards";
import RevenueChart from "./analyticsChart";
import SellingPlansChart from "./sellingPlansChart.tsx";
import SellingProducts from "./sellingProducts";

const DashboardPage = () => {
  return (
    <div className="flex flex-col gap-5">
      <StatsCards />
      <div className="grid grid-cols-1 xl:grid-cols-2 gap-5">
        <RevenueChart />
        <SellingPlansChart />
      </div>
      <SellingProducts />
    </div>
  );
};

export default DashboardPage;
