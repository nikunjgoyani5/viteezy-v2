import React from "react";
import { cn } from "@/lib/utils";
import { MdCheck } from "react-icons/md";
import { FaCheck } from "react-icons/fa";

interface CheckboxProps {
    checked: boolean;
    onChange?: (checked: boolean) => void;
    indeterminate?: boolean;
    disabled?: boolean;
}

export function Checkbox({
    checked,
    onChange,
    indeterminate,
    disabled,
}: CheckboxProps) {
    return (
        <button
            type="button"
            role="checkbox"
            aria-checked={indeterminate ? "mixed" : checked}
            disabled={disabled}
            onClick={() => onChange?.(!checked)}
            className={cn(
                "h-4 w-4 min-h-4 min-w-4 rounded border flex items-center justify-center transition-colors",
                checked || indeterminate
                    ? "bg-teal-green border-teal-green hover:bg-teal-600"
                    : "border-gray-300 bg-white",
                disabled && "opacity-50 cursor-not-allowed",
                !disabled && "hover:border-teal-green"
            )}
        >
            {(checked || indeterminate) && (
                <FaCheck className="h-2.5 w-2.5 text-white" />
            )}
        </button>
    );
}
