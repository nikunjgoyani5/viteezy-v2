"use client"
import React from "react";
import SubscriptionManagementTable from "@/components/subscription-management";
import { PageHeader } from "@/components/layout/PageHeader";

export default function SubscriptionManagementPage() {
    return (
        <>
            <PageHeader title="Subscription Management" />

            <div className="mt-4">
                <SubscriptionManagementTable />
            </div>
        </>
    );
}
