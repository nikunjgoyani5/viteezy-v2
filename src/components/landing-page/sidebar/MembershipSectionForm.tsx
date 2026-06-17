"use client";

import React from "react";
import { useFormContext, Controller } from "react-hook-form";
import InputField from "@/components/ui/inputs/input";
import TextareaField from "@/components/ui/inputs/textarea";
import UploadFile from "@/components/ui/uploadFile";
import SectionCard from "./SectionCard";
import type { LandingFormValues } from "../landing.schema";

export default function MembershipSectionForm() {
  const {
    control,
    register,
    formState: { errors },
  } = useFormContext<LandingFormValues>();

  return (
    <SectionCard
      id="membership"
      title="Memberships"
      enabledName="membershipSection_isEnabled"
      fields={[
        "membershipSection_title",
        "membershipSection_description",
        "membershipBackgroundImage",
        "membershipSection_benefits",
      ]}
    >
      <InputField
        label="Heading"
        required
        {...register("membershipSection_title")}
        error={errors.membershipSection_title?.message}
      />
      <TextareaField
        label="Description"
        required
        {...register("membershipSection_description")}
        error={errors.membershipSection_description?.message}
      />

      <Controller
        control={control}
        name="membershipBackgroundImage"
        render={({ field }) => (
          <UploadFile
            label="Background Image"
            value={field.value}
            onChange={field.onChange}
            error={errors.membershipBackgroundImage as any}
          />
        )}
      />

      {[0, 1, 2].map((i) => (
        <div key={i} className="pt-3 border-t space-y-3">
          <p className="text-sm font-semibold text-gray-900">Card {i + 1}</p>

          <InputField
            label="Title"
            required
            {...register(`membershipSection_benefits.${i}.title` as const)}
            error={
              (errors.membershipSection_benefits as any)?.[i]?.title?.message
            }
          />

          <TextareaField
            label="Subtitle"
            required
            {...register(
              `membershipSection_benefits.${i}.description` as const
            )}
            error={
              (errors.membershipSection_benefits as any)?.[i]?.description
                ?.message
            }
          />

          <Controller
            control={control}
            name={`membershipSection_benefits.${i}.icon` as const}
            render={({ field }) => (
              <UploadFile
                label="Image"
                value={field.value}
                onChange={field.onChange}
                error={
                  (errors.membershipSection_benefits as any)?.[i]?.icon?.message
                }
              />
            )}
          />
        </div>
      ))}
    </SectionCard>
  );
}
