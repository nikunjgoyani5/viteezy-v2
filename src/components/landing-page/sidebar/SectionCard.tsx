"use client";

import React, { useMemo } from "react";
import { useFormContext } from "react-hook-form";
import { AlertCircle } from "lucide-react";
import { cn } from "@/lib/utils";
import {
  AccordionItem,
  AccordionTrigger,
  AccordionContent,
} from "@/components/ui/accordion";
import type { LandingFormValues } from "../landing.schema";

// Helper function to check nested errors - improved to detect cleared errors
const hasNestedError = (errors: any, fieldPath: string): boolean => {
  if (!errors || !fieldPath) return false;
  
  // Handle array fields like heroSection_primaryCTA
  if (fieldPath.includes("_primaryCTA") || fieldPath.includes("_benefits") || 
      fieldPath.includes("_steps") || fieldPath.includes("_features") ||
      fieldPath.includes("_metrics") || fieldPath.includes("_highlightedText")) {
    // Extract the base field name (e.g., "heroSection_primaryCTA")
    const baseField = fieldPath.split(".")[0];
    const arrayErrors = errors[baseField];
    
    if (!arrayErrors) return false;
    
    // Check if it's an array of errors
    if (Array.isArray(arrayErrors)) {
      // Check if any item in the array has an error
      return arrayErrors.some((item: any) => {
        if (!item || typeof item !== "object") return false;
        // Check if item has any error properties
        return Object.values(item).some((val: any) => {
          if (val && typeof val === "object") {
            // Check for error message
            if (val.message) return true;
            // Check nested error objects
            return Object.values(val).some((v: any) => 
              v && typeof v === "object" && v.message
            );
          }
          return false;
        });
      });
    }
    
    // If not an array, check if it has error message
    if (arrayErrors.message) return true;
  }
  
  // Handle regular nested paths
  const parts = fieldPath.split(".");
  let current = errors;
  
  for (const part of parts) {
    if (current && typeof current === "object" && part in current) {
      current = current[part];
    } else {
      return false;
    }
  }
  
  if (!current) return false;
  
  // Check if it's an array of errors
  if (Array.isArray(current)) {
    return current.some((item) => {
      if (typeof item === "object" && item !== null) {
        return Object.values(item).some((val: any) => {
          if (val && typeof val === "object") {
            return val.message || Object.values(val).some((v: any) => v?.message);
          }
          return false;
        });
      }
      return false;
    });
  }
  
  // Check if it has a message property
  if (current && typeof current === "object") {
    if (current.message) return true;
    // Check nested properties
    return Object.values(current).some((val: any) => {
      if (val && typeof val === "object") {
        return val.message || (Array.isArray(val) && val.some((v: any) => v?.message));
      }
      return false;
    });
  }
  
  return false;
};

type Props = {
  id: string;
  title: string;
  enabledName: keyof LandingFormValues;
  fields?: readonly (keyof LandingFormValues)[];
  children: React.ReactNode;
};

export default function SectionCard({ id, title, enabledName, fields = [], children }: Props) {
  // Subscribe to formState.errors - React Hook Form updates this on validation
  const { formState, getFieldState } = useFormContext<LandingFormValues>();
  const { errors, submitCount } = formState;

  // Check if any field in this section has an error
  // Only show errors after submit attempt (submitCount > 0)
  // Use getFieldState for reactive error detection - it updates when errors are cleared
  const hasError = useMemo(() => {
    // Don't show errors until submit is attempted
    if (submitCount === 0) return false;
    
    if (!fields || fields.length === 0) return false;
    
    // Check each field for errors - use getFieldState for simple fields, errors object for nested
    return fields.some((fieldPath) => {
      // Use getFieldState for simple fields - it's reactive and updates when errors clear
      if (!fieldPath.includes(".") && !fieldPath.includes("[")) {
        try {
          const fieldState = getFieldState(fieldPath as any, formState);
          return !!fieldState.error;
        } catch {
          // Fallback to direct error check
          return !!(errors[fieldPath as keyof typeof errors]?.message);
        }
      }
      
      // For nested/array fields, check errors object
      // But also verify using getFieldState for the base field if it's an array
      if (fieldPath.includes("_primaryCTA") || fieldPath.includes("_benefits") || 
          fieldPath.includes("_steps") || fieldPath.includes("_features") ||
          fieldPath.includes("_metrics") || fieldPath.includes("_highlightedText")) {
        const baseField = fieldPath.split(".")[0];
        try {
          // Check base field state first - if no error, return false
          const baseFieldState = getFieldState(baseField as any, formState);
          if (!baseFieldState.error) return false;
        } catch {
          // If getFieldState fails, continue with nested check
        }
      }
      
      // Check nested errors
      return hasNestedError(errors, fieldPath);
    });
  }, [errors, fields, submitCount, formState, getFieldState]);

  return (
    <AccordionItem value={id} className="border-b last:border-b">
      <AccordionTrigger
        className={cn(
          "px-5 py-4 hover:no-underline transition-colors",
          hasError && "text-red-600 bg-red-50 hover:bg-red-100"
        )}
      >
        <div className="flex items-center justify-between w-full pr-4">
          <div className="flex items-center gap-2">
            <h3
              className={cn(
                "text-sm 3xl:text-base font-semibold transition-colors",
                hasError ? "text-red-600" : "text-gray-900"
              )}
            >
              {title}
            </h3>
            {hasError && <AlertCircle className="w-4 h-4 text-red-500 shrink-0" />}
          </div>
        </div>
      </AccordionTrigger>
      <AccordionContent className="px-5 pb-5">
        <div className="space-y-4 pt-2">{children}</div>
      </AccordionContent>
    </AccordionItem>
  );
}
