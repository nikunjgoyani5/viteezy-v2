"use client";

import React, { useEffect, useMemo, useState } from "react";
import toast from "react-hot-toast";
import { useRouter, useParams } from "next/navigation";
import Link from "next/link";
import { ChevronLeft } from "lucide-react";
import * as yup from "yup";
import { yupResolver } from "@hookform/resolvers/yup";
import { Controller, FormProvider, useForm } from "react-hook-form";

import InputField from "@/components/ui/inputs/input";
import SlugInput from "@/components/ui/inputs/SlugInput";
import RichTextEditor from "@/components/ui/inputs/RichTextEditor";
import SelectField from "@/components/ui/inputs/select";
import { Button } from "@/components/ui/button";
import UploadFile, {
  appendFile,
  type UploadFileValue,
} from "@/components/ui/uploadFile";
import ApiError from "@/components/common/ApiError";

import { ROUTES } from "@/constants/routes";
import { createSlugValidation, generateSlugFromTitle } from "@/lib/slugUtils";
import BlogCategoryModal from "../category/BlogCategoryModal";

import {
  useCreateBlogMutation,
  useUpdateBlogMutation,
  useGetBlogByIdQuery,
} from "@/store/api/blogApi";
import { useGetBlogCategoriesQuery } from "@/store/api/blogCategoryApi";
import { TextareaField } from "@/components/ui/inputs";

type FormValues = {
  title: string;
  // Yup schema allows description to be undefined before validation
  description?: string;
  categoryId: string;

  metaTitle: string;
  metaSlug: string;
  metaDescription: string;

  // create => File required
  // edit => string URL allowed (existing) OR File (new)
  coverImage: UploadFileValue | null | undefined;

  // create => always true; edit => from blog details
  isActive: boolean;
};

const schema: yup.ObjectSchema<FormValues> = yup.object({
  title: yup
    .string()
    .required("Title is required")
    .min(3, "Title must be at least 3 characters")
    .max(120, "Max 120 characters"),

  description: yup
    .string()
    .test(
      "required",
      "Description is required",
      (v) => !!v && v.trim() !== "" && v !== "<br>"
    ),

  categoryId: yup.string().required("Category is required"),

  metaTitle: yup
    .string()
    .required("Meta title is required")
    .min(3, "Meta title must be at least 3 characters")
    .max(60, "Max 60 characters"),

  metaSlug: createSlugValidation(),

  metaDescription: yup
    .string()
    .required("Meta description is required")
    .max(160, "Max 160 characters"),

  // NOTE: actual required logic handled in code based on mode (create/edit)
  coverImage: yup.mixed<UploadFileValue>(),

  isActive: yup.boolean().default(true),
}) as yup.ObjectSchema<FormValues>;

export default function BlogForm({ isEdit, id }: { isEdit: boolean; id?: string }) {
  const router = useRouter();
  const params = useParams();
  const blogId = id || (params.id as string);
  const isEditMode = isEdit && !!blogId;

  const [apiError, setApiError] = useState<string | null>(null);
  const [openCatModal, setOpenCatModal] = useState(false);

  // categories
  const {
    data: catRes,
    isLoading: catLoading,
    isFetching: catFetching,
  } = useGetBlogCategoriesQuery();

  const categoryOptions = useMemo(() => {
    const list = catRes?.data ?? [];
    return list
      .filter((c) => c.isActive && !c.isDeleted)
      .map((c) => ({ label: c.title, value: c._id }));
  }, [catRes?.data]);

  // blog data for edit
  const { data: blogRes, isLoading: blogLoading } = useGetBlogByIdQuery(blogId!, {
    skip: !isEdit || !blogId,
  });

  const [createBlog, { isLoading: creating }] = useCreateBlogMutation();
  const [updateBlog, { isLoading: updating }] = useUpdateBlogMutation();
  const saving = creating || updating;

  const methods = useForm({
    // Type-level mismatch between Yup's inferred shape and FormValues is safe here;
    // cast resolver to avoid over-strict generic constraints.
    resolver: yupResolver(schema) as any,
    defaultValues: {
      title: "",
      description: "",
      categoryId: "",
      metaTitle: "",
      metaSlug: "",
      metaDescription: "",
      coverImage: null,
      isActive: true, // create: always true
    },
    mode: "onSubmit",
    reValidateMode: "onChange",
  });

  const { handleSubmit, control, setValue, watch, formState, reset } = methods;
  const coverImageValue =
    (watch("coverImage") as UploadFileValue | null) ?? null;

  // prefill on edit
  useEffect(() => {
    if (!isEdit || !blogRes?.data?.blog) return;

    const b: any = blogRes.data.blog;

    reset({
      title: b.title ?? "",
      description: b.description ?? "",
      categoryId: b.categoryId?._id ?? b.categoryId ?? "",
      metaTitle: b.seo?.metaTitle ?? "",
      metaSlug: b.seo?.metaSlug ?? "",
      metaDescription: b.seo?.metaDescription ?? "",
      coverImage: b.coverImage ?? null, // string url
      isActive: b.isActive ?? true, // edit: from blog details
    });
  }, [isEdit, blogRes?.data?.blog?._id, reset]);

  const onSubmit = async (values: FormValues) => {
    setApiError(null);

    // cover required:
    // - create: must be File
    // - edit: can be string URL (existing) OR File
    const coverOk = isEdit
      ? values.coverImage instanceof File ||
        typeof values.coverImage === "string"
      : values.coverImage instanceof File;

    if (!coverOk) {
      // show error under the UploadFile area via RHF
      methods.setError("coverImage", {
        type: "manual",
        message: "Cover image is required",
      });
      return;
    }

    try {
      const fd = new FormData();
      fd.append("title", values.title.trim());
      fd.append("description", values.description ?? "");

      fd.append(
        "seo",
        JSON.stringify({
          metaTitle: values.metaTitle.trim(),
          metaSlug: values.metaSlug.trim(),
          metaDescription: values.metaDescription.trim(),
        })
      );

      fd.append("categoryId", values.categoryId);
      // create: always true; edit: use form value (prefilled from blog details)
      fd.append(
        "isActive",
        isEdit ? (values.isActive ? "true" : "false") : "true"
      );

      // only append if file is selected; if coverImage is string URL (edit), don't append
      appendFile(fd, "coverImage", values.coverImage);

      if (isEdit && blogId) {
        const res = await updateBlog({ id: blogId, body: fd }).unwrap();
        if (res.success) {
          toast.success("Blog updated successfully");
          router.push(ROUTES.BLOG.BLOG);
        } else {
          setApiError(res.message || "Failed to update blog.");
        }
      } else {
        const res = await createBlog(fd).unwrap();
        if (res.success) {
          toast.success("Blog created successfully");
          router.push(ROUTES.BLOG.BLOG);
        } else {
          setApiError(res.message || "Failed to create blog.");
        }
      }
    } catch (err: any) {
      toast.error(err?.data?.message || "Failed to save blog");
      setApiError(
        err?.data?.message ||
          err?.data?.error ||
          err?.message ||
          "Failed to save blog."
      );
    }
  };

  if (isEdit && blogLoading) {
    return (
      <div className="bg-white border rounded-lg p-6">Loading blog...</div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="form-container mx-auto">
        {/* Header */}
        <div className="flex items-center justify-between mb-5">
          {/* <Link
            href={ROUTES.BLOG.BLOG}
            className="cursor-pointer flex items-center gap-2"
          > */}
          <button
            className="cursor-pointer flex items-center gap-2"
            onClick={() => router.back()}
          >
            <ChevronLeft
              className="w-6.5 h-6.5 text-gray-600"
              strokeWidth={2}
            />
            <h1 className="text-2xl font-semibold text-gray-900">
              {isEdit ? "Edit Blog" : "Add Blog"}
            </h1>
          </button>
          {/* </Link> */}

          <Button
            type="button"
            variant="teal"
            size="lg"
            onClick={handleSubmit(onSubmit)}
            disabled={saving}
          >
            {saving ? "Saving..." : "Save"}
          </Button>
        </div>

        <FormProvider {...methods}>
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Left */}
            <div className="lg:col-span-2 space-y-6">
              <div className="bg-white rounded-lg border border-gray-200 p-6 gap-5 flex flex-col">
                <ApiError error={apiError} />

                <Controller
                  control={control}
                  name="title"
                  render={({ field, fieldState }) => (
                    <InputField
                      label="Title"
                      placeholder="Enter blog title"
                      required
                      disabled={saving}
                      {...field}
                      value={field.value ?? ""}
                      error={fieldState.error?.message}
                      maxLengthCount={120}
                    />
                  )}
                />

                <Controller
                  control={control}
                  name="description"
                  render={({ field }) => (
                    <RichTextEditor
                      label="Description"
                      placeholder="Enter Description"
                      value={field.value}
                      onChange={field.onChange}
                      error={formState.errors.description?.message}
                      required
                    />
                  )}
                />
              </div>

              {/* SEO */}
              <div className="bg-white rounded-lg border border-gray-200 p-6 space-y-6">
                <h2 className="text-lg font-semibold text-gray-900">
                  SEO Fields
                </h2>

                <Controller
                  control={control}
                  name="metaTitle"
                  render={({ field, fieldState }) => (
                    <InputField
                      label="Meta Title"
                      placeholder="Enter a meta title..."
                      required
                      disabled={saving}
                      {...field}
                      value={field.value ?? ""}
                      error={fieldState.error?.message}
                      maxLengthCount={60}
                    />
                  )}
                />

                <Controller
                  control={control}
                  name="metaSlug"
                  render={({ field, fieldState }) => (
                    <SlugInput
                      label="Meta Slug"
                      placeholder="e.g. my-first-blog-post"
                      required
                      disabled={saving}
                      value={field.value ?? ""}
                      onChange={field.onChange}
                      error={fieldState.error?.message}
                      titleForGeneration={watch("title")}
                      maxLength={80}
                    />
                  )}
                />

                <div className="flex flex-col gap-2">
                  <TextareaField
                    required
                    label="Meta Description"
                    placeholder="Enter a meta description..."
                    rows={4}
                    className={`
                      w-full rounded-lg border px-3 py-2 text-sm outline-none transition
                      focus:ring-1 focus:ring-teal-500 bg-white placeholder:text-gray-400 resize-none
                      ${
                        formState.errors.metaDescription
                          ? "border-red-500"
                          : "border-gray-300"
                      }
                    `}
                    disabled={saving}
                    {...methods.register("metaDescription")}
                  />
                  {formState.errors.metaDescription && (
                    <p className="text-xs text-red-500">
                      {formState.errors.metaDescription.message}
                    </p>
                  )}
                </div>
              </div>
            </div>

            {/* Right */}
            <div className="lg:col-span-1">
              <div className="bg-white rounded-lg border border-gray-200 p-6 sticky top-20 space-y-5">
                <UploadFile
                  label="Cover Image"
                  required={!isEdit}
                  value={coverImageValue}
                  onChange={(v) =>
                    setValue("coverImage", v as any, { shouldValidate: true })
                  }
                  error={
                    formState.errors.coverImage?.message as string | undefined
                  }
                />

                <div>
                  <SelectField
                    label="Category"
                    required
                    value={watch("categoryId")}
                    onValueChange={(v) =>
                      setValue("categoryId", v, { shouldValidate: true })
                    }
                    placeholder="Select category"
                    options={categoryOptions}
                    loading={catLoading || catFetching}
                    disabled={saving}
                    error={formState.errors.categoryId?.message}
                  />

                  <button
                    type="button"
                    className="text-sm text-teal-500 cursor-pointer mt-1.5"
                    onClick={() => setOpenCatModal(true)}
                    disabled={saving}
                  >
                    + Create Category
                  </button>
                </div>

                <BlogCategoryModal
                  open={openCatModal}
                  onOpenChange={setOpenCatModal}
                  editItem={null}
                  onCreated={(newId) => {
                    setValue("categoryId", newId, { shouldValidate: true });
                  }}
                />
              </div>
            </div>
          </div>
        </FormProvider>
      </div>
    </div>
  );
}
