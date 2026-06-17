"use client";

import React, { useEffect, useState } from "react";
import Link from "next/link";
import toast from "react-hot-toast";
import { ChevronLeft } from "lucide-react";
import { useRouter } from "next/navigation";
import * as yup from "yup";
import { yupResolver } from "@hookform/resolvers/yup";
import { Controller, FormProvider, useForm } from "react-hook-form";

import InputField from "@/components/ui/inputs/input";
import { Button } from "@/components/ui/button";
import UploadFile, {
  appendFile,
  type UploadFileValue,
} from "@/components/ui/uploadFile";
import ApiError from "@/components/common/ApiError";

import { ROUTES } from "@/constants/routes";
import {
  useCreateProductIngredientMutation,
  useGetProductIngredientByIdQuery,
  useUpdateProductIngredientMutation,
} from "@/store/api/productIngredientsApi";

import { useDebounce } from "@/hooks/useDebounce";
import { useInfiniteProducts } from "@/hooks/useInfiniteProducts";
import MultiSelectDropdown from "../customDropdowns/MultiSelectDropdown";

type FormValues = {
  name: string;
  scientificName?: string;
  description: string;
  products: string[];
  image: UploadFileValue | null; // File | string | null
};

export default function IngredientsForm({
  mode = "create",
  id,
}: {
  mode?: "create" | "edit";
  id?: string;
}) {
  const router = useRouter();
  const isEdit = mode === "edit";

  const [apiError, setApiError] = useState<string | null>(null);

  const [createIngredient, { isLoading: creating }] =
    useCreateProductIngredientMutation();
  const [updateIngredient, { isLoading: updating }] =
    useUpdateProductIngredientMutation();
  const saving = creating || updating;

  const { data: ingredientRes, isLoading: loadingIngredient } =
    useGetProductIngredientByIdQuery(id!, { skip: !isEdit || !id });

  // products dropdown (search + infinite)
  const [productSearch, setProductSearch] = useState("");
  const debouncedSearch = useDebounce(productSearch, 300);

  const {
    items: productOptions,
    loadNext,
    hasNext,
    isFetching: productsFetching,
  } = useInfiniteProducts({ search: debouncedSearch });

  const schema: yup.ObjectSchema<any> = yup.object({
    name: yup.string().required("Name is required").min(2).max(80),
    scientificName: yup.string().trim().max(120).optional(),
    description: yup.string().required("Description is required").min(2),
    products: yup.array().of(yup.string()),
    image: yup
      .mixed<UploadFileValue>()
      .nullable()
      .test("image-required", "Image is required", function (value) {
        // Required check with correct message; create vs edit handled in onSubmit
        if (value != null && value !== "") return true;
        return false;
      }),
  });

  const methods = useForm<FormValues>({
    resolver: yupResolver(schema) as any,
    defaultValues: {
      name: "",
      scientificName: "",
      description: "",
      products: [],
      image: null,
    },
    mode: "onSubmit",
    reValidateMode: "onChange",
  });

  const { handleSubmit, setValue, watch, formState, reset, setError } = methods;

  const imageValue = (watch("image") as UploadFileValue | null) ?? null;
  const productsValue = watch("products");

  // prefill on edit (API returns products as full objects; form expects product IDs only)
  useEffect(() => {
    if (!isEdit || !ingredientRes?.data?.ingredient) return;
    const ing = ingredientRes.data.ingredient;

    const productIds: string[] = (ing.products ?? []).map((p) =>
      typeof p === "string" ? p : (p as { _id: string })._id
    );

    const imageForForm: UploadFileValue | null =
      typeof ing.image === "string"
        ? ing.image
        : (ing.image && "url" in ing.image ? ing.image.url : null) ?? null;

    reset({
      name: ing.name ?? "",
      scientificName: ing.scientificName ?? "",
      description: ing.description ?? "",
      products: productIds,
      image: imageForForm,
    });
  }, [isEdit, ingredientRes?.data?.ingredient?._id, reset]);

  const onSubmit = async (values: FormValues) => {
    setApiError(null);

    const imageOk = isEdit
      ? values.image instanceof File || typeof values.image === "string"
      : values.image instanceof File;

    if (!imageOk) {
      setError("image", { type: "manual", message: "Image is required" });
      return;
    }

    try {
      const fd = new FormData();
      fd.append("name", values.name.trim());
      fd.append("scientificName", (values.scientificName ?? "").trim());
      fd.append("description", values.description.trim());
      fd.append("isActive", "true");
      fd.append("products", JSON.stringify(values.products));
      appendFile(fd, "image", values.image);

      if (isEdit && id) {
        const res = await updateIngredient({ id, body: fd }).unwrap();
        if (res.success) {
          toast.success("Ingredient updated successfully");
          router.push(ROUTES.INGREDIENTS_MANAGMENT.BASE);
        } else {
          setApiError(res.message || "Failed to update ingredient.");
        }
      } else {
        const res = await createIngredient(fd).unwrap();
        if (res.success) {
          toast.success("Ingredient created successfully");
          router.push(ROUTES.INGREDIENTS_MANAGMENT.BASE);
        } else {
          setApiError(res.message || "Failed to create ingredient.");
        }
      }
    } catch (err: any) {
      toast.error(err?.data?.message || "Failed to save ingredient");
      setApiError(
        err?.data?.message || err?.data?.error || "Failed to save ingredient."
      );
    }
  };

  if (isEdit && loadingIngredient) {
    return (
      <div className="bg-white border rounded-lg p-6">
        Loading ingredient...
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="form-container mx-auto">
        <div className="flex items-center justify-between mb-5">
          {/* <Link
            href={ROUTES.INGREDIENTS_MANAGMENT.BASE}
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
              {isEdit ? "Edit Ingredient" : "Add Ingredient"}
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
            <div className="lg:col-span-2 space-y-6">
              <div className="bg-white rounded-lg border border-gray-200 p-6 gap-5 flex flex-col">
                <ApiError error={apiError} />

                <Controller
                  control={methods.control}
                  name="name"
                  render={({ field, fieldState }) => (
                    <InputField
                      label="Ingredient Name"
                      placeholder="Enter ingredient name"
                      required
                      disabled={saving}
                      {...field}
                      value={field.value ?? ""}
                      error={fieldState.error?.message}
                      maxLengthCount={80}
                    />
                  )}
                />

                <Controller
                  control={methods.control}
                  name="scientificName"
                  render={({ field, fieldState }) => (
                    <InputField
                      label="Scientific Name"
                      placeholder="Enter scientific name"
                      disabled={saving}
                      {...field}
                      value={field.value ?? ""}
                      error={fieldState.error?.message}
                      maxLengthCount={120}
                    />
                  )}
                />

                <div className="flex flex-col gap-2">
                  <label className="text-sm font-medium text-gray-700">
                    Description <span className="text-red-500">*</span>
                  </label>
                  <textarea
                    rows={6}
                    placeholder="Enter ingredient description..."
                    className={`
                      w-full rounded-lg border px-3 py-2 text-sm outline-none transition
                      focus:ring-1 focus:ring-teal-500 bg-white placeholder:text-gray-400 resize-none
                      ${formState.errors.description
                        ? "border-red-500"
                        : "border-gray-300"
                      }
                    `}
                    disabled={saving}
                    {...methods.register("description")}
                  />
                  {formState.errors.description && (
                    <p className="text-xs text-red-500">
                      {formState.errors.description.message}
                    </p>
                  )}
                </div>
              </div>
            </div>

            <div className="lg:col-span-1">
              <div className="bg-white rounded-lg border border-gray-200 p-6 sticky top-20 space-y-5">
                <UploadFile
                  label="Upload Image"
                  required={!isEdit}
                  value={imageValue}
                  onChange={(v) =>
                    setValue("image", v, { shouldValidate: true })
                  }
                  error={formState.errors.image?.message as string | undefined}
                />

                <MultiSelectDropdown
                  label="Link to Products"
                  showSelectAll={false}
                  value={productsValue}
                  onChange={(next) =>
                    setValue("products", next, { shouldValidate: true })
                  }
                  options={productOptions}
                  searchValue={productSearch}
                  onSearchChange={setProductSearch}
                  searchPlaceholder="Search product"
                  loading={productsFetching}
                  onScrollEnd={() => {
                    if (hasNext && !productsFetching) loadNext();
                  }}
                  error={
                    formState.errors.products?.message as string | undefined
                  }
                />
              </div>
            </div>
          </div>
        </FormProvider>
      </div>
    </div>
  );
}
