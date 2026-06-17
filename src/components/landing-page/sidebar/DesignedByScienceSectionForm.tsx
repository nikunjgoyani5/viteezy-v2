"use client";

import React from "react";
import { useFormContext, Controller } from "react-hook-form";
import InputField from "@/components/ui/inputs/input";
import TextareaField from "@/components/ui/inputs/textarea";
import UploadFile from "@/components/ui/uploadFile";
import SectionCard from "./SectionCard";
import type { LandingFormValues } from "../landing.schema";

export default function DesignedByScienceSectionForm() {
  const {
    control,
    register,
    formState: { errors },
  } = useFormContext<LandingFormValues>();

  const stepsErrors =
    errors.designedByScienceSection_steps as unknown as
      | Array<{
          title?: { message?: string };
          description?: { message?: string };
          image?: { message?: string };
        }>
      | undefined;

  return (
    <SectionCard
      id="designed-by-science"
      title="Designed by science"
      enabledName="designedByScienceSection_isEnabled"
      fields={[
        "designedByScienceSection_title",
        "designedByScienceSection_description",
        "designedByScienceSection_steps",
      ]}
    >
      <InputField
        label="Title"
        required
        {...register("designedByScienceSection_title")}
        error={errors.designedByScienceSection_title?.message}
      />

      <TextareaField
        label="Description"
        required
        {...register("designedByScienceSection_description")}
        error={errors.designedByScienceSection_description?.message}
      />

      {[0, 1, 2].map((i) => (
        <div key={i} className="pt-3 border-t space-y-3">
          <p className="text-sm font-semibold text-gray-900">Step {i + 1}</p>

          <InputField
            label="Title"
            required
            {...register(`designedByScienceSection_steps.${i}.title` as const)}
            error={stepsErrors?.[i]?.title?.message}
          />

          <TextareaField
            label="Description"
            required
            {...register(
              `designedByScienceSection_steps.${i}.description` as const
            )}
            error={stepsErrors?.[i]?.description?.message}
          />

          <Controller
            control={control}
            name={`designedByScienceSection_steps.${i}.image` as const}
            render={({ field }) => (
              <UploadFile
                label="Image"
                value={field.value}
                onChange={field.onChange}
                error={
                  (stepsErrors?.[i]?.image as unknown as { message?: string })
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

