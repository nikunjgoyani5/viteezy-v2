"use client";

import { useMemo } from "react";
import { useLazyGetProductsQuery } from "@/store/api/productsApi";
import type {
  GetProductsParams,
  ProductListItem,
} from "@/store/api/types/products.types";
import { useInfiniteLazyQuery } from "@/hooks/useInfiniteLazyQuery";

export type Option = { label: string; value: string };

export function useInfiniteProducts(
  params: Omit<GetProductsParams, "page" | "limit">
) {
  const [trigger] = useLazyGetProductsQuery();

  // ✅ normalize so "iron" and "iron " and undefined behave consistently
  const normalizedParams = useMemo(() => {
    return {
      ...params,
      search: (params.search ?? "").trim(), // always string
    };
  }, [params]);

  // ✅ stable resetKey: same search => same key => no reset/refetch
  const resetKey = useMemo(
    () => JSON.stringify(normalizedParams),
    [normalizedParams]
  );

  return useInfiniteLazyQuery<
    Omit<GetProductsParams, "page" | "limit">,
    ProductListItem,
    Option
  >({
    args: normalizedParams,
    // Cast trigger to match the relaxed trigger function signature used in useInfiniteLazyQuery
    trigger: trigger as any,
    resetKey,
    limit: 10,
    selectItems: (res: any) => res?.data ?? [],
    selectPagination: (res: any) => res?.pagination,
    mapItem: (x) => ({ label: x.title, value: x._id }),
    getKey: (o) => o.value,
  });
}
