import React from "react";
import { cn } from "@/lib/utils";

interface StatusBadgeProps {
    status: "active" | "inactive" | "pending";
    className?: string;
}

export function StatusBadge({ status, className }: StatusBadgeProps) {
    const colors = {
        active: "bg-green-100 text-green-800",
        inactive: "bg-gray-100 text-gray-800",
        pending: "bg-yellow-100 text-yellow-800",
    };

    return (
        <span
            className={cn(
                "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium",
                colors[status],
                className
            )}
        >
            {status.charAt(0).toUpperCase() + status.slice(1)}
        </span>
    );
}
