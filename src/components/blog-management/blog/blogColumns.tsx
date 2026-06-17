"use client";

import React from "react";
import type { ColumnDef } from "@tanstack/react-table";
import Image from "next/image";
import { format } from "date-fns";
import { MdDelete, MdEdit } from "react-icons/md";

import { ToggleSwitch } from "@/components/ui/table";
import { ActionMenu } from "@/components/ui/table/ActionMenu";

import type { Blog } from "@/store/api/types/blog.types";
import Link from "next/link";
import { ROUTES } from "@/constants/routes";
import AppImage from "@/components/ui/appImage";

export const blogColumns = (args: {
  onEdit: (row: Blog) => void;
  onDelete: (row: Blog) => void;
  onToggleStatus?: (row: Blog, next: boolean) => void;
  updatingId?: string | null;
}): ColumnDef<Blog>[] => [
  {
    accessorKey: "title",
    header: "Title",
    cell: ({ row }) => {
      const blog = row.original;

      return (
        <Link
          href={ROUTES.BLOG.BLOG + `/${blog._id}`}
          className="flex items-center gap-3 min-w-0 cursor-pointer group"
        >
          <div className="h-12 w-12 rounded-lg overflow-hidden bg-slate-gray shrink-0">
            {blog.coverImage ? (
              <AppImage
                src={blog.coverImage}
                alt={blog.title}
                width={48}
                height={48}
                className="h-full w-full object-cover"
              />
            ) : (
              <div className="h-full w-full" />
            )}
          </div>

          <div className="min-w-0 max-w-[240px]">
            <span className="font-medium text-gray-900 truncate block group-hover:underline group-hover:text-blue-500">
              {blog.title}
            </span>
          </div>
        </Link>
      );
    },
  },
  {
    id: "category",
    header: "Category",
    cell: ({ row }) => (
      <span className="text-gray-700">
        {row.original.categoryId?.title ?? "-"}
      </span>
    ),
  },
  {
    accessorKey: "isActive",
    header: "Status",
    cell: ({ row }) => {
      const blog = row.original;
      const rowLoading = args.updatingId === blog._id;

      return (
        <ToggleSwitch
          checked={blog.isActive}
          disabled={rowLoading}
          onChange={(checked) => args.onToggleStatus?.(blog, checked)}
        />
      );
    },
  },
  {
    accessorKey: "updatedAt",
    header: "Updated",
    cell: ({ row }) => (
      <span className="text-gray-700">
        {row.original.updatedAt
          ? format(new Date(row.original.updatedAt), "MMM dd, yyyy")
          : "-"}
      </span>
    ),
  },
  {
    accessorKey: "createdAt",
    header: "Created",
    cell: ({ row }) => (
      <span className="text-gray-700">
        {row.original.createdAt
          ? format(new Date(row.original.createdAt), "MMM dd, yyyy")
          : "-"}
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
    ),
  },
];
