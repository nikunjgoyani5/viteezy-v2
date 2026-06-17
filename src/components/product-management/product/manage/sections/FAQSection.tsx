"use client";

import React, { useEffect, useMemo, useState } from "react";
import { useFormContext, useFieldArray, Controller } from "react-hook-form";
import { Trash2 } from "lucide-react";
import InputField from "@/components/ui/inputs/input";
import { TextareaField } from "@/components/ui/inputs";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { IoAddCircleOutline } from "react-icons/io5";

const MAX_FAQS = 10;

export default function FAQSection() {
  const {
    control,
    trigger,
    formState: { errors, submitCount },
  } = useFormContext();

  const { fields, append, remove } = useFieldArray({
    control,
    name: "faqs",
  });

  const [openItem, setOpenItem] = useState<string | undefined>(undefined);

  // Collect FAQ indices that have errors
  const firstErrorFaqId = useMemo(() => {
    const faqsErr = (errors as Record<string, any>)?.faqs as
      | Array<any>
      | undefined;

    if (!faqsErr || !Array.isArray(faqsErr)) return undefined;

    for (let i = 0; i < faqsErr.length; i++) {
      const faqErr = faqsErr[i];
      if (faqErr && (faqErr?.question || faqErr?.answer)) {
        return fields[i]?.id;
      }
    }

    return undefined;
  }, [errors, fields]);

  // Auto-open errored items after submit
  useEffect(() => {
    if (submitCount === 0) return;

    if (firstErrorFaqId) {
      setTimeout(() => {
        setOpenItem(firstErrorFaqId);
      }, 0);
    }
    // Only re-run when submitCount changes to avoid switching while user is typing
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [submitCount]);

  const canAddMore = fields.length < MAX_FAQS;

  return (
    <div>
      <div className="border-b border-gray-200 p-4">
        <h2 className="text-lg font-semibold text-gray-900">FAQs</h2>
      </div>

      <div className="space-y-0">
        {fields.length === 0 ? (
          <div className="p-6 text-center text-gray-500 text-sm 3xl:text-base border-b border-gray-200">
            No FAQs added yet. Click below to add one.
          </div>
        ) : (
          <Accordion
            type="single"
            collapsible
            value={openItem}
            onValueChange={setOpenItem}
            className="w-full"
          >
            {fields.map((row, index) => {
              const questionErr = (errors as any)?.faqs?.[index]?.question
                ?.message as string | undefined;

              const answerErr = (errors as any)?.faqs?.[index]?.answer
                ?.message as string | undefined;

              const hasError = !!questionErr || !!answerErr;

              return (
                <AccordionItem
                  key={row.id}
                  value={row.id}
                  className="border-b border-gray-200 last:border-b"
                >
                  <div className="bg-white hover:bg-gray-50 transition-colors">
                    <AccordionTrigger className="px-4 py-3 cursor-pointer hover:no-underline text-sm 3xl:text-base font-medium text-gray-900 flex items-center gap-0! outline-none!">
                      <span
                        className={`flex-1 text-left ${
                          hasError ? "text-red-600" : ""
                        }`}
                      >
                        {index + 1}. FAQ
                      </span>

                      {/* Delete button on the left of text */}
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
                          // Only revalidate FAQs after a submit attempt
                          if (submitCount > 0) {
                            trigger("faqs");
                          }
                        }}
                        className="p-2 mr-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-md transition-colors cursor-pointer"
                        aria-label="Remove FAQ"
                      >
                        <Trash2 className="w-4 h-4 text-red-500" />
                      </button>
                    </AccordionTrigger>
                  </div>

                  <AccordionContent className="px-4 pb-6 pt-0 bg-white border-t border-gray-100">
                    <div className="space-y-4 pt-4">
                      <Controller
                        control={control}
                        name={`faqs.${index}.question`}
                        render={({ field, fieldState }) => (
                          <InputField
                            label="Question"
                            placeholder="e.g. How many capsules per day?"
                            value={field.value ?? ""}
                            onChange={(e: any) => {
                              field.onChange(e?.target?.value ?? e);
                              // Live re-validation only after submit
                              if (submitCount > 0) {
                                trigger("faqs");
                              }
                            }}
                            onBlur={field.onBlur}
                            error={fieldState.error?.message}
                          />
                        )}
                      />

                      <Controller
                        control={control}
                        name={`faqs.${index}.answer`}
                        render={({ field, fieldState }) => (
                          <TextareaField
                            label="Answer"
                            placeholder="e.g. Take one capsule daily with water, preferably with a meal."
                            value={field.value ?? ""}
                            onChange={(e: any) => {
                              field.onChange(e?.target?.value ?? e);
                              // Live re-validation only after submit
                              if (submitCount > 0) {
                                trigger("faqs");
                              }
                            }}
                            onBlur={field.onBlur}
                            error={fieldState.error?.message}
                          />
                        )}
                      />
                    </div>
                  </AccordionContent>
                </AccordionItem>
              );
            })}
          </Accordion>
        )}

        {/* Add Button */}
        {canAddMore && (
          <div
            className="px-4 py-4 bg-white hover:bg-gray-50 cursor-pointer flex items-center gap-2 font-medium text-sm 3xl:text-base transition-colors"
            onClick={() => {
              append({ question: "", answer: "" });

              // open newly added FAQ after next render
              setTimeout(() => {
                const newId = fields[fields.length]?.id;
                if (newId) setOpenItem(newId);
              }, 0);
            }}
          >
            <IoAddCircleOutline className="w-5 h-5 text-teal-600" />
            Add FAQ ({fields.length}/{MAX_FAQS})
          </div>
        )}

        {!canAddMore && (
          <div className="px-4 py-3 bg-gray-50 text-sm text-gray-500">
            Maximum {MAX_FAQS} FAQs reached.
          </div>
        )}
      </div>
    </div>
  );
}
