"use client";

import React, { useState, useMemo } from "react";
import { useFormContext } from "react-hook-form";
import { Search, X, ChevronDown } from "lucide-react";
import AppImage from "@/components/ui/appImage";
import { useGetProductFiltersQuery } from "@/store/api/productsApi";
import { buildProductAdvancedFilters } from "@/components/product-management/product/productFilters";
import {
  SearchProductsModal,
  type SimilarProductItem,
} from "./SearchProductsModal";
import { cn } from "@/lib/utils";

type SimilarProductsFormValue = SimilarProductItem[];

export default function SimilarProductsSection() {
  const { watch, setValue } = useFormContext<{
    similarProducts: SimilarProductsFormValue;
  }>();
  const similarProducts = watch("similarProducts") ?? [];
  const [modalOpen, setModalOpen] = useState(false);
  const [sortBy, setSortBy] = useState<string>("");

  const { data: filtersRes } = useGetProductFiltersQuery();
  const sortOptions = useMemo(() => {
    const filters = buildProductAdvancedFilters(filtersRes);
    const sortFilter = filters.find((f) => f.key === "sortBy");
    return sortFilter?.options ?? [];
  }, [filtersRes]);

  const currentSortLabel =
    sortOptions.find((o) => o.value === sortBy)?.label ?? "Best selling";

  const handleDone = (selected: SimilarProductItem[]) => {
    // Only update when user has selected items; otherwise keep last
    if (selected.length === 0) return;
    setValue("similarProducts", selected, {
      shouldValidate: true,
      shouldDirty: true,
    });
  };

  const removeProduct = (id: string) => {
    setValue(
      "similarProducts",
      similarProducts.filter((p) => p._id !== id),
      { shouldValidate: true, shouldDirty: true }
    );
  };

  const initialSelectedIds = useMemo(
    () => similarProducts.map((p) => p._id),
    [similarProducts]
  );

  return (
    <div className="">
      <div className="border-b border-gray-200 py-4 px-5">
        <h2 className="text-lg font-semibold text-gray-900">
          Similar Products
        </h2>
      </div>

      <div className="flex flex-wrap items-center gap-3 p-5">
        <button
          type="button"
          onClick={() => setModalOpen(true)}
          className="flex items-center gap-2 w-full max-w-md px-4 py-2.5 border border-gray-200 rounded-lg text-left text-gray-500 hover:border-teal-300 hover:bg-gray-50 transition-colors"
        >
          <Search className="w-4 h-4 text-gray-400 shrink-0" />
          <span>Search products</span>
        </button>

        {/* <div className="relative">
          <span className="text-sm text-gray-600 mr-2">Sort:</span>
          <button
            type="button"
            className="flex items-center gap-1 px-3 py-2 border border-gray-200 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50"
          >
            {currentSortLabel}
            <ChevronDown className="w-4 h-4" />
          </button>
        </div> */}
      </div>

      <div className="space-y-2 p-5 pt-0">
        {similarProducts.length === 0 && (
          <div className="py-8 px-4 text-center text-gray-500 text-sm border border-dashed border-gray-200 rounded-lg">
            No similar products added. Click &quot;Search products&quot; to add.
          </div>
        )}
        {similarProducts.length > 0 && (
          <ul className="space-y-2">
            {similarProducts.map((product, index) => (
              <li
                key={product._id}
                className={cn(
                  "flex items-center gap-4 py-3 px-4 rounded-lg border border-gray-200",
                  "hover:border-teal-200 hover:bg-gray-50/50 transition-colors"
                )}
              >
                <span className="text-sm font-medium text-gray-500 w-6 shrink-0">
                  {index + 1}.
                </span>
                <div className="h-12 w-12 shrink-0 rounded-lg overflow-hidden bg-gray-100 border border-gray-200">
                  {product.productImage ? (
                    <AppImage
                      src={product.productImage}
                      alt={product.title}
                      width={48}
                      height={48}
                      className="object-cover"
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center text-gray-400 text-xs">
                      —
                    </div>
                  )}
                </div>
                <span className="font-medium text-gray-900 truncate flex-1">
                  {product.title}
                </span>
                <button
                  type="button"
                  onClick={() => removeProduct(product._id)}
                  className="p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-md transition-colors shrink-0"
                  title="Remove"
                >
                  <X className="w-5 h-5" />
                </button>
              </li>
            ))}
          </ul>
        )}
      </div>

      <SearchProductsModal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        onDone={handleDone}
        initialSelectedIds={initialSelectedIds}
      />
    </div>
  );
}
