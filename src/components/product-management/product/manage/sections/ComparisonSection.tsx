"use client";

import React, { useEffect, useMemo, useState } from "react";
import { useFormContext, useFieldArray, Controller } from "react-hook-form";
import { Trash2 } from "lucide-react";
import InputField from "@/components/ui/inputs/input";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { IoAddCircleOutline } from "react-icons/io5";

export default function ComparisonSection() {
  const {
    control,
    trigger,
    formState: { errors, submitCount },
  } = useFormContext();

  const { fields, append, remove } = useFieldArray({
    control,
    name: "comparisonSection.rows",
  });

  const [openItem, setOpenItem] = useState<string | undefined>(undefined);

  // auto-open first row with error after a submit attempt.
  const firstErrorRowId = useMemo(() => {
    // If we have errors in comparisonSection.rows, find the first one
    const rowsErr = (errors as any)?.comparisonSection?.rows as
      | Array<any>
      | undefined;
    if (!rowsErr || !Array.isArray(rowsErr)) return undefined;

    for (let i = 0; i < rowsErr.length; i++) {
      if (rowsErr[i]) return fields[i]?.id;
    }
    return undefined;
  }, [errors, fields]);

  useEffect(() => {
    if (submitCount === 0) return;
    if (firstErrorRowId) {
      setTimeout(() => {
        setOpenItem(firstErrorRowId);
      }, 0);
    }
    // Only re-run when submitCount changes to avoid switching while user is typing
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [submitCount]);

  return (
    <div>
      <div className="border-b border-gray-200 py-4 px-5">
        <h2 className="text-lg font-semibold text-gray-900">
          Feature Comparison
        </h2>
      </div>

      <div className="space-y-6">
        {/* Title (Controller for consistent live errors too) */}
        <div className="px-4 pt-5">
          <Controller
            control={control}
            name="comparisonSection.title"
            render={({ field, fieldState }) => (
              <InputField
                label="Title"
                placeholder="e.g. How Green tea extract Compares:"
                value={field.value ?? ""}
                onChange={async (e: any) => {
                  field.onChange(e?.target?.value ?? e);
                  // After submit, immediately revalidate title + rows so sidebar updates
                  if (submitCount > 0) {
                    await trigger([
                      "comparisonSection.title",
                      "comparisonSection.rows",
                    ] as any);
                  }
                }}
                onBlur={field.onBlur}
                error={fieldState.error?.message}
              />
            )}
          />
        </div>

        <div>
          <Accordion
            type="single"
            collapsible
            value={openItem}
            onValueChange={setOpenItem}
            className="w-full"
          >
            {fields.map((row, index) => (
              <AccordionItem
                key={row.id}
                value={row.id}
                className="border-t border-gray-200 border-b-0 last:border-b-0"
              >
                <div className="bg-white hover:bg-gray-50 transition-colors">
                  <AccordionTrigger className="px-4 py-3 cursor-pointer hover:no-underline text-sm 3xl:text-base font-medium text-gray-900 flex items-center gap-0! outline-none!">
                    <span className="flex-1 text-left">
                      {index + 1}. Comparison
                    </span>

                    {fields.length > 1 && (
                      <button
                        type="button"
                        onPointerDown={(e) => {
                          e.preventDefault();
                          e.stopPropagation();
                        }}
                        onClick={(e) => {
                          e.preventDefault();
                          e.stopPropagation();
                          remove(index);
                          if (row.id === openItem) {
                            setOpenItem(undefined);
                          }

                          // after removing, revalidate the whole rows array
                          trigger("comparisonSection.rows");
                        }}
                        className="p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-md transition-colors cursor-pointer"
                        aria-label="Remove comparison"
                      >
                        <Trash2 className="w-4 h-4 text-red-500" />
                      </button>
                    )}
                  </AccordionTrigger>
                </div>

                <AccordionContent className="px-4 pb-6 pt-0 bg-white border-t border-gray-100">
                  <div className="space-y-4 pt-4">
                    {/* ✅ Row label using Controller for stable live validation */}
                    <Controller
                      control={control}
                      name={`comparisonSection.rows.${index}.label`}
                      render={({ field, fieldState }) => (
                        <InputField
                          label="Title"
                          placeholder="e.g. Fast-acting"
                          value={field.value ?? ""}
                          onChange={(e: any) => {
                            field.onChange(e?.target?.value ?? e);

                            // ✅ make errors disappear immediately after submit attempt
                            if (submitCount > 0) {
                              // validate this field + array level (min, required)
                              trigger([
                                `comparisonSection.rows.${index}.label`,
                                "comparisonSection.rows",
                              ] as any);
                            }
                          }}
                          onBlur={field.onBlur}
                          error={fieldState.error?.message}
                        />
                      )}
                    />

                    {/* Radio */}
                    <div className="flex items-center gap-3">
                      <span className="text-sm 3xl:text-base font-medium text-gray-700">
                        Other:
                      </span>

                      <Controller
                        control={control}
                        name={`comparisonSection.rows.${index}.values`}
                        render={({ field: { value, onChange } }) => {
                          const checkedVal = Array.isArray(value)
                            ? value[0]
                            : true;

                          return (
                            <div className="flex gap-4">
                              <label className="flex items-center gap-2 cursor-pointer">
                                <input
                                  type="radio"
                                  checked={checkedVal === true}
                                  onChange={() => onChange([true])}
                                  className="accent-teal-600 w-4 h-4"
                                />
                                <span className="text-sm text-gray-600">
                                  Yes
                                </span>
                              </label>

                              <label className="flex items-center gap-2 cursor-pointer">
                                <input
                                  type="radio"
                                  checked={checkedVal === false}
                                  onChange={() => onChange([false])}
                                  className="accent-teal-600 w-4 h-4"
                                />
                                <span className="text-sm text-gray-600">
                                  No
                                </span>
                              </label>
                            </div>
                          );
                        }}
                      />
                    </div>
                  </div>
                </AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>

          {/* Add */}
          <div
            className="px-4 py-4 bg-white hover:bg-gray-50 cursor-pointer flex items-center gap-2 font-medium text-sm 3xl:text-base transition-colors border-t border-gray-200"
            onClick={() => {
              append({ label: "", values: [true] });
              setTimeout(() => {
                const newId = fields[fields.length]?.id;
                if (newId) setOpenItem(newId);
              }, 0);
            }}
          >
            <IoAddCircleOutline className="w-5 h-5 text-teal-600" />
            Add comparison
          </div>
        </div>
      </div>
    </div>
  );
}
