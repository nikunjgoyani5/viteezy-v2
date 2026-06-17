"use client";

import * as React from "react";
import { format, startOfDay } from "date-fns";
import { CalendarClock, CalendarDays } from "lucide-react";

import { cn } from "@/lib/utils";
import { Calendar } from "@/components/ui/calendar";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogTrigger } from "@/components/ui/dialog";
import { IoClose } from "react-icons/io5";

type Period = "AM" | "PM";

export type DateTimePickerFieldProps = {
  label?: string;
  required?: boolean;
  error?: string;
  disabled?: boolean;

  /** Controlled value in `yyyy-MM-dd'T'HH:mm` (local time), or empty string. */
  value: string;
  onChange: (next: string) => void;

  placeholder?: string;
  icon?: React.ReactNode;

  /** Single date selection always; shows time selector when true. */
  showTime?: boolean;
  timeLabel?: string;
  minuteStep?: number; // default 5
  use12Hour?: boolean; // default true
  defaultTime?: { hour: number; minute: number; period?: Period }; // hour: 1-12 when use12Hour, else 0-23

  /** When set, disables all dates before this (e.g. for end date: pass start date). When unset, disables dates before today. */
  minDate?: Date | null;
};

function parseLocalDateTime(v: string): Date | null {
  if (!v) return null;
  const d = new Date(v);
  return Number.isNaN(d.getTime()) ? null : d;
}

function toLocalDateTimeValue(d: Date): string {
  // Use local time parts (not ISO) for datetime-local style.
  return `${format(d, "yyyy-MM-dd")}T${format(d, "HH:mm")}`;
}

function pad2(n: number) {
  return String(n).padStart(2, "0");
}

export default function DateTimePickerField({
  label,
  required = false,
  error,
  disabled,
  value,
  onChange,
  placeholder = "Select date",
  icon,
  showTime = true,
  timeLabel = "Select Time",
  minuteStep = 5,
  use12Hour = true,
  defaultTime = { hour: 10, minute: 0, period: "AM" },
  minDate,
}: DateTimePickerFieldProps) {
  const disabledMatcher = React.useMemo(
    () =>
      minDate != null
        ? { before: startOfDay(minDate) }
        : { before: startOfDay(new Date()) },
    [minDate]
  );
  const [open, setOpen] = React.useState(false);

  const committed = React.useMemo(() => parseLocalDateTime(value), [value]);

  const [displayedMonth, setDisplayedMonth] = React.useState<Date>(
    () => committed ?? minDate ?? new Date()
  );
  const [draftDate, setDraftDate] = React.useState<Date | null>(committed);
  const [draftHour, setDraftHour] = React.useState<number>(
    use12Hour ? defaultTime.hour : defaultTime.hour
  );
  const [draftMinute, setDraftMinute] = React.useState<number>(
    defaultTime.minute
  );
  const [draftPeriod, setDraftPeriod] = React.useState<Period>(
    defaultTime.period ?? "AM"
  );

  // Sync draft state and displayed month when opening.
  React.useEffect(() => {
    if (!open) return;
    const d = committed;
    setDraftDate(d);
    setDisplayedMonth(d ?? minDate ?? new Date());
    if (!d) {
      setDraftHour(use12Hour ? defaultTime.hour : defaultTime.hour);
      setDraftMinute(defaultTime.minute);
      setDraftPeriod(defaultTime.period ?? "AM");
      return;
    }

    const h24 = d.getHours();
    const m = d.getMinutes();
    setDraftMinute(m);

    if (use12Hour) {
      const period: Period = h24 >= 12 ? "PM" : "AM";
      const h12 = h24 % 12 === 0 ? 12 : h24 % 12;
      setDraftHour(h12);
      setDraftPeriod(period);
    } else {
      setDraftHour(h24);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open]);

  const displayLabel = React.useMemo(() => {
    if (!committed) return placeholder;
    return showTime
      ? format(committed, "MMM dd, yyyy • hh:mm a")
      : format(committed, "MMM dd, yyyy");
  }, [committed, placeholder, showTime]);

  const applyEnabled = !!draftDate;

  const hourOptions = React.useMemo(() => {
    if (use12Hour) return Array.from({ length: 12 }, (_, i) => i + 1);
    return Array.from({ length: 24 }, (_, i) => i);
  }, [use12Hour]);

  const minuteOptions = React.useMemo(() => {
    const step = Math.max(1, Math.min(60, minuteStep));
    const out: number[] = [];
    for (let m = 0; m < 60; m += step) out.push(m);
    return out;
  }, [minuteStep]);

  const buildAppliedDate = React.useCallback((): Date | null => {
    if (!draftDate) return null;
    const d = new Date(draftDate);
    if (!showTime) {
      d.setHours(0, 0, 0, 0);
      return d;
    }

    let h = draftHour;
    if (use12Hour) {
      const base = h % 12; // 12 -> 0
      h = draftPeriod === "PM" ? base + 12 : base;
    }
    d.setHours(h, draftMinute, 0, 0);
    return d;
  }, [draftDate, draftHour, draftMinute, draftPeriod, showTime, use12Hour]);

  return (
    <div className="flex flex-col gap-1">
      {label ? (
        <label className="text-sm 3xl:text-base font-medium text-gray-700 mb-1">
          {label}
          {required && <span className="text-red-500">*</span>}
        </label>
      ) : null}

      <Dialog open={open} onOpenChange={setOpen}>
        <DialogTrigger asChild>
          <button
            type="button"
            disabled={disabled}
            className={cn(
              "w-full rounded-lg border px-3 py-2.5 3xl:py-3 text-sm  outline-none transition text-left cursor-pointer",
              "bg-white focus:ring-1 focus:ring-teal-500",
              "border-extra-light-gray",
              disabled && "opacity-60 cursor-not-allowed",
              error && "border-red-500"
            )}
          >
            <div className="flex items-center justify-between gap-3">
              <span
                className={cn(
                  "truncate",
                  !committed ? "text-text-gray" : "text-gray-900"
                )}
              >
                {displayLabel}
              </span>
              <span className="shrink-0">
                {icon ?? <CalendarClock size={20} />}
              </span>
            </div>
          </button>
        </DialogTrigger>

        <DialogContent
          showCloseButton={false}
          className=" p-0 gap-0 bg-white rounded-lg overflow-hidden flex flex-col max-h-[90vh]"
        >
          <div className="flex items-center px-3.5 py-3 gap-3 justify-between border-b">
            <span className="text-xl font-medium">Select Date</span>
            <IoClose
              className="bg-surface-light w-10 h-10 p-2 rounded-full cursor-pointer"
              onClick={() => setOpen(false)}
            />
          </div>
          {/* Scrollable body so calendar + time fit on small screens */}
          <div className="overflow-y-auto flex-1 min-h-0">
            <div className="flex items-center px-3.5 pt-5 gap-3 mb-3">
              <div className="px-3 py-2.5 text-center border rounded-md w-full">
                <div className="text-sm font-medium text-gray-900">
                  {draftDate
                    ? format(draftDate, "MMM dd, yyyy")
                    : "Select date"}
                </div>
              </div>
            </div>

            <Calendar
              mode="single"
              numberOfMonths={1}
              month={displayedMonth}
              onMonthChange={setDisplayedMonth}
              selected={draftDate ?? undefined}
              onSelect={(d) => setDraftDate(d ?? null)}
              disabled={disabledMatcher}
              startMonth={minDate ?? new Date()}
              endMonth={new Date(2035, 11)}
              className="w-full px-2.5 pb-2.5 pt-2"
            />

            {showTime ? (
              <div className="px-3 py-3 3xl:py-6 bg-surface-light">
                <div className="text-sm 3xl:text-base text-center font-medium text-gray-900 mb-2">
                  {timeLabel}
                </div>

                <div className="flex items-center gap-1.5 justify-center text-sm 3xl:text-base font-medium">
                  <select
                    disabled={disabled}
                    value={String(draftHour)}
                    onChange={(e) => setDraftHour(Number(e.target.value))}
                    className="h-10 rounded-lg border border-extra-light-gray bg-white px-3 outline-none focus:ring-1 focus:ring-teal-500"
                  >
                    {hourOptions.map((h) => (
                      <option key={h} value={h}>
                        {use12Hour ? h : pad2(h)}
                      </option>
                    ))}
                  </select>
                  :
                  <select
                    disabled={disabled}
                    value={String(draftMinute)}
                    onChange={(e) => setDraftMinute(Number(e.target.value))}
                    className="h-10 rounded-lg border border-extra-light-gray bg-white px-3 outline-none focus:ring-1 focus:ring-teal-500"
                  >
                    {minuteOptions.map((m) => (
                      <option key={m} value={m}>
                        {pad2(m)}
                      </option>
                    ))}
                  </select>
                  :
                  {use12Hour ? (
                    <select
                      disabled={disabled}
                      value={draftPeriod}
                      onChange={(e) => setDraftPeriod(e.target.value as Period)}
                      className="h-10 rounded-lg border border-extra-light-gray bg-white px-3 outline-none focus:ring-1 focus:ring-teal-500"
                    >
                      <option value="AM">AM</option>
                      <option value="PM">PM</option>
                    </select>
                  ) : null}
                </div>
              </div>
            ) : null}
          </div>

          {/* Sticky footer – always visible at bottom of dialog */}
          <div className="flex items-center justify-end gap-2 border-t p-2.5 shrink-0 bg-white">
            <Button
              className="text-red text-base"
              variant="ghost"
              size="sm"
              onClick={() => {
                setDraftDate(null);
                onChange("");
                setOpen(false);
              }}
              disabled={disabled}
            >
              Clear all
            </Button>

            <Button
              className="text-base px-3.5"
              variant="teal"
              size="default"
              disabled={!applyEnabled || disabled}
              onClick={() => {
                const next = buildAppliedDate();
                onChange(next ? toLocalDateTimeValue(next) : "");
                setOpen(false);
              }}
            >
              Apply
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      {error ? <p className="text-xs text-red-500">{error}</p> : null}
    </div>
  );
}
