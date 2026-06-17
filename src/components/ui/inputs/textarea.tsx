"use client";

import React, { useState, useEffect } from "react";
import { cn } from "@/lib/utils";

interface TextareaFieldProps
  extends React.TextareaHTMLAttributes<HTMLTextAreaElement> {
  label?: string;
  preIcon?: React.ReactNode;
  className?: string;
  error?: string;
  required?: boolean;
  maxLengthCount?: number;
}

const TextareaField: React.FC<TextareaFieldProps> = ({
  label,
  preIcon,
  className,
  error,
  required = false,
  maxLengthCount,
  value,
  onChange,
  ...props
}) => {
  const showCounter = typeof maxLengthCount === "number" && maxLengthCount > 0;

  const [len, setLen] = useState(0);

  // 🔹 Sync length when value comes from API
  useEffect(() => {
    if (typeof value === "string") {
      setLen(value.length);
    }
  }, [value]);

  const handleChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setLen(e.target.value.length);
    onChange?.(e);
  };

  return (
    <div className="flex flex-col">
      {label && (
        <label className="text-sm 3xl:text-base font-medium text-gray-700 mb-2 block">
          {label}
          {required && <span className="text-red-500">*</span>}
        </label>
      )}

      <div className="relative">
        {preIcon && (
          <span className="absolute left-3 top-3 text-gray-400">{preIcon}</span>
        )}

        <textarea
          {...props}
          value={value}
          onChange={handleChange}
          maxLength={maxLengthCount}
          className={cn(
            "w-full rounded-lg border px-3 py-2.5 text-sm 3xl:text-base outline-none transition bg-white resize-y min-h-[126px] 3xl:min-h-[146px] placeholder:text-gray-400 focus:ring-1 focus:ring-teal-500",
            preIcon && "pl-10",
            showCounter && "pr-16",
            error ? "border-red-500" : "border-gray-300",
            className
          )}
        />

        {showCounter && (
          <span className="absolute right-3 bottom-3 text-sm 3xl:text-base text-gray-500 pointer-events-none">
            {len}/{maxLengthCount}
          </span>
        )}
      </div>

      {error && (
        <p className="text-xs text-red-500 -translate-y-0.75">{error}</p>
      )}
    </div>
  );
};

export default TextareaField;