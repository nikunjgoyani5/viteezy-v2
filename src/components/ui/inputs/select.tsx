"use client";

import * as React from "react";
import { cn } from "@/lib/utils";
import { Loader2 } from "lucide-react";

import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

type Option = { label: string; value: string; disabled?: boolean };

export type SelectFieldProps = {
  label?: string;
  required?: boolean;
  error?: string;
  className?: string;

  value?: string;
  defaultValue?: string;
  onValueChange?: (value: string) => void;

  placeholder?: string;
  options: Option[];
  disabled?: boolean;

  /** ✅ new */
  loading?: boolean;
};

export default function SelectField({
  label,
  required = false,
  error,
  className,
  value,
  defaultValue,
  onValueChange,
  placeholder = "Select an option",
  options,
  disabled,
  loading = false,
}: SelectFieldProps) {
  const finalDisabled = disabled || loading;

  return (
    <div className="flex flex-col gap-1">
      {label && (
        <label className="text-sm 3xl:text-base font-medium text-gray-700 mb-1">
          {label}
          {required && <span className="text-red-500">*</span>}
        </label>
      )}

      <div className="relative">
        <Select
          value={value}
          defaultValue={defaultValue}
          onValueChange={onValueChange}
          disabled={finalDisabled}
        >
          <SelectTrigger
            className={cn(
              "w-full rounded-lg border px-3 py-2.5 3xl:py-3 text-sm outline-none transition 3xl:text-base min-h-11.5",
              "focus:ring-1 focus:ring-gray-200 bg-surface-light",
              "border-extra-light-gray data-[placeholder]:text-text-gray focus:ring-teal-500",
              error && "border-red-500",
              value && "bg-white",
              className
            )}
          >
            <SelectValue placeholder={placeholder} />
          </SelectTrigger>

          <SelectContent className="bg-white border border-extra-light-gray rounded-lg">
            {options.map((opt) => (
              <SelectItem
                key={opt.value}
                value={opt.value}
                disabled={opt.disabled}
                className="text-base"
              >
                {opt.label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>

        {loading && (
          <div className="absolute inset-0 rounded-lg bg-white/40 backdrop-blur-[1px] flex items-center justify-center">
            <Loader2 className="h-5 w-5 animate-spin text-text-gray" />
          </div>
        )}
      </div>

      {error && <p className="text-xs text-red-500">{error}</p>}
    </div>
  );
}
