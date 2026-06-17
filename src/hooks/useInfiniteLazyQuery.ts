"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";

type PaginationLike = {
  hasNext?: boolean;
  pages?: number;
  page?: number;
};

type InfiniteLazyQueryOptions<TArgs, TItem, TMapped> = {
  args: TArgs;
  trigger: (args: unknown) => { unwrap: () => Promise<unknown> };
  selectItems: (res: unknown) => TItem[];
  selectPagination: (res: unknown) => PaginationLike | undefined;
  mapItem: (item: TItem) => TMapped;
  limit?: number;
  getKey?: (mapped: TMapped) => string;
  resetKey?: string;
};

export function useInfiniteLazyQuery<TArgs, TItem, TMapped>({
  args,
  trigger,
  selectItems,
  selectPagination,
  mapItem,
  limit = 10,
  getKey,
  resetKey,
}: InfiniteLazyQueryOptions<TArgs, TItem, TMapped>) {
  const [items, setItems] = useState<TMapped[]>([]);
  const [page, setPage] = useState(1);
  const [hasNext, setHasNext] = useState(true);

  const loadedPagesRef = useRef(new Set<string>());
  const inFlightRef = useRef(false);

  const keyBase = useMemo(() => {
    if (resetKey) return resetKey;
    return JSON.stringify({ args, limit });
  }, [resetKey, args, limit]);

  useEffect(() => {
    setItems([]);
    setPage(1);
    setHasNext(true);
    loadedPagesRef.current = new Set();
    inFlightRef.current = false;
  }, [keyBase]);

  const fetchPage = useCallback(
    async (p: number) => {
      const pageKey = `${keyBase}|page=${p}`;

      if (loadedPagesRef.current.has(pageKey)) return;
      if (inFlightRef.current) return;
      if (!hasNext && p !== 1) return;

      inFlightRef.current = true;
      loadedPagesRef.current.add(pageKey);

      try {
        const res = await trigger({
          ...args,
          page: p,
          limit,
        }).unwrap();

        const raw = selectItems(res) ?? [];
        const mapped = raw.map(mapItem);

        setItems((prev) => {
          const next = p === 1 ? mapped : [...prev, ...mapped];

          if (!getKey) return next;

          const seen = new Set<string>();
          return next.filter((x) => {
            const k = getKey(x);
            if (seen.has(k)) return false;
            seen.add(k);
            return true;
          });
        });

        const pg = selectPagination(res);
        if (typeof pg?.hasNext === "boolean") setHasNext(pg.hasNext);
        else if (typeof pg?.pages === "number" && typeof pg?.page === "number")
          setHasNext(pg.page < pg.pages);

        setPage(p);
      } finally {
        inFlightRef.current = false;
      }
    },
    [
      args,
      limit,
      trigger,
      selectItems,
      selectPagination,
      mapItem,
      getKey,
      keyBase,
      hasNext,
    ]
  );

  useEffect(() => {
    fetchPage(1);
  }, [fetchPage]);

  const loadNext = useCallback(() => {
    if (inFlightRef.current || !hasNext) return;
    fetchPage(page + 1);
  }, [fetchPage, page, hasNext]);

  return {
    items,
    isFetching: inFlightRef.current,
    hasNext,
    page,
    loadNext,
    resetKey: keyBase,
  };
}
