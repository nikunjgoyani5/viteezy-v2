"use client";

import React, { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { DataTable } from "@/components/ui/table";
import { testimonialColumns, TestimonialRow } from "./testimonialColumns";
import { FaPlus } from "react-icons/fa";
import { Button } from "@/components/ui/button";
import OverlayLoader from "@/components/common/OverlayLoader";
import ConfirmModal from "@/components/ui/confirmModal";
import { useDeleteConfirm } from "@/hooks/useDeleteConfirm";
import {
  useGetTestimonialsQuery,
  useUpdateTestimonialStatusMutation,
  useDeleteTestimonialMutation,
} from "@/store/api/testimonialApi";
import toast from "react-hot-toast";
import { PageHeader } from "../layout/PageHeader";
import Link from "next/link";
import { MdOutlineAdd } from "react-icons/md";

export default function TestimonialsComponent() {
  const router = useRouter();
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState(10);
  const [activeTab, setActiveTab] = useState("all");
  const [search, setSearch] = useState("");
  const [updatingId, setUpdatingId] = useState<string | null>(null);

  // Fetch testimonials from API
  const {
    data: testimonialsData,
    isLoading,
    isFetching,
  } = useGetTestimonialsQuery({
    page,
    limit,
    search: search || undefined,
    isActive: activeTab === "all" ? undefined : activeTab === "active" ? true : false,
  });

  // Mutations
  const [updateStatus] = useUpdateTestimonialStatusMutation();
  const [deleteTestimonial, { isLoading: isDeleting }] =
    useDeleteTestimonialMutation();

  // Delete confirmation
  const deleteConfirm = useDeleteConfirm<TestimonialRow>({
    onDelete: (item) => deleteTestimonial(item._id).unwrap(),
    isDeleting,
    onSuccess: () => toast.success("Testimonial deleted successfully"),
  });

  // Transform API data to table rows
  // No need for client-side filtering since API handles search and status filtering
  const data: TestimonialRow[] = useMemo(() => {
    if (!testimonialsData?.data?.testimonials) return [];

    return testimonialsData.data.testimonials.map((testimonial) => ({
      _id: testimonial._id,
      videoUrl: testimonial.videoUrl,
      videoThumbnail: testimonial.videoThumbnail,
      products: testimonial.products || [],
      isActive: testimonial.isActive,
    }));
  }, [testimonialsData]);

  const handleToggleStatus = async (row: TestimonialRow, next: boolean) => {
    setUpdatingId(row._id);
    try {
      await updateStatus({
        id: row._id,
        body: { isActive: next },
        listArgs: {
          page,
          limit,
          search: search || undefined,
          isActive: activeTab === "all" ? undefined : activeTab === "active" ? true : false,
        },
      }).unwrap();
      toast.success(
        `Testimonial ${next ? "activated" : "deactivated"} successfully`
      );
    } catch (error: any) {
      toast.error(
        error?.data?.message || "Failed to update testimonial status"
      );
    } finally {
      setUpdatingId(null);
    }
  };

  const handleEdit = (row: TestimonialRow) => {
    router.push(`/admin/cms-management/testimonials/${row._id}`);
  };

  const handleDelete = (row: TestimonialRow) => {
    deleteConfirm.openDelete(row);
  };

  const handleAdd = () => {
    router.push("/admin/cms-management/testimonials/create");
  };

  const handlePageChange = (newPage: number) => {
    setPage(newPage);
  };

  const handleLimitChange = (newLimit: number) => {
    setLimit(newLimit);
    setPage(1); // Reset to first page when changing limit
  };

  const columns = useMemo(
    () =>
      testimonialColumns({
        updatingId,
        onToggleStatus: handleToggleStatus,
        onEdit: handleEdit,
        onDelete: handleDelete,
      }),
    [updatingId]
  );

  return (
    <div className="relative">
      <PageHeader
        title="Testimonials"
        actions={
          <button
            onClick={handleAdd}
            className="flex text-sm 3xl:text-base items-center justify-center font-medium gap-2 px-4 py-2 bg-teal-green text-white rounded-md hover:bg-teal-green/90 cursor-pointer transition-colors"
          >
            <FaPlus className="w-3 h-3" /> Add Testimonials
          </button>
        }
      />

      <DataTable
        title="Testimonials"
        columns={columns}
        data={data}
        searchKey="videoUrl"
        searchPlaceholder="Searching all testimonials"
        tabs={[
          { value: "all", label: "All" },
          { value: "active", label: "Active" },
          { value: "inactive", label: "Inactive" },
        ]}
        activeTab={activeTab}
        onTabChange={setActiveTab}
        onSearchChange={(s) => {
          setSearch(s);
          setPage(1);
        }}
        showPagination={true}
        pageSize={limit}
        pagination={testimonialsData?.pagination}
        onPageChange={handlePageChange}
        onLimitChange={handleLimitChange}
        headerAction={
          <Button
            onClick={handleAdd}
            className="bg-teal-600 hover:bg-teal-700 text-white rounded-md px-4 py-2 flex items-center gap-2"
          >
            <FaPlus size={14} />
            Add Testimonials
          </Button>
        }
      />

      <OverlayLoader
        show={isLoading || isFetching || updatingId !== null || isDeleting}
      />

      <ConfirmModal
        open={deleteConfirm.open}
        onOpenChange={deleteConfirm.onOpenChange}
        title="Delete testimonial?"
        description={
          deleteConfirm.deleteItem
            ? `Are you sure you want to delete "${deleteConfirm.deleteItem.videoUrl
                .split("/")
                .pop()}"? This action cannot be undone.`
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
