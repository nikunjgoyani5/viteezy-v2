"use client";

import React, { useState, ChangeEvent, FocusEvent } from "react";
import { cn } from "@/lib/utils";

export interface PhoneInputProps {
    name?: string;
    value?: string;
    onChange?: (value: string) => void;
    onBlur?: () => void;
    placeholder?: string;
    label?: string;
    floating?: boolean;
    error?: string;
    className?: string;
}

const supportedCountries = ["US", "IN", "GB", "CA", "AU"];

const countryCallingCodes: Record<string, string> = {
    US: "+1",
    IN: "+91",
    GB: "+44",
    CA: "+1",
    AU: "+61",
};

const countryToFlag = (countryCode: string): string => {
    const codePoints = countryCode
        .toUpperCase()
        .split("")
        .map((char) => 127397 + char.charCodeAt(0));
    return String.fromCodePoint(...codePoints);
};

const PhoneInput = React.forwardRef<HTMLInputElement, PhoneInputProps>(
    (
        {
            name,
            value = "",
            onChange,
            onBlur,
            placeholder = "Phone Number",
            label,
            floating = false,
            error,
            className,
        },
        ref
    ) => {
        const [selectedCountry, setSelectedCountry] = useState<string>("US");
        const [isFocused, setIsFocused] = useState(false);

        const callingCode = countryCallingCodes[selectedCountry];

        // Remove calling code prefix if present
        const phoneWithoutCode = value.startsWith(callingCode)
            ? value.slice(callingCode.length).trim()
            : value;

        const formattedValue = phoneWithoutCode;
        const isActive = isFocused || formattedValue !== "";

        const handleCountryChange = (e: ChangeEvent<HTMLSelectElement>) => {
            const newCountry = e.target.value;
            setSelectedCountry(newCountry);
            const newCode = countryCallingCodes[newCountry];
            // Keep the phone number but update the calling code
            onChange?.(newCode + " " + phoneWithoutCode);
        };

        const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
            const inputValue = e.target.value;
            // Only allow numbers, spaces, hyphens, and parentheses
            const numbersOnly = inputValue.replace(/[^\d\s\-()]/g, '');
            // Construct full phone number with calling code
            onChange?.(callingCode + " " + numbersOnly);
        };

        const handleFocus = () => {
            setIsFocused(true);
        };

        const handleInternalBlur = (e: FocusEvent<HTMLInputElement>) => {
            setIsFocused(false);
            onBlur?.();
        };

        return (
            <div className="w-full flex flex-col gap-1 ">
                <div className="relative w-full">
                    {/* Country selector with flag + calling code */}
                    <div className="absolute right-2 top-1/2 -translate-y-1/2 flex items-center gap-1">
                        <select
                            value={selectedCountry}
                            onChange={handleCountryChange}
                            className="bg-transparent text-lg text-gray-700 outline-none cursor-pointer pr-1"
                        >
                            {supportedCountries.map((c) => (
                                <option key={c} value={c}>
                                    {countryToFlag(c)}
                                </option>
                            ))}
                        </select>
                    </div>

                    <input
                        ref={ref}
                        type="tel"
                        name={name}
                        value={formattedValue}
                        onChange={handleChange}
                        onFocus={handleFocus}
                        onBlur={handleInternalBlur}
                        placeholder={floating ? undefined : placeholder}
                        onKeyPress={(e) => {
                            // Prevent non-numeric characters except for space, hyphen, and parentheses
                            if (!/[\d\s\-()]/.test(e.key)) {
                                e.preventDefault();
                            }
                        }}
                        className={cn(
                            "w-full rounded-2xl border bg-white text-sm text-gray-800 focus:outline-none focus:ring-2 ps-4 pe-14 hover:border-teal-500",
                            floating ? "pt-6.5 pb-2" : "py-4",
                            error
                                ? "border-red-500 focus:ring-red-500"
                                : "border-extra-light-gray focus:ring-teal-500",
                            className
                        )}
                    />

                    {floating && (
                        <label
                            className={cn(
                                "pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 transition-all duration-200",
                                isActive
                                    ? "top-2.5 translate-y-0 text-[13px] text-teal-600"
                                    : "text-base text-medium-gray"
                            )}
                        >
                            {placeholder || label}
                        </label>
                    )}
                </div>

                {error && <p className="text-red-500 text-sm mt-1">{error}</p>}
            </div>
        );
    }
);

PhoneInput.displayName = "PhoneInput";

export default PhoneInput;
