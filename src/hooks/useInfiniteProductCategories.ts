"use client";

import { useMemo } from "react";
import { useInfiniteLazyQuery } from "@/hooks/useInfiniteLazyQuery";
import { useLazyGetProductCategoriesQuery } from "@/store/api/productCategoriesApi";

export type Option = { label: string; value: string };

type CategoryItem = {
  _id: string;
  name: string;
  isActive?: boolean;
  isDeleted?: boolean;
};

type GetProductCategoriesParams = {
  search?: string;
};

export function useInfiniteProductCategories(
  params: GetProductCategoriesParams
) {
  const [trigger] = useLazyGetProductCategoriesQuery();

  const normalizedArgs = useMemo<GetProductCategoriesParams>(() => {
    const s = (params.search ?? "").trim();

    // ✅ If blank, don't include `search` key at all
    return s ? { search: s } : {};
  }, [params.search]);

  const resetKey = useMemo(
    () => JSON.stringify(normalizedArgs),
    [normalizedArgs]
  );

  return useInfiniteLazyQuery<GetProductCategoriesParams, CategoryItem, Option>(
    {
      args: normalizedArgs,
      // Cast trigger to align with the generic trigger signature expected by useInfiniteLazyQuery
      trigger: trigger as any,
      resetKey,
      limit: 10,

      // filter locally (no isActive/isDeleted sent to API)
      selectItems: (res) => {
        const list: CategoryItem[] = (res as any)?.data ?? [];
        return list.filter(
          (c) => c?.isActive !== false && c?.isDeleted !== true
        );
      },

      selectPagination: (res) => (res as any)?.pagination,
      mapItem: (x) => ({ label: x.name, value: x._id }),
      getKey: (o) => o.value,
    }
  );
}
