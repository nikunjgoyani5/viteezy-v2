"use client";

import React from "react";
import { Controller, useFormContext, useWatch } from "react-hook-form";

import UploadFile from "@/components/ui/uploadFile";
import MultiUploadFile from "@/components/ui/multiUploadFile";
import MultiSelectDropdown from "@/components/customDropdowns/MultiSelectDropdown";

type Option = { label: string; value: string };

export default function RightSidebar({
  categoryOptions,
  categorySearch,
  onCategorySearchChange,
  categoriesFetching,
  onCategoryScrollEnd,
}: {
  categoryOptions: Option[];
  categorySearch: string;
  onCategorySearchChange: (v: string) => void;
  categoriesFetching: boolean;
  /** Optional: no scroll load when omitted (e.g. when API has no pagination) */
  onCategoryScrollEnd?: () => void;
}) {
  const {
    control,
    formState: { errors },
  } = useFormContext();

  const hasStandupPouch = useWatch({
    control,
    name: "hasStandupPouch",
  });

  return (
    <div className="space-y-5 bg-white rounded-lg border p-5">
      {/* Media */}
      <div className="space-y-5">
        {/* Product Main Image (Single) */}
        <Controller
          control={control}
          name="productImage"
          render={({ field }) => (
            <UploadFile
              label="Product Main Image"
              required
              value={field.value}
              onChange={(val) => field.onChange(val)}
              error={errors.productImage?.message as string}
            />
          )}
        />

        {hasStandupPouch && (
          <Controller
            control={control}
            name="standupPouchImages"
            render={({ field }) => (
              <MultiUploadFile
                label="Stand-up Pouch Images"
                value={field.value || []}
                onChange={(val) => field.onChange(val)}
                error={errors.standupPouchImages?.message as string}
                helperText="Upload images for the pouch variant"
              />
            )}
          />
        )}

        {/* Gallery Images (Multiple) */}
        <Controller
          control={control}
          name="galleryImages"
          render={({ field }) => (
            <MultiUploadFile
              label="Gallery Images"
              value={field.value || []}
              onChange={(val) => field.onChange(val)}
              error={errors.galleryImages?.message as string}
              maxFiles={10}
            />
          )}
        />
      </div>

      {/* Category (MultiSelectDropdown with search + infinite scroll) */}
      <div className="space-y-5">
        <Controller
          control={control}
          name="categories"
          render={({ field }) => (
            <MultiSelectDropdown
              label="Category"
              required
              showSelectAll={false}
              placeholder="Select category"
              value={field.value || []}
              onChange={(next) => field.onChange(next)}
              options={categoryOptions}
              searchValue={categorySearch}
              onSearchChange={onCategorySearchChange}
              searchPlaceholder="Search category"
              loading={categoriesFetching}
              onScrollEnd={onCategoryScrollEnd ?? undefined}
              error={errors.categories?.message as string}
            />
          )}
        />
      </div>
    </div>
  );
}