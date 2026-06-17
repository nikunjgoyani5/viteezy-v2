"use client";

import React from "react";
import { useFormContext } from "react-hook-form";
import InputField from "@/components/ui/inputs/input";
import SectionCard from "./SectionCard";
import type { LandingFormValues } from "../landing.schema";

export default function TestimonialsSectionForm() {
  const {
    register,
    formState: { errors },
  } = useFormContext<LandingFormValues>();

  return (
    <SectionCard
      id="testimonials"
      title="Testimonials"
      enabledName="testimonialsSection_isEnabled"
      fields={["testimonialsSection_title"]}
    >
      <InputField
        label="Title"
        required
        {...register("testimonialsSection_title")}
        error={errors.testimonialsSection_title?.message}
      />

      <InputField
        label="Subtitle"
        {...register("testimonialsSection_subTitle")}
        error={errors.testimonialsSection_subTitle?.message}
      />
    </SectionCard>
  );
}
