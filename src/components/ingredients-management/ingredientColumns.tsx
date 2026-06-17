"use client";

import React from "react";
import type { ColumnDef } from "@tanstack/react-table";
import Image from "next/image";
import { format } from "date-fns";

import { ActionMenu, ToggleSwitch } from "@/components/ui/table";
import type { ProductIngredient } from "@/store/api/types/productIngredient.types";
import { MdDelete, MdEdit } from "react-icons/md";
import AppImage from "../ui/appImage";

export const ingredientColumns = (args: {
  onEdit?: (row: ProductIngredient) => void;
  onDelete?: (row: ProductIngredient) => void;
  onToggleStatus?: (row: ProductIngredient, next: boolean) => void;
  updatingId?: string | null;
}): ColumnDef<ProductIngredient>[] => [
  {
    accessorKey: "name",
    header: "Ingredient",
    cell: ({ row }) => {
      const ing = row.original;
      const imgUrl = ing.image?.url;

      return (
        <button
          type="button"
          onClick={() => args.onEdit?.(ing)}
          className="flex items-center gap-3 min-w-0 text-left group cursor-pointer group"
        >
          <div className="h-12 w-12 rounded-lg overflow-hidden bg-slate-gray shrink-0">
            {imgUrl ? (
              <AppImage
                src={imgUrl}
                alt={ing.name}
                width={48}
                height={48}
                className="h-full w-full object-cover"
              />
            ) : (
              <div className="h-full w-full" />
            )}
          </div>

          <div className="min-w-0">
            <div className="font-medium group-hover:text-blue-600 text-gray-900 truncate group-hover:underline">
              {ing.name}
            </div>
            {/* <div className="text-xs text-text-gray truncate">
              {ing.linkedProductCount ?? 0} linked
            </div> */}
          </div>
        </button>
      );
    },
  },
  {
    accessorKey: "description",
    header: "Description",
    cell: ({ row }) => (
      <span className="text-gray-700 max-w-140 line-clamp-2 3xl:line-clamp-1">
        {row.original.description || "-"}
      </span>
    ),
  },
  {
    accessorKey: "linkedProductCount",
    header: "Linked Products",
    cell: ({ row }) => (
      <span className="text-gray-700">
        {row.original.linkedProductCount ?? 0}
        {row.original.linkedProductCount === 1 ? " Product" : " Products"}
      </span>
    ),
  },
  {
    accessorKey: "isActive",
    header: "Status",
    cell: ({ row }) => {
      const ing = row.original;
      const rowLoading = args.updatingId === ing._id;

      return (
        <ToggleSwitch
          checked={ing.isActive}
          disabled={rowLoading}
          onChange={(checked) => args.onToggleStatus?.(ing, checked)}
        />
      );
    },
  },
  {
    id: "actions",
    header: () => <div className="text-center">Actions</div>,
    cell: ({ row }) => (
      <div className="flex justify-center">
        <ActionMenu
          items={[
            {
              label: "Edit",
              icon: <MdEdit className="h-4 w-4" />,
              onClick: () => args.onEdit?.(row.original),
            },
            {
              label: "Delete",
              icon: <MdDelete className="h-4 w-4" />,
              onClick: () => args.onDelete?.(row.original),
              danger: true,
            },
          ]}
        />
      </div>
    ),
  },
];
