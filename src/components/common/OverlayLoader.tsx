"use client";

import React from "react";
import { cn } from "@/lib/utils";
import { Loader2 } from "lucide-react";

type OverlayLoaderProps = {
  show: boolean;
  className?: string;
  spinnerClassName?: string;
  label?: string;
};

export default function OverlayLoader({
  show,
  className,
  spinnerClassName,
  label,
}: OverlayLoaderProps) {
  if (!show) return null;

  return (
    <div
      className={cn(
        "absolute inset-0 z-50",
        "bg-white/60 backdrop-blur-[1px]",
        "flex items-center justify-center",
        className
      )}
    >
      <div className="flex flex-col items-center gap-2">
        <Loader2
          className={cn(
            "h-6 w-6 animate-spin text-text-gray",
            spinnerClassName
          )}
        />
        {label ? <div className="text-sm text-text-gray">{label}</div> : null}
      </div>
    </div>
  );
}
