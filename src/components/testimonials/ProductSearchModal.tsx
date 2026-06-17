"use client";

import React, { useState, useEffect } from "react";
import { FiSearch } from "react-icons/fi";
import { X } from "lucide-react";
import AppModal from "@/components/ui/appModal";
import { useLazyGetPublicProductsQuery } from "@/store/api/productsApi";
import { useGetPublicCategoriesQuery } from "@/store/api/productCategoriesApi";

interface Product {
    _id: string;
    title: string;
    productImage: string;
    slug: string;
}

interface ProductSearchModalProps {
    isOpen: boolean;
    onClose: () => void;
    selectedProducts: string[];
    onDone: (selectedIds: string[]) => void;
}

export default function ProductSearchModal({
    isOpen,
    onClose,
    selectedProducts,
    onDone,
}: ProductSearchModalProps) {
    const [searchQuery, setSearchQuery] = useState("");
    const [selectedCategories, setSelectedCategories] = useState<string[]>([]);
    const [tempSelectedProducts, setTempSelectedProducts] =
        useState<string[]>(selectedProducts);
    const [isCategoryDropdownOpen, setIsCategoryDropdownOpen] = useState(false);

    // API hooks
    const [fetchProducts, { data: productsData, isLoading: isLoadingProducts }] =
        useLazyGetPublicProductsQuery();
    const { data: categoriesData, isLoading: isLoadingCategories } =
        useGetPublicCategoriesQuery();

    // Extract data from API responses
    const products = (productsData?.data || []) as Product[];
    const categories = categoriesData?.data?.categories || [];

    // Fetch products when modal opens or filters change
    useEffect(() => {
        if (isOpen) {
            const params: any = {};

            if (searchQuery) {
                params.search = searchQuery;
            }

            if (selectedCategories.length > 0) {
                params.categories = selectedCategories.join(",");
            }

            fetchProducts(params);
        }
    }, [isOpen, searchQuery, selectedCategories, fetchProducts]);

    // Reset state when modal opens
    useEffect(() => {
        if (isOpen) {
            setTempSelectedProducts(selectedProducts);
            setSearchQuery("");
            setSelectedCategories([]);
        }
    }, [isOpen, selectedProducts]);

    const handleProductSelection = (productId: string) => {
        setTempSelectedProducts((prev) =>
            prev.includes(productId)
                ? prev.filter((id) => id !== productId)
                : [...prev, productId]
        );
    };

    const handleDoneSelection = () => {
        onDone(tempSelectedProducts);
        onClose();
    };

    const handleCancelSelection = () => {
        setTempSelectedProducts(selectedProducts);
        onClose();
    };

    const handleCategoryToggle = (categoryId: string) => {
        setSelectedCategories((prev) =>
            prev.includes(categoryId)
                ? prev.filter((c) => c !== categoryId)
                : [...prev, categoryId]
        );
    };

    const handleRemoveCategory = (categoryId: string) => {
        setSelectedCategories((prev) => prev.filter((c) => c !== categoryId));
    };

    return (
        <AppModal
            open={isOpen}
            onOpenChange={(v) => !v && handleCancelSelection()}
            title="Search products"
            className="min-w-75!"
            footer={
                <div className="flex items-center justify-end gap-3 ">
                    <button
                        onClick={handleCancelSelection}
                        className="px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 rounded-lg transition-colors cursor-pointer border border-extra-light-gray"
                    >
                        Cancel
                    </button>
                    <button
                        onClick={handleDoneSelection}
                        className="px-4 py-2 text-sm font-medium text-white bg-teal-500 hover:bg-teal-600 rounded-lg transition-colors cursor-pointer"
                    >
                        Done
                    </button>
                </div>
            }
        >
            <div className="space-y-4 h-125 flex flex-col min-w-0 overflow-hidden">
                {/* Search Input */}
                <div className="space-y-3">
                    {/* Search */}
                    <div className="flex items-center gap-3">
                        <div className="relative flex-1">
                            <FiSearch className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                            <input
                                type="text"
                                placeholder="Search products"
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                                className="w-full rounded-lg border border-extra-light-gray pl-10 pr-3 py-1.5 text-sm outline-none focus:border-teal-green"
                            />
                        </div>
                        <button
                            onClick={() => setSearchQuery("")}
                            className="text-sm text-gray-900 rounded-lg border border-gray-300 px-3 py-1.5"
                        >
                            Cancel
                        </button>
                    </div>

                    {/* Filters row */}
                    <div className="flex items-start gap-3">
                        {/* Category filter dropdown */}
                        <div className="relative">
                            <button
                                onClick={() =>
                                    setIsCategoryDropdownOpen(!isCategoryDropdownOpen)
                                }
                                className="appearance-none rounded-lg border border-extra-light-gray bg-white px-4 py-1.5 pr-10 text-sm text-gray-900 cursor-pointer hover:border-teal-green transition-colors min-w-30 text-left"
                            >
                                Category
                            </button>

                            <svg
                                className="pointer-events-none absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-500"
                                fill="none"
                                stroke="currentColor"
                                viewBox="0 0 24 24"
                            >
                                <path
                                    strokeLinecap="round"
                                    strokeLinejoin="round"
                                    strokeWidth={2}
                                    d="M19 9l-7 7-7-7"
                                />
                            </svg>

                            {/* Dropdown menu */}
                            {isCategoryDropdownOpen && (
                                <div className="absolute top-full left-0 mt-2 w-48 bg-white rounded-lg border border-extra-light-gray shadow-lg z-10 max-h-64 overflow-y-auto">
                                    <div className="py-1.5">
                                        {isLoadingCategories ? (
                                            <div className="px-4 py-2.5 text-sm text-gray-500">
                                                Loading...
                                            </div>
                                        ) : categories.length === 0 ? (
                                            <div className="px-4 py-2.5 text-sm text-gray-500">
                                                No categories found
                                            </div>
                                        ) : (
                                            categories.map((category) => (
                                                <label
                                                    key={category._id}
                                                    className={`flex items-center gap-3 px-4 py-2.5 cursor-pointer hover:bg-gray-50 transition-colors ${selectedCategories.includes(category.name)
                                                        ? "bg-green-50"
                                                        : ""
                                                        }`}
                                                >
                                                    <input
                                                        type="checkbox"
                                                        checked={selectedCategories.includes(category.name)}
                                                        onChange={() => handleCategoryToggle(category.name)}
                                                        className="w-4 h-4 text-teal-500 border-extra-light-gray rounded focus:ring-teal-500"
                                                    />
                                                    <span className="text-sm text-gray-900">
                                                        {category.name}
                                                    </span>
                                                </label>
                                            ))
                                        )}
                                    </div>
                                </div>
                            )}
                        </div>

                        {/* Selected categories chips */}
                        <div className="flex-1 flex items-center gap-2 flex-wrap">
                            {selectedCategories.map((category) => (
                                <div
                                    key={category}
                                    className="relative inline-flex items-center gap-1.5 bg-green-100 text-green-800 px-3 py-1.5 rounded-full text-sm font-medium"
                                >
                                    <span>{category}</span>
                                    <button
                                        onClick={() => handleRemoveCategory(category)}
                                        className="hover:bg-green-200 cursor-pointer rounded-full p-0.5 transition-colors items-center"
                                    >
                                        <X className="w-3.5 h-3.5" />
                                    </button>
                                </div>
                            ))}
                            {selectedCategories.length > 0 && (
                                <button
                                    onClick={() => setSelectedCategories([])}
                                    className="text-sm text-black hover:bg-slate-50 ml-1 border py-1.5 px-3 rounded-lg transition-colors cursor-pointer"
                                >
                                    Clear all
                                </button>
                            )}
                        </div>
                    </div>
                </div>

                {/* Products List */}
                <div className="flex-1 overflow-y-auto overflow-x-hidden min-h-0 min-w-0 -mx-4.5">
                    {isLoadingProducts ? (
                        <div className="text-center py-8 text-gray-500 text-sm">
                            Loading products...
                        </div>
                    ) : products.length === 0 ? (
                        <div className="text-center py-8 text-gray-500 text-sm">
                            No products found
                        </div>
                    ) : (
                        <div className="space-y-0 min-w-0">
                            {products.map((product) => (
                                <label
                                    key={product._id}
                                    className="flex items-center gap-3 py-2 px-6 border-t border-extra-light-gray last:border-b-0 cursor-pointer hover:bg-gray-50 transition-colors min-w-0"
                                >
                                    <div className="relative flex items-center justify-center">
                                        <input
                                            type="checkbox"
                                            checked={tempSelectedProducts.includes(product._id)}
                                            onChange={() => handleProductSelection(product._id)}
                                            className="appearance-none w-5 h-5 border-2 border-extra-light-gray rounded-full cursor-pointer checked:bg-teal-500 checked:border-teal-500 transition-all"
                                        />
                                        {tempSelectedProducts.includes(product._id) && (
                                            <div className="absolute w-2 h-2 bg-white rounded-full pointer-events-none"></div>
                                        )}
                                    </div>
                                    {product.productImage ? (
                                        <img
                                            src={product.productImage}
                                            alt={product.title}
                                            className="w-10 h-10 object-cover rounded-md shrink-0"
                                        />
                                    ) : (
                                        <div className="w-10 h-10 bg-extra-light-gray rounded-md flex items-center justify-center text-gray-400 shrink-0">
                                            <span className="text-xs">IMG</span>
                                        </div>
                                    )}
                                    <div className="flex-1 min-w-0">
                                        <p className="text-sm text-gray-900 truncate">
                                            {product.title}
                                        </p>
                                    </div>
                                </label>
                            ))}
                        </div>
                    )}
                </div>
            </div>
        </AppModal>
    );
}
