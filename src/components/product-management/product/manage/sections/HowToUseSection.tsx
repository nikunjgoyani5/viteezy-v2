"use client";

import React from "react";
import { useFormContext, Controller } from "react-hook-form";
import RichTextEditor from "@/components/ui/inputs/RichTextEditor";

export default function HowToUseSection() {
  const { control, formState: { errors } } = useFormContext();

  return (
    <div className="">
      <div className="border-b border-gray-200 py-4 px-5">
        <h2 className="text-lg font-semibold text-gray-900">How to Use</h2>
      </div>

      <div className="p-5">
        <div className="bg-white rounded-lg">
          <Controller
            control={control}
            name="howToUse"
            render={({ field, fieldState }) => (
              <RichTextEditor
                label="Description"
                required
                placeholder="Enter Description"
                value={field.value ?? ""}
                onChange={(value: string) =>
                  field.onChange(value)
                }
                error={fieldState.error?.message || (errors.howToUse?.message as string)}
                options={['headings', 'bold', 'italic', 'underline', 'strikethrough', 'lists']}
              />
            )}
          />
        </div>
      </div>
    </div>
  );
}
