"use client";

import React from "react";
import { cn } from "@/lib/utils";

interface RadioOption {
    label: string;
    value: string | boolean;
}

interface RadioGroupProps {
    label?: string;
    options: RadioOption[];
    value: string | boolean;
    onChange: (value: string | boolean) => void;
    className?: string;
    error?: string;
    required?: boolean;
}

export default function RadioGroup({
    label,
    options,
    value,
    onChange,
    className,
    error,
    required = false,
}: RadioGroupProps) {
    return (
        <div className={cn("flex flex-col gap-2", className)}>
            {label && (
                <label className="text-sm 3xl:text-base font-medium text-gray-700">
                    {label}
                    {required && <span className="text-red-500 ml-1">*</span>}
                </label>
            )}

            <div className="flex flex-col gap-3">
                {options.map((option) => (
                    <label
                        key={String(option.value)}
                        className="flex items-center gap-3 cursor-pointer group"
                    >
                        <div className="relative flex items-center justify-center">
                            <input
                                type="radio"
                                checked={value === option.value}
                                onChange={() => onChange(option.value)}
                                className="sr-only"
                            />
                            <div
                                className={cn(
                                    "w-5 h-5 rounded-full border-2 flex items-center justify-center transition-colors",
                                    value === option.value
                                        ? "border-teal-500 bg-white"
                                        : "border-gray-300 bg-white group-hover:border-teal-400"
                                )}
                            >
                                {value === option.value && (
                                    <div className="w-2.5 h-2.5 rounded-full bg-teal-500" />
                                )}
                            </div>
                        </div>
                        <span className="text-sm text-gray-700 select-none">
                            {option.label}
                        </span>
                    </label>
                ))}
            </div>

            {error && <p className="text-xs text-red-500">{error}</p>}
        </div>
    );
}
