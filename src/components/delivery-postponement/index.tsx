"use client";

import React, { useMemo, useState } from "react";
import { DataTable } from "@/components/ui/table";
import type { FilterOption } from "@/components/ui/table/TableFilterRow";
import OverlayLoader from "@/components/common/OverlayLoader";
import { deliveryPostponementColumns } from "./deliveryPostponementColumns";
import { useGetPostponementsQuery } from "@/store/api/postponementsApi";
import type { PostponementStatus } from "@/store/api/types/postponement.types";
import { useDebounce } from "@/hooks/useDebounce";
import { useUrlTableState } from "@/hooks/useUrlTableState";

const advancedFilters: FilterOption[] = [
  {
    key: "status",
    label: "Status",
    type: "select",
    options: [
      { value: "Pending", label: "Pending" },
      { value: "Approved", label: "Approved" },
      { value: "Rejected", label: "Rejected" },
    ],
  },
];

export default function DeliveryPostponementTable() {
  const { page, limit, search, onPageChange, onLimitChange, onSearchChange } =
    useUrlTableState({ defaultPage: 1, defaultLimit: 10 });

  const debouncedSearch = useDebounce(search, 300);
  const [filters, setFilters] = useState<Record<string, string>>({});

  const apiParams = useMemo(() => {
    const params: {
      page: number;
      limit: number;
      status?: PostponementStatus;
      search?: string;
    } = { page, limit };
    const status = filters.status;
    if (status && ["Pending", "Approved", "Rejected"].includes(status)) {
      params.status = status as PostponementStatus;
    }
    if (debouncedSearch?.trim()) {
      params.search = debouncedSearch.trim();
    }
    return params;
  }, [page, limit, filters, debouncedSearch]);

  const { data, isLoading, isFetching } = useGetPostponementsQuery(apiParams);

  const handleFilterChange = (next: Record<string, string>) => {
    setFilters(next);
    onPageChange(1);
  };

  const list = data?.data ?? [];
  const pagination = data?.pagination;

  return (
    <div className="relative">
      <DataTable
        columns={deliveryPostponementColumns}
        data={list}
        searchKey="orderNumber"
        searchPlaceholder="Search by order number..."
        advancedFilters={advancedFilters}
        pageSize={limit}
        pagination={pagination}
        onPageChange={onPageChange}
        onLimitChange={onLimitChange}
        onFilterChange={handleFilterChange}
        onSearchChange={onSearchChange}
        showCheckbox={false}
      />
      <OverlayLoader show={isLoading || isFetching} />
    </div>
  );
}
