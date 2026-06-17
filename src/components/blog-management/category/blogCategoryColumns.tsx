"use client";

import React from "react";
import type { ColumnDef } from "@tanstack/react-table";
import { ActionMenu } from "@/components/ui/table/ActionMenu";
import { MdDelete, MdEdit } from "react-icons/md";
import type { BlogCategory } from "@/store/api/types/blogCategory.types";
import { format } from "date-fns";
import { ToggleSwitch } from "@/components/ui/table";

export const blogCategoryColumns = (args: {
  onEdit: (row: BlogCategory) => void;
  onDelete: (row: BlogCategory) => void;
  onToggleStatus?: (row: BlogCategory, checked: boolean) => void;
  updatingId?: string | null;
}): ColumnDef<BlogCategory>[] => [
  {
    accessorKey: "title",
    header: "Title",
    cell: ({ row }) => (
      <span className="font-medium text-gray-900">{row.getValue("title")}</span>
    ),
  },
  {
    accessorKey: "slug",
    header: "Slug",
    cell: ({ row }) => (
      <span className="text-gray-700">{row.getValue("slug")}</span>
    ),
  },
  {
    accessorKey: "isActive",
    header: "Status",
    cell: ({ row }) => {
      const category = row.original;
      const isUpdating = args.updatingId === category._id;
      return (
        <ToggleSwitch
          checked={row.getValue("isActive")}
          disabled={isUpdating}
          onChange={(checked) => args.onToggleStatus?.(category, checked)}
        />
      );
    },
  },
  {
    accessorKey: "updatedAt",
    header: "Updated",
    cell: ({ row }) => (
      <span className="text-gray-700">
        {format(row.getValue("updatedAt"), "MMM dd, yyyy")}
      </span>
    ),
  },
  {
    accessorKey: "createdAt",
    header: "Created",
    cell: ({ row }) => (
      <span className="text-gray-700">
        {format(row.getValue("createdAt"), "MMM dd, yyyy")}
      </span>
    ),
  },
  {
    id: "actions",
    header: ({ column }) => <div className="text-center">Actions</div>,
    cell: ({ row }) => (
      <div className="flex justify-center">
        <ActionMenu
          items={[
            {
              label: "Edit",
              icon: <MdEdit className="h-4 w-4" />,
              onClick: () => args.onEdit(row.original),
            },
            {
              label: "Delete",
              icon: <MdDelete className="h-4 w-4" />,
              onClick: () => args.onDelete(row.original),
              danger: true,
            },
          ]}
        />
      </div>
    ),
  },
];
