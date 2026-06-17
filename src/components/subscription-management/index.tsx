"use client";

import React, { useState, useMemo } from "react";
import { DataTable } from "@/components/ui/table";
import type { FilterOption } from "@/components/ui/table/TableFilterRow";
import { subscriptionColumns } from "./subscriptionColumns";
import { useGetSubscriptionsQuery } from "@/store/api/subscriptionApi";

const advancedFilters: FilterOption[] = [
    {
        key: "status",
        label: "Status",
        type: "select",
        options: [
            { value: "Active", label: "Active" },
            { value: "Paused", label: "Paused" },
            { value: "Cancelled", label: "Cancelled" },
            { value: "Expired", label: "Expired" },
            { value: "Suspended", label: "Suspended" },
        ],
    },
    {
        key: "startDate",
        label: "Start Date",
        type: "date",
    },
    {
        key: "endDate",
        label: "End Date",
        type: "date",
    },
];

export default function SubscriptionManagementTable() {
    const [page, setPage] = useState(1);
    const [limit, setLimit] = useState(10);
    const [search, setSearch] = useState("");
    const [filters, setFilters] = useState<Record<string, any>>({});

    const sanitizedFilters = useMemo(() => {
        return Object.fromEntries(
            Object.entries(filters).filter(([, v]) => v !== undefined && v !== null && v !== "")
        );
    }, [filters]);

    const queryParams = useMemo(
        () => ({
            page,
            limit,
            ...(search ? { search } : {}),
            ...sanitizedFilters,
        }),
        [page, limit, search, sanitizedFilters]
    );

    const { data, isLoading, error, refetch } = useGetSubscriptionsQuery(queryParams);

    const handleFilterChange = (newFilters: Record<string, string>) => {
        setFilters(newFilters);
        setPage(1);
    };

    const handleSearchChange = (newSearch: string) => {
        setSearch(newSearch);
        setPage(1);
    };

    if (error) {
        return (
            <div className="p-8 text-center">
                <p className="text-red-600 mb-4">
                    {(error as any)?.data?.message || "Failed to load subscriptions"}
                </p>
                <button
                    onClick={refetch}
                    className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
                >
                    Retry
                </button>
            </div>
        );
    }

    return (
        <>
            {isLoading && (
                <div className="absolute inset-0 bg-white/60 backdrop-blur-[1px] flex items-center justify-center z-50">
                    <div className="loader"></div>
                </div>
            )}
            <DataTable
                columns={subscriptionColumns}
                data={data?.data || []}
                searchKey="subscriptionNumber"
                searchPlaceholder="Search by subscription number, user, or product..."
                advancedFilters={advancedFilters}
                pageSize={limit}
                pagination={data?.pagination}
                onPageChange={setPage}
                onLimitChange={setLimit}
                onFilterChange={handleFilterChange}
                onSearchChange={handleSearchChange}
            />
        </>
    );
}
