"use client";

import React from "react";
import { format, isSameDay } from "date-fns";
import type { DateRange } from "react-day-picker";
import { Button } from "@/components/ui/button";
import { FaChevronDown } from "react-icons/fa6";
import { DateRangePicker } from "@/components/ui/dateRangePicker";
import { DURATIONS, type Duration } from "@/lib/dateUtils";

export default function FiltersNav({
  duration,
  range,
  onChangeDuration,
  onApplyRange,
  title = "Total Revenue Overview",
}: {
  duration: Duration;
  range?: DateRange;
  onChangeDuration: (d: Duration) => void;
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
    <div className="flex gap-3 flex-row flex-wrap xl:flex-nowrap lg:items-center justify-between">
      <h3 className="heading-sm flex items-center gap-2 whitespace-nowrap">
        {title}
      </h3>

      <div className="flex flex-wrap items-center gap-3 justify-end">
        <div className="border rounded-md overflow-hidden divide-x flex">
          {DURATIONS.map((item) => (
            <button
              key={item}
              onClick={() => onChangeDuration(item)}
              className={`px-3.5 py-1.5 text-sm 3xl:text-base font-medium transition-colors cursor-pointer capitalize ${
                duration === item
                  ? "bg-white text-black"
                  : "bg-slate-gray text-gray-500 hover:bg-gray-100"
              }`}
              type="button"
            >
              {item}
            </button>
          ))}
        </div>

        <DateRangePicker value={range} onApply={onApplyRange}>
          <Button className="text-sm 3xl:text-base h-9.5 border justify-start text-left text-black font-medium bg-white hover:bg-slate-gray">
            {label}
            <FaChevronDown className="text-text-gray" size={14} />
          </Button>
        </DateRangePicker>
      </div>
    </div>
  );
}
