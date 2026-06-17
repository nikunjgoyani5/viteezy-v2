"use client";

import React, { useState } from "react";
import {
    ColumnDef,
    flexRender,
    getCoreRowModel,
    getPaginationRowModel,
    getSortedRowModel,
    getFilteredRowModel,
    SortingState,
    ColumnFiltersState,
    useReactTable,
} from "@tanstack/react-table";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "./table-ui";
import { TablePagination } from "./TablePagination";
import { TableSearch } from "./TableSearch";
import { TableFilters } from "./TableFilters";
import { TableFilterRow, FilterOption } from "./TableFilterRow";
import { FilterIcon } from "@/components/icons";
import { PaginationData } from "@/store/api/types/user.types";

export interface TabOption {
    value: string;
    label: string;
}

export interface DataTableProps<TData, TValue> {
    columns: ColumnDef<TData, TValue>[];
    data: TData[];
    searchKey?: string;
    searchPlaceholder?: string;
    filters?: { value: string; label: string }[];
    advancedFilters?: FilterOption[];
    pageSize?: number;
    showCheckbox?: boolean;
    pagination?: PaginationData;
    onPageChange?: (page: number) => void;
    onLimitChange?: (limit: number) => void;
    onFilterChange?: (filters: Record<string, string>) => void;
    onSearchChange?: (search: string) => void;
    // Header props
    title?: string;
    tabs?: TabOption[];
    activeTab?: string;
    onTabChange?: (tab: string) => void;
    headerAction?: React.ReactNode;
    showPagination?: boolean;
}

export function DataTable<TData, TValue>({
    columns,
    data,
    searchKey,
    searchPlaceholder = "Search...",
    filters,
    advancedFilters,
    pageSize = 10,
    showCheckbox = false,
    pagination,
    onPageChange,
    onLimitChange,
    onFilterChange,
    onSearchChange,
    title,
    tabs,
    activeTab,
    onTabChange,
    headerAction,
    showPagination = true,
}: DataTableProps<TData, TValue>) {
    const [sorting, setSorting] = useState<SortingState>([]);
    const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([]);
    const [activeFilter, setActiveFilter] = useState("all");
    const [rowSelection, setRowSelection] = useState({});
    const [showAdvancedFilters, setShowAdvancedFilters] = useState(false);
    const [activeAdvancedFilters, setActiveAdvancedFilters] = useState<Record<string, any>>({});
    const [searchText, setSearchText] = useState("");

    const isServerSidePagination = !!pagination && !!onPageChange;

    const table = useReactTable({
        data,
        columns,
        getCoreRowModel: getCoreRowModel(),
        getPaginationRowModel: isServerSidePagination ? undefined : getPaginationRowModel(),
        getSortedRowModel: getSortedRowModel(),
        getFilteredRowModel: isServerSidePagination ? undefined : getFilteredRowModel(),
        onSortingChange: setSorting,
        onColumnFiltersChange: setColumnFilters,
        onRowSelectionChange: setRowSelection,
        state: {
            sorting,
            columnFilters,
            rowSelection,
        },
        initialState: {
            pagination: {
                pageSize: pageSize,
            },
        },
        manualPagination: isServerSidePagination,
        manualFiltering: isServerSidePagination,
        pageCount: pagination?.pages,
    });

    const handleAdvancedFilterChange = (key: string, value: any) => {
        const newFilters = {
            ...activeAdvancedFilters,
            [key]: value,
        };
        setActiveAdvancedFilters(newFilters);

        if (onFilterChange) {
            onFilterChange(newFilters);
        } else {
            // Apply filter to table column for client-side filtering
            table.getColumn(key)?.setFilterValue(value);
        }
    };

    const handleRemoveAdvancedFilter = (key: string) => {
        setActiveAdvancedFilters((prevFilters) => {
            const newFilters = { ...prevFilters };
            delete newFilters[key];

            if (onFilterChange) {
                onFilterChange(newFilters);
            } else {
                // Clear filter from table column for client-side filtering
                table.getColumn(key)?.setFilterValue(undefined);
            }

            return newFilters;
        });
    };

    const handleClearAllFilters = () => {
        setActiveAdvancedFilters({});

        if (onFilterChange) {
            onFilterChange({});
        } else {
            // Clear all filters from table columns for client-side filtering
            Object.keys(activeAdvancedFilters).forEach((key) => {
                table.getColumn(key)?.setFilterValue(undefined);
            });
        }
    };

    const handleSearchChange = (value: string) => {
        if (onSearchChange) {
            setSearchText(value);
            onSearchChange(value);
        } else {
            table.getColumn(searchKey!)?.setFilterValue(value);
        }
    };

    return (
        <div className="w-full flex flex-col h-[calc(100vh-12rem)]">
            {/* Table Container with fixed height and internal scroll */}
            <div className="flex-1 flex flex-col rounded-lg border border-gray-200 bg-white overflow-hidden">
                {/* Header with Title, Search, Tabs and Filters - Fixed at top */}
                <div className="px-6 pt-4 shrink-0">
                    <div className="flex items-center justify-between gap-6">
                        {/* Title */}
                        {title && (
                            <h1 className="text-xl font-semibold text-gray-900 whitespace-nowrap">{title}</h1>
                        )}

                        {/* Right side: Search and Tabs */}
                        <div className={`flex items-center gap-4 ${!title ? "flex-1" : ""}`}>
                            {/* Search */}
                            {searchKey && (
                                <div className={title ? "w-80" : "flex-1"}>
                                    <TableSearch
                                        placeholder={searchPlaceholder}
                                        value={
                                            onSearchChange
                                                ? searchText
                                                : ((table.getColumn(searchKey)?.getFilterValue() as string) ?? "")
                                        }
                                        onChange={handleSearchChange}
                                    />
                                </div>
                            )}

                            {/* Tabs */}
                            {tabs && tabs.length > 0 && (
                                <div className="inline-flex  items-center rounded-md border border-extra-light-gray bg-white divide-x divide-gray-200 overflow-hidden ">
                                    {tabs.map((tab) => (
                                        <button
                                            key={tab.value}
                                            onClick={() => onTabChange?.(tab.value)}
                                            aria-pressed={activeTab === tab.value}
                                            className={`px-4 py-1.5 text-sm transition-colors focus:outline-none ${activeTab === tab.value
                                                ? "text-gray-900 "
                                                : "text-text-gray cursor-pointer hover:text-gray-700 bg-slate-gray"
                                                }`}
                                        >
                                            {tab.label}
                                        </button>
                                    ))}
                                </div>
                            )}
                        </div>

                        {/* Filter Button - Only show if no tabs */}
                        {!tabs && advancedFilters && advancedFilters.length > 0 && (
                            <button
                                onClick={() => {
                                    if (showAdvancedFilters) {
                                        // If filters panel is open and user clicks Cancel, clear all filters and close panel
                                        handleClearAllFilters();
                                        setShowAdvancedFilters(false);
                                    } else {
                                        // If filters panel is closed, open it
                                        setShowAdvancedFilters(true);
                                    }
                                }}
                                className="flex items-center gap-2 px-4 py-1.5 border border-extra-light-gray rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50 whitespace-nowrap cursor-pointer"
                            >
                                <FilterIcon />
                                {showAdvancedFilters ? "Cancel" : "Filter"}
                            </button>
                        )}

                        {filters && (
                            <TableFilters
                                filters={filters}
                                activeFilter={activeFilter}
                                onFilterChange={setActiveFilter}
                            />
                        )}
                    </div>

                    {/* Advanced Filter Row */}
                    {advancedFilters && showAdvancedFilters && (
                        <div className=" pt-3 ">
                            <TableFilterRow
                                availableFilters={advancedFilters}
                                activeFilters={activeAdvancedFilters}
                                onFilterChange={handleAdvancedFilterChange}
                                onRemoveFilter={handleRemoveAdvancedFilter}
                                onClearAllFilters={handleClearAllFilters}
                            />
                        </div>
                    )}
                </div>

                {/* Scrollable Table Container */}
                <div className="flex-1 overflow-auto border-t border-gray-200 mt-4">
                    <Table>
                        <TableHeader className="sticky top-0 bg-white z-10">
                            {table.getHeaderGroups().map((headerGroup) => (
                                <TableRow key={headerGroup.id}>
                                    {headerGroup.headers.map((header) => (
                                        <TableHead key={header.id}>
                                            {header.isPlaceholder
                                                ? null
                                                : flexRender(
                                                    header.column.columnDef.header,
                                                    header.getContext()
                                                )}
                                        </TableHead>
                                    ))}
                                </TableRow>
                            ))}
                        </TableHeader>
                        <TableBody>
                            {table.getRowModel().rows?.length ? (
                                table.getRowModel().rows.map((row) => (
                                    <TableRow
                                        key={row.id}
                                        data-state={row.getIsSelected() && "selected"}
                                    >
                                        {row.getVisibleCells().map((cell) => (
                                            <TableCell key={cell.id}>
                                                {flexRender(cell.column.columnDef.cell, cell.getContext())}
                                            </TableCell>
                                        ))}
                                    </TableRow>
                                ))
                            ) : (
                                <TableRow>
                                    <TableCell colSpan={columns.length} className="h-24 text-center">
                                        No results found.
                                    </TableCell>
                                </TableRow>
                            )}
                        </TableBody>
                    </Table>
                </div>
            </div>

            {/* Pagination - Fixed at bottom, outside table */}
            {showPagination && (
                <div className="mt-4 shrink-0">
                    <TablePagination
                        table={table}
                        pagination={pagination}
                        onPageChange={onPageChange}
                        onLimitChange={onLimitChange}
                        currentLimit={pageSize}
                    />
                </div>
            )}
        </div>
    );
}
