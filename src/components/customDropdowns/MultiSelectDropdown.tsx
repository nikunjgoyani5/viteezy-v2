"use client";

import React, { useMemo, useRef } from "react";
import { cn } from "@/lib/utils";
import { ChevronDown, Loader2, Search, X } from "lucide-react";

import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Checkbox } from "../ui/table";

export type MultiSelectOption = {
  label: string;
  value: string;
};

type MultiSelectDropdownProps = {
  label?: string;
  required?: boolean;
  error?: string;
  disabled?: boolean;

  placeholder?: string;

  value: string[];
  onChange: (next: string[]) => void;

  options: MultiSelectOption[];

  searchValue?: string;
  onSearchChange?: (value: string) => void;
  searchPlaceholder?: string;

  showSelectAll?: boolean;
  className?: string;

  onScrollEnd?: () => void;
  loading?: boolean;
};

export default function MultiSelectDropdown({
  label,
  required,
  error,
  disabled,
  placeholder = "Select...",
  value,
  onChange,
  options,
  searchValue = "",
  onSearchChange,
  searchPlaceholder = "Search...",
  showSelectAll = true,
  className,
  onScrollEnd,
  loading = false,
}: MultiSelectDropdownProps) {
  const selectedSet = useMemo(() => new Set(value), [value]);

  const selectedLabels = useMemo(() => {
    const map = new Map(options.map((o) => [o.value, o.label]));
    return value.map((v) => ({ value: v, label: map.get(v) ?? v }));
  }, [value, options]);

  const allSelected =
    options.length > 0 && options.every((o) => selectedSet.has(o.value));

  const toggleOne = (id: string) => {
    if (selectedSet.has(id)) onChange(value.filter((v) => v !== id));
    else onChange([...value, id]);
  };

  const toggleSelectAll = () => {
    if (allSelected) onChange([]);
    else onChange(options.map((o) => o.value));
  };

  const removeChip = (id: string) => {
    onChange(value.filter((v) => v !== id));
  };

  const summary =
    value.length === 0
      ? placeholder
      : `${value.length} ${value.length > 1 ? "items" : "item"} selected`;
  // const summary = placeholder;

  const listRef = useRef<HTMLDivElement | null>(null);

  const handleScroll: React.UIEventHandler<HTMLDivElement> = () => {
    if (!onScrollEnd) return;
    const el = listRef.current;
    if (!el) return;

    const nearBottom = el.scrollTop + el.clientHeight >= el.scrollHeight - 40;
    if (nearBottom && !loading) onScrollEnd();
  };

  return (
    <div className={cn("flex flex-col gap-1", className)}>
      {label && (
        <label className="text-sm 3xl:text-base font-medium text-gray-700">
          {label} {required && <span className="text-red-500">*</span>}
        </label>
      )}

      <DropdownMenu>
        <DropdownMenuTrigger asChild disabled={disabled} className="cursor-pointer">
          <button
            type="button"
            className={cn(
              "w-full min-h-11.5 rounded-lg border px-3 py-2.5 bg-surface-light",
              "flex items-center justify-between gap-3 text-left text-sm 3xl:text-base",
              "outline-none transition focus:ring-1 focus:ring-teal-500",
              error ? "border-red-500" : "border-extra-light-gray",
              disabled && "opacity-60 cursor-not-allowed"
            )}
          >
            <span
              className={cn("truncate", value.length === 0 && "text-text-gray")}
            >
              {summary}
            </span>
            <ChevronDown className="h-4 w-4 text-text-gray shrink-0" />
          </button>
        </DropdownMenuTrigger>

        <DropdownMenuContent
          ref={listRef}
          onScroll={handleScroll}
          align="start"
          className="w-[var(--radix-dropdown-menu-trigger-width)] p-0! rounded-lg max-h-100"
        >
          {/* Search UI (parent controlled) */}
          <div className=" bg-white sticky top-0">
            <div className="p-2">
              <div className="flex items-center gap-2 rounded-md border border-extra-light-gray px-2 py-1.5">
                <Search className="h-4 3xl:h-5 w-4 3xl:w-5 text-text-gray" />
                <input
                  value={searchValue}
                  onChange={(e) => onSearchChange?.(e.target.value)}
                  placeholder={searchPlaceholder}
                  className="w-full outline-none text-sm 3xl:text-base"
                />
              </div>
            </div>
          </div>

          {/* Options list */}
          {/* <div className="max-h-84 overflow-auto p-1 pt-0 bg-white"> */}
          <div className="overflow-auto p-1 pt-0 bg-white">
            {showSelectAll && (
              <button
                type="button"
                onClick={toggleSelectAll}
                className="w-full flex items-center gap-2 px-2 py-2 rounded-md hover:bg-slate-gray text-left"
              >
                <input
                  type="checkbox"
                  checked={allSelected}
                  readOnly
                  className="accent-teal-500"
                />
                <span className="text-xs 3xl:text-sm font-medium">
                  Select all
                </span>
              </button>
            )}

            {options.map((o) => {
              const checked = selectedSet.has(o.value);
              return (
                <button
                  key={o.value}
                  type="button"
                  onClick={() => toggleOne(o.value)}
                  className="w-full flex items-center gap-2 px-2 py-2 rounded-md hover:bg-slate-gray text-left cursor-pointer"
                >
                  <Checkbox checked={checked} />
                  <span className="text-sm 3xl:text-base font-medium">
                    {o.label}
                  </span>
                </button>
              );
            })}

            {!loading && options.length === 0 && (
              <div className="px-2 py-3 text-sm text-text-gray">No results</div>
            )}

            {loading && (
              <div className="px-2 py-3 flex items-center justify-center gap-2 text-text-gray">
                <Loader2 className="h-4 w-4 animate-spin" />
                <span className="text-xs 3xl:text-sm">Loading...</span>
              </div>
            )}
          </div>
        </DropdownMenuContent>
      </DropdownMenu>

      {/* Selected chips under field */}
      {value.length > 0 && (
        <div className="flex flex-wrap gap-2 pt-2.5">
          {selectedLabels.map((s) => (
            <span
              key={s.value}
              className="inline-flex items-center gap-1 rounded-sm border border-extra-light-gray bg-extra-light-gray px-2.5 py-1 text-xs 3xl:text-sm text-gray-800"
            >
              <span className="max-w-[180px] truncate">{s.label}</span>
              <button
                type="button"
                onClick={() => removeChip(s.value)}
                className="cursor-pointer"
                aria-label={`Remove ${s.label}`}
              >
                <X className="h-3.75 w-3.75" strokeWidth={2} />
              </button>
            </span>
          ))}
        </div>
      )}

      {error && <p className="text-xs text-red-500">{error}</p>}
    </div>
  );
}
