"use client";

import React from "react";
import { ColumnDef } from "@tanstack/react-table";
import { DataTable } from "@/components/ui/table";
import { ToggleSwitch } from "@/components/ui/table/ToggleSwitch";
import { ActionMenu } from "@/components/ui/table/ActionMenu";
import { MdEdit, MdDelete, MdVisibility } from "react-icons/md";
import Image from "next/image";
import AppImage from "@/components/ui/appImage";

// Ingredient data type
interface Ingredient {
    id: string;
    name: string;
    description: string;
    linkedProducts: number;
    status: boolean;
    image: string;
}

// Sample data
const ingredientData: Ingredient[] = [
    {
        id: "1",
        name: "Chorella",
        description: "Grown in Oldenzaal (the Netherlands) in closed fermentation tanks for the highest ...",
        linkedProducts: 5,
        status: true,
        image: "/images/ingredient-1.jpg",
    },
    {
        id: "2",
        name: "Lithothamnion",
        description: "Collected along the coast of Iceland, exclusively from naturally occurring seaweed, ...",
        linkedProducts: 5,
        status: true,
        image: "/images/ingredient-2.jpg",
    },
    {
        id: "3",
        name: "Spirulina",
        description: "Grown in Catalonia (Spain) and dried at a low temperature to preserve nutritional value,...",
        linkedProducts: 5,
        status: true,
        image: "/images/ingredient-3.jpg",
    },
    {
        id: "4",
        name: "Wakame",
        description: "Grown in Brittany, France, in a protected marine ecosystem, wakame is a natural source...",
        linkedProducts: 5,
        status: true,
        image: "/images/ingredient-4.jpg",
    },
];

const IngredientsPage = () => {
    const columns: ColumnDef<Ingredient>[] = [
        {
            accessorKey: "name",
            header: "Ingredient",
            cell: ({ row }) => {
                const ingredient = row.original;
                return (
                    <div className="flex items-center gap-3">
                        <div className="h-10 w-10 rounded-lg overflow-hidden bg-gray-100 shrink-0">
                            <AppImage
                                src={ingredient.image}
                                alt={ingredient.name}
                                width={40}
                                height={40}
                                className="h-full w-full object-cover"
                            />
                        </div>
                        <span className="font-medium text-gray-900">{ingredient.name}</span>
                    </div>
                );
            },
        },
        {
            accessorKey: "description",
            header: "Description",
            cell: ({ row }) => (
                <div className="max-w-md">
                    <p className="text-gray-700 text-sm line-clamp-2">
                        {row.getValue("description")}
                    </p>
                </div>
            ),
        },
        {
            accessorKey: "linkedProducts",
            header: "Linked Products",
            cell: ({ row }) => (
                <span className="text-gray-700">{row.getValue("linkedProducts")} Products</span>
            ),
        },
        {
            accessorKey: "status",
            header: "Status",
            cell: ({ row }) => (
                <ToggleSwitch
                    checked={row.getValue("status")}
                    onChange={(checked) => {
                        console.log("Status changed:", checked);
                        // Handle status change
                    }}
                />
            ),
        },
        {
            id: "actions",
            header: "Actions",
            cell: ({ row }) => {
                const ingredient = row.original;
                return (
                    <ActionMenu
                        items={[
                            {
                                label: "View",
                                icon: <MdVisibility className="h-4 w-4" />,
                                onClick: () => console.log("View", ingredient.id),
                            },
                            {
                                label: "Edit",
                                icon: <MdEdit className="h-4 w-4" />,
                                onClick: () => console.log("Edit", ingredient.id),
                            },
                            {
                                label: "Delete",
                                icon: <MdDelete className="h-4 w-4" />,
                                onClick: () => console.log("Delete", ingredient.id),
                                danger: true,
                            },
                        ]}
                    />
                );
            },
        },
    ];

    return (
        <div className="p-6">
            <div className="mb-6">
                <h1 className="text-2xl font-bold text-gray-900">All Ingredients</h1>
            </div>

            <DataTable
                columns={columns}
                data={ingredientData}
                searchKey="name"
                searchPlaceholder="Searching all ingredients"
                filters={[
                    { value: "all", label: "All" },
                    { value: "active", label: "Active" },
                    { value: "inactive", label: "Inactive" },
                ]}
                pageSize={10}
            />
        </div>
    );
};

export default IngredientsPage;
