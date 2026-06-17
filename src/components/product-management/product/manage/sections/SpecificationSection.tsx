"use client";

import React, { useEffect, useMemo, useState, useCallback } from "react";
import InputField from "@/components/ui/inputs/input";
import UploadFile from "@/components/ui/uploadFile";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { TextareaField } from "@/components/ui/inputs";
import { Controller, useFormContext, Path } from "react-hook-form";
import { ProductFormValues } from "../product.schema";

function SpecificationSection() {
  const {
    control,
    trigger,
    formState: { errors, submitCount },
  } = useFormContext<ProductFormValues>();

  const [openItem, setOpenItem] = useState<string | undefined>();
  const [hasAutoOpened, setHasAutoOpened] = useState(false);

  // Find first specification item with error
  const firstSpecErrorItem = useMemo(() => {
    const errs = errors as Record<string, unknown>;

    for (const i of [1, 2, 3, 4] as const) {
      const t = errs[`specificationTitle${i}`];
      const d = errs[`specificationDescr${i}`];
      const img = errs[`specificationItemImage${i}`];
      const mob = errs[`specificationItemImagemobile${i}`];

      if (t || d || img || mob) return `spec-${i}`;
    }

    return undefined;
  }, [errors]);

  // Auto-open first accordion with error after submit
  useEffect(() => {
    if (submitCount > 0 && firstSpecErrorItem) {
      setOpenItem(firstSpecErrorItem);
    }
    // Only re-run when submitCount changes to avoid switching while user is typing
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [submitCount]);

  // Optimized field change handler
  const handleFieldChange = useCallback(
    async (
      fieldOnChange: (v: any) => void,
      value: any,
      name?: Path<ProductFormValues>,
    ) => {
      fieldOnChange(value);

      if (submitCount > 0 && name) {
        await trigger(name);
      }
    },
    [submitCount, trigger],
  );

  const renderSpecBlock = useCallback(
    (idx: number) => {
      const index = idx as 1 | 2 | 3 | 4;

      return (
        <AccordionItem
          key={index}
          value={`spec-${index}`}
          className="border-t border-gray-200 border-b-0 last:border-b"
        >
          <div className="bg-white hover:bg-gray-50 transition-colors">
            <AccordionTrigger className="px-4 py-3 hover:no-underline text-sm 3xl:text-base font-medium text-gray-900 cursor-pointer">
              {index}. Specification
            </AccordionTrigger>
          </div>

          <AccordionContent className="px-4 pb-6 pt-0 bg-white border-t border-gray-100">
            <div className="space-y-5 pt-4">
              <Controller
                control={control}
                name={`specificationTitle${index}` as any}
                render={({ field, fieldState }) => (
                  <InputField
                    label="Title"
                    placeholder="e.g. Composed of the most nutritious algae"
                    {...field}
                    value={(field.value as string) || ""}
                    onChange={(e) =>
                      handleFieldChange(field.onChange, e, field.name)
                    }
                    error={fieldState.error?.message}
                  />
                )}
              />

              <Controller
                control={control}
                name={`specificationDescr${index}` as any}
                render={({ field, fieldState }) => (
                  <TextareaField
                    label="Description"
                    placeholder="e.g. Provides natural energy boost"
                    {...field}
                    value={(field.value as string) || ""}
                    onChange={(e) =>
                      handleFieldChange(field.onChange, e, field.name)
                    }
                    error={fieldState.error?.message}
                  />
                )}
              />

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <Controller
                  control={control}
                  name={`specificationItemImage${index}` as any}
                  render={({ field, fieldState }) => (
                    <UploadFile
                      label="Image (Desktop)"
                      value={field.value as any}
                      onChange={(v) =>
                        handleFieldChange(field.onChange, v, field.name)
                      }
                      error={fieldState.error?.message}
                      helperText="Desktop View"
                    />
                  )}
                />

                <Controller
                  control={control}
                  name={`specificationItemImagemobile${index}` as any}
                  render={({ field, fieldState }) => (
                    <UploadFile
                      label="Image (Mobile)"
                      value={field.value as any}
                      onChange={(v) =>
                        handleFieldChange(field.onChange, v, field.name)
                      }
                      error={fieldState.error?.message}
                      helperText="Mobile View"
                    />
                  )}
                />
              </div>
            </div>
          </AccordionContent>
        </AccordionItem>
      );
    },
    [control, handleFieldChange],
  );

  return (
    <div>
      <div className="space-y-5 p-5">
        <Controller
          control={control}
          name="specificationMainTitle"
          render={({ field, fieldState }) => (
            <InputField
              label="Title"
              placeholder="e.g. Composed of the most nutritious algae"
              {...field}
              value={field.value ?? ""}
              onChange={(e) => handleFieldChange(field.onChange, e, field.name)}
              error={fieldState.error?.message}
            />
          )}
        />

        <Controller
          control={control}
          name="specificationBgImage"
          render={({ field, fieldState }) => (
            <UploadFile
              label="Background Image"
              value={field.value as any}
              onChange={(v) => handleFieldChange(field.onChange, v, field.name)}
              error={fieldState.error?.message}
            />
          )}
        />
      </div>

      <Accordion
        type="single"
        collapsible
        className="w-full"
        value={openItem}
        onValueChange={setOpenItem}
      >
        {[1, 2, 3, 4].map(renderSpecBlock)}
      </Accordion>
    </div>
  );
}

export default React.memo(SpecificationSection);
