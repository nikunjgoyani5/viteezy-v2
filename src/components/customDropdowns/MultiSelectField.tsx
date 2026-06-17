"use client";

import React, { useMemo, useState } from "react";
import { ChevronDown, Search, X, Check } from "lucide-react";
import { cn } from "@/lib/utils";
import { Badge } from "@/components/ui/badge";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Checkbox } from "../ui/table";

export type Option = {
  label: string;
  value: string;
};

interface MultiSelectFieldProps {
  options: Option[];
  value?: string[]; // Array of selected values
  onChange: (value: string[]) => void;
  placeholder?: string;
  label?: string;
  required?: boolean;
  error?: string;
  disabled?: boolean;
  className?: string;
  isSearch?: boolean;
}

export default function MultiSelectField({
  options,
  value = [],
  onChange,
  placeholder = "Select options...",
  label,
  required,
  error,
  disabled,
  className,
  isSearch = true,
}: MultiSelectFieldProps) {
  const [searchValue, setSearchValue] = useState("");

  const filteredOptions = useMemo(() => {
    if (!searchValue) return options;
    return options.filter((o) =>
      o.label.toLowerCase().includes(searchValue.toLowerCase())
    );
  }, [options, searchValue]);

  const handleUnselect = (item: string) => {
    onChange(value.filter((i) => i !== item));
  };

  const toggleOption = (val: string) => {
    if (value.includes(val)) {
      onChange(value.filter((v) => v !== val));
    } else {
      onChange([...value, val]);
    }
  };

  return (
    <div className={cn("flex flex-col gap-1.5 w-full", className)}>
      {label && (
        <label className="text-sm 3xl:text-base font-medium text-gray-700">
          {label} {required && <span className="text-red-500">*</span>}
        </label>
      )}

      <DropdownMenu>
        <DropdownMenuTrigger asChild disabled={disabled}>
          <button
            type="button"
            className={cn(
              "flex min-h-[46px] w-full focus:bg-white items-center justify-between rounded-lg border border-gray-200 bg-surface-light px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-teal-500 transition disabled:opacity-60 disabled:cursor-not-allowed",
              error && "border-red-500",
              value.length !== 0 && "bg-white"
            )}
          >
            <div className="flex flex-wrap gap-1">
              {value.length === 0 && (
                <span className="text-gray-500">{placeholder}</span>
              )}
              {value.map((item) => {
                const label =
                  options.find((opt) => opt.value === item)?.label || item;
                return (
                  <span
                    key={label}
                    className="inline-flex items-center gap-1 rounded-sm border border-extra-light-gray bg-extra-light-gray px-2 py-0.5 text-xs 3xl:text-sm text-gray-800"
                  >
                    <span className="max-w-[180px] truncate">{item}</span>
                    <button
                      type="button"
                      onPointerDown={(e) => {
                        e.preventDefault();
                        e.stopPropagation();
                      }}
                      onClick={(e) => {
                        e.preventDefault();
                        e.stopPropagation();
                        handleUnselect(item);
                      }}
                      className="cursor-pointer"
                      aria-label={`Remove ${label}`}
                    >
                      <X className="h-3.75 w-3.75" strokeWidth={2} />
                    </button>
                  </span>
                );
              })}
            </div>
            <ChevronDown className="h-4 w-4 shrink-0 opacity-50 ml-2" />
          </button>
        </DropdownMenuTrigger>

        <DropdownMenuContent
          align="start"
          className="w-[var(--radix-dropdown-menu-trigger-width)] p-1 rounded-lg"
        >
          {/* Search Input */}
          {isSearch && (
            <div className="p-2 bg-white">
              <div className="flex items-center gap-2 rounded-md border border-extra-light-gray px-2 py-1.5">
                <Search className="h-4 w-4 text-text-gray" />
                <input
                  value={searchValue}
                  onChange={(e) => setSearchValue(e.target.value)}
                  placeholder="Search..."
                  className="w-full outline-none text-sm"
                  onKeyDown={(e) => e.stopPropagation()} // Prevent menu close on space
                />
              </div>
            </div>
          )}

          {/* Options List */}
          <div className="max-h-64 overflow-auto p-1 pt-0 bg-white">
            {filteredOptions.length === 0 ? (
              <div className="px-2 py-3 text-sm text-text-gray text-center">
                No results found.
              </div>
            ) : (
              filteredOptions.map((option) => {
                const isSelected = value.includes(option.value);
                return (
                  <button
                    key={option.value}
                    type="button"
                    onClick={() => toggleOption(option.value)}
                    className={cn(
                      "w-full flex items-center gap-2 px-2 py-2 rounded-md hover:bg-slate-gray text-left text-sm transition-colors",
                      isSelected && "bg-slate-gray/50"
                    )}
                  >
                    <Checkbox checked={isSelected} />
                    <span className="truncate">{option.label}</span>
                  </button>
                );
              })
            )}
          </div>
        </DropdownMenuContent>
      </DropdownMenu>

      {error && <p className="text-xs text-red-500">{error}</p>}
    </div>
  );
}
