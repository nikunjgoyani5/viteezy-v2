import { useFormContext } from "react-hook-form";
import { useMemo } from "react";
import type { FieldPath, FieldValues } from "react-hook-form";

/**
 * Hook to get field error message that only shows when:
 * Submit was attempted (submitCount > 0) - shows all errors on submit
 * 
 * Errors will NOT show when clearing/changing fields, only after submit click
 * Memoized to prevent unnecessary re-renders
 */
export function useFieldError<TFieldValues extends FieldValues = FieldValues>(
  fieldName: FieldPath<TFieldValues>
): string | undefined {
  const { formState } = useFormContext<TFieldValues>();
  const { errors, submitCount } = formState;
  
  // Memoize error check to prevent unnecessary re-renders
  return useMemo(() => {
    const error = errors[fieldName]?.message as string | undefined;
    
    // Show error ONLY if submit was attempted
    if (!error || submitCount === 0) return undefined;
    
    return error;
  }, [errors, fieldName, submitCount]);
}

/**
 * Helper function to get error message for nested fields (e.g., array items)
 * Shows error ONLY if submit was attempted
 */
export function getNestedFieldError(
  errors: any,
  fieldPath: string,
  submitCount: number
): string | undefined {
  const error = getNestedError(errors, fieldPath);
  if (!error) return undefined;
  
  // Show error ONLY if submit was attempted
  if (submitCount > 0) {
    return error;
  }
  
  return undefined;
}

/**
 * Helper to get nested error from errors object
 */
function getNestedError(errors: any, path: string): string | undefined {
  if (!errors || !path) return undefined;
  
  const parts = path.split(".");
  let current: any = errors;
  
  for (const part of parts) {
    // Handle array indices like "field[0].subfield"
    if (part.includes("[")) {
      const [key, indexStr] = part.split("[");
      const index = parseInt(indexStr.replace("]", ""), 10);
      if (current?.[key]?.[index] !== undefined) {
        current = current[key][index];
      } else {
        return undefined;
      }
    } else {
      if (current?.[part] !== undefined) {
        current = current[part];
      } else {
        return undefined;
      }
    }
  }
  
  return current?.message as string | undefined;
}
