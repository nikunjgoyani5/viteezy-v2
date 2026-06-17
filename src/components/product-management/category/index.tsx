"use client";

import React, { useMemo, useState } from "react";

import { DataTable } from "@/components/ui/table";
import OverlayLoader from "@/components/common/OverlayLoader";
import { PageHeader } from "@/components/layout/PageHeader";
import { Button } from "@/components/ui/button";
import ConfirmModal from "@/components/ui/confirmModal";
import { useDeleteConfirm } from "@/hooks/useDeleteConfirm";

import { MdOutlineAdd } from "react-icons/md";

import type { ProductCategory } from "@/store/api/types/productCategory.types";
import {
  useDeleteProductCategoryMutation,
  useGetProductCategoriesQuery,
} from "@/store/api/productCategoriesApi";

import { productCategoryColumns } from "./productCategoryColumns";
import ProductCategoryModal from "./ProductCategoryModal";

export default function ProductCategoriesPage() {
  const [search, setSearch] = useState("");

  const { data, isLoading, isFetching, isError } =
    useGetProductCategoriesQuery();

  const allRows = useMemo(() => data?.data ?? [], [data?.data]);

  const filteredRows = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return allRows;
    return allRows.filter((c) => (c.name ?? "").toLowerCase().includes(q));
  }, [allRows, search]);

  const [openModal, setOpenModal] = useState(false);
  const [editItem, setEditItem] = useState<ProductCategory | null>(null);

  const [deleteCategory, { isLoading: deleting }] =
    useDeleteProductCategoryMutation();

  const deleteConfirm = useDeleteConfirm<ProductCategory>({
    onDelete: (item) => deleteCategory(item._id).unwrap(),
    isDeleting: deleting,
  });

  const columns = useMemo(
    () =>
      productCategoryColumns({
        onEdit: (row) => {
          setEditItem(row);
          setOpenModal(true);
        },
        onDelete: (row) => deleteConfirm.openDelete(row),
      }),
    [deleteConfirm]
  );

  if (isError) {
    return (
      <div className="bg-white border rounded-lg p-5 text-red-600">
        Failed to load product categories.
      </div>
    );
  }

  return (
    <div className="relative">
      <PageHeader
        title="Product Categories"
        actions={
          <Button
          className="text-sm 3xl:text-base"
            variant="teal"
            onClick={() => {
              setEditItem(null);
              setOpenModal(true);
            }}
          >
            <MdOutlineAdd size={20} />
            Create Category
          </Button>
        }
      />

      <div className="relative">
        <DataTable
          title="All categories"
          columns={columns}
          data={filteredRows}
          searchKey="name"
          pageSize={10000}
          searchPlaceholder="Search categories"
          onSearchChange={setSearch}
          showPagination={false}
        />

        <OverlayLoader show={isLoading || isFetching} />
      </div>

      <ProductCategoryModal
        open={openModal}
        onOpenChange={(v) => {
          setOpenModal(v);
          if (!v) setEditItem(null);
        }}
        editItem={editItem}
      />

      <ConfirmModal
        open={deleteConfirm.open}
        onOpenChange={deleteConfirm.onOpenChange}
        title="Delete category?"
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
