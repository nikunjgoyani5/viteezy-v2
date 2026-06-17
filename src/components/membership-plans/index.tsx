"use client";

import React, { useMemo, useState } from "react";
import toast from "react-hot-toast";
import { useRouter } from "next/navigation";
import { DataTable } from "@/components/ui/table";
import { membershipColumns } from "./membershipColumns";
import { FaPlus } from "react-icons/fa";
import { RiEdit2Line } from "react-icons/ri";
import { IoTrashOutline } from "react-icons/io5";
import { Button } from "@/components/ui/button";
import OverlayLoader from "@/components/common/OverlayLoader";
import ConfirmModal from "@/components/ui/confirmModal";
import { useDeleteConfirm } from "@/hooks/useDeleteConfirm";
import {
  useGetMembershipPlansQuery,
  useUpdateMembershipPlanMutation,
  useDeleteMembershipPlanMutation,
} from "@/store/api/membershipPlansApi";
import type { MembershipPlanResponse } from "@/store/api/types/membershipPlan.types";
import { PageHeader } from "../layout/PageHeader";

export default function MembershipPlansComponent() {
  const router = useRouter();
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState(10);
  const [search, setSearch] = useState("");
  const [activeTab, setActiveTab] = useState("all");
  const [updatingId, setUpdatingId] = useState<string | null>(null);

  const { data, isFetching, isError } = useGetMembershipPlansQuery({
    page,
    limit,
    ...(search && { search }),
  });

  const [updatePlan] = useUpdateMembershipPlanMutation();
  const [deletePlan, { isLoading: deleting }] =
    useDeleteMembershipPlanMutation();
  const deleteConfirm = useDeleteConfirm<MembershipPlanResponse>({
    onDelete: (item) => deletePlan(item._id).unwrap(),
    isDeleting: deleting,
    onSuccess: () => toast.success("Membership plan deleted successfully"),
  });

  // Filter data locally based on isActive field
  const plansData = useMemo(() => {
    const allPlans = data?.data ?? [];

    if (activeTab === "active") {
      return allPlans.filter((plan) => plan.isActive === true);
    }
    if (activeTab === "inactive") {
      return allPlans.filter((plan) => plan.isActive === false);
    }
    return allPlans; // "all" - no filter
  }, [data?.data, activeTab]);

  const handleToggleStatus = async (
    row: MembershipPlanResponse,
    next: boolean
  ) => {
    setUpdatingId(row._id);
    try {
      await updatePlan({ id: row._id, data: { isActive: next } }).unwrap();
      toast.success(`Plan ${next ? "activated" : "deactivated"} successfully`);
    } catch (error: any) {
      toast.error(error?.data?.message || "Failed to update status");
      console.error("Failed to update status:", error);
    } finally {
      setUpdatingId(null);
    }
  };

  const handleEdit = (row: MembershipPlanResponse) => {
    router.push(`/admin/membership-plans/${row._id}`);
  };

  const handleDelete = (row: MembershipPlanResponse) =>
    deleteConfirm.openDelete(row);

  const handleAddPlan = () => {
    router.push("/admin/membership-plans/create");
  };

  const columns = useMemo(
    () =>
      membershipColumns({
        updatingId,
        onToggleStatus: handleToggleStatus,
        onEdit: handleEdit,
        onDelete: handleDelete,
      }),
    [updatingId, deleteConfirm]
  );

  if (isError) {
    return (
      <div className="bg-white border rounded-lg p-5 text-red-600">
        Failed to load membership plans.
      </div>
    );
  }

  return (
    <div className="relative">
      <PageHeader
        title="Membership Plans"
        actions={
          <button
            onClick={() => router.push("/admin/membership-plans/create")}
            className="text-sm 3xl:text-base flex items-center font-medium justify-center gap-2 px-4 py-2 bg-teal-green text-white rounded-md hover:bg-teal-green/90 cursor-pointer transition-colors"
          >
            <FaPlus className="w-3 h-3" /> Add Plan
          </button>
        }
      />
      <DataTable
        title="Membership Plans"
        columns={columns}
        data={plansData}
        searchKey="name"
        searchPlaceholder="Searching all membership"
        tabs={[
          { value: "all", label: "All Plan" },
          { value: "active", label: "Active" },
          { value: "inactive", label: "Inactive" },
        ]}
        activeTab={activeTab}
        onTabChange={setActiveTab}
        onSearchChange={(s) => {
          setSearch(s);
          setPage(1);
        }}
        showPagination={false}
        headerAction={
          <Button
            onClick={handleAddPlan}
            className="bg-teal-600 hover:bg-teal-700 text-white rounded-md px-4 py-2 flex items-center gap-2"
          >
            <FaPlus size={14} />
            Add Plan
          </Button>
        }
      />
      <OverlayLoader show={isFetching} />

      <ConfirmModal
        open={deleteConfirm.open}
        onOpenChange={deleteConfirm.onOpenChange}
        title="Delete membership plan?"
        description={
          deleteConfirm.deleteItem?.name
            ? `Are you sure you want to delete "${deleteConfirm.deleteItem.name}"? This action cannot be undone.`
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
