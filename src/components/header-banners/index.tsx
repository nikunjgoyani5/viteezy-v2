"use client";

import React, { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import toast from "react-hot-toast";
import { DataTable } from "@/components/ui/table";
import type { FilterOption } from "@/components/ui/table/TableFilterRow";
import OverlayLoader from "@/components/common/OverlayLoader";
import ConfirmModal from "@/components/ui/confirmModal";
import { useDeleteConfirm } from "@/hooks/useDeleteConfirm";
import { headerBannerColumns } from "./headerBannerColumns";
import {
  useGetHeaderBannersQuery,
  useUpdateHeaderBannerStatusMutation,
  useDeleteHeaderBannerMutation,
} from "@/store/api/headerBannerApi";
import type {
  DeviceType,
  HeaderBanner,
} from "@/store/api/types/headerBanner.types";
import { useDebounce } from "@/hooks/useDebounce";
import { ROUTES } from "@/constants/routes";

const advancedFilters: FilterOption[] = [
  {
    key: "deviceType",
    label: "Device",
    type: "select",
    options: [
      { value: "WEB", label: "WEB" },
      { value: "MOBILE", label: "MOBILE" },
    ],
  },
  {
    key: "isActive",
    label: "Status",
    type: "select",
    options: [
      { value: "true", label: "Active" },
      { value: "false", label: "Inactive" },
    ],
  },
];

export default function HeaderBannersTable() {
  const router = useRouter();
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState(10);
  const [search, setSearch] = useState("");
  const [filters, setFilters] = useState<Record<string, any>>({});
  const [updatingId, setUpdatingId] = useState<string | null>(null);

  const debouncedSearch = useDebounce(search, 300);

  const cleanFilters = useMemo(() => {
    const cleaned: Record<string, any> = {};
    Object.entries(filters).forEach(([key, value]) => {
      if (value === undefined || value === null || value === "") return;
      if (key === "isActive") {
        cleaned.isActive = value === "true";
      } else if (key === "deviceType") {
        cleaned.deviceType = value as DeviceType;
      } else {
        cleaned[key] = value;
      }
    });
    return cleaned;
  }, [filters]);

  const queryParams = useMemo(
    () => ({
      page,
      limit,
      ...(debouncedSearch ? { search: debouncedSearch } : {}),
      ...cleanFilters,
    }),
    [page, limit, debouncedSearch, cleanFilters]
  );

  const { data, isLoading, isFetching } = useGetHeaderBannersQuery(queryParams);
  const [updateStatus] = useUpdateHeaderBannerStatusMutation();
  const [deleteBanner, { isLoading: isDeleting }] = useDeleteHeaderBannerMutation();

  const deleteConfirm = useDeleteConfirm<HeaderBanner>({
    onDelete: (item) => deleteBanner(item._id).unwrap(),
    isDeleting,
    onSuccess: () => toast.success("Offer banner deleted successfully"),
  });

  const rows = data?.data ?? [];

  const columns = useMemo(() => {
    return headerBannerColumns({
      updatingId,
      onToggleStatus: async (id, isActive) => {
        try {
          setUpdatingId(id);
          await updateStatus({
            id,
            isActive,
            listArgs: queryParams,
          });
        } catch (error) {
          console.error(error);
        } finally {
          setUpdatingId(null);
        }
      },
      onEdit: (row) => router.push(`${ROUTES.HEADER_BANNERS}/${row._id}`),
      onDelete: (row) => deleteConfirm.openDelete(row),
    });
  }, [updatingId, updateStatus, queryParams, router, deleteConfirm]);

  const handleFilterChange = (next: Record<string, string>) => {
    setFilters(next);
    setPage(1);
  };

  const handleSearchChange = (value: string) => {
    setSearch(value);
    setPage(1);
  };

  return (
    <>
      <div className="relative">
        <DataTable
          columns={columns}
          data={rows}
          searchKey="text"
          searchPlaceholder="Search banner text..."
          advancedFilters={advancedFilters}
          pageSize={limit}
          pagination={data?.pagination}
          onPageChange={setPage}
          onLimitChange={setLimit}
          onFilterChange={handleFilterChange}
          onSearchChange={handleSearchChange}
          showCheckbox={false}
        />
        <OverlayLoader show={isLoading || isFetching} />
      </div>
      <ConfirmModal
        open={deleteConfirm.open}
        onOpenChange={deleteConfirm.onOpenChange}
        title="Delete offer banner"
        description={
          deleteConfirm.deleteItem
            ? `Are you sure you want to delete this banner? "${deleteConfirm.deleteItem.text}" will be removed. This action cannot be undone.`
            : "This action cannot be undone."
        }
        error={deleteConfirm.deleteError}
        confirmText="Delete"
        cancelText="Cancel"
        variant="danger"
        loading={isDeleting}
        onConfirm={deleteConfirm.onConfirm}
      />
    </>
  );
}
