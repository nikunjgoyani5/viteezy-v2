"use client";

import React from "react";
import { ArrowGrowth, ArrowGrowthDown } from "@/components/icons";
import { StatsCardsSkeleton } from "@/components/dashboard/skeletons/StatsCardsSkeleton";
import { cn } from "@/lib/utils";

export interface StatItem {
  key: string;
  label: string;
  value: string | number;
  changePercentage: number;
  isPositive: boolean;
  subLabel?: string;
  hideChange?: boolean;
  customLabel?: string;
  customLabelVariant?: "default" | "warning" | "danger";
}

interface StatsGridProps {
  data: StatItem[];
  isLoading?: boolean;
  className?: string;
  /** Number of columns at xl breakpoint (and up, unless overridden by cols3xl) */
  cols?: number;
  /**
   * Optional number of columns at 3xl breakpoint.
   * Falls back to `cols` when not provided.
   */
  cols3xl?: number;
  /**
   * @deprecated Use `cols` instead. Kept for backward compatibility.
   */
  limit?: number;
}

export default function StatsGrid({
  data,
  isLoading = false,
  className = "",
  cols,
  cols3xl,
  limit,
}: StatsGridProps) {
  if (isLoading) return <StatsCardsSkeleton />;

  const totalItems = data.length;

  const COLS_SM = 2;
  const COLS_LG = 3;
  const COLS_XL = cols ?? limit ?? 5;
  const COLS_3XL = cols3xl ?? COLS_XL;

  return (
    <section>
      <div
        className={cn(
          "grid bg-white rounded-xl border overflow-hidden",
          "grid-cols-2 lg:grid-cols-3 xl:grid-cols-[repeat(var(--cols-xl),minmax(0,1fr))] 3xl:grid-cols-[repeat(var(--cols-3xl),minmax(0,1fr))]",
          className
        )}
        style={
          {
            "--cols-xl": COLS_XL,
            "--cols-3xl": COLS_3XL,
          } as React.CSSProperties
        }
      >
        {data.map((stat, index) => {
          const positive = stat.isPositive;

          const smRow = Math.floor(index / COLS_SM);
          const smTotalRows = Math.ceil(totalItems / COLS_SM);
          const isSmLastCol = (index + 1) % COLS_SM === 0;
          const isSmLastRow = smRow === smTotalRows - 1;

          const lgRow = Math.floor(index / COLS_LG);
          const lgTotalRows = Math.ceil(totalItems / COLS_LG);
          const isLgLastCol = (index + 1) % COLS_LG === 0;
          const isLgLastRow = lgRow === lgTotalRows - 1;

          const xlRow = Math.floor(index / COLS_XL);
          const xlTotalRows = Math.ceil(totalItems / COLS_XL);
          const isXlLastCol = (index + 1) % COLS_XL === 0;
          const isXlLastRow = xlRow === xlTotalRows - 1;

          const xl3Cols = COLS_3XL || 1;
          const xl3Row = Math.floor(index / xl3Cols);
          const xl3TotalRows = Math.ceil(totalItems / xl3Cols);
          const is3xlLastCol = (index + 1) % xl3Cols === 0;
          const is3xlLastRow = xl3Row === xl3TotalRows - 1;

          return (
            <div
              key={stat.key}
              className={cn(
                "p-4 3xl:p-5 flex flex-col justify-between border-gray-200",

                !isSmLastCol && "border-r",
                isSmLastCol && "border-r-0",
                !isSmLastRow && "border-b",

                !isLgLastCol && "lg:border-r lg:border-b-0",
                isLgLastCol && "lg:border-r-0",
                !isLgLastRow && "lg:border-b",

                !isXlLastCol && "xl:border-r xl:border-b-0",
                isXlLastCol && "xl:border-r-0",
                !isXlLastRow && "xl:border-b",

                !is3xlLastCol && "3xl:border-r 3xl:border-b-0",
                is3xlLastCol && "3xl:border-r-0",
                !is3xlLastRow && "3xl:border-b"
              )}
            >
              <div className="text-base font-medium text-black max-w-xs truncate">
                {stat.label}
              </div>

              <div className="my-3 3xl:my-4 text-[28px] font-semibold leading-none">
                {stat.value}
              </div>

              {/* Custom Label */}
              {stat.customLabel && (
                <span
                  className={cn(
                    "inline-flex w-fit text-sm 3xl:text-base font-medium rounded",
                    stat.customLabelVariant === "danger" && "text-red",
                    stat.customLabelVariant === "warning" && "text-orange-400",
                    (stat.customLabelVariant === "default" ||
                      !stat.customLabelVariant) &&
                      "text-gray-600"
                  )}
                >
                  {stat.customLabel}
                </span>
              )}

              {/* Change Percentage - only show if not hidden */}
              {!stat.hideChange && !stat.customLabel && (
                <div className="flex flex-wrap items-start gap-2 text-sm 3xl:text-base">
                  <span
                    className={cn(
                      "flex items-center gap-1.5 font-medium",
                      positive ? "text-green" : "text-red"
                    )}
                  >
                    {positive ? (
                      <ArrowGrowth width={18} height={18} />
                    ) : (
                      <ArrowGrowthDown width={18} height={18} />
                    )}
                    {positive ? "+" : "-"}
                    {Math.abs(stat.changePercentage)}%
                  </span>

                  <span className="text-text-gray">
                    {stat.subLabel || "vs last period"}
                  </span>
                </div>
              )}
            </div>
          );
        })}
      </div>
    </section>
  );
}
