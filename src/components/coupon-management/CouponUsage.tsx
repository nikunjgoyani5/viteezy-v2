"use client";

import React, { useCallback, useMemo, useRef, useState } from "react";
import { useGetCouponUsageLogsQuery } from "@/store/api/couponApi";
import { formatCurrencyDashboard, timeAgo } from "@/lib/common";
import { cn } from "@/lib/utils";

export default function CouponUsage() {
  const limit = 10;
  const [page, setPage] = useState(1);

  const { data, isFetching, isLoading, isError } = useGetCouponUsageLogsQuery({
    page,
    limit,
  });

  const logs = useMemo(() => data?.data ?? [], [data?.data]);
  const pg = data?.pagination;

  const canLoadMore = !!pg?.hasNext && !isFetching;

  const containerRef = useRef<HTMLDivElement | null>(null);

  const onScroll = useCallback(() => {
    const el = containerRef.current;
    if (!el) return;

    const nearBottom = el.scrollTop + el.clientHeight >= el.scrollHeight - 40;
    if (nearBottom && canLoadMore) {
      setPage((p) => p + 1);
    }
  }, [canLoadMore]);

  if (isError) {
    return (
      <div className="w-full bg-white rounded-lg border p-4 text-red-600 text-sm sm:text-base">
        Failed to load usage logs.
      </div>
    );
  }

  return (
    <div className="w-full min-w-0 bg-white rounded-lg border">
      <div className="px-3 sm:px-4 py-3 border-b">
        <div className="text-sm sm:text-base 3xl:text-lg font-medium text-gray-900">
          Coupon Usage Logs
        </div>
      </div>

      <div
        ref={containerRef}
        onScroll={onScroll}
        className="max-h-90 sm:max-h-105 md:max-h-145 overflow-auto"
      >
        {isLoading && (
          <div className="p-4 text-sm text-gray-500">Loading...</div>
        )}

        {!isLoading && logs.length === 0 && (
          <div className="p-4 text-sm text-gray-500">No usage logs found.</div>
        )}

        {!isLoading && (
          <div className="divide-y px-2 sm:px-3 py-2 sm:py-2.5">
            {logs.map((x) => (
              <div key={x._id} className="px-2 sm:px-3 3xl:px-4 py-2.5 sm:py-3">
                <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-2 sm:gap-3">
                  <div className="min-w-0 space-y-1 flex-1">
                    <div className="font-medium text-gray-900 truncate text-sm sm:text-base 3xl:text-lg">
                      #{x.orderNumber || "-"}
                    </div>
                    <div className="text-xs sm:text-sm 3xl:text-base truncate font-medium">
                      {x.user?.firstName} {x.user?.lastName}
                    </div>
                    <div className="flex flex-wrap items-center gap-1.5 sm:gap-2 text-xs sm:text-sm 3xl:text-base font-medium">
                      <span className="text-black">Used</span>
                      <span className="bg-slate-gray text-gray-500 border px-1.5 py-0.5 text-xs 3xl:text-sm rounded-sm inline-block truncate max-w-[120px] sm:max-w-none">
                        {x.couponCode}
                      </span>
                    </div>
                    <div className="text-xs sm:text-sm 3xl:text-base wrap-break-word">
                      Flate Price:{" "}
                      <span className="font-bold">
                        {formatCurrencyDashboard(
                          x.discountAmount?.amount ?? 0,
                          x.discountAmount?.currency ?? "USD"
                        )}
                      </span>
                    </div>
                  </div>
                  <div className="text-left sm:text-right shrink-0">
                    <div className="text-xs sm:text-sm font-semibold text-gray-900">
                      {timeAgo(x.createdAt)}
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {(isFetching || canLoadMore) && (
          <div className={cn("px-3 sm:px-4 py-3")}>
            {isFetching && (
              <div className="h-20 sm:h-24 w-full bg-gray-100 rounded-lg animate-pulse" />
            )}
          </div>
        )}
      </div>
    </div>
  );
}
