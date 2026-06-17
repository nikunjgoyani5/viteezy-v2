"use client";

import React from "react";
import type { ColumnDef } from "@tanstack/react-table";
import Link from "next/link";
import { format, parseISO, isValid } from "date-fns";
import { MdEdit, MdDelete } from "react-icons/md";
import type { HeaderBanner } from "@/store/api/types/headerBanner.types";
import { ToggleSwitch } from "../ui/table";
import { ActionMenu } from "@/components/ui/table/ActionMenu";
import { ROUTES } from "@/constants/routes";

function formatDate(iso: string | null | undefined): string {
  if (!iso) return "—";
  try {
    const d = parseISO(iso);
    return isValid(d) ? format(d, "MMM dd, yyyy") : "—";
  } catch {
    return "—";
  }
}

function StatusBadge({ active }: { active: boolean }) {
  return (
    <span
      className={`inline-flex items-center px-2 h-7 rounded-sm text-xs 3xl:text-sm font-medium ${
        active ? "bg-parrot-green text-dark-green" : "bg-soft-red text-hard-red"
      }`}
    >
      {active ? "Active" : "Inactive"}
    </span>
  );
}

export const headerBannerColumns = ({
  onToggleStatus,
  onEdit,
  onDelete,
  updatingId,
}: {
  onToggleStatus: (id: string, nextStatus: boolean) => void;
  onEdit: (row: HeaderBanner) => void;
  onDelete: (row: HeaderBanner) => void;
  updatingId: string | null;
}): ColumnDef<HeaderBanner>[] => [
  {
    accessorKey: "text",
    header: "Banner Text",
    cell: ({ row }) => {
      const item = row.original;
      return (
        <Link
          href={`${ROUTES.HEADER_BANNERS}/${item._id}`}
          className="font-medium text-gray-900 line-clamp-2 group hover:underline hover:text-blue-600"
        >
          {item.text}
        </Link>
      );
    },
  },
  {
    accessorKey: "deviceType",
    header: "Device",
    cell: ({ row }) => (
      <span className="font-medium text-gray-900">
        {row.original.deviceType}
      </span>
    ),
  },
  {
    id: "schedule",
    header: "Schedule",
    cell: ({ row }) => {
      const { isScheduled, startDate, endDate } = row.original;
      if (!isScheduled) {
        return (
          <span className="text-xs 3xl:text-sm text-gray-600">Direct</span>
        );
      }
      return (
        <div className="flex flex-col text-xs 3xl:text-sm text-gray-700">
          <span>From: {formatDate(startDate)}</span>
          <span>To: {formatDate(endDate)}</span>
        </div>
      );
    },
  },
  {
    accessorKey: "isActive",
    header: "Status",
    cell: ({ row }) => {
      const item = row.original;
      const isToggling = !!updatingId;

      return (
        <ToggleSwitch
          checked={item.isActive}
          disabled={isToggling}
          onChange={(checked) => onToggleStatus(item._id, checked)}
        />
      );
    },
  },
  {
    accessorKey: "createdAt",
    header: "Created",
    cell: ({ row }) => (
      <span className="text-xs 3xl:text-sm text-gray-600">
        {formatDate(row.original.createdAt)}
      </span>
    ),
  },
  {
    id: "actions",
    header: "Actions",
    cell: ({ row }) => (
      <ActionMenu
        items={[
          {
            label: "Edit",
            icon: <MdEdit className="h-4 w-4" />,
            onClick: () => onEdit(row.original),
          },
          {
            label: "Delete",
            icon: <MdDelete className="h-4 w-4" />,
            onClick: () => onDelete(row.original),
            danger: true,
          },
        ]}
      />
    ),
  },
];
