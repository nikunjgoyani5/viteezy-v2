import React from "react";
import { Table } from "@tanstack/react-table";
import { MdChevronLeft, MdChevronRight } from "react-icons/md";
import { PaginationData } from "@/store/api/types/user.types";

interface TablePaginationProps<TData> {
    table: Table<TData>;
    pagination?: PaginationData;
    onPageChange?: (page: number) => void;
    onLimitChange?: (limit: number) => void;
    currentLimit?: number;
}

export function TablePagination<TData>({
    table,
    pagination,
    onPageChange,
    onLimitChange,
    currentLimit,
}: TablePaginationProps<TData>) {
    const isServerSide = !!pagination && !!onPageChange;

    const currentPage = isServerSide ? pagination.page : table.getState().pagination.pageIndex + 1;
    const totalPages = isServerSide ? pagination.pages : table.getPageCount();
    const canPreviousPage = isServerSide ? pagination.hasPrev : table.getCanPreviousPage();
    const canNextPage = isServerSide ? pagination.hasNext : table.getCanNextPage();

    const handlePreviousPage = () => {
        if (isServerSide) {
            onPageChange(currentPage - 1);
        } else {
            table.previousPage();
        }
    };

    const handleNextPage = () => {
        if (isServerSide) {
            onPageChange(currentPage + 1);
        } else {
            table.nextPage();
        }
    };

    return (
        <div className="flex items-center justify-between px-2">
            <div className="flex-1 text-sm text-gray-600">
                {table.getFilteredSelectedRowModel().rows.length > 0 && (
                    <span>
                        {table.getFilteredSelectedRowModel().rows.length} of{" "}
                        {isServerSide ? pagination?.total : table.getFilteredRowModel().rows.length} row(s) selected.
                    </span>
                )}
            </div>
            <div className="flex items-center gap-6">
                <div className="flex items-center gap-2">
                    <span className="text-sm text-gray-600">Rows per page:</span>
                    <select
                        className="h-8 w-[70px] rounded-md border border-gray-300 bg-white px-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500"
                        value={isServerSide ? currentLimit : table.getState().pagination.pageSize}
                        onChange={(e) => {
                            const newLimit = Number(e.target.value);
                            if (isServerSide && onLimitChange) {
                                onLimitChange(newLimit);
                            } else {
                                table.setPageSize(newLimit);
                            }
                        }}
                    >
                        {[10, 20, 30].map((pageSize) => (
                            <option key={pageSize} value={pageSize}>
                                {pageSize}
                            </option>
                        ))}
                    </select>
                </div>

                <div className="flex items-center gap-1 text-sm text-gray-600">
                    <span>
                        Page {currentPage} of {totalPages}
                    </span>
                    {/* {isServerSide && (
                        <span className="ml-2">
                            ({pagination.total} total items)
                        </span>
                    )} */}
                </div>

                <div className="flex items-center gap-1">
                    <button
                        className="h-8 w-8 rounded-md border border-gray-300 bg-white p-0 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center"
                        onClick={handlePreviousPage}
                        disabled={!canPreviousPage}
                    >
                        <MdChevronLeft className="h-5 w-5" />
                    </button>
                    <button
                        className="h-8 w-8 rounded-md border border-gray-300 bg-white p-0 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center"
                        onClick={handleNextPage}
                        disabled={!canNextPage}
                    >
                        <MdChevronRight className="h-5 w-5" />
                    </button>
                </div>
            </div>
        </div>
    );
}
