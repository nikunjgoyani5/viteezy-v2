"use client";

import React from "react";
import OrderManagementTable from "@/components/order-management";
import OrderCards from "@/components/ui/otderCard";

export default function OrderManagementPage() {
    return (
        <div className="flex flex-col gap-5">
            {/* Top stats cards copied from Dashboard */}
            <OrderCards />
            {/* Orders table with filters and colored statuses */}
            <OrderManagementTable />
        </div>
    );
}
