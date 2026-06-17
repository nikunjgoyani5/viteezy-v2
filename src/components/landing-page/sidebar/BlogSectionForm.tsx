"use client";

import React from "react";
import { useFormContext } from "react-hook-form";
import InputField from "@/components/ui/inputs/input";
import TextareaField from "@/components/ui/inputs/textarea";
import SectionCard from "./SectionCard";
import type { LandingFormValues } from "../landing.schema";

export default function BlogSectionForm() {
  const {
    register,
    formState: { errors },
  } = useFormContext<LandingFormValues>();

  return (
    <SectionCard
      id="blog"
      title="Blog"
      enabledName="blogSection_isEnabled"
      fields={["blogSection_title", "blogSection_description"]}
    >
      <InputField
        label="Title"
        required
        {...register("blogSection_title")}
        error={errors.blogSection_title?.message}
      />

      <TextareaField
        label="Description"
        required
        {...register("blogSection_description")}
        error={errors.blogSection_description?.message}
      />
    </SectionCard>
  );
}
