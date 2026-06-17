"use client";

import React, { useMemo, useState } from "react";
import toast from "react-hot-toast";
import { PageHeader } from "@/components/layout/PageHeader";
import { Button } from "@/components/ui/button";
import { DataTable } from "@/components/ui/table";
import { MdOutlineAdd } from "react-icons/md";

import type { BlogCategory } from "@/store/api/types/blogCategory.types";
import {
  useGetBlogCategoriesQuery,
  useDeleteBlogCategoryMutation,
  useUpdateBlogCategoryMutation,
} from "@/store/api/blogCategoryApi";
import { blogCategoryColumns } from "./blogCategoryColumns";

import BlogCategoryModal from "./BlogCategoryModal";
import ConfirmModal from "@/components/ui/confirmModal";
import OverlayLoader from "@/components/common/OverlayLoader";
import { useDeleteConfirm } from "@/hooks/useDeleteConfirm";

export default function BlogCategoryPage() {
  const [search, setSearch] = useState("");

  const { data, isError, isLoading, isFetching } =
    useGetBlogCategoriesQuery(undefined);

  const allRows = useMemo(() => data?.data ?? [], [data?.data]);

  const filteredRows = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return allRows;
    return allRows.filter((c) => (c.title ?? "").toLowerCase().includes(q));
  }, [allRows, search]);

  const [modalOpen, setModalOpen] = useState(false);
  const [editItem, setEditItem] = useState<BlogCategory | null>(null);

  const [deleteCategory, { isLoading: deleting }] =
    useDeleteBlogCategoryMutation();
  const deleteConfirm = useDeleteConfirm<BlogCategory>({
    onDelete: (item) => deleteCategory(item._id).unwrap(),
    isDeleting: deleting,
    onSuccess: () => toast.success("Category deleted successfully"),
  });
  const [updateCategory] = useUpdateBlogCategoryMutation();

  const [updatingId, setUpdatingId] = useState<string | null>(null);

  const columns = useMemo(
    () =>
      blogCategoryColumns({
        onEdit: (row) => {
          setEditItem(row);
          setModalOpen(true);
        },
        onDelete: (row) => deleteConfirm.openDelete(row),
        onToggleStatus: async (row, checked) => {
          setUpdatingId(row._id);
          try {
            await updateCategory({
              id: row._id,
              body: { title: row.title, isActive: checked },
            }).unwrap();
            toast.success(
              `Category ${checked ? "activated" : "deactivated"} successfully`
            );
          } catch (error: any) {
            toast.error(error?.data?.message || "Failed to update status");
            console.error("Failed to update status:", error);
          } finally {
            setUpdatingId(null);
          }
        },
        updatingId,
      }),
    [updateCategory, updatingId, deleteConfirm.openDelete]
  );

  return (
    <div>
      <PageHeader
        title="Category"
        actions={
          <Button
            className="text-sm 3xl:text-base"
            variant="teal"
            onClick={() => {
              setEditItem(null); // create mode
              setModalOpen(true);
            }}
          >
            <MdOutlineAdd size={20} />
            Create category
          </Button>
        }
      />

      <BlogCategoryModal
        open={modalOpen}
        onOpenChange={(v) => {
          setModalOpen(v);
          if (!v) setEditItem(null);
        }}
        editItem={editItem}
      />

      <ConfirmModal
        open={deleteConfirm.open}
        onOpenChange={deleteConfirm.onOpenChange}
        title="Delete category?"
        description={
          deleteConfirm.deleteItem?.title
            ? `Are you sure you want to delete “${deleteConfirm.deleteItem.title}”? This action cannot be undone.`
            : "This action cannot be undone."
        }
        error={deleteConfirm.deleteError}
        confirmText="Delete"
        cancelText="Cancel"
        loading={deleting}
        variant="danger"
        onConfirm={deleteConfirm.onConfirm}
      />

      {isError ? (
        <div className="bg-white border rounded-lg p-5 text-red-600">
          Failed to load categories.
        </div>
      ) : (
        <div className="relative">
          <DataTable
            title="All Categories"
            columns={columns}
            data={filteredRows}
            pageSize={10000}
            searchKey="title"
            searchPlaceholder="Searching all category"
            onSearchChange={setSearch}
            showPagination={false}
          />
          <OverlayLoader show={isLoading || isFetching} />
        </div>
      )}
    </div>
  );
}
