// Example: How to use DataTable with API data and state management

"use client";

import React, { useEffect, useState } from "react";
import { ColumnDef } from "@tanstack/react-table";
import { DataTable } from "@/components/ui/table";
import { ToggleSwitch } from "@/components/ui/table/ToggleSwitch";
import { ActionMenu } from "@/components/ui/table/ActionMenu";
import { Checkbox } from "@/components/ui/table/Checkbox";
import { MdEdit, MdDelete } from "react-icons/md";

interface Product {
    id: string;
    name: string;
    price: number;
    category: string;
    status: boolean;
    stock: number;
}

const ProductsPageExample = () => {
    const [products, setProducts] = useState<Product[]>([]);
    const [loading, setLoading] = useState(true);

    // Fetch data from API
    useEffect(() => {
        const fetchProducts = async () => {
            try {
                setLoading(true);
                const response = await fetch("/api/products");
                const data = await response.json();
                setProducts(data);
            } catch (error) {
                console.error("Error fetching products:", error);
            } finally {
                setLoading(false);
            }
        };

        fetchProducts();
    }, []);

    // Handle status toggle
    const handleStatusToggle = async (id: string, newStatus: boolean) => {
        try {
            await fetch(`/api/products/${id}`, {
                method: "PATCH",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ status: newStatus }),
            });

            // Update local state
            setProducts((prev) =>
                prev.map((product) =>
                    product.id === id ? { ...product, status: newStatus } : product
                )
            );
        } catch (error) {
            console.error("Error updating status:", error);
        }
    };

    // Handle delete
    const handleDelete = async (id: string) => {
        if (!confirm("Are you sure you want to delete this product?")) return;

        try {
            await fetch(`/api/products/${id}`, {
                method: "DELETE",
            });

            // Update local state
            setProducts((prev) => prev.filter((product) => product.id !== id));
        } catch (error) {
            console.error("Error deleting product:", error);
        }
    };

    // Handle edit
    const handleEdit = (id: string) => {
        // Navigate to edit page or open modal
        window.location.href = `/admin/products/edit/${id}`;
    };

    const columns: ColumnDef<Product>[] = [
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
            accessorKey: "name",
            header: "Product Name",
            cell: ({ row }) => (
                <span className="font-medium text-gray-900">{row.getValue("name")}</span>
            ),
        },
        {
            accessorKey: "category",
            header: "Category",
            cell: ({ row }) => (
                <span className="text-gray-700">{row.getValue("category")}</span>
            ),
        },
        {
            accessorKey: "price",
            header: "Price",
            cell: ({ row }) => {
                const price = parseFloat(row.getValue("price"));
                return <span className="text-gray-700">${price.toFixed(2)}</span>;
            },
        },
        {
            accessorKey: "stock",
            header: "Stock",
            cell: ({ row }) => {
                const stock = row.getValue("stock") as number;
                return (
                    <span
                        className={`${stock > 0 ? "text-green-600" : "text-red-600"
                            } font-medium`}
                    >
                        {stock}
                    </span>
                );
            },
        },
        {
            accessorKey: "status",
            header: "Status",
            cell: ({ row }) => (
                <ToggleSwitch
                    checked={row.getValue("status")}
                    onChange={(checked) =>
                        handleStatusToggle(row.original.id, checked)
                    }
                />
            ),
        },
        {
            id: "actions",
            header: "Actions",
            cell: ({ row }) => {
                const product = row.original;
                return (
                    <ActionMenu
                        items={[
                            {
                                label: "Edit",
                                icon: <MdEdit className="h-4 w-4" />,
                                onClick: () => handleEdit(product.id),
                            },
                            {
                                label: "Delete",
                                icon: <MdDelete className="h-4 w-4" />,
                                onClick: () => handleDelete(product.id),
                                danger: true,
                            },
                        ]}
                    />
                );
            },
        },
    ];

    if (loading) {
        return (
            <div className="p-6">
                <div className="flex items-center justify-center h-64">
                    <div className="text-gray-500">Loading...</div>
                </div>
            </div>
        );
    }

    return (
        <div className="p-6">
            <div className="mb-6 flex items-center justify-between">
                <h1 className="text-2xl font-bold text-gray-900">Products</h1>
                <button
                    onClick={() => (window.location.href = "/admin/products/new")}
                    className="px-4 py-2 bg-emerald-500 text-white rounded-lg hover:bg-emerald-600 transition-colors"
                >
                    Add Product
                </button>
            </div>

            <DataTable
                columns={columns}
                data={products}
                searchKey="name"
                searchPlaceholder="Search products..."
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

export default ProductsPageExample;
