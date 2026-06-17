"use client";

import React from "react";
import type { ColumnDef } from "@tanstack/react-table";
import { ToggleSwitch } from "@/components/ui/table";
import { ActionMenu } from "@/components/ui/table/ActionMenu";
import { RiEdit2Line } from "react-icons/ri";
import { IoTrashOutline } from "react-icons/io5";

export interface TestimonialRow {
    _id: string;
    videoUrl: string;
    videoThumbnail: string | null;
    products: Array<{
        _id: string;
        title: string;
        slug: string;
        productImage: string;
    }>;
    isActive: boolean;
}

export const testimonialColumns = (args: {
    onToggleStatus?: (row: TestimonialRow, next: boolean) => void;
    onEdit?: (row: TestimonialRow) => void;
    onDelete?: (row: TestimonialRow) => void;
    updatingId?: string | null;
}): ColumnDef<TestimonialRow>[] => [
        {
            accessorKey: "videoUrl",
            header: "Video",
            size: 400,
            cell: ({ row }) => {
                const t = row.original;
                const fileName = t.videoUrl.split("/").pop() || "Video";

                return (
                    <div className="flex items-center gap-3 pr-8">
                        <div className="w-12 h-12 rounded-md overflow-hidden shrink-0 relative">
                            <video
                                src={t.videoUrl}
                                preload="metadata"
                                muted
                                loop
                                playsInline
                                controlsList="nodownload nofullscreen noremoteplayback"
                                disablePictureInPicture
                                className="w-full h-full object-cover"
                                style={{ maxHeight: '64px' }}
                                onMouseEnter={(e) => {
                                    e.currentTarget.play();
                                }}
                                onMouseLeave={(e) => {
                                    e.currentTarget.pause();
                                    e.currentTarget.currentTime = 0;
                                }}
                            />
                        </div>
                        <div className="flex flex-col gap-1">
                            <span className="font-medium text-black text-sm">{fileName}</span>
                        </div>
                    </div>
                );
            },
        },
        {
            accessorKey: "products",
            header: "Products",
            size: 300,
            cell: ({ row }) => {
                const products = row.original.products || [];
                return (
                    <div className="flex flex-col gap-1">
                        {products.length > 0 ? (
                            products.map((product, idx) => {
                                const title = product.title;
                                return (
                                    <span key={product._id} className="text-gray-700 text-sm">
                                        {title}
                                    </span>
                                );
                            })
                        ) : (
                            <span className="text-gray-400 text-sm">No products</span>
                        )}
                    </div>
                );
            },
        },
        {
            accessorKey: "isActive",
            header: ({ column }) => <div className="text-right">Status</div>,
            size: 150,
            cell: ({ row }) => {
                const rec = row.original;
                const rowLoading = args.updatingId === rec._id;
                return (
                    <div className="flex justify-end">
                        <ToggleSwitch
                            checked={rec.isActive}
                            disabled={rowLoading}
                            onChange={(checked) => args.onToggleStatus?.(rec, checked)}
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
                const rec = row.original;
                return (
                    <div className="flex justify-center">
                        <ActionMenu
                            items={[
                                {
                                    label: "Edit",
                                    icon: <RiEdit2Line />,
                                    onClick: () => args.onEdit?.(rec),
                                },
                                {
                                    label: "Delete",
                                    icon: <IoTrashOutline />,
                                    onClick: () => args.onDelete?.(rec),
                                    danger: true,
                                },
                            ]}
                        />
                    </div>
                );
            },
        },
    ];
