"use client";

import React from "react";
import { format, isSameDay } from "date-fns";
import type { DateRange } from "react-day-picker";
import { Button } from "@/components/ui/button";
import { FaChevronDown } from "react-icons/fa6";
import { DateRangePicker } from "@/components/ui/dateRangePicker";

export default function TopSellingPlansFilters({
  range,
  onApplyRange,
  title = "Top Selling Plans",
}: {
  range?: DateRange;
  onApplyRange: (range?: DateRange) => void;
  title?: string;
}) {
  const label =
    range?.from && range?.to
      ? isSameDay(range.from, range.to)
        ? format(range.from, "MMM dd, yyyy")
        : `${format(range.from, "MMM dd, yyyy")} – ${format(
            range.to,
            "MMM dd, yyyy"
          )}`
      : "Select date range";

  return (
    <div className="flex items-center justify-between gap-3 flex-wrap">
      <h3 className="heading-sm whitespace-nowrap">{title}</h3>

      <DateRangePicker value={range} onApply={onApplyRange}>
        <Button className="textsm 3xl:text-base h-9.5 border justify-start text-left text-black font-medium bg-white hover:bg-slate-gray">
          {label}
          <FaChevronDown className="text-text-gray" size={14} />
        </Button>
      </DateRangePicker>
    </div>
  );
}
