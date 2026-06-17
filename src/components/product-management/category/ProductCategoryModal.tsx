"use client";

import React, { useEffect, useState } from "react";
import * as yup from "yup";
import { yupResolver } from "@hookform/resolvers/yup";
import { FormProvider, useForm } from "react-hook-form";

import AppModal from "@/components/ui/appModal";
import { Button } from "@/components/ui/button";
import InputField from "@/components/ui/inputs/input";
import TextareaField from "@/components/ui/inputs/textarea";
import UploadFile, {
  appendFile,
  type UploadFileValue,
} from "@/components/ui/uploadFile";
import ApiError from "@/components/common/ApiError";

import type { ProductCategory } from "@/store/api/types/productCategory.types";
import {
  useCreateProductCategoryMutation,
  useUpdateProductCategoryMutation,
} from "@/store/api/productCategoriesApi";

type FormValues = {
  name: string;
  description: string;
  image: UploadFileValue | null;
};

const schema: yup.ObjectSchema<any> = yup.object({
  name: yup
    .string()
    .required("Category name is required")
    .min(2, "Min 2 characters")
    .max(40, "Max 40 characters"),
  description: yup.string().max(500, "Max 500 characters").default(""),
  image: yup.mixed<UploadFileValue>().nullable(),
});

export default function ProductCategoryModal({
  open,
  onOpenChange,
  editItem,
}: {
  open: boolean;
  onOpenChange: (v: boolean) => void;
  editItem?: ProductCategory | null;
}) {
  const isEdit = !!editItem?._id;

  const [apiError, setApiError] = useState<string | null>(null);

  const [createCategory, { isLoading: creating }] =
    useCreateProductCategoryMutation();
  const [updateCategory, { isLoading: updating }] =
    useUpdateProductCategoryMutation();

  const saving = creating || updating;

  const methods = useForm<FormValues>({
    resolver: yupResolver(schema) as any,
    defaultValues: { name: "", description: "", image: null },
    mode: "onSubmit",
    reValidateMode: "onChange",
  });

  const { reset, clearErrors, formState, setValue, watch } = methods;
  const imageValue = watch("image");

  useEffect(() => {
    if (!open) return;
    setApiError(null);
    clearErrors();
    const imageUrl =
      (editItem?.image && typeof editItem.image === "object" && "url" in editItem.image
        ? editItem.image.url
        : null) ?? editItem?.icon ?? null;
    reset({
      name: editItem?.name ?? "",
      description: editItem?.description ?? "",
      image: imageUrl ?? null,
    });
  }, [open, editItem, reset, clearErrors]);

  const close = () => {
    setApiError(null);
    clearErrors();
    reset({ name: "", description: "", image: null });
    onOpenChange(false);
  };

  const submit = async (values: FormValues) => {
    setApiError(null);

    try {
      const fd = new FormData();
      fd.append("name", values.name.trim());
      if (values.description?.trim()) {
        fd.append("description", values.description.trim());
      }
      fd.append("isActive", "true");
      appendFile(fd, "image", values.image);

      if (isEdit && editItem?._id) {
        const res = await updateCategory({
          id: editItem._id,
          body: fd,
        }).unwrap();
        if (!res.success)
          setApiError(res.message || "Failed to update category.");
        else close();
      } else {
        const res = await createCategory(fd).unwrap();
        if (!res.success)
          setApiError(res.message || "Failed to create category.");
        else close();
      }
    } catch (err: unknown) {
      setApiError(
        (err as { data?: { message?: string; error?: string } })?.data
          ?.message ||
          (err as { data?: { message?: string; error?: string } })?.data
            ?.error ||
          "Something went wrong."
      );
    }
  };

  return (
    <AppModal
      open={open}
      onOpenChange={(v) => {
        if (!v) close();
        else onOpenChange(true);
      }}
      title={isEdit ? "Edit Category" : "Create Category"}
      footer={
        <>
          <Button size="lg" variant="outline" onClick={close} disabled={saving}>
            Cancel
          </Button>

          {/* ✅ submit button linked to form */}
          <Button
            size="lg"
            variant="teal"
            type="submit"
            form="product-category-form"
            disabled={saving}
          >
            {saving ? "Saving..." : isEdit ? "Update" : "Create"}
          </Button>
        </>
      }
    >
      <FormProvider {...methods}>
        <form
          id="product-category-form"
          onSubmit={methods.handleSubmit(submit)}
          className="space-y-4"
        >
          <ApiError error={apiError} />

          <InputField
            label="Category Name"
            placeholder="Enter category name"
            required
            disabled={saving}
            {...methods.register("name")}
            error={formState.errors.name?.message}
            maxLengthCount={40}
          />

          <TextareaField
            label="Description"
            placeholder="Enter category description (optional)"
            disabled={saving}
            rows={3}
            {...methods.register("description")}
            error={formState.errors.description?.message}
          />

          <UploadFile
            label="Category Image"
            value={imageValue}
            onChange={(v) => setValue("image", v, { shouldValidate: true })}
            error={formState.errors.image?.message as string | undefined}
            mainClassName="max-w-72"
          />
        </form>
      </FormProvider>
    </AppModal>
  );
}
