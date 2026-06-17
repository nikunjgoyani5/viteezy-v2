"use client";

import React, { useMemo, useCallback } from "react";
import { useFormContext, useFieldArray, Controller } from "react-hook-form";
import { Trash2 } from "lucide-react";

import InputField from "@/components/ui/inputs/input";
import TextareaField from "@/components/ui/inputs/textarea";
import UploadFile from "@/components/ui/uploadFile";
import SectionCard from "./SectionCard";
import type { LandingFormValues } from "../landing.schema";
import { useFieldError, getNestedFieldError } from "../hooks/useFieldError";

// Memoize fields array to prevent recreation
const HERO_FIELDS = [
  "heroSection_title",
  "heroSection_description",
  "heroSection_video_url",
  "heroBackgroundImage",
  "heroSection_highlightedText",
  "heroSection_primaryCTA",
] as const;

// Separate component for CTA button fields to ensure proper re-rendering when errors change
// Uses useFormContext directly to get reactive error updates
function CTAButtonFields({
  index,
  control,
  register,
}: {
  index: number;
  control: any;
  register: any;
}) {
  // Get formState directly from context for reactive updates
  // Use getFieldState for each field to ensure reactive error updates
  const { formState, getFieldState } = useFormContext<LandingFormValues>();
  const { submitCount } = formState;

  // Get field states directly - these are reactive and update when validation runs
  const labelFieldState = getFieldState(`heroSection_primaryCTA.${index}.label` as any, formState);
  const linkFieldState = getFieldState(`heroSection_primaryCTA.${index}.link` as any, formState);
  const imageFieldState = getFieldState(`heroSection_primaryCTA.${index}.image` as any, formState);

  // Show errors only after submit attempt
  const labelError = submitCount > 0 ? labelFieldState.error?.message : undefined;
  const linkError = submitCount > 0 ? linkFieldState.error?.message : undefined;
  const imageError = submitCount > 0 ? imageFieldState.error?.message : undefined;

  return (
    <div className="space-y-3 pb-4 border-b last:border-b-0">
      <InputField
        label={`CTA Button ${index + 1}`}
        required
        placeholder="Talk to an Expert"
        {...register(`heroSection_primaryCTA.${index}.label` as const)}
        error={labelError}
      />
      <InputField
        label="Link"
        required
        placeholder="https://..."
        {...register(`heroSection_primaryCTA.${index}.link` as const)}
        error={linkError}
      />
      <Controller
        control={control}
        name={`heroSection_primaryCTA.${index}.image` as const}
        render={({ field }) => (
          <UploadFile
            label="Image"
            value={field.value}
            onChange={field.onChange}
            error={imageError}
          />
        )}
      />
    </div>
  );
}

export default function HeroSectionForm() {
  const {
    control,
    register,
    formState: { errors, submitCount },
  } = useFormContext<LandingFormValues>();

  const highlighted = useFieldArray({
    control,
    name: "heroSection_highlightedText",
  });

  // Get errors using helper hooks/functions
  const titleError = useFieldError("heroSection_title");
  const descriptionError = useFieldError("heroSection_description");
  const videoUrlError = useFieldError("heroSection_video_url");
  const bgImageError = useFieldError("heroBackgroundImage");

  // Memoize remove handler to prevent recreation
  const handleRemoveHighlighted = useCallback(
    (index: number) => {
      highlighted.remove(index);
    },
    [highlighted]
  );

  // Memoize append handler
  const handleAppendHighlighted = useCallback(() => {
    if (highlighted.fields.length >= 10) return;
    highlighted.append({ value: "" });
  }, [highlighted]);

  return (
    <SectionCard
      id="hero"
      title="Hero Details"
      enabledName="heroSection_isEnabled"
      fields={HERO_FIELDS}
    >
      <InputField
        label="Title"
        required
        placeholder="Personalized vitamins, especially for"
        {...register("heroSection_title")}
        error={titleError}
      />

      <TextareaField
        label="Description"
        required
        placeholder="Join 400,000+ people..."
        {...register("heroSection_description")}
        error={descriptionError}
      />

      {/* Animation titles (max 10) */}
      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <label className="text-sm font-medium text-gray-700">
            Animation title
          </label>
          <button
            type="button"
            className="text-sm text-teal-600 font-medium"
            onClick={handleAppendHighlighted}
          >
            + Add Title
          </button>
        </div>

        {highlighted.fields.map((f, idx) => (
          <div key={f.id} className="flex items-center gap-2">
            <div className="flex-1 min-w-0">
              <InputField
                placeholder="Enter title"
                {...register(`heroSection_highlightedText.${idx}.value` as const)}
                error={getNestedFieldError(
                  errors,
                  `heroSection_highlightedText.${idx}.value`,
                  submitCount
                )}
              />
            </div>
            {highlighted.fields.length > 1 && (
              <button
                type="button"
                onClick={() => handleRemoveHighlighted(idx)}
                className="p-2 text-red-500 shrink-0"
                title="Remove"
              >
                <Trash2 className="w-4 h-4" />
              </button>
            )}
          </div>
        ))}
      </div>

      <InputField
        label="Video URL"
        placeholder="https://..."
        {...register("heroSection_video_url")}
        error={videoUrlError}
      />

      <Controller
        control={control}
        name="heroBackgroundImage"
        render={({ field }) => (
          <UploadFile
            label="Hero Background Image"
            value={field.value}
            onChange={field.onChange}
            error={bgImageError}
          />
        )}
      />

      {/* CTA 0..2 fixed */}
      <div className="pt-3 border-t space-y-4">
        <p className="text-sm font-semibold text-gray-900">Button Text</p>

        {[0, 1, 2].map((i) => (
          <CTAButtonFields
            key={i}
            index={i}
            control={control}
            register={register}
          />
        ))}
      </div>
    </SectionCard>
  );
}
