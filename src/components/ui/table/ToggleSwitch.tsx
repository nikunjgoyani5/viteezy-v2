import React from "react";
import { cn } from "@/lib/utils";

interface ToggleSwitchProps {
    checked: boolean;
    onChange?: (checked: boolean) => void;
    disabled?: boolean;
}

export function ToggleSwitch({ checked, onChange, disabled }: ToggleSwitchProps) {
    return (
        <label className="switch inline-block cursor-pointer">
            <input
                type="checkbox"
                checked={checked}
                onChange={e => onChange?.(e.target.checked)}
                disabled={disabled}
                className="appearance-none h-6 w-11 relative rounded-sm cursor-pointer transition-colors
                bg-gray-300
                checked:bg-teal-green
                before:content-[''] before:block before:h-[1.4em] before:w-[1.4em] 
                before:absolute before:top-1/2 before:left-[calc(1.4em/2+0.2em)]
                before:-translate-x-1/2 before:-translate-y-1/2 
                before:bg-white before:rounded-sm before:transition-all before:duration-300
                checked:before:bg-white checked:before:left-[calc(100%-1.4em/2-0.2em)]
                disabled:opacity-50 disabled:cursor-not-allowed"
            />
        </label>
    );
}
