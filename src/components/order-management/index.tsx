"use client";

import React, { useState, useMemo } from "react";
import { DataTable } from "@/components/ui/table";
import type { FilterOption } from "@/components/ui/table/TableFilterRow";
import { orderColumns } from "./orderColumns";
import { useGetOrdersQuery } from "@/store/api/orderApi";
import { DateRangePicker } from "@/components/ui/dateRangePicker";
import { Button } from "@/components/ui/button";
import { FaChevronDown } from "react-icons/fa6";
import { format, isSameDay } from "date-fns";
import type { DateRange } from "react-day-picker";

const statusOptions = [
  { value: "Pending", label: "Pending" },
  { value: "Confirmed", label: "Confirmed" },
  { value: "Processing", label: "Processing" },
  { value: "Shipped", label: "Shipped" },
  { value: "Delivered", label: "Delivered" },
  { value: "Cancelled", label: "Cancelled" },
  { value: "Refunded", label: "Refunded" },
];

const paymentStatusOptions = [
  { value: "Pending", label: "Pending" },
  { value: "Processing", label: "Processing" },
  { value: "Completed", label: "Completed" },
  { value: "Failed", label: "Failed" },
  { value: "Cancelled", label: "Cancelled" },
  { value: "Refunded", label: "Refunded" },
];

const planTypeOptions = [
  { value: "One-Time", label: "One-Time" },
  { value: "Subscription", label: "Subscription" },
];

const advancedFilters: FilterOption[] = [
  { key: "orderDate", label: "Order date", type: "date" },
  {
    key: "status",
    label: "Order status",
    type: "select",
    options: statusOptions,
  },
  {
    key: "paymentStatus",
    label: "Payment status",
    type: "select",
    options: paymentStatusOptions,
  },
  {
    key: "planType",
    label: "Plan Type",
    type: "select",
    options: planTypeOptions,
  },
  {
    key: "amountRange",
    label: "Amount Range",
    type: "range",
    rangeKeys: { min: "minTotal", max: "maxTotal" },
  },
];

export default function OrderManagementTable() {
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState(10);
  const [search, setSearch] = useState("");
  const [range, setRange] = useState<DateRange | undefined>();
  const [filters, setFilters] = useState<Record<string, any>>({});
  const [refetchTrigger, setRefetchTrigger] = useState(0);

  // Clean up filters to only pass non-empty values
  const cleanFilters = useMemo(() => {
    const cleaned: Record<string, any> = {};

    Object.entries(filters).forEach(([key, value]) => {
      if (key === "amountRange" && value && typeof value === "object") {
        // Handle range filter
        const rangeValue = value as { min?: string; max?: string };
        if (rangeValue.min) cleaned.minTotal = rangeValue.min;
        if (rangeValue.max) cleaned.maxTotal = rangeValue.max;
      } else if (key === "orderDate" && value) {
        cleaned.date = value;
      } else if (value && value !== "") {
        cleaned[key] = value;
      }
    });

    return cleaned;
  }, [filters]);

  const queryParams = useMemo(() => ({
    page,
    limit,
    ...(search ? { search } : {}),
    ...(range?.from ? { startDate: format(range.from, "yyyy-MM-dd") } : {}),
    ...(range?.to ? { endDate: format(range.to, "yyyy-MM-dd") } : {}),
    ...cleanFilters,
  }), [page, limit, search, range, cleanFilters, refetchTrigger]);

  const { data: ordersData, isLoading } = useGetOrdersQuery(queryParams);

  const onApplyRange = (newRange?: DateRange) => {
    setRange(newRange);
    setPage(1);
    setRefetchTrigger(prev => prev + 1);
  };

  const label =
    range?.from && range?.to
      ? isSameDay(range.from, range.to)
        ? format(range.from, "MMM dd, yyyy")
        : `${format(range.from, "MMM dd, yyyy")} – ${format(
          range.to,
          "MMM dd, yyyy"
        )}`
      : "Select date range";

  const datePicker = (
    <DateRangePicker value={range} onApply={onApplyRange}>
      <Button className="text-sm 3xl:text-base h-9.5 border justify-start text-left text-black font-medium bg-white hover:bg-slate-gray">
        {label}
        <FaChevronDown className="text-text-gray" size={14} />
      </Button>
    </DateRangePicker>
  );

  return (
    <DataTable
      columns={orderColumns}
      data={ordersData?.data?.orders || []}
      searchKey="orderNumber"
      searchPlaceholder="Searching all orders"
      advancedFilters={advancedFilters}
      pageSize={limit}
      pagination={ordersData?.data?.pagination}
      onPageChange={(newPage) => {
        setPage(newPage);
        setRefetchTrigger(prev => prev + 1);
      }}
      onLimitChange={(newLimit) => {
        setLimit(newLimit);
        setPage(1);
        setRefetchTrigger(prev => prev + 1);
      }}
      onSearchChange={(newSearch) => {
        setSearch(newSearch);
        setPage(1);
        setRefetchTrigger(prev => prev + 1);
      }}
      onFilterChange={(newFilters) => {
        setFilters(newFilters);
        setPage(1);
        setRefetchTrigger(prev => prev + 1);
      }}
      headerAction={datePicker}
    />
  );
}
