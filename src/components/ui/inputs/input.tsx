"use client";

import React, { forwardRef, useEffect, useRef, useState } from "react";
import { cn } from "@/lib/utils";

export interface InputFieldProps
  extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  preIcon?: React.ReactNode;
  postIcon?: React.ReactNode;
  className?: string;
  error?: string;
  required?: boolean;
  maxLengthCount?: number;
  syncKey?: string | number;
  noDecimals?: boolean;
}

const InputField = forwardRef<HTMLInputElement, InputFieldProps>(
  (
    {
      label,
      preIcon,
      postIcon,
      className,
      error,
      required = false,
      maxLengthCount,
      onChange,
      defaultValue,
      syncKey,
      noDecimals = false,
      ...props
    },
    ref
  ) => {
    const showCounter =
      typeof maxLengthCount === "number" && maxLengthCount > 0;

    const innerRef = useRef<HTMLInputElement | null>(null);

    const setRefs = (el: HTMLInputElement | null) => {
      innerRef.current = el;

      if (typeof ref === "function") ref(el);
      else if (ref)
        (ref as React.MutableRefObject<HTMLInputElement | null>).current = el;
    };

    const [len, setLen] = useState(0);

    useEffect(() => {
      if (typeof props.value === "string") {
        setLen(props.value.length);
        return;
      }
      const v = innerRef.current?.value ?? "";
      setLen(v.length);
    }, [defaultValue, syncKey, props.value]);

    return (
      <div className="flex flex-col gap-1 w-full">
        {label && (
          <label className="text-sm 3xl:text-base font-medium text-gray-700 mb-1">
            {label}
            {required && <span className="text-red-500">*</span>}
          </label>
        )}

        <div className="relative">
          {preIcon && (
            <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">
              {preIcon}
            </span>
          )}

          {postIcon && (
            <span className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400">
              {postIcon}
            </span>
          )}

          <input
            ref={setRefs}
            {...props}
            placeholder={props.placeholder ?? " "}
            defaultValue={defaultValue}
            maxLength={showCounter ? maxLengthCount : props.maxLength}
            onKeyDown={(e) => {
              if (props.type === "number") {
                const block =
                  ["e", "E", "+", "-"].includes(e.key) ||
                  (noDecimals && e.key === ".");
                if (block) e.preventDefault();
              }
              props.onKeyDown?.(e);
            }}
            onChange={(e) => {
              setLen(e.currentTarget.value.length);
              onChange?.(e);
            }}
            className={cn(
              "w-full rounded-lg border px-3 py-2.5 3xl:py-3 text-sm 3xl:text-base outline-none transition focus:ring-1 focus:ring-gray-200 placeholder:text-text-gray",
              "bg-white placeholder-shown:bg-surface-light focus:bg-white focus:ring-teal-500",
              preIcon && "pl-10",
              showCounter && "pr-16",
              error ? "border-red-500" : "border-extra-light-gray",
              className
            )}
            onWheel={(e) => (e.target as HTMLInputElement).blur()}
          />

          {showCounter && (
            <span className="absolute right-3 top-1/2 -translate-y-1/2 text-sm 3xl:text-base text-text-gray pointer-events-none">
              {len}/{maxLengthCount}
            </span>
          )}
        </div>

        {error && <p className="text-xs text-red-500">{error}</p>}
      </div>
    );
  }
);

InputField.displayName = "InputField";
export default InputField;
