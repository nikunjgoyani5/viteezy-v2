// Common table types and interfaces

import React from "react";

export interface BaseTableData {
    id: string;
}

export interface TableFilter {
    value: string;
    label: string;
}

export interface ActionMenuItem {
    label: string;
    onClick: () => void;
    icon?: React.ReactNode;
    danger?: boolean;
    disabled?: boolean;
}

export interface PaginationState {
    pageIndex: number;
    pageSize: number;
}

export interface SortingState {
    id: string;
    desc: boolean;
}

// Status filter helper
export const statusFilters: TableFilter[] = [
    { value: "all", label: "All" },
    { value: "active", label: "Active" },
    { value: "inactive", label: "Inactive" },
];

// Common date formatter
export const formatDate = (dateString: string): string => {
    const date = new Date(dateString);
    return date.toLocaleDateString("en-US", {
        month: "short",
        day: "numeric",
        year: "numeric",
    });
};

// Common status badge props
export interface StatusBadgeProps {
    status: "active" | "inactive" | "pending";
}

