"use client";

import React, { useMemo, useState } from "react";
import { useRouter } from "next/navigation";

import { DataTable } from "@/components/ui/table";
import OverlayLoader from "@/components/common/OverlayLoader";
import ConfirmModal from "@/components/ui/confirmModal";
import { useDeleteConfirm } from "@/hooks/useDeleteConfirm";

import { ROUTES } from "@/constants/routes";
import type { ProductIngredient } from "@/store/api/types/productIngredient.types";
import {
  useDeleteProductIngredientMutation,
  useGetProductIngredientsQuery,
  useUpdateProductIngredientStatusMutation,
} from "@/store/api/productIngredientsApi";
import { ingredientColumns } from "./ingredientColumns";

import { useUrlTableState } from "@/hooks/useUrlTableState";
import toast from "react-hot-toast";

export default function IngredientsManagmentPage() {
  const router = useRouter();
  const [activeTab, setActiveTab] = useState("all");

  const statusParam = useMemo(() => {
    if (activeTab === "active") return true;
    if (activeTab === "inactive") return false;
    return undefined; // "all" - no filter
  }, [activeTab]);

  const { queryArgs, limit, onPageChange, onLimitChange, onSearchChange } =
    useUrlTableState({ defaultPage: 1, defaultLimit: 10 });

  const listArgs = useMemo(
    () => ({
      ...queryArgs,
      ...(statusParam !== undefined && { isActive: statusParam }),
    }),
    [queryArgs, statusParam]
  );

  const { data, isLoading, isFetching, isError } =
    useGetProductIngredientsQuery(listArgs);

  const rows = useMemo(() => data?.data ?? [], [data?.data]);

  const [deleteIngredient, { isLoading: deleting }] =
    useDeleteProductIngredientMutation();

  const [updateStatus] = useUpdateProductIngredientStatusMutation();

  const [updatingId, setUpdatingId] = useState<string | null>(null);

  const deleteConfirm = useDeleteConfirm<ProductIngredient>({
    onDelete: (item) =>
      deleteIngredient({ id: item._id, listArgs: listArgs }).unwrap(),
    isDeleting: deleting,
  });

  const columns = useMemo(
    () =>
      ingredientColumns({
        onEdit: (row: ProductIngredient) =>
          router.push(`${ROUTES.INGREDIENTS_MANAGMENT.BASE}/${row._id}`),
        onDelete: (row: ProductIngredient) => deleteConfirm.openDelete(row),
        onToggleStatus: async (row, nextStatus) => {
          try {
            setUpdatingId(row._id);
            await updateStatus({
              id: row._id,
              isActive: nextStatus,
              listArgs: listArgs,
            }).unwrap();
            toast.success(
              `Product ingredient ${
                nextStatus ? "activated" : "deactivated"
              } successfully`
            );
          } catch (error: any) {
            toast.error(error?.data?.message || "Failed to update status");
          } finally {
            setUpdatingId(null);
          }
        },
        updatingId,
      }),
    [router, deleteConfirm, updateStatus, listArgs, updatingId]
  );

  const tabs = [
    { value: "all", label: "All" },
    { value: "active", label: "Active" },
    { value: "inactive", label: "Inactive" },
  ];

  const handleTabChange = (tab: string) => {
    setActiveTab(tab);
    onPageChange(1);
  };

  if (isError) {
    return (
      <div className="bg-white border rounded-lg p-5 text-red-600">
        Failed to load ingredients.
      </div>
    );
  }

  return (
    <div className="relative">
      <DataTable
        title="All Ingredients"
        tabs={tabs}
        activeTab={activeTab}
        onTabChange={handleTabChange}
        columns={columns}
        data={rows}
        searchKey="name"
        searchPlaceholder="Search ingredients"
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
        title="Delete ingredient?"
        description={
          deleteConfirm.deleteItem?.name
            ? `Are you sure you want to delete “${deleteConfirm.deleteItem.name}”? This action cannot be undone.`
            : "This action cannot be undone."
        }
        error={deleteConfirm.deleteError}
        confirmText="Delete"
        cancelText="Cancel"
        variant="danger"
        loading={deleting}
        onConfirm={deleteConfirm.onConfirm}
      />
    </div>
  );
}
