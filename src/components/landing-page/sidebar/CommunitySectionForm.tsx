"use client";

import React from "react";
import { useFormContext, Controller } from "react-hook-form";
import InputField from "@/components/ui/inputs/input";
import UploadFile from "@/components/ui/uploadFile";
import SectionCard from "./SectionCard";
import type { LandingFormValues } from "../landing.schema";

export default function CommunitySectionForm() {
  const {
    control,
    register,
    formState: { errors },
  } = useFormContext<LandingFormValues>();

  const metricsErrors =
    errors.communitySection_metrics as unknown as
      | Array<{
          label?: { message?: string };
          value?: { message?: string };
        }>
      | undefined;

  return (
    <SectionCard
      id="community"
      title="Community"
      enabledName="communitySection_isEnabled"
      fields={[
        "communitySection_title",
        "communitySection_subTitle",
        "communityBackgroundImage",
        "communitySection_metrics",
      ]}
    >
      <InputField
        label="Title"
        required
        {...register("communitySection_title")}
        error={errors.communitySection_title?.message}
      />

      <InputField
        label="Subtitle"
        {...register("communitySection_subTitle")}
        error={errors.communitySection_subTitle?.message}
      />

      <Controller
        control={control}
        name="communityBackgroundImage"
        render={({ field }) => (
          <UploadFile
            label="Background Image"
            value={field.value}
            onChange={field.onChange}
            error={
              (errors.communityBackgroundImage as unknown as { message?: string })
                ?.message
            }
          />
        )}
      />

      <div className="pt-3 border-t space-y-3">
        <p className="text-sm font-semibold text-gray-900">Metrics</p>

        {[0, 1, 2, 3].map((i) => (
          <div key={i} className="grid grid-cols-1 md:grid-cols-2 gap-3">
            <InputField
              label="Label"
              required
              {...register(`communitySection_metrics.${i}.label` as const)}
              error={metricsErrors?.[i]?.label?.message}
            />

            <InputField
              label="Value"
              required
              {...register(`communitySection_metrics.${i}.value` as const)}
              error={metricsErrors?.[i]?.value?.message}
            />
          </div>
        ))}
      </div>
    </SectionCard>
  );
}

