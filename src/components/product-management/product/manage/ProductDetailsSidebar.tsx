"use client";

import React from "react";
import { useFormContext } from "react-hook-form";
import { cn } from "@/lib/utils";
import { AlertCircle } from "lucide-react";
import { PRODUCT_DETAILS_SECTIONS } from "./productSectionConfig";

export type ProductDetailsSidebarProps = {
  activeTab: string;
  onTabChange: (id: string) => void;
};

/** Sidebar nav in its own component: only this file subscribes to form state for errors, so container stays light. */
function ProductDetailsSidebarInner({ activeTab, onTabChange }: ProductDetailsSidebarProps) {
  const {
    formState,
    formState: { submitCount },
    getFieldState,
  } = useFormContext();

  const hasError = (fields: string[]) =>
    submitCount > 0 &&
    fields.some((name) => !!getFieldState(name, formState).error);

  return (
    <div className="w-[260px] shrink-0 border-r border-gray-200">
      <div className="p-4">
        <nav className="space-y-1">
          {PRODUCT_DETAILS_SECTIONS.map((item) => {
            const isActive = activeTab === item.id;
            const isError = hasError(item.fields);
            const IconComponent = isActive ? item.iconOutline : item.iconFill;
            return (
              <button
                key={item.id}
                type="button"
                onClick={() => onTabChange(item.id)}
                className={cn(
                  "w-full flex items-center justify-between px-3 py-2.5 text-sm 3xl:text-base font-medium rounded-md transition-colors cursor-pointer",
                  isActive
                    ? "bg-teal-500 text-white"
                    : "text-text-gray hover:bg-gray-100 hover:text-gray-900",
                  isError && !isActive && "text-red-600 bg-red-50 hover:bg-red-100"
                )}
              >
                <div className="flex items-center gap-3">
                  <IconComponent
                    className={cn(
                      "w-5 h-5",
                      isError ? "text-red-500" : isActive ? "text-white" : "text-gray-400"
                    )}
                  />
                  {item.label}
                </div>
                {isError && <AlertCircle className="w-4 h-4 text-red-500" />}
              </button>
            );
          })}
        </nav>
      </div>
    </div>
  );
}

/** Memoized so parent (container) re-renders don't force sidebar re-render when props are unchanged. */
export const ProductDetailsSidebar = React.memo(ProductDetailsSidebarInner);
