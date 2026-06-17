"use client";

import React, { useState, useMemo } from "react";
import { ColumnDef } from "@tanstack/react-table";
import { DataTable } from "@/components/ui/table";
import { ToggleSwitch } from "@/components/ui/table/ToggleSwitch";
import { ActionMenu } from "@/components/ui/table/ActionMenu";
import { Checkbox } from "@/components/ui/table/Checkbox";
import { useRouter } from "next/navigation";
import toast from "react-hot-toast";
import {
  useGetUsersQuery,
  useUpdateUserStatusMutation,
} from "@/store/api/userApi";
import { User } from "@/store/api/types/user.types";
import { PageHeader } from "@/components/layout/PageHeader";

interface TableUser {
  _id: string;
  customerName: string;
  email: string;
  phone: string;
  memberId: string;
  registrationDate: string;
  status: boolean;
  userType: "New User" | "Recurring User";
}

const UserManagementPage = () => {
  const router = useRouter();
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState(10);
  const [userType, setUserType] = useState<
    "New User" | "Recurring User" | undefined
  >();
  const [isActive, setIsActive] = useState<boolean | undefined>();
  const [search, setSearch] = useState("");
  const [registrationDate, setRegistrationDate] = useState<
    string | undefined
  >();

  // Fetch users from API
  const {
    data: usersData,
    isLoading,
    isError,
  } = useGetUsersQuery({
    page,
    limit,
    userType,
    isActive,
    search,
    registrationDate,
  });

  const [updateUserStatus, { isLoading: isUpdatingStatus }] =
    useUpdateUserStatusMutation();

  // Transform API data to match table format
  const tableData: TableUser[] = useMemo(() => {
    if (!usersData?.data) return [];
    const dashIfEmpty = (v?: string | null) =>
      v && v.trim().length > 0 ? v : "-";
    const safeFormatDate = (dateStr?: string) => {
      if (!dateStr) return "-";
      const date = new Date(dateStr);
      if (isNaN(date.getTime())) return "-";
      return date.toLocaleDateString("en-US", {
        year: "numeric",
        month: "short",
        day: "numeric",
      });
    };

    return usersData.data.map((user: User) => ({
      _id: user._id,
      customerName: `${dashIfEmpty(user.firstName)} ${dashIfEmpty(
        user.lastName
      )}`.trim(),
      email: dashIfEmpty(user.email),
      phone: dashIfEmpty(user.phone),
      memberId: dashIfEmpty(user.memberId),
      registrationDate: safeFormatDate(user.registeredAt),
      status: user.status.isActive,
      userType: user.status.userType,
    }));
  }, [usersData]);

  const userColumns: ColumnDef<TableUser>[] = [
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
      accessorKey: "customerName",
      header: "Customer name",
      cell: ({ row }) => (
        <button
          onClick={() =>
            router.push(`/admin/user-management/${row.original._id}`)
          }
          className="font-medium text-nowrap! text-black hover:text-blue-600 hover:underline transition-colors text-left"
        >
          {row.getValue("customerName")}
        </button>
      ),
    },
    {
      accessorKey: "email",
      header: "Email",
      cell: ({ row }) => (
        <span className="font-medium text-black">{row.getValue("email")}</span>
      ),
    },
    {
      accessorKey: "phone",
      header: "Phone",
      cell: ({ row }) => (
        <span className="font-medium text-nowrap! text-black">
          {row.getValue("phone")}
        </span>
      ),
    },
    {
      accessorKey: "memberId",
      header: "Member ID",
      cell: ({ row }) => (
        <span className="font-medium text-nowrap! text-black">
          {row.getValue("memberId")}
        </span>
      ),
    },
    {
      accessorKey: "registrationDate",
      header: "Registration date",
      cell: ({ row }) => (
        <span className="font-medium text-nowrap! text-black">
          {row.getValue("registrationDate")}
        </span>
      ),
      filterFn: "includesString",
    },
    {
      accessorKey: "status",
      header: "Status",
      cell: ({ row }) => (
        <ToggleSwitch
          checked={row.getValue("status")}
          disabled={isUpdatingStatus}
          onChange={async (checked) => {
            const userId = row.original._id;
            try {
              await updateUserStatus({ userId, isActive: checked }).unwrap();
              toast.success(`User status ${checked ? 'activated' : 'deactivated'} successfully`);
            } catch (err: any) {
              toast.error(err?.data?.message || "Failed to update user status");
              console.error("Failed to update user status", err);
            }
          }}
        />
      ),
      filterFn: (row, id, value) => {
        if (!value) return true;
        return value === "active"
          ? row.getValue(id) === true
          : row.getValue(id) === false;
      },
    },
    {
      accessorKey: "userType",
      header: "User Type",
      cell: ({ row }) => {
        const userType = row.getValue("userType") as string;
        const isNewUser = userType === "New User";
        return (
          <span
            className={`inline-flex items-center px-3 py-1 text-nowrap! rounded-md text-xs font-medium ${isNewUser
                ? "bg-parrot-green text-dark-green"
                : "bg-yellow text-dark-yellow"
              }`}
          >
            {userType}
          </span>
        );
      },
      filterFn: "equals",
    },
    {
      id: "actions",
      header: () => <div className="text-center">Actions</div>,
      cell: ({ row }) => {
        const user = row.original;
        const isActiveNow = !!user.status;
        const actionLabel = isActiveNow ? "Block" : "Unblock";
        const nextActiveState = !isActiveNow;
        return (
          <div className="flex justify-center">
            <ActionMenu
              items={[
                {
                  label: actionLabel,
                  onClick: async () => {
                    try {
                      await updateUserStatus({
                        userId: user._id,
                        isActive: nextActiveState,
                      }).unwrap();
                      console.log(
                        `User ${user._id} status updated to`,
                        nextActiveState
                      );
                      toast.success(`User ${nextActiveState ? 'activated' : 'deactivated'} successfully`);
                    } catch (err: any) {
                      toast.error(err?.data?.message || "Failed to update user status");
                      console.error("Failed to update user status", err);
                    }
                  },
                  danger: isActiveNow,
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
      key: "isActive",
      label: "Status",
      type: "select" as const,
      options: [
        { value: "true", label: "Active" },
        { value: "false", label: "Inactive" },
      ],
    },
    {
      key: "userType",
      label: "User Type",
      type: "select" as const,
      options: [
        { value: "New User", label: "New User" },
        { value: "Recurring User", label: "Recurring User" },
      ],
    },
    {
      key: "registrationDate",
      label: "Registration Date",
      type: "date" as const,
    },
  ];

  const handleFilterChange = (filters: Record<string, string>) => {
    if (filters.userType) {
      setUserType(filters.userType as "New User" | "Recurring User");
    } else {
      setUserType(undefined);
    }

    if (filters.isActive) {
      setIsActive(filters.isActive === "true");
    } else {
      setIsActive(undefined);
    }

    if (filters.registrationDate) {
      // Expecting YYYY-MM-DD from the date input
      setRegistrationDate(filters.registrationDate);
    } else {
      setRegistrationDate(undefined);
    }
  };

  const handleSearchChange = (searchValue: string) => {
    setSearch(searchValue);
    setPage(1); // Reset to first page on search
  };

  const handlePageChange = (newPage: number) => {
    setPage(newPage);
  };

  const handleLimitChange = (newLimit: number) => {
    setLimit(newLimit);
    setPage(1); // Reset to first page when changing limit
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-500">Loading users...</div>
      </div>
    );
  }

  if (isError) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-red-500">
          Error loading users. Please try again.
        </div>
      </div>
    );
  }

  return (
    <div>
      <PageHeader title="User Management" />
      <DataTable
        columns={userColumns}
        data={tableData}
        searchKey="customerName"
        searchPlaceholder="Search customers by name or email"
        advancedFilters={advancedFilters}
        pageSize={limit}
        pagination={usersData?.pagination}
        onPageChange={handlePageChange}
        onLimitChange={handleLimitChange}
        onFilterChange={handleFilterChange}
        onSearchChange={handleSearchChange}
      />
    </div>
  );
};

export default UserManagementPage;
