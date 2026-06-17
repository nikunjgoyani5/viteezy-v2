"use client";

import React, { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { MdOutlineAdd } from "react-icons/md";

import { DataTable } from "@/components/ui/table";
import { PageHeader } from "@/components/layout/PageHeader";
import { Button } from "@/components/ui/button";
import ConfirmModal from "@/components/ui/confirmModal";
import OverlayLoader from "@/components/common/OverlayLoader";
import { useDeleteConfirm } from "@/hooks/useDeleteConfirm";

import { ROUTES } from "@/constants/routes";
import type { Blog, GetBlogsParams } from "@/store/api/types/blog.types";
import {
  useGetBlogsQuery,
  useDeleteBlogMutation,
  useUpdateBlogStatusMutation,
} from "@/store/api/blogApi";
import { blogColumns } from "./blogColumns";

import { useUrlTableState } from "@/hooks/useUrlTableState";
import { useDebounce } from "@/hooks/useDebounce";

export default function BlogPage() {
  const router = useRouter();

  const { page, limit, onPageChange, onLimitChange } = useUrlTableState({
    defaultPage: 1,
    defaultLimit: 10,
  });

  const [search, setSearch] = useState("");
  const debouncedSearch = useDebounce(search, 300);
  const [activeTab, setActiveTab] = useState("all");

  const statusParam = useMemo(() => {
    if (activeTab === "active") return true;
    if (activeTab === "inactive") return false;
    return undefined; // "all" - no filter
  }, [activeTab]);

  const listArgs = useMemo(
    () =>
      ({
        page,
        limit,
        ...(debouncedSearch ? { search: debouncedSearch } : {}),
        ...(statusParam !== undefined && { isActive: statusParam }),
      } as GetBlogsParams),
    [page, limit, debouncedSearch, statusParam]
  );

  const { data, isError, isLoading, isFetching } = useGetBlogsQuery(listArgs);
  const rows = useMemo(() => data?.data?.blogs ?? [], [data?.data?.blogs]);

  const [deleteBlog, { isLoading: deleting }] = useDeleteBlogMutation();
  const deleteConfirm = useDeleteConfirm<Blog>({
    onDelete: (item) => deleteBlog(item._id).unwrap(),
    isDeleting: deleting,
  });

  const [updateStatus] = useUpdateBlogStatusMutation();
  const [updatingId, setUpdatingId] = useState<string | null>(null);

  const columns = useMemo(
    () =>
      blogColumns({
        onEdit: (row) => router.push(`${ROUTES.BLOG.BLOG}/${row._id}`),
        onDelete: (row) => deleteConfirm.openDelete(row),
        onToggleStatus: async (row, next) => {
          try {
            setUpdatingId(row._id);
            await updateStatus({
              id: row._id,
              isActive: next,
              listArgs,
            }).unwrap();
          } catch (e) {
            console.error(e);
          } finally {
            setUpdatingId(null);
          }
        },
        updatingId,
      }),
    [router, updateStatus, listArgs, updatingId, deleteConfirm]
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
        Failed to load blogs.
      </div>
    );
  }

  return (
    <div>
      <PageHeader
        title="Blog Management"
        actions={
          <Link href={ROUTES.BLOG.NEW_BLOG}>
            <Button variant="teal" className="text-sm 3xl:text-base">
              <MdOutlineAdd size={20} />
              Add Blog
            </Button>
          </Link>
        }
      />

      <div className="relative">
        <DataTable
          title="All Blogs"
          tabs={tabs}
          activeTab={activeTab}
          onTabChange={handleTabChange}
          columns={columns}
          data={rows}
          searchKey="title"
          searchPlaceholder="Searching all blog"
          pageSize={limit}
          pagination={data?.pagination}
          onPageChange={onPageChange}
          onLimitChange={(l) => onLimitChange(l)}
          onSearchChange={(s) => {
            setSearch(s);
            onPageChange(1);
          }}
        />

        <OverlayLoader show={isLoading || isFetching} />
      </div>

      <ConfirmModal
        open={deleteConfirm.open}
        onOpenChange={deleteConfirm.onOpenChange}
        title="Delete blog?"
        description={
          deleteConfirm.deleteItem?.title
            ? `Are you sure you want to delete “${deleteConfirm.deleteItem.title}”? This action cannot be undone.`
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
