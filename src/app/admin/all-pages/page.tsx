"use client";

import React, { useState, useMemo } from "react";
import { useRouter } from "next/navigation";
import { ColumnDef } from "@tanstack/react-table";
import { DataTable } from "@/components/ui/table";
import { ToggleSwitch } from "@/components/ui/table/ToggleSwitch";
import { ActionMenu } from "@/components/ui/table/ActionMenu";
import { Checkbox } from "@/components/ui/table/Checkbox";
import toast from "react-hot-toast";
import OverlayLoader from "@/components/common/OverlayLoader";
import { RiEdit2Line } from "react-icons/ri";
import { IoTrashOutline } from "react-icons/io5";
import { FaPlus } from "react-icons/fa";
import {
  useGetStaticPagesQuery,
  useUpdateStaticPageStatusMutation,
  useDeleteStaticPageMutation,
} from "@/store/api/staticPagesApi";
import { formatDistanceToNow } from "date-fns";
import { PageHeader } from "@/components/layout/PageHeader";

interface PageData {
  _id: string;
  title: string;
  description: string;
  status: boolean;
  updated: string;
  isSystemPage: boolean;
  route?: string;
}

const AllPagesPage = () => {
  const router = useRouter();
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState(10);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<boolean | undefined>();
  const [activeTab, setActiveTab] = useState("all");

  // Map tab to status for API
  const statusParam = useMemo(() => {
    if (activeTab === "visible") return "Published";
    if (activeTab === "hidden") return "Unpublished";
    return undefined; // "all" - no filter
  }, [activeTab]);

  const { data, isFetching, isError, isLoading } = useGetStaticPagesQuery({
    page,
    limit,
    ...(search && { search }),
    ...(statusParam && { status: statusParam }),
  });
  const [updateStatus, { isLoading: isUpdatingStatus }] =
    useUpdateStaticPageStatusMutation();
  const [deletePage] = useDeleteStaticPageMutation();

  const pagesData: PageData[] = useMemo(() => {
    const items = data?.data ?? [];
    return items.map((item) => {
      const tempDiv =
        typeof window !== "undefined" ? document.createElement("div") : null;
      let plain = "";
      if (tempDiv) {
        tempDiv.innerHTML = item.content || "";
        plain = tempDiv.textContent || tempDiv.innerText || "";
      }
      const desc = plain.length > 140 ? `${plain.slice(0, 140)}...` : plain;
      return {
        _id: item._id,
        title: item.title,
        description: desc,
        status: (item.status || "").toLowerCase() === "published",
        updated: item.updatedAt
          ? `${formatDistanceToNow(new Date(item.updatedAt), {
            addSuffix: true,
          })}`
          : "-",
        isSystemPage: item.isSystemPage || false,
        route: item.route,
      } as PageData;
    });
  }, [data]);

  const columns: ColumnDef<PageData>[] = [
    {
      id: "select",
      header: ({ table }) => (
        <Checkbox
          checked={table.getIsAllPageRowsSelected()}
          indeterminate={table.getIsSomePageRowsSelected()}
          onChange={(value) => table.toggleAllPageRowsSelected(!!value)}
        />
      ),
      cell: ({ row }) => (
        <Checkbox
          checked={row.getIsSelected()}
          onChange={(value) => row.toggleSelected(!!value)}
        />
      ),
      enableSorting: false,
      enableHiding: false,
    },
    {
      accessorKey: "title",
      header: "Title",
      cell: ({ row }) => (
        <span className="font-medium text-black">{row.getValue("title")}</span>
      ),
    },
    {
      accessorKey: "description",
      header: "Description",
      cell: ({ row }) => (
        <span className="font-normal text-gray-600 max-w-md truncate block">
          {row.getValue("description")}
        </span>
      ),
    },
    {
      accessorKey: "status",
      header: "Status",
      cell: ({ row }) => {
        const pageData = row.original;
        return (
          <ToggleSwitch
            checked={row.getValue("status")}
            disabled={pageData.isSystemPage}
            onChange={async (checked) => {
              try {
                await updateStatus({
                  id: pageData._id,
                  body: { status: checked ? "Published" : "Unpublished" },
                }).unwrap();
                toast.success(`Page ${checked ? 'published' : 'unpublished'} successfully`);
              } catch (error: any) {
                toast.error(error?.data?.message || "Failed to update status");
                console.error("Failed to update status:", error);
              }
            }}
          />
        );
      },
      filterFn: (row, id, value) => {
        if (!value) return true;
        return value === "active"
          ? row.getValue(id) === true
          : row.getValue(id) === false;
      },
    },
    {
      accessorKey: "updated",
      header: "Updated",
      cell: ({ row }) => (
        <span className="font-medium text-nowrap text-black">
          {row.getValue("updated")}
        </span>
      ),
    },
    {
      id: "actions",
      header: () => <div className="text-center">Actions</div>,
      cell: ({ row }) => {
        const pageData = row.original;
        return (
          <div className="flex justify-center">
            <ActionMenu
              items={[
                {
                  label: "Edit",
                  icon: <RiEdit2Line className="w-4.5 h-4.5" />,
                  onClick: () => {
                    if (pageData.isSystemPage && pageData.route) {
                      router.push(pageData.route);
                    } else {
                      router.push(`/admin/all-pages/${pageData._id}`);
                    }
                  },
                },
                {
                  label: "Delete",
                  icon: <IoTrashOutline className="w-4.5 h-4.5" />,
                  onClick: async () => {
                    try {
                      await deletePage(pageData._id).unwrap();
                      toast.success("Page deleted successfully");
                    } catch (error: any) {
                      toast.error(error?.data?.message || "Failed to delete page");
                      console.error("Failed to delete page:", error);
                    }
                  },
                  danger: true,
                  disabled: pageData.isSystemPage,
                },
              ]}
            />
          </div>
        );
      },
    },
  ];

  const advancedFilters = [
    {
      key: "status",
      label: "Status",
      type: "select" as const,
      options: [
        { value: "true", label: "Active" },
        { value: "false", label: "Inactive" },
      ],
    },
  ];

  const handleFilterChange = (filters: Record<string, string>) => {
    if (filters.status) {
      setStatusFilter(filters.status === "true");
    } else {
      setStatusFilter(undefined);
    }
  };

  const handleSearchChange = (searchValue: string) => {
    setSearch(searchValue);
    setPage(1);
  };

  const handlePageChange = (newPage: number) => {
    setPage(newPage);
  };

  const handleLimitChange = (newLimit: number) => {
    setLimit(newLimit);
    setPage(1);
  };

  const handleTabChange = (tab: string) => {
    setActiveTab(tab);
    setPage(1); // Reset to first page when changing tabs
  };

  // Define tabs
  const tabs = [
    { value: "all", label: "All" },
    { value: "visible", label: "Visible" },
    { value: "hidden", label: "Hidden" },
  ];

  const showLoader = isFetching || isLoading || isUpdatingStatus;

  const paginationData = data?.pagination ?? {
    total: 0,
    page,
    pages: 0,
    limit,
    hasNext: false,
    hasPrev: false,
  };

  return (
    <div className="relative">
      <PageHeader
        title="All Pages"
        actions={
          <button
            onClick={() => router.push("/admin/all-pages/create")}
            className="text-sm 3xl:text-base flex items-center font-medium justify-center gap-2 px-4 py-2 bg-teal-green text-white rounded-md hover:bg-teal-green/90 cursor-pointer transition-colors"
          >
            <FaPlus className="w-3 h-3" /> Create Page
          </button>
        }
      />
      <DataTable
        title="All Pages"
        tabs={tabs}
        activeTab={activeTab}
        onTabChange={handleTabChange}
        columns={columns}
        data={pagesData}
        searchKey="title"
        searchPlaceholder="Searching all pages"
        advancedFilters={advancedFilters}
        pageSize={limit}
        pagination={paginationData}
        onPageChange={handlePageChange}
        onLimitChange={handleLimitChange}
        onFilterChange={handleFilterChange}
        onSearchChange={handleSearchChange}
      />
      <OverlayLoader show={showLoader} />
    </div>
  );
};

export default AllPagesPage;
