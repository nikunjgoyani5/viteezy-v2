"use client";

import React, { useState, useMemo } from "react";
import { useGetCategoriesListQuery } from "@/store/api/productCategoriesApi";

interface PageProduct {
    id: string;
    name: string;
    image: string;
}

interface Page {
    id: string;
    name: string;
    hasSubpages: boolean;
    products: PageProduct[];
}

interface PageSelectorProps {
    selectedPages: string[];
    selectedPageProducts: Record<string, string[]>;
    onPageToggle: (pageId: string) => void;
    onPageProductToggle: (pageId: string, productId: string) => void;
    onSelectAllProducts: (pageId: string, productIds: string[]) => void;
}

export default function PageSelector({
    selectedPages,
    selectedPageProducts,
    onPageToggle,
    onPageProductToggle,
    onSelectAllProducts,
}: PageSelectorProps) {
    const [isPageDropdownOpen, setIsPageDropdownOpen] = useState(false);
    const [expandedPageId, setExpandedPageId] = useState<string | null>(null);

    // Fetch categories from API
    const { data: categoriesData, isLoading } = useGetCategoriesListQuery();

    // Transform API data to pages format
    const pages = useMemo(() => {
        const homePages: Page[] = [
            { id: "home", name: "Home Page", hasSubpages: false, products: [] },
        ];

        if (!categoriesData?.data?.categories) {
            return homePages;
        }

        const categoryPages: Page[] = categoriesData.data.categories.map(
            (category) => ({
                id: category._id,
                name: category.name,
                hasSubpages: category.products.length > 0,
                products: category.products.map((product) => ({
                    id: product._id,
                    name: product.title,
                    image: product.productImage,
                })),
            })
        );

        return [...homePages, ...categoryPages];
    }, [categoriesData]);

    const getSelectedPagesDisplay = () => {
        const selectedPagesList: string[] = [];
        if (selectedPages.includes("home")) {
            selectedPagesList.push("Home");
        }

        Object.entries(selectedPageProducts || {}).forEach(([pageId, products]) => {
            if (products.length > 0) {
                const page = pages.find((p) => p.id === pageId);
                if (page) {
                    selectedPagesList.push(`${page.name} (${products.length})`);
                }
            }
        });

        if (selectedPagesList.length === 0) return "Select Pages";
        return selectedPagesList.join(", ");
    };

    const handlePageClick = (pageId: string) => {
        if (pageId === "home") {
            onPageToggle(pageId);
        } else {
            setExpandedPageId(expandedPageId === pageId ? null : pageId);
        }
    };

    return (
        <div className="bg-white rounded-lg border border-extra-light-gray p-4 sticky top-20 mt-5">
            <label className="text-sm font-medium text-gray-700 block mb-2">
                Page <span className="text-red-500">*</span>
            </label>
            <div className="relative">
                <button
                    type="button"
                    onClick={() => setIsPageDropdownOpen(!isPageDropdownOpen)}
                    className="w-full appearance-none rounded-lg border border-extra-light-gray bg-white px-4 py-2.5 pr-10 text-sm text-gray-700 cursor-pointer hover:border-teal-green transition-colors text-left"
                >
                    {getSelectedPagesDisplay()}
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

                {/* First Dropdown - Pages List */}
                {isPageDropdownOpen && !expandedPageId && (
                    <div className="absolute top-full left-0 mt-2 w-full bg-white rounded-lg border border-extra-light-gray shadow-lg z-10 max-h-50 overflow-y-auto">
                        {isLoading ? (
                            <div className="py-8 text-center text-gray-500 text-sm">
                                Loading categories...
                            </div>
                        ) : (
                            <div className="py-1.5">
                                {pages.map((page) => (
                                    <div
                                        key={page.id}
                                        className={`flex items-center justify-between px-4 py-2.5 cursor-pointer hover:bg-gray-50 transition-colors ${page.id === "home" && selectedPages.includes(page.id)
                                                ? "bg-teal-50"
                                                : ""
                                            } ${page.id === "home" ? "border-b border-extra-light-gray" : ""
                                            }`}
                                        onClick={() => handlePageClick(page.id)}
                                    >
                                        <span className="text-sm text-gray-900">{page.name}</span>

                                        {/* Checkbox for home page or arrow for other pages */}
                                        {page.id === "home" ? (
                                            <div className="flex items-center justify-center">
                                                <label className="flex items-center cursor-pointer">
                                                    <input
                                                        type="checkbox"
                                                        checked={selectedPages.includes(page.id)}
                                                        onChange={() => onPageToggle(page.id)}
                                                        onClick={(e) => e.stopPropagation()}
                                                        className="appearance-none w-4 h-4 border border-extra-light-gray rounded cursor-pointer relative checked:bg-teal-green checked:border-teal-green focus:ring-2 focus:ring-teal-green after:content-[''] after:absolute after:hidden checked:after:block after:left-1.25 after:top-0.5 after:w-1 after:h-2 after:border-white after:border-r-2 after:border-b-2 after:rotate-45"
                                                    />
                                                </label>
                                            </div>
                                        ) : (
                                            page.hasSubpages && (
                                                <svg
                                                    className="w-4 h-4 text-text-gray"
                                                    fill="none"
                                                    stroke="currentColor"
                                                    viewBox="0 0 24 24"
                                                >
                                                    <path
                                                        strokeLinecap="round"
                                                        strokeLinejoin="round"
                                                        strokeWidth={2}
                                                        d="M9 5l7 7-7 7"
                                                    />
                                                </svg>
                                            )
                                        )}
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>
                )}

                {/* Second Dropdown - Products List */}
                {isPageDropdownOpen && expandedPageId && (
                    <div className="absolute top-full left-0 mt-2 w-full bg-white rounded-lg border border-extra-light-gray shadow-lg z-20 max-h-100 overflow-y-auto">
                        {(() => {
                            const selectedPage = pages.find((p) => p.id === expandedPageId);
                            if (!selectedPage) return null;

                            return (
                                <>
                                    {/* Back button */}
                                    <div className="px-4 py-2 border-b border-extra-light-gray flex items-center justify-between sticky top-0 bg-white">
                                        <button
                                            onClick={(e) => {
                                                e.stopPropagation();
                                                setExpandedPageId(null);
                                            }}
                                            className="flex items-center gap-2 text-sm text-gray-700 hover:text-gray-900"
                                        >
                                            <svg
                                                className="w-4 h-4"
                                                fill="none"
                                                stroke="currentColor"
                                                viewBox="0 0 24 24"
                                            >
                                                <path
                                                    strokeLinecap="round"
                                                    strokeLinejoin="round"
                                                    strokeWidth={2}
                                                    d="M15 19l-7-7 7-7"
                                                />
                                            </svg>
                                            Back
                                        </button>
                                        <span className="text-sm text-gray-600">
                                            {(selectedPageProducts?.[expandedPageId] || []).length}{" "}
                                            results
                                        </span>
                                    </div>

                                    <div className="py-1.5">
                                        {/* All products checkbox */}
                                        <label
                                            className="flex items-center gap-3 px-4 py-2.5 cursor-pointer hover:bg-gray-50 transition-colors border-b border-extra-light-gray"
                                            onClick={(e) => e.stopPropagation()}
                                        >
                                            <input
                                                type="checkbox"
                                                checked={
                                                    selectedPage.products.length > 0 &&
                                                    selectedPage.products.every((product) =>
                                                        selectedPageProducts?.[expandedPageId]?.includes(
                                                            product.id
                                                        )
                                                    )
                                                }
                                                onChange={(e) => {
                                                    e.stopPropagation();
                                                    const allSelected = selectedPage.products.every(
                                                        (product) =>
                                                            selectedPageProducts?.[expandedPageId]?.includes(
                                                                product.id
                                                            )
                                                    );

                                                    if (allSelected) {
                                                        // Deselect all
                                                        onSelectAllProducts(expandedPageId, []);
                                                    } else {
                                                        // Select all
                                                        onSelectAllProducts(
                                                            expandedPageId,
                                                            selectedPage.products.map((p) => p.id)
                                                        );
                                                    }
                                                }}
                                                className="appearance-none w-4 h-4 border border-extra-light-gray rounded cursor-pointer relative checked:bg-teal-green checked:border-teal-green focus:ring-2 focus:ring-teal-green after:content-[''] after:absolute after:hidden checked:after:block after:left-1.25 after:top-0.5 after:w-1 after:h-2 after:border-white after:border-r-2 after:border-b-2 after:rotate-45"
                                            />
                                            <span className="text-sm font-medium text-gray-900">
                                                All products
                                            </span>
                                        </label>

                                        {/* Product list */}
                                        {selectedPage.products.map((product) => (
                                            <label
                                                key={product.id}
                                                className="flex items-center gap-3 px-4 py-2.5 cursor-pointer hover:bg-gray-50 transition-colors"
                                                onClick={(e) => e.stopPropagation()}
                                            >
                                                <input
                                                    type="checkbox"
                                                    checked={
                                                        selectedPageProducts?.[expandedPageId]?.includes(
                                                            product.id
                                                        ) || false
                                                    }
                                                    onChange={() =>
                                                        onPageProductToggle(expandedPageId, product.id)
                                                    }
                                                    className="appearance-none w-4 h-4 border border-extra-light-gray rounded cursor-pointer relative checked:bg-teal-green checked:border-teal-green focus:ring-2 focus:ring-teal-green after:content-[''] after:absolute after:hidden checked:after:block after:left-1.25 after:top-0.5 after:w-1 after:h-2 after:border-white after:border-r-2 after:border-b-2 after:rotate-45"
                                                />
                                                <div className="w-8 h-8 bg-extra-light-gray rounded flex items-center justify-center shrink-0">
                                                    <span className="text-xs font-medium text-gray-600">
                                                        E
                                                    </span>
                                                </div>
                                                <span className="text-sm text-gray-900">
                                                    {product.name}
                                                </span>
                                            </label>
                                        ))}
                                    </div>
                                </>
                            );
                        })()}
                    </div>
                )}
            </div>
        </div>
    );
}
