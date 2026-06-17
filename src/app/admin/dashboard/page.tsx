import DashboardPage from "@/components/dashboard";
import { PageHeader } from "@/components/layout/PageHeader";
import React from "react";

function Dashboard() {
  return (
    <div>
      <PageHeader
        title="Dashboard Overview"
        description="Welcome back! Here's what's happening with your business today."
      />
      <DashboardPage />
    </div>
  );
}

export default Dashboard;
