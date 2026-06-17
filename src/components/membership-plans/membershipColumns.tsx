"use client";

import React from "react";
import type { ColumnDef } from "@tanstack/react-table";
import { ToggleSwitch } from "@/components/ui/table";
import { ActionMenu } from "@/components/ui/table/ActionMenu";
import { RiEdit2Line } from "react-icons/ri";
import { IoTrashOutline } from "react-icons/io5";
import type { MembershipPlanResponse } from "@/store/api/types/membershipPlan.types";

export const membershipColumns = (args: {
    onToggleStatus?: (row: MembershipPlanResponse, next: boolean) => void;
    onEdit?: (row: MembershipPlanResponse) => void;
    onDelete?: (row: MembershipPlanResponse) => void;
    updatingId?: string | null;
}): ColumnDef<MembershipPlanResponse>[] => [
        {
            accessorKey: "name",
            header: "Title",
            size: 400,
            cell: ({ row }) => (
                <span className="font-medium text-black break-words pr-8">{row.original.name}</span>
            ),
        },
        {
            accessorKey: "durationDays",
            header: ({ column }) => <div className="text-right">Days</div>,
            size: 150,
            cell: ({ row }) => (
                <div className="text-right">
                    <span className="text-gray-700">{row.original.durationDays}</span>
                </div>
            ),
        },
        // {
        //     accessorKey: "price.currency",
        //     header: ({ column }) => <div className="text-right">Currency</div>,
        //     size: 150,
        //     cell: ({ row }) => (
        //         <div className="text-right">
        //             <span className="text-gray-700">{row.original.price.currency}</span>
        //         </div>
        //     ),
        // },
        {
            accessorKey: "price.amount",
            header: ({ column }) => <div className="text-right">Price</div>,
            size: 150,
            cell: ({ row }) => (
                <div className="text-right">
                    <span className="text-gray-700">${row.original.price.amount.toFixed(2)}</span>
                </div>
            ),
        },
        {
            accessorKey: "isActive",
            header: ({ column }) => <div className="text-right">Status</div>,
            size: 150,
            cell: ({ row }) => {
                const plan = row.original;
                const rowLoading = args.updatingId === plan._id;

                return (
                    <div className="flex justify-end">
                        <ToggleSwitch
                            checked={plan.isActive}
                            disabled={rowLoading}
                            onChange={(checked) => args.onToggleStatus?.(plan, checked)}
                        />
                    </div>
                );
            },
        },
        {
            id: "actions",
            header: ({ column }) => <div className="text-center">Actions</div>,
            size: 100,
            cell: ({ row }) => {
                const plan = row.original;

                return (
                    <div className="flex justify-center">
                        <ActionMenu
                            items={[
                                {
                                    label: "Edit",
                                    icon: <RiEdit2Line className="w-4.5 h-4.5" />,
                                    onClick: () => args.onEdit?.(plan),
                                },
                                {
                                    label: "Delete",
                                    icon: <IoTrashOutline className="w-4.5 h-4.5" />,
                                    onClick: () => args.onDelete?.(plan),
                                    danger: true,
                                },
                            ]}
                        />
                    </div>
                );
            },
        },
    ];
