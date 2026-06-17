"use client";

import React from "react";
import { useFormContext } from "react-hook-form";
import InputField from "@/components/ui/inputs/input";
import TextareaField from "@/components/ui/inputs/textarea";
import SectionCard from "./SectionCard";
import type { LandingFormValues } from "../landing.schema";

export default function FAQSectionForm() {
  const {
    register,
    formState: { errors },
  } = useFormContext<LandingFormValues>();

  return (
    <SectionCard
      id="faq"
      title="FAQ"
      enabledName="faqSection_isEnabled"
      fields={["faqSection_title", "faqSection_description"]}
    >
      <InputField
        label="Title"
        required
        {...register("faqSection_title")}
        error={errors.faqSection_title?.message}
      />

      <TextareaField
        label="Description"
        required
        {...register("faqSection_description")}
        error={errors.faqSection_description?.message}
      />
    </SectionCard>
  );
}
