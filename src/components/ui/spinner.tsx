"use client";

import React from "react";
import { cn } from "@/lib/utils";
import { Loader2 } from "lucide-react";

interface SpinnerProps {
  size?: "sm" | "md" | "lg" | "xl";
  color?: "teal" | "teal-green" | "gray" | "white" | "black" | "primary";
  className?: string;
  spinClassName?: string;
  text?: string;
}

const sizeClasses = {
  sm: "h-6 w-6",
  md: "h-10 w-10",
  lg: "h-12 w-12",
  xl: "h-16 w-16",
};

const colorClasses = {
  teal: "border-teal-500",
  "teal-green": "border-teal-green-color",
  gray: "border-gray-500",
  white: "border-white",
  black: "border-black",
  primary: "border-primary",
};

const Spinner: React.FC<SpinnerProps> = ({
  size = "sm",
  color = "gray",
  className,
  spinClassName,
  text = "",
}) => {
  return (
    <div className={cn("text-center", className)}>
      {/* <div
        className={cn(
          "animate-spin rounded-full border-b-2 mx-auto",
          sizeClasses[size],
          colorClasses[color],
          spinClassName
        )}
      /> */}
      <Loader2
        className={cn(
          "animate-spin text-text-gray",
          sizeClasses[size],
          colorClasses[color],
          spinClassName
        )}
      />
      {text && <span className="block mt-5 text-gray-400">{text}</span>}
    </div>
  );
};

export default Spinner;
