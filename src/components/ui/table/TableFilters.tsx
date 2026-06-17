import React from "react";
import { cn } from "@/lib/utils";

interface TableFiltersProps {
    filters: { value: string; label: string }[];
    activeFilter: string;
    onFilterChange: (value: string) => void;
}

export function TableFilters({
    filters,
    activeFilter,
    onFilterChange,
}: TableFiltersProps) {
    return (
        <div className="flex items-center gap-2 rounded-lg border border-gray-200 bg-white p-1">
            {filters.map((filter) => (
                <button
                    key={filter.value}
                    onClick={() => onFilterChange(filter.value)}
                    className={cn(
                        "px-4 py-1.5 rounded-md text-sm font-medium transition-colors ",
                        activeFilter === filter.value
                            ? "bg-gray-900 text-white"
                            : "text-gray-600 hover:text-gray-900"
                    )}
                >
                    {filter.label}
                </button>
            ))}
        </div>
    );
}
