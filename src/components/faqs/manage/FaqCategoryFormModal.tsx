"use client";

import React, { useEffect, useMemo, useState } from "react";
import toast from "react-hot-toast";
import * as yup from "yup";
import { yupResolver } from "@hookform/resolvers/yup";
import { FormProvider, useForm } from "react-hook-form";

import AppModal from "@/components/ui/appModal";
import { Button } from "@/components/ui/button";
import InputField from "@/components/ui/inputs/input";
import UploadFile, {
  appendFile,
  type UploadFileValue,
} from "@/components/ui/uploadFile";

import type { FaqCategory } from "@/store/api/types/faqCategory.types";
import {
  useCreateFaqCategoryMutation,
  useUpdateFaqCategoryMutation,
} from "@/store/api/faqCategoryApi";

const baseSchema = {
  title: yup
    .string()
    .required("Category name is required")
    .min(3, "Category name must be at least 3 characters"),
  icon: yup.mixed<UploadFileValue>().nullable(),
};

type FormValues = {
  title: string;
  icon: UploadFileValue | null;
};

export default function FaqCategoryFormModal({
  open,
  onOpenChange,
  onCreated,
  editCategory, // ✅ pass category when editing
}: {
  open: boolean;
  onOpenChange: (v: boolean) => void;
  onCreated?: (createdCategoryId: string) => void;
  editCategory?: Pick<FaqCategory, "_id" | "title" | "icon"> | null;
}) {
  const isEdit = !!editCategory?._id;

  // schema depends on create vs edit
  const schema = useMemo(() => {
    return yup.object({
      ...baseSchema,
      icon: isEdit
        ? yup.mixed<UploadFileValue>().nullable()
        : yup
          .mixed<UploadFileValue>()
          .test(
            "required",
            "Category icon is required",
            (v) => v instanceof File
          ),
    }) as yup.ObjectSchema<FormValues>;
  }, [isEdit]);

  const [createCategory, { isLoading: creating }] =
    useCreateFaqCategoryMutation();
  const [updateCategory, { isLoading: updating }] =
    useUpdateFaqCategoryMutation();

  const isLoading = creating || updating;

  const [apiError, setApiError] = useState<string | null>(null);

  const methods = useForm<FormValues>({
    resolver: yupResolver(schema) as any,
    defaultValues: { title: "", icon: null },
    mode: "onSubmit",
    reValidateMode: "onChange",
  });

  const { handleSubmit, reset, setValue, watch, formState, clearErrors } =
    methods;
  const iconValue = watch("icon");

  // ✅ prefill when modal opens for edit (simple and safe)
  useEffect(() => {
    if (!open) return;

    if (editCategory?._id) {
      reset({
        title: editCategory.title ?? "",
        icon: editCategory.icon ?? null, // string URL allowed for preview
      });
    } else {
      reset({ title: "", icon: null });
    }

    setApiError(null);
    clearErrors();
  }, [open, editCategory?._id]); // keep minimal deps

  const submit = async (values: FormValues) => {
    setApiError(null);

    try {
      const fd = new FormData();
      fd.append("title", values.title);
      fd.append("isActive", "true");

      // ✅ only append icon if user selected a NEW file
      appendFile(fd, "icon", values.icon);

      if (isEdit && editCategory?._id) {
        const res = await updateCategory({
          id: editCategory._id,
          body: fd,
        }).unwrap();
        if (res.success) {
          toast.success("Category updated successfully");
          onOpenChange(false);
        } else {
          setApiError(res.message || "Failed to update category.");
        }
      } else {
        const res = await createCategory(fd).unwrap();
        if (res.success) {
          toast.success("Category created successfully");
          onCreated?.(res.data._id);
          onOpenChange(false);
        } else {
          setApiError(res.message || "Failed to create category.");
        }
      }
    } catch (err: any) {
      toast.error(err?.data?.message || "Failed to save category");
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
        }
        onOpenChange(v);
      }}
      trigger={null}
      title={isEdit ? "Edit Category" : "Create Category"}
      footer={
        <>
          <Button
            size="lg"
            variant="outline"
            onClick={() => {
              clearErrors();
              onOpenChange(false);
            }}
            disabled={isLoading}
          >
            Cancel
          </Button>

          <Button
            form="faq-category-form"
            size="lg"
            variant="teal"
            onClick={handleSubmit(submit)}
            disabled={isLoading}
          >
            {isLoading
              ? "Saving..."
              : isEdit
                ? "Update Category"
                : "Create Category"}
          </Button>
        </>
      }
    >
      <FormProvider {...methods}>
        <form action="" id="faq-category-form">
          <div className="space-y-4">
            {apiError && (
              <div className="bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-lg text-sm">
                {apiError}
              </div>
            )}

            <InputField
              label="Category Name"
              placeholder="Enter category name"
              required
              disabled={isLoading}
              {...methods.register("title")}
              error={formState.errors.title?.message}
              maxLengthCount={40}
            />

            <UploadFile
              label="Category Icon"
              required={!isEdit} // ✅ required only on create
              value={iconValue}
              onChange={(v) => setValue("icon", v, { shouldValidate: true })}
              error={formState.errors.icon?.message as string | undefined}
              mainClassName="max-w-72"
            />
          </div>
        </form>
      </FormProvider>
    </AppModal>
  );
}
