"use client";

import React from "react";
import { useFormContext } from "react-hook-form";
import InputField from "@/components/ui/inputs/input";
import TextareaField from "@/components/ui/inputs/textarea";
import SectionCard from "./SectionCard";
import type { LandingFormValues } from "../landing.schema";

export default function ProductCategorySectionForm() {
  const {
    register,
    formState: { errors },
  } = useFormContext<LandingFormValues>();

  return (
    <SectionCard
      id="product-category"
      title="Product Category"
      enabledName="productCategorySection_isEnabled"
      fields={[
        "productCategorySection_title",
        "productCategorySection_description",
      ]}
    >
      <InputField
        label="Title"
        required
        {...register("productCategorySection_title")}
        error={errors.productCategorySection_title?.message}
      />
      <TextareaField
        label="Description"
        required
        {...register("productCategorySection_description")}
        error={errors.productCategorySection_description?.message}
      />
    </SectionCard>
  );
}
