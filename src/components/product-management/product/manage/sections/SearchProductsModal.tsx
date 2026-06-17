"use client";

import React, { useState, useEffect, useMemo, useRef } from "react";
import { Search } from "lucide-react";
import { Button } from "@/components/ui/button";
import { TableFilterRow } from "@/components/ui/table/TableFilterRow";
import { Checkbox } from "@/components/ui/table/Checkbox";
import AppImage from "@/components/ui/appImage";
import AppModal from "@/components/ui/appModal";
import { useGetProductFiltersQuery } from "@/store/api/productsApi";
import { useLazyGetProductsQuery } from "@/store/api/productsApi";
import {
  buildProductAdvancedFilters,
  mapProductFiltersToApi,
} from "@/components/product-management/product/productFilters";
import type { ProductListItem } from "@/store/api/types/products.types";
import type { GetProductsParams } from "@/store/api/types/products.types";
import { cn } from "@/lib/utils";
import { useDebounce } from "@/hooks/useDebounce"; // ✅ Import debounce hook

export type SimilarProductItem = {
  _id: string;
  title: string;
  productImage?: string;
};

const MODAL_PAGE_SIZE = 10;

interface SearchProductsModalProps {
  open: boolean;
  onClose: () => void;
  onDone: (selected: SimilarProductItem[]) => void;
  /** IDs of products already selected (shown as checked when modal opens) */
  initialSelectedIds?: string[];
}

function toSimilarItem(p: ProductListItem): SimilarProductItem {
  return {
    _id: p._id,
    title: p.title,
    productImage: p.productImage ?? undefined,
  };
}

export function SearchProductsModal({
  open,
  onClose,
  onDone,
  initialSelectedIds = [],
}: SearchProductsModalProps) {
  const [search, setSearch] = useState("");
  // ✅ 1. Debounce Search Input
  const debouncedSearch = useDebounce(search, 500);

  const [activeFilters, setActiveFilters] = useState<Record<string, string>>(
    {}
  );
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  const [products, setProducts] = useState<ProductListItem[]>([]);
  const [hasNext, setHasNext] = useState(false);
  const [page, setPage] = useState(1);

  // When modal opens, pre-select already selected products
  useEffect(() => {
    if (open && initialSelectedIds.length > 0) {
      setSelectedIds(new Set(initialSelectedIds));
    } else if (open) {
      setSelectedIds(new Set());
    }
  }, [open, initialSelectedIds.join(",")]);

  const { data: filtersRes } = useGetProductFiltersQuery(undefined, {
    skip: !open,
  });
  const advancedFilters = useMemo(
    () =>
      buildProductAdvancedFilters(filtersRes).map((f) => ({
        key: f.key,
        label: f.label,
        type: f.type as "select",
        options: f.options,
      })),
    [filtersRes]
  );

  const [fetchProducts, { isLoading, isFetching }] = useLazyGetProductsQuery();

  const apiParams = useMemo((): GetProductsParams => {
    return {
      page: 1,
      limit: MODAL_PAGE_SIZE,
      // ✅ 2. Use debounced search here
      search: debouncedSearch.trim() || undefined,
      ...mapProductFiltersToApi(activeFilters),
    };
  }, [debouncedSearch, activeFilters]);

  // Initial load
  useEffect(() => {
    if (!open) return;
    setProducts([]);
    setPage(1);
    fetchProducts(apiParams)
      .unwrap()
      .then((res) => {
        const list = Array.isArray(res.data)
          ? res.data
          : (res.data as any)?.blogs || [];
        setProducts(list);
        setHasNext(res.pagination?.hasNext ?? false);
      })
      .catch(() => {});
  }, [open, apiParams, fetchProducts]);

  const loadMore = () => {
    if (isFetching || !hasNext) return;
    const nextPage = page + 1;
    fetchProducts({ ...apiParams, page: nextPage })
      .unwrap()
      .then((res) => {
        const list = Array.isArray(res.data)
          ? res.data
          : (res.data as any)?.blogs || [];
        setProducts((prev) => [...prev, ...list]);
        setHasNext(res.pagination?.hasNext ?? false);
        setPage(nextPage);
      })
      .catch(() => {});
  };

  // Scroll Handler for Infinite Scroll
  const listRef = useRef<HTMLDivElement>(null);
  const handleScroll = () => {
    const el = listRef.current;
    if (!el) return;

    if (el.scrollTop + el.clientHeight >= el.scrollHeight - 50) {
      loadMore();
    }
  };

  const handleFilterChange = (key: string, value: string) => {
    setActiveFilters((prev) => ({ ...prev, [key]: value }));
  };
  const handleRemoveFilter = (key: string) => {
    setActiveFilters((prev) => {
      const next = { ...prev };
      delete next[key];
      return next;
    });
  };

  const toggleProduct = (id: string) => {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  const handleDone = () => {
    // Only return products currently in the list that are selected.
    // If you need to keep selections that are NOT in the current filtered list,
    // you would need to manage selectedItems state separately.
    const selected = products
      .filter((p) => selectedIds.has(p._id))
      .map(toSimilarItem);
    onDone(selected);
    onClose();
    setSelectedIds(new Set());
    setSearch("");
    setActiveFilters({});
  };

  const handleCancel = () => {
    onClose();
    setSelectedIds(new Set());
  };

  return (
    <AppModal
      open={open}
      onOpenChange={(v) => !v && handleCancel()}
      title="Search products"
      className="sm:max-w-[580px] max-h-[90vh] flex flex-col p-0 overflow-hidden"
      bodyClassName="p-0!"
      footer={
        <>
          <Button type="button" variant="outline" onClick={handleCancel}>
            Cancel
          </Button>
          <Button type="button" variant="teal" onClick={handleDone}>
            Done
          </Button>
        </>
      }
    >
      <div className="space-y-4 flex-1 min-h-0 flex flex-col">
        {/* Search & Filters */}
        <div className="flex flex-col space-y-4 px-4 pt-1">
          <div className="relative w-full">
            <div className="flex gap-3">
              <div className="relative flex-1">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  type="text"
                  placeholder="Searching all products"
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  className="w-full pl-9 pr-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                />
              </div>
              <Button
                className="rounded-lg"
                variant="outline"
                onClick={() => setSearch("")}
              >
                Clear
              </Button>
            </div>
          </div>

          <div className="flex flex-wrap items-center gap-2">
            <TableFilterRow
              availableFilters={advancedFilters}
              activeFilters={activeFilters}
              onFilterChange={handleFilterChange}
              onRemoveFilter={handleRemoveFilter}
            />
          </div>
        </div>

        {/* List with onScroll */}
        <div
          ref={listRef}
          onScroll={handleScroll}
          className="flex-1 overflow-y-auto border-t min-h-[300px] max-h-[400px]"
        >
          {(isLoading || (isFetching && products.length === 0)) && (
            <div className="p-8 text-center text-gray-500 text-sm">
              Loading products…
            </div>
          )}

          {!isLoading && !isFetching && products.length === 0 && (
            <div className="p-8 text-center text-gray-500 text-sm">
              No products found.
            </div>
          )}

          {products.length > 0 && (
            <ul className="divide-y divide-gray-200">
              {products.map((product) => {
                const checked = selectedIds.has(product._id);
                return (
                  <li key={product._id}>
                    <label
                      className={cn(
                        "flex items-center gap-3 px-4 py-3 cursor-pointer hover:bg-gray-50 transition-colors"
                      )}
                    >
                      <Checkbox
                        checked={checked}
                        onChange={() => toggleProduct(product._id)}
                      />
                      <div className="h-10 w-10 shrink-0 rounded-lg overflow-hidden bg-gray-100 border border-gray-200">
                        {product.productImage ? (
                          <AppImage
                            src={product.productImage}
                            alt={product.title}
                            width={40}
                            height={40}
                            className="object-cover w-full h-full"
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
                    </label>
                  </li>
                );
              })}
            </ul>
          )}

          {/* Bottom loader */}
          {isFetching && products.length > 0 && (
            <div className="p-4 text-center text-xs text-gray-400">
              Loading more...
            </div>
          )}
        </div>
      </div>
    </AppModal>
  );
}
