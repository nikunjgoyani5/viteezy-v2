"use client";

import React, { useEffect, useState } from "react";
import toast from "react-hot-toast";
import { useRouter } from "next/navigation";
import { FormProvider, useForm } from "react-hook-form";
import { yupResolver } from "@hookform/resolvers/yup";
import { ChevronLeft } from "lucide-react";

import { Button } from "@/components/ui/button";
import ApiError from "@/components/common/ApiError";

import { buildProductFormData } from "@/lib/buildProductFormData";
import { PRODUCT_DEFAULT_VALUES } from "./productDefaults"; // ✅ Imported defaults

import {
  useCreateProductMutation,
  useUpdateProductMutation,
  useGetProductByIdQuery,
} from "@/store/api/productsApi";

import BasicDetails from "./BasicDetails";
import ProductDetailsContainer from "./ProductDetailsContainer";
import RightSidebar from "./RightSidebar";

import { ROUTES } from "@/constants/routes";
import { useGetProductCategoriesQuery } from "@/store/api/productCategoriesApi";
import type { ProductFormValues } from "./product.schema";
import { productSchema } from "./product.schema";

export default function ProductForm({
  mode,
  id,
}: {
  mode: "create" | "edit";
  id?: string;
}) {
  const router = useRouter();
  const isEdit = mode === "edit";

  const [apiError, setApiError] = useState<any>(null);

  // Fetch product for edit
  const { data: productData, isLoading: isLoadingData } =
    useGetProductByIdQuery(id!, { skip: !isEdit || !id });

  const [createProduct, { isLoading: isCreating }] = useCreateProductMutation();
  const [updateProduct, { isLoading: isUpdating }] = useUpdateProductMutation();

  const isSaving = isCreating || isUpdating;

  // Categories: fetch once, filter by search on frontend
  const [categorySearch, setCategorySearch] = useState("");
  const { data: categoriesRes, isFetching: categoriesFetching } =
    useGetProductCategoriesQuery();

  const categoryOptions = React.useMemo(() => {
    const list = categoriesRes?.data ?? [];
    const opts = list
      .filter((c) => c?.isActive !== false && c?.isDeleted !== true)
      .map((c) => ({ label: c.name, value: c._id }));
    const q = (categorySearch ?? "").trim().toLowerCase();
    if (!q) return opts;
    return opts.filter((o) => o.label.toLowerCase().includes(q));
  }, [categoriesRes?.data, categorySearch]);

  const methods = useForm<ProductFormValues>({
    // Cast resolver because yup's Resolver typing is slightly incompatible with RHF's generic
    resolver: yupResolver(productSchema) as any,
    context: { mode },
    defaultValues: PRODUCT_DEFAULT_VALUES,
    mode: "onSubmit",
    reValidateMode: "onChange",
  });

  const { reset, handleSubmit } = methods;

  // Prefill on Edit – support both { data: { product } } and { data: product } (live API)
  useEffect(() => {
    const raw = productData?.data;
    const p =
      raw && typeof raw === "object" && "product" in raw
        ? (raw as { product: Record<string, unknown> }).product
        : raw;
    if (!isEdit || !p || typeof p !== "object") return;

    const prod = p as Record<string, unknown>;

    const categoryIds = Array.isArray(prod.categories)
      ? (prod.categories as Array<{ _id?: string }>)
          .map((c) => c._id ?? "")
          .filter(Boolean)
      : [];

    const ingredientCompositions = Array.isArray(prod.ingredientCompositions)
      ? (
          prod.ingredientCompositions as Array<{
            ingredient?: string | { _id?: string };
            quantity?: number | string;
            driPercentage?: number | string;
          }>
        )
          .map((entry) => {
            const ingredientId =
              typeof entry.ingredient === "string"
                ? entry.ingredient
                : entry.ingredient?._id ?? "";
            if (!ingredientId) return null;

            const dri = entry.driPercentage;
            const driStr =
              dri === "*" || dri === "**"
                ? dri
                : typeof dri === "number"
                  ? String(dri)
                  : String(dri ?? "").trim().replace(/%$/, "");

            return {
              ingredient: ingredientId,
              quantity:
                typeof entry.quantity === "number"
                  ? String(entry.quantity)
                  : String(entry.quantity ?? "").trim(),
              driPercentage: driStr,
            };
          })
          .filter(Boolean)
      : Array.isArray(prod.ingredients)
        ? (prod.ingredients as Array<string | { _id?: string }>)
            .map((i) => (typeof i === "string" ? i : i._id ?? ""))
            .filter(Boolean)
            .map((id) => ({
              ingredient: id,
              quantity: "",
              driPercentage: "",
            }))
        : [];

    const spec = (prod.specification as Record<string, unknown>) || {};
    const specItems = (Array.isArray(spec.items) ? spec.items : []) as Array<
      Record<string, unknown>
    >;
    const specMainTitle =
      (spec.main_title as string) || (spec.mainTitle as string) || "";

    const getStr = (v: unknown) => (typeof v === "string" ? v : "");

    const rawIngredientMeta = prod.ingredientMeta as
      | Record<string, unknown>
      | undefined;
    const parseExcipients = (value: unknown) => {
      if (typeof value === "string") return value;
      if (Array.isArray(value)) {
        return value
          .map((item) => {
            if (typeof item === "string") return item;
            if (item && typeof item === "object" && "commonName" in item) {
              return getStr((item as { commonName?: string }).commonName);
            }
            return "";
          })
          .filter(Boolean)
          .join(", ");
      }
      return "";
    };

    const rawBgImage = rawIngredientMeta?.backgroundImage;
    const backgroundImage =
      typeof rawBgImage === "string"
        ? rawBgImage
        : rawBgImage &&
            typeof rawBgImage === "object" &&
            "url" in rawBgImage
          ? getStr((rawBgImage as { url?: string }).url)
          : null;

    const ingredientMeta = {
      sectionTitle: getStr(rawIngredientMeta?.sectionTitle) || "",
      sectionSubtitle: getStr(rawIngredientMeta?.sectionSubtitle) || "",
      excipients: parseExcipients(rawIngredientMeta?.excipients),
      backgroundImage,
    };

    reset({
      ...PRODUCT_DEFAULT_VALUES,
      title: getStr(prod.title ?? prod.name) || "",
      description: getStr(prod.description) || "",
      shortDescription: getStr(prod.shortDescription) || "",
      hasStandupPouch: !!prod.hasStandupPouch,
      status: prod.status !== false,
      isFeatured: !!prod.isFeatured,

      categories: categoryIds,
      ingredientMeta,
      ingredientCompositions: ingredientCompositions as ProductFormValues["ingredientCompositions"],
      healthGoals: (prod.healthGoals as string[]) || [],
      benefits:
        Array.isArray(prod.benefits) && prod.benefits.length
          ? (prod.benefits as string[])
          : [""],
      similarProducts: (prod.similarProducts as unknown[]) || [],

      productImage: prod.productImage ?? null,
      galleryImages: (prod.galleryImages as unknown[]) || [],
      standupPouchImages: (prod.standupPouchImages as unknown[]) || [],

      nutritionInfo: getStr(prod.nutritionInfo) || "",
      howToUse: getStr(prod.howToUse) || "",

      faqs: (prod.faqs as unknown[]) || [],

      sachetPrices: {
        ...PRODUCT_DEFAULT_VALUES.sachetPrices,
        ...(prod.sachetPrices as object),
      },
      standupPouchPrice: {
        ...PRODUCT_DEFAULT_VALUES.standupPouchPrice,
        ...(prod.standupPouchPrice as object),
      },

      comparisonSection:
        (prod.comparisonSection as typeof PRODUCT_DEFAULT_VALUES.comparisonSection) ||
        PRODUCT_DEFAULT_VALUES.comparisonSection,

      specificationMainTitle: specMainTitle,
      specificationBgImage: spec.bg_image ?? spec.bgImage ?? null,

      specificationTitle1: getStr(specItems[0]?.title) || "",
      specificationDescr1:
        getStr(specItems[0]?.descr ?? specItems[0]?.description) || "",
      specificationItemImage1: specItems[0]?.image ?? null,
      specificationItemImagemobile1: specItems[0]?.imageMobile ?? null,

      specificationTitle2: getStr(specItems[1]?.title) || "",
      specificationDescr2:
        getStr(specItems[1]?.descr ?? specItems[1]?.description) || "",
      specificationItemImage2: specItems[1]?.image ?? null,
      specificationItemImagemobile2: specItems[1]?.imageMobile ?? null,

      specificationTitle3: getStr(specItems[2]?.title) || "",
      specificationDescr3:
        getStr(specItems[2]?.descr ?? specItems[2]?.description) || "",
      specificationItemImage3: specItems[2]?.image ?? null,
      specificationItemImagemobile3: specItems[2]?.imageMobile ?? null,

      specificationTitle4: getStr(specItems[3]?.title) || "",
      specificationDescr4:
        getStr(specItems[3]?.descr ?? specItems[3]?.description) || "",
      specificationItemImage4: specItems[3]?.image ?? null,
      specificationItemImagemobile4: specItems[3]?.imageMobile ?? null,
    } as ProductFormValues);
  }, [isEdit, productData, reset]);

  const onSubmit = async (values: ProductFormValues) => {
    setApiError(null);
    try {
      const formData = buildProductFormData(values as any);

      if (isEdit && id) {
        const res = await updateProduct({ id, body: formData }).unwrap();
        if (res.success) {
          toast.success("Product updated successfully");
          router.push(ROUTES.PRODUCT_MANAGEMENT.PRODUCT); // Adjust route if needed
        }
      } else {
        const res = await createProduct(formData).unwrap();
        if (res.success) {
          toast.success("Product created successfully");
          router.push(ROUTES.PRODUCT_MANAGEMENT.PRODUCT);
        }
      }
    } catch (err: any) {
      toast.error(err?.data?.message || "Failed to save product");
      console.error(err);
      setApiError(err?.data || err?.message || "Failed to save product.");
    }
  };

  if (isEdit && isLoadingData) {
    return (
      <div className="flex h-screen items-center justify-center bg-gray-50">
        Loading product...
      </div>
    );
  }

  return (
    <FormProvider {...methods}>
      <form id="product-form" onSubmit={handleSubmit(onSubmit)}>
        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <button
            type="button"
            className="flex items-center gap-2 text-gray-600 hover:text-gray-900 transition-colors cursor-pointer"
            onClick={() => router.back()}
            disabled={isSaving}
          >
            <ChevronLeft className="w-5 h-5" />
            <h1 className="text-2xl font-bold text-gray-900">
              {isEdit ? "Edit Product" : "Add Product"}
            </h1>
          </button>

          <div className="flex gap-3">
            <Button variant="teal" size="lg" type="submit" disabled={isSaving}>
              {isSaving ? "Saving..." : "Save Product"}
            </Button>
          </div>
        </div>

        {/* API Error */}
        <div className="mb-6">
          <ApiError error={apiError} />
        </div>

        {/* Main Grid */}
        <div className="grid grid-cols-1 xl:grid-cols-3 gap-5">
          <div className="xl:col-span-2 space-y-5">
            <BasicDetails />
            <ProductDetailsContainer />
          </div>

          <div className="xl:col-span-1 space-y-8 sticky top-20 h-fit">
            <RightSidebar
              categoryOptions={categoryOptions}
              categorySearch={categorySearch}
              onCategorySearchChange={setCategorySearch}
              categoriesFetching={categoriesFetching}
            />
          </div>
        </div>
      </form>
    </FormProvider>
  );
}
