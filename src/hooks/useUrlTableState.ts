"use client";

import { useMemo, useState } from "react";
import { usePathname, useRouter, useSearchParams } from "next/navigation";

const toInt = (v: string | null, fallback: number) => {
  const n = Number(v);
  return Number.isFinite(n) && n > 0 ? n : fallback;
};

export function useUrlTableState(opts?: {
  defaultPage?: number;
  defaultLimit?: number;
}) {
  const router = useRouter();
  const pathname = usePathname();
  const sp = useSearchParams();

  const defaultPage = opts?.defaultPage ?? 1;
  const defaultLimit = opts?.defaultLimit ?? 10;

  const [page, setPage] = useState(() => toInt(sp.get("page"), defaultPage));
  const [limit, setLimit] = useState(() =>
    toInt(sp.get("limit"), defaultLimit)
  );
  const [search, setSearch] = useState(() => sp.get("search") ?? "");

  const setUrl = (next: { page?: number; limit?: number; search?: string }) => {
    const params = new URLSearchParams(sp.toString());

    if (next.page !== undefined) params.set("page", String(next.page));
    if (next.limit !== undefined) params.set("limit", String(next.limit));

    // if (next.search !== undefined) {
    //   const s = next.search.trim();
    //   if (s) params.set("search", s);
    //   else params.delete("search");
    // }

    router.replace(`${pathname}?${params.toString()}`, { scroll: false });
  };

  const onPageChange = (p: number) => {
    setPage(p);
    setUrl({ page: p });
  };

  const onLimitChange = (l: number) => {
    setLimit(l);
    setPage(1);
    setUrl({ limit: l, page: 1 });
  };

  const onSearchChange = (s: string) => {
    setSearch(s);
    setPage(1);
    setUrl({ search: s, page: 1 });
  };

  const queryArgs = useMemo(
    () => ({
      page,
      limit,
      ...(search ? { search } : {}),
    }),
    [page, limit, search]
  );

  return {
    page,
    limit,
    search,
    queryArgs,
    onPageChange,
    onLimitChange,
    onSearchChange,
  };
}
