"use client";

import React from "react";
import { useFormContext, Controller } from "react-hook-form";
import RichTextEditor from "@/components/ui/inputs/RichTextEditor";

export default function ProductDetailsSection() {
  const {
    control,
    trigger,
    formState: { errors, submitCount },
  } = useFormContext();

  return (
    <div className="">
      <div className="border-b border-gray-200 py-4 px-5">
        <h2 className="text-lg font-semibold text-gray-900">Product Details</h2>
      </div>

      <div className="bg-white rounded-lg p-5">
        <Controller
          control={control}
          name="description"
          render={({ field, fieldState }) => (
            <RichTextEditor
              label="Description"
              required
              placeholder="Enter Description"
              value={field.value ?? ""}
              onChange={async (value: string) => {
                field.onChange(value);
                // After a submit attempt, re-trigger validation so sidebar updates immediately
                if (submitCount > 0) {
                  await trigger("description");
                }
              }}
              error={fieldState.error?.message || (errors.description?.message as string)}
              options={['headings', 'bold', 'italic', 'underline', 'strikethrough', 'lists']}
            />
          )}
        />
      </div>
    </div>
  );
}
