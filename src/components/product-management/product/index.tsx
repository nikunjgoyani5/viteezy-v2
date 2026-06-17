"use client";

import React, { useMemo, useState } from "react";
import toast from "react-hot-toast";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { MdOutlineAdd } from "react-icons/md";

import { PageHeader } from "@/components/layout/PageHeader";
import { DataTable } from "@/components/ui/table";
import OverlayLoader from "@/components/common/OverlayLoader";
import { Button } from "@/components/ui/button";
import ConfirmModal from "@/components/ui/confirmModal";
import { useDeleteConfirm } from "@/hooks/useDeleteConfirm";

import { useUrlTableState } from "@/hooks/useUrlTableState";
import { useDebounce } from "@/hooks/useDebounce";
import {
  useGetProductsQuery,
  useGetProductFiltersQuery,
  useDeleteProductMutation,
  useUpdateProductStatusMutation,
} from "@/store/api/productsApi";
import type {
  GetProductsParams,
  ProductListItem,
} from "@/store/api/types/products.types";

import { productColumns } from "./productColumns";
import {
  buildProductAdvancedFilters,
  mapProductFiltersToApi,
} from "./productFilters";
import { ROUTES } from "@/constants/routes";

export default function ProductsPage() {
  const router = useRouter();

  const { queryArgs, limit, onPageChange, onLimitChange, onSearchChange } =
    useUrlTableState({ defaultPage: 1, defaultLimit: 10 });

  const [apiFilters, setApiFilters] = useState<Partial<GetProductsParams>>({});

  const { data: filtersRes, isFetching: filtersFetching } =
    useGetProductFiltersQuery();

  const advancedFilters = useMemo(
    () => buildProductAdvancedFilters(filtersRes),
    [filtersRes]
  );

  const debouncedSearch = useDebounce((queryArgs)?.search ?? "", 300);

  const listArgs = useMemo(() => {
    const { search, ...rest } = (queryArgs) ?? {};

    return {
      ...(rest as GetProductsParams),
      ...(debouncedSearch ? { search: debouncedSearch } : {}),
      ...apiFilters,
    } as GetProductsParams;
  }, [queryArgs, debouncedSearch, apiFilters]);

  const { data, isLoading, isFetching, isError } =
    useGetProductsQuery(listArgs);

  const rows = useMemo(() => data?.data ?? [], [data?.data]);

  const [deleteProduct, { isLoading: isDeleting }] = useDeleteProductMutation();
  const [updateStatus] = useUpdateProductStatusMutation();

  const deleteConfirm = useDeleteConfirm<ProductListItem>({
    onDelete: (item) => deleteProduct(item._id).unwrap(),
    isDeleting: isDeleting,
    onSuccess: () => toast.success("Product deleted successfully"),
  });

  const [updatingId, setUpdatingId] = useState<string | null>(null);

  const handleDeleteClick = (row: ProductListItem) =>
    deleteConfirm.openDelete(row);

  const handleToggleStatus = async (
    row: ProductListItem,
    nextStatus: boolean
  ) => {
    try {
      setUpdatingId(row._id);
      await updateStatus({
        id: row._id,
        enabled: nextStatus,
        listArgs,
      }).unwrap();
      toast.success(`Product ${nextStatus ? "activated" : "deactivated"} successfully`);
    } catch (error: any) {
      toast.error(error?.data?.message || "Failed to update status");
      console.error("Failed to update status:", error);
    } finally {
      setUpdatingId(null);
    }
  };

  const columns = useMemo(
    () =>
      productColumns({
        onEdit: (row: ProductListItem) =>
          router.push(`${ROUTES.PRODUCT_MANAGEMENT.PRODUCT}/${row._id}`),
        onDelete: handleDeleteClick,
        onToggleStatus: handleToggleStatus,
        updatingId,
      }),
    [router, updatingId, deleteConfirm, listArgs]
  );

  if (isError) {
    return (
      <div className="bg-white border rounded-lg p-5 text-red-600">
        Failed to load products.
      </div>
    );
  }

  return (
    <div className="relative">
      <PageHeader
        title="Products"
        actions={
          <Link href={ROUTES.PRODUCT_MANAGEMENT.CREATE_PRODUCT}>
            <Button variant="teal" className="text-sm 3xl:text-base">
              <MdOutlineAdd size={20} />
              Add Product
            </Button>
          </Link>
        }
      />

      <div className="relative">
        <DataTable
          columns={columns}
          data={rows}
          searchKey="title"
          searchPlaceholder="Search products"
          advancedFilters={advancedFilters}
          pageSize={limit}
          pagination={data?.pagination}
          onPageChange={onPageChange}
          onLimitChange={onLimitChange}
          onSearchChange={(v) => {
            onSearchChange(v); // updates URL immediately
            onPageChange(1); // reset page immediately
          }}
          onFilterChange={(filters: Record<string, string>) => {
            setApiFilters(mapProductFiltersToApi(filters));
            onPageChange(1);
          }}
        />

        <OverlayLoader show={isLoading || isFetching || filtersFetching} />
      </div>

      <ConfirmModal
        open={deleteConfirm.open}
        onOpenChange={deleteConfirm.onOpenChange}
        title="Delete Product?"
        description={
          deleteConfirm.deleteItem
            ? `Are you sure you want to delete "${deleteConfirm.deleteItem.title}"? This action cannot be undone.`
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
