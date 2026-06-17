"use client";

import React, { useEffect } from "react";
import { X } from "lucide-react";
import { useLazyGetPublicProductsQuery } from "@/store/api/productsApi";

interface Product {
    _id: string;
    title: string;
    productImage: string;
    slug: string;
}

interface SelectedProductsListProps {
    selectedProductIds: string[];
    onRemove: (productId: string) => void;
}

export default function SelectedProductsList({
    selectedProductIds,
    onRemove,
}: SelectedProductsListProps) {
    const [fetchProducts, { data: productsData }] = useLazyGetPublicProductsQuery();
    const products = (productsData?.data || []) as Product[];

    // Fetch products when selected IDs change
    useEffect(() => {
        if (selectedProductIds.length > 0) {
            fetchProducts({});
        }
    }, [selectedProductIds, fetchProducts]);

    const selectedProducts = products.filter((p) =>
        selectedProductIds.includes(p._id)
    );

    if (selectedProducts.length === 0) {
        return null;
    }

    return (
        <div className="mt-3 space-y-2">
            {selectedProducts.map((product) => (
                <div
                    key={product._id}
                    className="flex items-center gap-3 p-2 border border-extra-light-gray rounded-lg bg-white"
                >
                    {product.productImage ? (
                        <img
                            src={product.productImage}
                            alt={product.title}
                            className="w-10 h-10 object-cover rounded-md shrink-0"
                        />
                    ) : (
                        <div className="w-10 h-10 bg-gray-200 rounded-md shrink-0 flex items-center justify-center">
                            <span className="text-gray-500 text-xs">No img</span>
                        </div>
                    )}
                    <div className="flex-1 min-w-0">
                        <p className="text-sm text-gray-900 truncate">{product.title}</p>
                    </div>
                    <button
                        onClick={() => onRemove(product._id)}
                        className="p-1 hover:bg-gray-100 rounded-full cursor-pointer transition-colors"
                    >
                        <X className="w-4 h-4 text-gray-500" />
                    </button>
                </div>
            ))}
        </div>
    );
}
