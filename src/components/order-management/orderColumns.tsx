"use client";

import React from "react";
import { ColumnDef } from "@tanstack/react-table";
import { Checkbox } from "@/components/ui/table";
import { DownIcon } from "@/components/icons";
import { useRouter } from "next/navigation";

import { Order } from "@/store/api/types/order.types";
import { format } from "date-fns";

export type PaymentStatus =
    | "Paid"
    | "Pending"
    | "Cancelled"
    | "Processing"
    | "Completed"
    | "Failed"
    | "Refunded";
export type PlanType = "Subscription" | "One-time" | "One-Time";
export type OrderStatus =
    | "Delivered"
    | "Processing"
    | "Shipped"
    | "Cancelled"
    | "Pending"
    | "Confirmed"
    | "Refunded";

const pill = (text: string, color: string) => (
    <span
        className={`inline-flex items-center px-3 py-1 rounded-md text-xs font-medium ${color}`}
    >
        {text}
    </span>
);

const paymentColors: Record<string, string> = {
    Paid: "bg-green-100 text-green-800",
    Completed: "bg-green-100 text-green-800",
    Pending: "bg-yellow-100 text-yellow-800",
    Processing: "bg-blue-100 text-blue-800",
    Cancelled: "bg-red-100 text-red-800",
    Failed: "bg-red-100 text-red-800",
    Refunded: "bg-gray-100 text-gray-800",
};

const planColors: Record<string, string> = {
    Subscription: "bg-blue-100 text-blue-800",
    "One-time": "bg-orange-100 text-orange-800",
    "One-Time": "bg-orange-100 text-orange-800",
};

const orderColors: Record<string, string> = {
    Delivered: "bg-green-100 text-green-800",
    Processing: "bg-orange-100 text-orange-800",
    Shipped: "bg-blue-100 text-blue-800",
    Cancelled: "bg-red-100 text-red-800",
    Pending: "bg-yellow-100 text-yellow-800",
    Confirmed: "bg-teal-100 text-teal-800",
    Refunded: "bg-gray-100 text-gray-800",
};

export const orderColumns: ColumnDef<Order>[] = [
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
        accessorKey: "orderNumber",
        header: "Order ID",
        cell: ({ row }) => {
            const router = useRouter();
            const orderNumber = row.original.orderNumber;
            const id = row.original.id;
            return (
                <button
                    onClick={() =>
                        router.push(`/admin/order-management/${encodeURIComponent(id)}`)
                    }
                    className="font-medium text-black hover:text-blue-600 hover:underline transition-colors text-left cursor-pointer"
                >
                    {orderNumber}
                </button>
            );
        },
    },
    {
        accessorKey: "orderDate",
        header: "Order date",
        cell: ({ row }) => {
            const date = row.original.orderDate
                ? format(new Date(row.original.orderDate), "MMM dd 'at' hh:mm a")
                : "-";
            return <span className="font-medium text-black">{date}</span>;
        },
        filterFn: "equals",
    },
    {
        accessorKey: "customer",
        header: "Customer",
        cell: ({ row }) => {
            const customer = row.original.customer;

            if (!customer) {
                return <span className="font-medium text-gray-400">Guest User</span>;
            }

            const firstName = customer?.firstName || "";
            const lastName = customer?.lastName || "";
            const name = `${firstName} ${lastName}`.trim() || "-";
            const email = customer?.email || "-";
            const location = "Los Angeles, CA, United States";
            const ordersCount = 3;

            const [open, setOpen] = React.useState(false);
            const router = useRouter();

            return (
                <div
                    className="relative cursor-pointer inline-flex items-center group"
                    onClick={(e) => {
                        e.stopPropagation();
                        setOpen((v) => !v);
                    }}
                >
                    <span className="font-medium text-black">{name}</span>
                    <button
                        aria-label="Open customer menu"
                        className="ml-1 mt-1 opacity-0 group-hover:opacity-100 transition-opacity"
                    >
                        <DownIcon />
                    </button>

                    {open && (
                        <div className="absolute left-0 top-full mt-3 w-72 bg-white border border-gray-200 rounded-md shadow-lg z-50 p-3">
                            <div className="text-base font-semibold text-gray-900">{name}</div>
                            <div className="text-sm text-gray-600 ">{location}</div>
                            <div className="text-sm text-gray-600 mt-1 leading-3">
                                {ordersCount} orders
                            </div>
                            <a
                                href={`mailto:${email}`}
                                className="text-teal-600 text-sm mt-2 block"
                            >
                                {email}
                            </a>
                            <button
                                onClick={() => router.push(`/admin/user-management/${customer.id}`)}
                                className="mt-3 w-full border border-extra-light-gray rounded-md py-2 text-sm hover:bg-gray-50"
                            >
                                View customer
                            </button>
                        </div>
                    )}
                </div>
            );
        },
    },
    {
        accessorKey: "paymentStatus",
        header: "Payment status",
        cell: ({ row }) => {
            const v = row.getValue("paymentStatus") as string;
            return pill(v, paymentColors[v] || "bg-gray-100 text-gray-800");
        },
        filterFn: "equals",
    },
    {
        accessorKey: "pricing",
        header: "Order total",
        cell: ({ row }) => {
            const total = row.original.itemsTotal || 0;
            return (
                <span className="font-medium text-black">
                    {new Intl.NumberFormat("en-US", {
                        style: "currency",
                        currency: "USD",
                    }).format(total)}
                </span>
            );
        },
        filterFn: "includesString",
    },
    {
        accessorKey: "planType",
        header: "Plan type",
        cell: ({ row }) => {
            const v = row.getValue("planType") as string;
            return pill(v, planColors[v] || "bg-gray-100 text-gray-800");
        },
        filterFn: "equals",
    },
    {
        accessorKey: "status",
        header: "Order status",
        cell: ({ row }) => {
            const v = row.getValue("status") as string;
            return pill(v, orderColors[v] || "bg-gray-100 text-gray-800");
        },
        filterFn: "equals",
    },
    {
        accessorKey: "items",
        header: "Product",
        cell: ({ row }) => {
            const items = row.original.items;
            if (!items || items.length === 0) return <span className="font-medium text-black">-</span>;

            const firstItem = items[0];
            const productName = firstItem?.product?.title || firstItem?.name || "-";
            const additionalCount = items.length - 1;

            return (
                <span className="font-medium text-black">
                    {productName}
                    {additionalCount > 0 && (
                        <span className="text-gray-500 ml-1">+{additionalCount}</span>
                    )}
                </span>
            );
        },
        filterFn: "includesString",
    },
];
