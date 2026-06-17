"use client";

import React, { useEffect, useMemo, useState } from "react";
import toast from "react-hot-toast";
import * as yup from "yup";
import { yupResolver } from "@hookform/resolvers/yup";
import { FormProvider, useForm } from "react-hook-form";

import AppModal from "@/components/ui/appModal";
import { Button } from "@/components/ui/button";
import InputField from "@/components/ui/inputs/input";

import type { BlogCategory } from "@/store/api/types/blogCategory.types";
import {
  useCreateBlogCategoryMutation,
  useUpdateBlogCategoryMutation,
} from "@/store/api/blogCategoryApi";

type FormValues = { title: string; isActive: boolean };

const schema = yup.object({
  title: yup
    .string()
    .required("Title is required")
    .max(40, "Max 40 characters"),
  isActive: yup.boolean().default(true),
});

export default function BlogCategoryModal({
  open,
  onOpenChange,
  editItem,
  onCreated,
}: {
  open: boolean;
  onOpenChange: (v: boolean) => void;
  editItem?: BlogCategory | null; // if present => edit mode
  onCreated?: (id: string) => void;
}) {
  const isEdit = !!editItem?._id;

  const [apiError, setApiError] = useState<string | null>(null);

  const [createCategory, { isLoading: creating }] =
    useCreateBlogCategoryMutation();
  const [updateCategory, { isLoading: updating }] =
    useUpdateBlogCategoryMutation();

  const loading = creating || updating;

  const methods = useForm<FormValues>({
    resolver: yupResolver(schema),
    defaultValues: { title: "", isActive: true },
    mode: "onSubmit",
    reValidateMode: "onSubmit",
  });

  const { handleSubmit, reset, clearErrors, formState } = methods;

  // Prefill when opening in edit mode
  useEffect(() => {
    if (!open) return;
    setApiError(null);
    clearErrors();

    reset({
      title: editItem?.title ?? "",
      isActive: editItem?.isActive ?? true,
    });
  }, [open, editItem?._id]); // intentional

  const submit = async (values: FormValues) => {
    setApiError(null);
    // create: always true; edit: use value from category details (prefilled in reset)
    const payload = {
      title: values.title.trim(),
      isActive: isEdit ? values.isActive : true,
    };

    try {
      if (isEdit && editItem?._id) {
        const res = await updateCategory({
          id: editItem._id,
          body: payload,
        }).unwrap();
        if (!res.success) {
          setApiError(res.message || "Failed to update category.");
        } else {
          toast.success("Category updated successfully");
          onOpenChange(false);
        }
      } else {
        const res = await createCategory(payload).unwrap();
        if (!res.success) {
          setApiError(res.message || "Failed to create category.");
        } else {
          toast.success("Category created successfully");
          onCreated?.(res.data._id);
          onOpenChange(false);
        }
      }
    } catch (err: any) {
      toast.error(err?.data?.message || "Something went wrong");
      setApiError(err?.data?.message || "Something went wrong.");
    }
  };

  return (
    <AppModal
      open={open}
      onOpenChange={(v) => {
        if (!v) {
          setApiError(null);
          clearErrors();
          reset({ title: "", isActive: true });
        }
        onOpenChange(v);
      }}
      title={isEdit ? "Edit Category" : "Create Category"}
      footer={
        <>
          <Button
            size="lg"
            variant="outline"
            onClick={() => onOpenChange(false)}
            disabled={loading}
          >
            Cancel
          </Button>

          <Button
            form="blog-category-form"
            size="lg"
            variant="teal"
            onClick={handleSubmit(submit)}
            disabled={loading}
          >
            {loading ? "Saving..." : isEdit ? "Update" : "Create"}
          </Button>
        </>
      }
    >
      <FormProvider {...methods}>
        <form
          id="blog-category-form"
          onSubmit={handleSubmit(submit)}
          className="space-y-4"
        >
          <div className="space-y-4">
            {apiError && (
              <div className="bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-lg text-sm">
                {apiError}
              </div>
            )}

            <InputField
              key={editItem?._id ?? "create"}
              label="Title"
              placeholder="Enter category title"
              required
              disabled={loading}
              {...methods.register("title")}
              error={formState.errors.title?.message}
              maxLengthCount={40}
            />
          </div>
        </form>
      </FormProvider>
    </AppModal>
  );
}
