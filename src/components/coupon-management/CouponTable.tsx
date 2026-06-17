"use client";

import React, { useMemo, useState } from "react";
import toast from "react-hot-toast";
import { useRouter } from "next/navigation";

import { DataTable } from "@/components/ui/table";
import OverlayLoader from "@/components/common/OverlayLoader";
import ConfirmModal from "@/components/ui/confirmModal";
import { useDeleteConfirm } from "@/hooks/useDeleteConfirm";

import {
  useGetCouponsQuery,
  useDeleteCouponMutation,
  useUpdateCouponStatusMutation,
} from "@/store/api/couponApi";
import type { Coupon, CouponStatus } from "@/store/api/types/coupon.types";
import { couponColumns } from "./couponColumns";
import { ROUTES } from "@/constants/routes";
import { useUrlTableState } from "@/hooks/useUrlTableState";
import { useDebounce } from "@/hooks/useDebounce";

const TABS = [
  { value: "all", label: "All" },
  { value: "active", label: "Active" },
  { value: "inactive", label: "Inactive" },
  { value: "expired", label: "Expired" },
];

export default function CouponTable() {
  const router = useRouter();

  const { queryArgs, limit, onPageChange, onLimitChange, onSearchChange } =
    useUrlTableState({ defaultPage: 1, defaultLimit: 10 });

  const [activeTab, setActiveTab] = useState<CouponStatus>("all");

  const statusParam = useMemo(() => {
    if (activeTab === "active") return "active";
    if (activeTab === "inactive") return "inactive";
    if (activeTab === "expired") return "expired";
    return undefined;
  }, [activeTab]);

  const debouncedSearch = useDebounce((queryArgs as any)?.search ?? "", 300);

  const apiArgs = useMemo(() => {
    const { search, ...rest } = (queryArgs as any) ?? {};
    return {
      ...rest,
      ...(debouncedSearch ? { search: debouncedSearch } : {}),
      ...(statusParam ? { status: statusParam } : {}),
    };
  }, [queryArgs, debouncedSearch, statusParam]);

  const { data, isLoading, isFetching, isError } = useGetCouponsQuery(apiArgs);

  const rows = useMemo(() => data?.data ?? [], [data?.data]);

  const [deleteCoupon, { isLoading: isDeleting }] = useDeleteCouponMutation();
  const [updateCouponStatus] = useUpdateCouponStatusMutation();

  const [updatingId, setUpdatingId] = useState<string | null>(null);

  const deleteConfirm = useDeleteConfirm<Coupon>({
    onDelete: (item) => deleteCoupon(item._id).unwrap(),
    isDeleting: isDeleting,
    onSuccess: () => toast.success("Coupon deleted successfully"),
  });

  const columns = useMemo(
    () =>
      couponColumns({
        onEdit: (row) => {
          router.push(ROUTES.COUPON_MANAGEMENT.EDIT(row._id));
        },
        onDelete: (row) => deleteConfirm.openDelete(row),
        onToggleStatus: async (row, checked) => {
          setUpdatingId(row._id);
          try {
            await updateCouponStatus({
              id: row._id,
              body: { isActive: checked },
              listArgs: apiArgs,
            }).unwrap();
            toast.success(`Coupon ${checked ? "activated" : "deactivated"} successfully`);
          } catch (error: any) {
            toast.error(error?.data?.message || "Failed to update status");
            console.error("Failed to update status:", error);
          } finally {
            setUpdatingId(null);
          }
        },
        updatingId,
      }),
    [router, updatingId, updateCouponStatus, apiArgs, deleteConfirm]
  );

  const handleTabChange = (tab: string) => {
    setActiveTab(tab as CouponStatus);
    onPageChange(1);
  };

  if (isError) {
    return (
      <div className="bg-white border rounded-lg p-5 text-red-600">
        Failed to load coupons.
      </div>
    );
  }

  return (
    <div className="relative w-full min-w-0 overflow-hidden">
      <DataTable
        // title="Manage Coupons"
        columns={columns}
        data={rows}
        tabs={TABS}
        activeTab={activeTab}
        onTabChange={handleTabChange}
        searchKey="code"
        searchPlaceholder="Search coupons..."
        pageSize={limit}
        pagination={data?.pagination}
        onPageChange={onPageChange}
        onLimitChange={onLimitChange}
        onSearchChange={onSearchChange}
      />

      <OverlayLoader show={isLoading || isFetching} />

      <ConfirmModal
        open={deleteConfirm.open}
        onOpenChange={deleteConfirm.onOpenChange}
        title="Delete coupon?"
        description={
          deleteConfirm.deleteItem?.code
            ? `Are you sure you want to delete "${deleteConfirm.deleteItem.code}"? This action cannot be undone.`
            : "This action cannot be undone."
        }
        error={deleteConfirm.deleteError}
        confirmText="Delete"
        cancelText="Cancel"
        variant="danger"
        loading={isDeleting}
        onConfirm={deleteConfirm.onConfirm}
      />
    </div>
  );
}
