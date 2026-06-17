"use client";

import React, { useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { ColumnDef } from "@tanstack/react-table";
import { MdDelete, MdEdit } from "react-icons/md";

import AppImage from "@/components/ui/appImage";
import RichTextDisplay from "@/components/ui/inputs/RichTextDisplay";
import {
  ActionMenu,
  DataTable,
  ToggleSwitch,
} from "@/components/ui/table";
import ConfirmModal from "@/components/ui/confirmModal";
import { useDeleteConfirm } from "@/hooks/useDeleteConfirm";

import type { Product } from "@/store/api/types/dashboard.types";
import {
  useDeleteProductMutation,
  useUpdateProductStatusMutation,
} from "@/store/api/productsApi";
import { ROUTES } from "@/constants/routes";

const ProductTable = ({ data }: { data: Array<Product> }) => {
  const router = useRouter();

  const [updateStatus] = useUpdateProductStatusMutation();
  const [deleteProduct, { isLoading: deleting }] = useDeleteProductMutation();

  const [updatingId, setUpdatingId] = useState<string | null>(null);

  const deleteConfirm = useDeleteConfirm<Product>({
    onDelete: (item) => deleteProduct(item.productId).unwrap(),
    isDeleting: deleting,
  });

  const columns = useMemo<ColumnDef<Product>[]>(
    () => [
      {
        accessorKey: "productName",
        header: "Product",
        cell: ({ row }) => {
          const p = row.original;
          const id = p.productId;

          return (
            <Link
              href={`${ROUTES.PRODUCT_MANAGEMENT.PRODUCT}/${id}`}
              className="flex items-center gap-3 group min-w-0"
            >
              <div className="h-12 w-12 rounded-lg overflow-hidden bg-gray-100 shrink-0">
                <AppImage
                  src={p.productImage}
                  alt={p.slug}
                  width={48}
                  height={48}
                  className="h-full w-full object-cover"
                />
              </div>
              <span className="font-medium text-gray-900 truncate group-hover:underline group-hover:text-blue-600">
                {p.productName}
              </span>
            </Link>
          );
        },
      },
      {
        accessorKey: "description",
        header: "Description",
        cell: ({ row }) => (
          <RichTextDisplay 
            content={row.original.description || ""} 
            className="max-w-xs"
          />
        ),
      },
      {
        accessorKey: "category",
        header: "Category",
        cell: ({ row }) => (
          <span className="text-gray-700">{row.original.category}</span>
        ),
      },
      {
        id: "status",
        header: "Status",
        cell: ({ row }) => {
          const id = row.original.productId;
          const isUpdating = updatingId === id;

          return (
            <ToggleSwitch
              checked={!!row.original.status}
              disabled={isUpdating}
              onChange={async (checked) => {
                setUpdatingId(id);
                try {
                  await updateStatus({ id, enabled: checked }).unwrap();
                } catch (error) {
                  console.error(error);
                } finally {
                  setUpdatingId(null);
                }
              }}
            />
          );
        },
      },
      // {
      //   id: "actions",
      //   header: "Actions",
      //   cell: ({ row }) => (
      //     <ActionMenu
      //       items={[
      //         {
      //           label: "Edit",
      //           icon: <MdEdit className="h-4 w-4" />,
      //           onClick: () =>
      //             router.push(
      //               `${ROUTES.PRODUCT_MANAGEMENT.PRODUCT}/${row.original.productId}`
      //             ),
      //         },
      //         {
      //           label: "Delete",
      //           icon: <MdDelete className="h-4 w-4" />,
      //           danger: true,
      //           onClick: () => {
      //             setDeleteItem(row.original);
      //             setConfirmOpen(true);
      //           },
      //         },
      //       ]}
      //     />
      //   ),
      // },
    ],
    [router, updateStatus, updatingId]
  );

  return (
    <div>
      <DataTable
        columns={columns}
        data={data}
        searchPlaceholder="Searching all products"
        pageSize={20}
        title="Top Selling Products"
        showPagination={false}
      />

      <ConfirmModal
        open={deleteConfirm.open}
        onOpenChange={deleteConfirm.onOpenChange}
        title="Delete product?"
        description={
          deleteConfirm.deleteItem?.productName
            ? `Are you sure you want to delete “${deleteConfirm.deleteItem.productName}”? This action cannot be undone.`
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
};

export default ProductTable;
