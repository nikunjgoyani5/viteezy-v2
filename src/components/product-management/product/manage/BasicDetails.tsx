"use client";

import { useFormContext, Controller } from "react-hook-form";
import InputField from "@/components/ui/inputs/input";
import { TextareaField } from "@/components/ui/inputs";
import MultiSelectField from "@/components/customDropdowns/MultiSelectField";
import { Checkbox } from "@/components/ui/table";

// Define packaging options static for now
const PACKAGING_OPTIONS = [
  { label: "Sachets", value: "sachets" },
  { label: "Stand-up Pouch", value: "stand_up_pouch" },
];

export default function BasicDetails() {
  const {
    register,
    control,
    formState: { errors },
    watch,
    setValue,
  } = useFormContext();

  return (
    <div className="bg-white rounded-lg border border-gray-200 p-5 space-y-5">
      {/* Use Controller for better control */}
      <Controller
        control={control}
        name="title"
        render={({ field }) => (
          <InputField
            label="Product Title"
            placeholder="e.g. Green tea extract"
            required
            {...field}
            value={field.value || ""}
            error={errors.title?.message as string}
            maxLengthCount={150}
          />
        )}
      />

      <div className="flex flex-col gap-2">
        <label className="text-sm 3xl:text-base font-medium text-gray-700">
          Packaging Options
        </label>
        <div className="flex items-center space-x-2 border rounded-lg p-3 bg-surface-light border-extra-light-gray">
          <Controller
            control={control}
            name="hasStandupPouch"
            render={({ field }) => (
              <div
                className="flex items-center space-x-3 cursor-pointer"
                onClick={() => field.onChange(!field.value)} // Make whole row clickable
              >
                <Checkbox
                  checked={field.value}
                  onChange={(checked) => field.onChange(checked)}
                />
                <span className="text-sm 3xl:text-base font-medium text-gray-900 select-none">
                  Include Stand-up Pouch option
                </span>
              </div>
            )}
          />
        </div>
        <p className="text-xs text-gray-500">
          Sachets are included by default. Check this to also offer a Stand-up
          Pouch variant.
        </p>
      </div>

      <Controller
        control={control}
        name="shortDescription"
        render={({ field }) => (
          <TextareaField
            label="Short Description"
            placeholder="Enter a brief summary..."
            rows={4}
            required
            {...field}
            value={field.value || ""}
            error={errors.shortDescription?.message as string}
            maxLengthCount={70}
          />
        )}
      />
    </div>
  );
}
