"use client";

import React from "react";
import type { ColumnDef } from "@tanstack/react-table";
import Image from "next/image";
import { format } from "date-fns";
import { MdDelete, MdEdit } from "react-icons/md";

import { ActionMenu } from "@/components/ui/table/ActionMenu";
import { ToggleSwitch } from "@/components/ui/table";

import type { ProductCategory } from "@/store/api/types/productCategory.types";

export const productCategoryColumns = (args: {
  onEdit: (row: ProductCategory) => void;
  onDelete: (row: ProductCategory) => void;
}): ColumnDef<ProductCategory>[] => [
    {
      accessorKey: "name",
      header: "Title",
      cell: ({ row }) => {
        const c = row.original;
        const img = c.image?.url || c.icon;

        return (
          <div className="flex items-center gap-3 min-w-0">
            {/* <div className="h-12 w-12 rounded-lg overflow-hidden bg-slate-gray shrink-0">
            {img ? (
              <Image
                src={img}
                alt={c.name}
                width={48}
                height={48}
                className="h-full w-full object-cover"
              />
            ) : (
              <div className="h-full w-full" />
            )}
          </div> */}

            <div className="min-w-0">
              <div className="font-medium text-gray-900 truncate">{c.name}</div>
              {/* <div className="text-xs text-text-gray truncate">{c.slug}</div> */}
            </div>
          </div>
        );
      },
    },
    {
      accessorKey: "productCount",
      header: "Products",
      cell: ({ row }) => (
        <span className="text-gray-700">{row.original.productCount ?? 0}</span>
      ),
    },
    //   {
    //     accessorKey: "isActive",
    //     header: "Status",
    //     cell: ({ row }) => (
    //       <ToggleSwitch
    //         checked={row.original.isActive}
    //         onChange={(checked) => {
    //           console.log("toggle category status", row.original._id, checked);
    //         }}
    //       />
    //     ),
    //   },
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
          {row.original.updatedAt
            ? format(new Date(row.original.createdAt), "MMM dd, yyyy")
            : "-"}
        </span>
      ),
    },
    {
      id: "actions",
      header: ({ column }) => <div className="text-center">Actions</div>,
      size: 100,
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
