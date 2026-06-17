"use client";

import React from "react";
import type { ColumnDef } from "@tanstack/react-table";
import Image from "next/image";
import { format } from "date-fns";
import { MdEdit, MdDelete } from "react-icons/md";
import Link from "next/link";

import { ActionMenu } from "@/components/ui/table/ActionMenu";
import { ToggleSwitch } from "@/components/ui/table";
import RichTextDisplay from "@/components/ui/inputs/RichTextDisplay";
import type { ProductListItem } from "@/store/api/types/products.types";
import { ROUTES } from "@/constants/routes";
import AppImage from "@/components/ui/appImage";

export const productColumns = (args: {
  onEdit: (row: ProductListItem) => void;
  onDelete: (row: ProductListItem) => void;
  onToggleStatus?: (row: ProductListItem, next: boolean) => void;
  updatingId?: string | null;
}): ColumnDef<ProductListItem>[] => [
  {
    accessorKey: "title",
    header: "Product",
    cell: ({ row }) => {
      const p = row.original;
      return (
        <Link
          href={`${ROUTES.PRODUCT_MANAGEMENT.PRODUCT}/${p._id}`}
          className="flex items-center gap-3 min-w-0 group"
        >
          <div className="h-12 w-12 rounded-lg overflow-hidden bg-slate-gray shrink-0">
            <AppImage
              // Always render an image; fall back to placeholder when productImage is missing
              src={p.productImage || "/images/noImage.webp"}
              fallbackSrc="/images/noImage.webp"
              alt={p.title}
              width={48}
              height={48}
              className="h-full w-full object-cover"
            />
          </div>
          <div className="min-w-0 max-w-[240px]">
            <div className="font-medium text-gray-900 truncate group-hover:underline group-hover:text-blue-600">
              {p.title}
            </div>
          </div>
        </Link>
      );
    },
  },
  {
    accessorKey: "variants",
    header: "Packaging Types",
    cell: ({ row }) => {
      const variants = row.original.variants ?? [];
      return (
        <span className="text-gray-700">
          {variants.length ? variants.join(", ") : "-"}
        </span>
      );
    },
  },
  {
    id: "shortDescription",
    header: "Description",
    cell: ({ row }) => (
      <RichTextDisplay 
        content={row.original.shortDescription ?? ""} 
        className="max-w-lg"
      />
    ),
  },
  {
    id: "category",
    header: "Category",
    cell: ({ row }) => (
      <span className="text-gray-700">
        {row.original.categories?.[0]?.name ?? "-"}
      </span>
    ),
  },
  {
    id: "status",
    header: "Status",
    cell: ({ row }) => {
      const product = row.original;
      const isUpdating = args.updatingId === product._id;

      return (
        <ToggleSwitch
          checked={!!product.status}
          disabled={isUpdating} 
          onChange={(checked) => args.onToggleStatus?.(product, checked)}
        />
      );
    },
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
