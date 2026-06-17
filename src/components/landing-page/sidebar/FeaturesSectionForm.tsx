"use client";

import React from "react";
import { useFormContext, Controller } from "react-hook-form";
import InputField from "@/components/ui/inputs/input";
import TextareaField from "@/components/ui/inputs/textarea";
import UploadFile from "@/components/ui/uploadFile";
import SectionCard from "./SectionCard";
import type { LandingFormValues } from "../landing.schema";

export default function FeaturesSectionForm() {
  const {
    control,
    register,
    formState: { errors },
  } = useFormContext<LandingFormValues>();

  const featuresErrors =
    errors.featuresSection_features as unknown as
      | Array<{
          title?: { message?: string };
          description?: { message?: string };
          icon?: { message?: string };
        }>
      | undefined;

  return (
    <SectionCard
      id="features"
      title="Features"
      enabledName="featuresSection_isEnabled"
      fields={[
        "featuresSection_title",
        "featuresSection_description",
        "featuresSection_features",
      ]}
    >
      <InputField
        label="Title"
        required
        {...register("featuresSection_title")}
        error={errors.featuresSection_title?.message}
      />

      <TextareaField
        label="Description"
        required
        {...register("featuresSection_description")}
        error={errors.featuresSection_description?.message}
      />

      {[0, 1, 2, 3].map((i) => (
        <div key={i} className="pt-3 border-t space-y-3">
          <p className="text-sm font-semibold text-gray-900">Feature {i + 1}</p>

          <InputField
            label="Title"
            required
            {...register(`featuresSection_features.${i}.title` as const)}
            error={featuresErrors?.[i]?.title?.message}
          />

          <TextareaField
            label="Description"
            required
            {...register(`featuresSection_features.${i}.description` as const)}
            error={featuresErrors?.[i]?.description?.message}
          />

          <Controller
            control={control}
            name={`featuresSection_features.${i}.icon` as const}
            render={({ field }) => (
              <UploadFile
                label="Icon"
                value={field.value}
                onChange={field.onChange}
                error={
                  (featuresErrors?.[i]?.icon as unknown as { message?: string })
                    ?.message
                }
              />
            )}
          />
        </div>
      ))}
    </SectionCard>
  );
}
