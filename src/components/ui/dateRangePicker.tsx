"use client";

import * as React from "react";
import { format } from "date-fns";
import { DateRange } from "react-day-picker";
import { Calendar } from "@/components/ui/calendar";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { Button } from "@/components/ui/button";

export function DateRangePicker({
  value,
  onApply,
  children,
}: {
  value?: DateRange;
  onApply: (range?: DateRange) => void;
  children: React.ReactNode;
}) {
  const [range, setRange] = React.useState<DateRange | undefined>(value);
  const [open, setOpen] = React.useState(false);

  React.useEffect(() => setRange(value), [value]);

  const canApply = !!range?.from && !!range?.to;

  const fromLabel = range?.from
    ? format(range.from, "dd MMM yyyy")
    : "Start date";
  const toLabel = range?.to ? format(range.to, "dd MMM yyyy") : "End date";

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>{children}</PopoverTrigger>

      <PopoverContent
        align="end"
        side="bottom"
        className="min-w-fit p-0 bg-white rounded-lg"
      >
        {/* Top selected range display */}
        <div className="mb-3 grid grid-cols-2 gap-2 text-center p-2.5">
          <div className="rounded-md border bg-white px-3 py-2">
            <div className="text-base font-medium text-black">{fromLabel}</div>
          </div>
          <div className="rounded-md border bg-white px-3 py-2">
            <div className="text-base font-medium text-black">{toLabel}</div>
          </div>
        </div>

        <Calendar
          mode="range"
          numberOfMonths={1} // ✅ single month only
          selected={range}
          onSelect={setRange}
          className="w-full px-2.5 pb-2.5 pt-0"
          //   classNames={{
          //     day_today:
          //       "relative after:absolute after:bottom-1 after:left-1/2 after:h-[2px] after:w-4 after:-translate-x-1/2 after:bg-black",
          //     day_selected: "bg-black text-white hover:bg-black",
          //     day_range_middle: "bg-gray-100 text-black",
          //   }}
        />

        <div className="mt-4 flex items-center justify-end gap-2 border-t p-2.5">
          <Button
            className="text-red text-base"
            variant="ghost"
            size="sm"
            onClick={() => {
              setRange(undefined);
              onApply(undefined);
              setOpen(false);
            }}
          >
            Clear all
          </Button>

          <Button
            className="text-base px-3.5"
            variant="teal"
            size="default"
            disabled={!canApply}
            onClick={() => {
              onApply(range);
              setOpen(false);
            }}
          >
            Apply
          </Button>
        </div>
      </PopoverContent>
    </Popover>
  );
}
