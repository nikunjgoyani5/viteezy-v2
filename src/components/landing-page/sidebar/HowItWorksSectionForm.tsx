"use client";

import React from "react";
import { useFormContext, Controller } from "react-hook-form";
import InputField from "@/components/ui/inputs/input";
import TextareaField from "@/components/ui/inputs/textarea";
import UploadFile from "@/components/ui/uploadFile";
import SectionCard from "./SectionCard";
import type { LandingFormValues } from "../landing.schema";

export default function HowItWorksSectionForm() {
  const {
    control,
    register,
    formState: { errors },
  } = useFormContext<LandingFormValues>();

  return (
    <SectionCard
      id="how-it-works"
      title="How it works"
      enabledName="howItWorksSection_isEnabled"
      fields={[
        "howItWorksSection_title",
        "howItWorksSection_subTitle",
        "howItWorksSection_steps",
      ]}
    >
      <InputField
        label="Title"
        required
        {...register("howItWorksSection_title")}
        error={errors.howItWorksSection_title?.message}
      />
      <InputField
        label="Subtitle"
        required
        {...register("howItWorksSection_subTitle")}
        error={errors.howItWorksSection_subTitle?.message}
      />

      {[0, 1, 2].map((i) => (
        <div key={i} className="pt-3 border-t space-y-3">
          <p className="text-sm font-semibold text-gray-900">Step {i + 1}</p>

          <InputField
            label="Title"
            required
            {...register(`howItWorksSection_steps.${i}.title` as const)}
            error={(errors.howItWorksSection_steps as any)?.[i]?.title?.message}
          />

          <TextareaField
            label="Description"
            required
            {...register(`howItWorksSection_steps.${i}.description` as const)}
            error={
              (errors.howItWorksSection_steps as any)?.[i]?.description?.message
            }
          />

          <Controller
            control={control}
            name={`howItWorksSection_steps.${i}.image` as const}
            render={({ field }) => (
              <UploadFile
                label="Image"
                value={field.value}
                onChange={field.onChange}
                error={
                  (errors.howItWorksSection_steps as any)?.[i]?.image?.message
                }
              />
            )}
          />
        </div>
      ))}
    </SectionCard>
  );
}
