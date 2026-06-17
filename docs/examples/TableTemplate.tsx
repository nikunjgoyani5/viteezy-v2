// Template for creating a new table page
// Copy this file and modify as needed

"use client";

import React from "react";
import { ColumnDef } from "@tanstack/react-table";
import { DataTable } from "@/components/ui/table";
import { ToggleSwitch } from "@/components/ui/table/ToggleSwitch";
import { ActionMenu } from "@/components/ui/table/ActionMenu";
import { Checkbox } from "@/components/ui/table/Checkbox";
import { MdEdit, MdDelete, MdVisibility } from "react-icons/md";
import Image from "next/image";

// 1. Define your data type
interface YourDataType {
    id: string;
    name: string;
    // Add more fields as needed
}

// 2. Add sample data or fetch from API
const sampleData: YourDataType[] = [
    {
        id: "1",
        name: "Sample Item 1",
    },
    {
        id: "2",
        name: "Sample Item 2",
    },
];

const YourPage = () => {
    // 3. Define columns
    const columns: ColumnDef<YourDataType>[] = [
        // Optional: Checkbox column for row selection
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

        // Regular text column
        {
            accessorKey: "name",
            header: "Name",
            cell: ({ row }) => (
                <span className="font-medium text-gray-900">
                    {row.getValue("name")}
                </span>
            ),
        },

        // Column with image
        // {
        //   accessorKey: "name",
        //   header: "Name",
        //   cell: ({ row }) => {
        //     const item = row.original;
        //     return (
        //       <div className="flex items-center gap-3">
        //         <div className="h-10 w-10 rounded-lg overflow-hidden bg-gray-100">
        //           <Image
        //             src={item.image}
        //             alt={item.name}
        //             width={40}
        //             height={40}
        //             className="h-full w-full object-cover"
        //           />
        //         </div>
        //         <span className="font-medium text-gray-900">{item.name}</span>
        //       </div>
        //     );
        //   },
        // },

        // Status toggle column
        // {
        //   accessorKey: "status",
        //   header: "Status",
        //   cell: ({ row }) => (
        //     <ToggleSwitch
        //       checked={row.getValue("status")}
        //       onChange={(checked) => {
        //         console.log("Status changed:", checked);
        //         // Handle status change
        //       }}
        //     />
        //   ),
        // },

        // Date column
        // {
        //   accessorKey: "createdAt",
        //   header: "Created",
        //   cell: ({ row }) => (
        //     <span className="text-gray-700">
        //       {new Date(row.getValue("createdAt")).toLocaleDateString()}
        //     </span>
        //   ),
        // },

        // Actions column
        {
            id: "actions",
            header: "Actions",
            cell: ({ row }) => {
                const item = row.original;
                return (
                    <ActionMenu
                        items={[
                            {
                                label: "View",
                                icon: <MdVisibility className="h-4 w-4" />,
                                onClick: () => console.log("View", item.id),
                            },
                            {
                                label: "Edit",
                                icon: <MdEdit className="h-4 w-4" />,
                                onClick: () => console.log("Edit", item.id),
                            },
                            {
                                label: "Delete",
                                icon: <MdDelete className="h-4 w-4" />,
                                onClick: () => console.log("Delete", item.id),
                                danger: true,
                            },
                        ]}
                    />
                );
            },
        },
    ];

    // 4. Render the table
    return (
        <div className="p-6">
            {/* Page header */}
            <div className="mb-6">
                <h1 className="text-2xl font-bold text-gray-900">Your Page Title</h1>
            </div>

            {/* DataTable component */}
            <DataTable
                columns={columns}
                data={sampleData}
                searchKey="name" // Column to search on
                searchPlaceholder="Search..." // Search input placeholder
                filters={[
                    // Optional: Add filter tabs
                    { value: "all", label: "All" },
                    { value: "active", label: "Active" },
                    { value: "inactive", label: "Inactive" },
                ]}
                pageSize={10} // Rows per page
            />
        </div>
    );
};

export default YourPage;
