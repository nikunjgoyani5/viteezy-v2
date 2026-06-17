"use client";

import React from "react";
import { useFormContext, Controller } from "react-hook-form";
import InputField from "@/components/ui/inputs/input";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";

interface PriceRowProps {
  basePath: string;
  label: string;
  defaultOpen?: boolean;
}

export default function PriceRow({
  basePath,
  label,
  defaultOpen = false,
}: PriceRowProps) {
  const {
    control,
    formState: { errors },
    register,
    watch,
  } = useFormContext();

  const amountVal = watch(`${basePath}.amount`);
  const saleVal = watch(`${basePath}.discountedPrice`);
  const amount = Number(amountVal) || 0;
  const discountedPrice = Number(saleVal) || 0;
  const regularPriceBelowSale =
    discountedPrice > 0 && amount < discountedPrice;
  const priceOrderError = regularPriceBelowSale
    ? "Regular Price ($) should not be below Total Sale Price ($)"
    : undefined;

  const getError = (field: string) => {
    const path = basePath.split(".");
    let err = errors as any;
    for (const key of path) {
      err = err?.[key];
    }
    return err?.[field]?.message as string | undefined;
  };

  // Object-level error (e.g. "Regular Price cannot be below Total Sale Price")
  const pathKeys = basePath.split(".");
  let rowErr: any = errors;
  for (const key of pathKeys) {
    rowErr = rowErr?.[key];
  }
  const rowError = rowErr?.message as string | undefined;

  return (
    <Accordion
      type="single"
      collapsible
      defaultValue={defaultOpen ? "item-1" : undefined}
      className="w-full border-b border-gray-200"
    >
      <AccordionItem value="item-1" className="border-none">
        <AccordionTrigger className="px-4 py-3 hover:bg-gray-50 text-gray-700 font-semibold text-base hover:no-underline data-[state=open]:text-teal-600">
          {label}
        </AccordionTrigger>
        <AccordionContent className="px-4 pb-6 pt-2 bg-white">
          <div className="space-y-4">
            {/* Capsule Count */}
            <Controller
              control={control}
              name={`${basePath}.capsuleCount`}
              render={({ field: { value, onChange, ...rest } }) => (
                <InputField
                  label="Capsules Count"
                  type="number"
                  placeholder="0"
                  min={0}
                  noDecimals
                  value={value === 0 ? "" : value}
                  onChange={(e) => {
                    // Convert back to number for storage
                    const val =
                      e.target.value === "" ? 0 : parseFloat(e.target.value);
                    onChange(val);
                  }}
                  error={getError("capsuleCount")}
                  {...rest}
                />
              )}
            />

            {/* Regular Price */}
            <Controller
              control={control}
              name={`${basePath}.amount`}
              render={({ field: { value, onChange, ...rest } }) => (
                <InputField
                  label="Regular Price ($)"
                  type="number"
                  step="0.01"
                  min={0}
                  placeholder="0.00"
                  value={value === 0 ? "" : value}
                  onChange={(e) => {
                    const val =
                      e.target.value === "" ? 0 : parseFloat(e.target.value);
                    onChange(val);
                  }}
                  error={getError("amount") ?? priceOrderError}
                  {...rest}
                />
              )}
            />

            {/* Sale Price */}
            <Controller
              control={control}
              name={`${basePath}.discountedPrice`}
              render={({ field: { value, onChange, ...rest } }) => (
                <InputField
                  label="Total Sale Price ($)"
                  type="number"
                  step="0.01"
                  min={0}
                  placeholder="0.00"
                  value={value === 0 ? "" : value}
                  onChange={(e) => {
                    const val =
                      e.target.value === "" ? 0 : parseFloat(e.target.value);
                    onChange(val);
                  }}
                  error={rowError ?? getError("discountedPrice")}
                  {...rest}
                />
              )}
            />

            {/* Hidden Fields */}
            <input
              type="hidden"
              {...register(`${basePath}.currency`)}
              value="USD"
            />
            <input
              type="hidden"
              {...register(`${basePath}.taxRate`)}
              value="0"
            />
          </div>
        </AccordionContent>
      </AccordionItem>
    </Accordion>
  );
}
