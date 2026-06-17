"use client";

import { LeftArrowIcon } from "@/components/icons";
import { ROUTES } from "@/constants/routes";
import Link from "next/link";
import React, { useMemo, useState } from "react";

import InputField from "@/components/ui/inputs/input";
import TextareaField from "@/components/ui/inputs/textarea";
import SelectField from "@/components/ui/inputs/select";
import { Button } from "@/components/ui/button";

import { useGetFaqCategoriesQuery } from "@/store/api/faqCategoryApi";
import {
  useGetFaqByIdQuery,
  useCreateFaqMutation,
  useUpdateFaqMutation,
} from "@/store/api/faqApi";
import FaqCategoryFormModal from "./FaqCategoryFormModal";

import * as yup from "yup";
import { yupResolver } from "@hookform/resolvers/yup";
import { Controller, FormProvider, useForm } from "react-hook-form";
import toast from "react-hot-toast";
import { useRouter } from "next/navigation";

export type FormValues = {
  question: string;
  answer: string;
  categoryId: string;
};

const schema = yup.object({
  question: yup.string().required("Question is required").trim(),
  answer: yup.string().required("Answer is required").trim(),
  categoryId: yup.string().required("Category is required"),
});

const defaultFormValues: FormValues = {
  question: "",
  answer: "",
  categoryId: "",
};

type FaqFormProps = {
  /** When provided, form is in edit mode (load FAQ and update). Otherwise create mode. */
  faqId?: string;
};

export default function FaqForm({ faqId }: FaqFormProps) {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const isEdit = Boolean(faqId);

  const {
    data: faqRes,
    isLoading: faqLoading,
    isError: faqError,
  } = useGetFaqByIdQuery(faqId ?? "", { skip: !faqId });
  const {
    data: catRes,
    isLoading: catLoading,
    isFetching: catFetching,
  } = useGetFaqCategoriesQuery();
  const [createFaq, { isLoading: creating }] = useCreateFaqMutation();
  const [updateFaq, { isLoading: updating }] = useUpdateFaqMutation();

  const faq = faqRes?.data?.faq;
  const saving = creating || updating;

  const methods = useForm<FormValues>({
    resolver: yupResolver(schema),
    defaultValues: defaultFormValues,
    mode: "onChange",
  });

  const { handleSubmit, setValue, control, formState, reset } = methods;

  const faqCategoryId = faq
    ? typeof faq.categoryId === "object" && faq.categoryId?._id
      ? String(faq.categoryId._id)
      : faq.categoryId
        ? String(faq.categoryId)
        : ""
    : "";

  const faqCategoryTitle =
    faq && typeof faq.categoryId === "object" && faq.categoryId?.title
      ? String(faq.categoryId.title)
      : "Category";

  const categoryOptions = useMemo(() => {
    const list = catRes?.data ?? [];
    const options = list
      .filter((c) => c.isActive && !c.isDeleted)
      .map((c) => ({ label: c.title, value: c._id }));

    if (faqCategoryId && !options.some((o) => o.value === faqCategoryId)) {
      options.unshift({ label: faqCategoryTitle, value: faqCategoryId });
    }
    return options;
  }, [catRes?.data, faqCategoryId, faqCategoryTitle]);

  const formDefaultValues = React.useMemo<FormValues | null>(() => {
    if (!faq || !faqCategoryId) return null;
    return {
      question: faq.question ?? "",
      answer: faq.answer ?? "",
      categoryId: faqCategoryId,
    };
  }, [faq, faqCategoryId]);

  React.useEffect(() => {
    if (!formDefaultValues) return;
    reset(formDefaultValues);
  }, [formDefaultValues, reset]);

  const onSubmit = async (values: FormValues) => {
    try {
      if (isEdit && faqId) {
        await updateFaq({
          id: faqId,
          body: {
            question: values.question,
            answer: values.answer,
            categoryId: values.categoryId,
            tags: [],
            status: "Active",
            isActive: true,
          },
        }).unwrap();
        toast.success("FAQ updated successfully");
      } else {
        await createFaq({
          question: values.question,
          answer: values.answer,
          categoryId: values.categoryId,
          tags: [],
          status: "Active",
          isActive: true,
        }).unwrap();
        toast.success("FAQ created successfully");
      }
      router.push(ROUTES.CMS_MANAGEMENT.FAQS);
    } catch (error: any) {
      toast.error(error?.data?.message || `Failed to ${isEdit ? "update" : "create"} FAQ`);
      console.error(`Failed to ${isEdit ? "update" : "create"} FAQ:`, error);
    }
  };

  if (faqId && !faq && (faqLoading || !faqError)) {
    return (
      <div className="min-h-[calc(100vh-96px)] bg-gray-50 flex justify-center items-center">
        <div className="text-gray-600">
          {faqLoading ? "Loading..." : "FAQ not found."}
        </div>
      </div>
    );
  }

  if (faqId && faqError) {
    return (
      <div className="min-h-[calc(100vh-96px)] bg-gray-50 flex justify-center items-center">
        <div className="text-red-600">Failed to load FAQ.</div>
      </div>
    );
  }

  const pageTitle = isEdit ? "Edit Question" : "Add Question";
  const formId = isEdit ? "faq-edit-form" : "faq-form";

  return (
    <div className="min-h-[calc(100vh-96px)] bg-gray-50 flex justify-center">
      <div className="h-full w-full form-container">
        <div className="flex items-center justify-between mb-6">
          <Link
            href={ROUTES.CMS_MANAGEMENT.FAQS}
            className="flex items-center gap-3 text-gray-700 hover:text-gray-900 transition-colors cursor-pointer"
          >
            <LeftArrowIcon />
            <div className="text-xl 3xl:text-2xl font-semibold">
              {pageTitle}
            </div>
          </Link>
          <Button
            form={formId}
            type="submit"
            variant="teal"
            size="lg"
            disabled={saving}
          >
            {saving ? "Saving..." : "Save"}
          </Button>
        </div>

        <FormProvider {...methods}>
          <form
            id={formId}
            onSubmit={handleSubmit(onSubmit)}
            className="flex gap-5 items-start flex-col lg:flex-row"
          >
            <div className="bg-white p-5 border rounded-lg w-full">
              <InputField
                required
                className="sm:min-w-100"
                placeholder="e.g. How do i reset my password?"
                label="Question"
                disabled={saving}
                {...methods.register("question")}
                error={formState.errors.question?.message}
              />

              <div className="mt-5">
                <Controller
                  control={control}
                  name="answer"
                  render={({ field }) => (
                    <TextareaField
                      required
                      placeholder="Provide the answer"
                      label="Answer"
                      disabled={saving}
                      value={field.value ?? ""}
                      onChange={field.onChange}
                      onBlur={field.onBlur}
                      error={formState.errors.answer?.message}
                    />
                  )}
                />
              </div>
            </div>

            <div className="bg-white p-5 border rounded-lg min-w-full lg:min-w-80 flex flex-col gap-1.5">
              {isEdit && faq ? (
                <Controller
                  control={control}
                  name="categoryId"
                  render={({ field }) => (
                    <SelectField
                      key={`category-${field.value || "empty"}`}
                      label="Category"
                      required
                      value={field.value ?? ""}
                      onValueChange={field.onChange}
                      placeholder="Select category"
                      options={categoryOptions}
                      loading={catLoading || catFetching}
                      error={formState.errors.categoryId?.message}
                    />
                  )}
                />
              ) : (
                <SelectField
                  label="Category"
                  required
                  value={methods.watch("categoryId")}
                  onValueChange={(v) =>
                    setValue("categoryId", v, { shouldValidate: true })
                  }
                  placeholder="Select category"
                  options={categoryOptions}
                  loading={catLoading || catFetching}
                  error={formState.errors.categoryId?.message}
                />
              )}

              <button
                className="text-sm text-teal-500 cursor-pointer text-start"
                onClick={() => setOpen(true)}
                type="button"
                disabled={saving}
              >
                + Create Category
              </button>

              <FaqCategoryFormModal
                open={open}
                onOpenChange={setOpen}
                onCreated={(newId) => {
                  setValue("categoryId", newId, { shouldValidate: true });
                }}
              />
            </div>
          </form>
        </FormProvider>
      </div>
    </div>
  );
}
