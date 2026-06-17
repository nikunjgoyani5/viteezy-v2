"use client";

import React, { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { ChevronLeft } from "lucide-react";
import { FiSearch } from "react-icons/fi";
import UploadFile, { UploadFileValue } from "@/components/ui/uploadFile";
import RadioGroup from "@/components/ui/inputs/RadioGroup";
import ProductSearchModal from "./ProductSearchModal";
import PageSelector from "./PageSelector";
import SelectedProductsList from "./SelectedProductsList";
import { useCreateTestimonialMutation, useUpdateTestimonialMutation } from "@/store/api/testimonialApi";
import toast from "react-hot-toast";

export interface TestimonialFormData {
  video: UploadFileValue | null;
  thumbnail: UploadFileValue | null;
  products: string[];
  visibility: boolean;
  pages: string[];
  selectedPageProducts?: Record<string, string[]>;
}

type TestimonialFormProps = {
  mode?: "create" | "edit";
  testimonialId?: string;
  initialData?: Partial<TestimonialFormData>;
  submitLabel?: string;
  titleLabel?: string;
  onSubmit?: (data: TestimonialFormData) => Promise<void> | void;
};

export default function TestimonialForm({
  mode = "create",
  testimonialId,
  initialData,
  submitLabel = "Save Testimonial",
  titleLabel = "Add Testimonials",
  onSubmit,
}: TestimonialFormProps) {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const [errors, setErrors] = useState<
    Partial<Record<keyof TestimonialFormData, string>>
  >({});
  const [isProductDialogOpen, setIsProductDialogOpen] = useState(false);
  const [createTestimonial] = useCreateTestimonialMutation();
  const [updateTestimonial] = useUpdateTestimonialMutation();

  const isEditMode = mode === "edit";

  const [formData, setFormData] = useState<TestimonialFormData>({
    video: initialData?.video ?? null,
    thumbnail: initialData?.thumbnail ?? null,
    products: initialData?.products ?? [],
    visibility: initialData?.visibility ?? true,
    pages: initialData?.pages ?? ["home"], // Home selected by default
    selectedPageProducts: initialData?.selectedPageProducts ?? {},
  });

  useEffect(() => {
    if (initialData) {
      setFormData((prev) => ({
        ...prev,
        video: initialData.video ?? prev.video,
        thumbnail: initialData.thumbnail ?? prev.thumbnail,
        products: initialData.products ?? prev.products,
        visibility: initialData.visibility ?? prev.visibility,
        pages: initialData.pages ?? prev.pages,
      }));
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [
    initialData?.video,
    initialData?.thumbnail,
    initialData?.products,
    initialData?.visibility,
    initialData?.pages,
  ]);

  const handleChange = (field: keyof TestimonialFormData, value: any) => {
    setFormData((prev) => ({
      ...prev,
      [field]: value,
    }));
    // Clear error when user makes changes
    if (errors[field]) {
      setErrors((prev) => ({
        ...prev,
        [field]: undefined,
      }));
    }
  };

  const handleOpenProductDialog = () => {
    setIsProductDialogOpen(true);
  };

  const handleProductsDone = (selectedIds: string[]) => {
    handleChange("products", selectedIds);
  };

  const handleRemoveProduct = (productId: string) => {
    const updatedProducts = formData.products.filter((id) => id !== productId);
    handleChange("products", updatedProducts);
  };

  const handlePageToggle = (pageId: string) => {
    setFormData((prev) => ({
      ...prev,
      pages: prev.pages.includes(pageId)
        ? prev.pages.filter((id) => id !== pageId)
        : [...prev.pages, pageId],
    }));
  };

  const handlePageProductToggle = (pageId: string, productId: string) => {
    setFormData((prev) => {
      const currentProducts = prev.selectedPageProducts?.[pageId] || [];
      const updatedProducts = currentProducts.includes(productId)
        ? currentProducts.filter((id) => id !== productId)
        : [...currentProducts, productId];

      return {
        ...prev,
        selectedPageProducts: {
          ...prev.selectedPageProducts,
          [pageId]: updatedProducts,
        },
      };
    });
  };

  const handleSelectAllPageProducts = (pageId: string, productIds: string[]) => {
    setFormData((prev) => ({
      ...prev,
      selectedPageProducts: {
        ...prev.selectedPageProducts,
        [pageId]: productIds,
      },
    }));
  };

  const validate = (): boolean => {
    const newErrors: Partial<Record<keyof TestimonialFormData, string>> = {};

    // In edit mode, video can be a URL string; in create mode, it must be a File
    if (!formData.video) {
      newErrors.video = "Video is required";
    } else if (!isEditMode && !(formData.video instanceof File)) {
      newErrors.video = "Please upload a video file";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validate()) {
      return;
    }

    setIsLoading(true);

    try {
      if (onSubmit) {
        await onSubmit(formData);
      } else {
        const fd = new FormData();

        // products - array of string -> pass in this Product Search Modal of selected product id
        fd.append("products", JSON.stringify(formData.products));

        // video - binary (only append if it's a File, not a URL string)
        if (formData.video && formData.video instanceof File) {
          fd.append("video", formData.video);
        }

        // isVisibleOnHomepage -> if selected page selector then pass true or false
        fd.append("isVisibleOnHomepage", formData.pages.includes("home") ? "true" : "false");

        // productsForDetailsPage - array of string -> pass in this page select of selected product id
        const detailsPageProducts = Object.values(formData.selectedPageProducts || {}).flat();
        fd.append("productsForDetailsPage", JSON.stringify(detailsPageProducts));

        // visibility/isActive
        fd.append("isActive", formData.visibility ? "true" : "false");

        let response;
        if (isEditMode && testimonialId) {
          response = await updateTestimonial({ id: testimonialId, body: fd }).unwrap();
          toast.success(response.message || "Testimonial updated successfully");
        } else {
          response = await createTestimonial(fd).unwrap();
          toast.success(response.message || "Testimonial created successfully");
        }

        router.push("/admin/cms-management/testimonials");
      }
    } catch (error: any) {
      console.error(`Failed to ${isEditMode ? "update" : "create"} testimonial:`, error);

      let errorMessage = `Failed to ${isEditMode ? "update" : "create"} testimonial`;

      if (error?.data?.errors && Array.isArray(error.data.errors) && error.data.errors.length > 0) {
        const firstError = error.data.errors[0];
        if (typeof firstError === 'string') {
          errorMessage = firstError;
        } else if (firstError?.message) {
          errorMessage = typeof firstError.message === 'string' ? firstError.message : errorMessage;
        }
      } else if (error?.data?.message) {
        // Handle case where message might be an object (e.g., translations)
        if (typeof error.data.message === 'string') {
          errorMessage = error.data.message;
        } else if (typeof error.data.message === 'object' && error.data.message !== null) {
          // If it's a translation object, try to get the English version or first available
          errorMessage = error.data.message.en || error.data.message[Object.keys(error.data.message)[0]] || errorMessage;
        }
      } else if (error?.message && typeof error.message === 'string') {
        errorMessage = error.message;
      }

      toast.error(errorMessage);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-5xl mx-auto px-6">
        {/* Header */}
        <div className="flex items-center justify-between mb-5">
          <div className="flex items-center gap-3 cursor-pointer">
            <button
              onClick={() => router.back()}
              className="p-2 hover:bg-gray-100 rounded-lg transition-colors cursor-pointer"
            >
              <ChevronLeft className="w-5 h-5 text-gray-600" />
            </button>
            <h1 className="text-2xl font-semibold text-gray-900">
              {titleLabel}
            </h1>
          </div>

          <button
            onClick={handleSubmit}
            disabled={isLoading}
            className="text-sm 3xl:text-base px-6 py-2.5 bg-teal-500 text-white rounded-lg hover:bg-teal-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed font-medium"
          >
            {isLoading ? "Saving..." : submitLabel}
          </button>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 ">
          {/* Main Content - Left Side */}
          <div className="lg:col-span-2 space-y-6 bg-white border border-extra-light-gray border-dashed rounded-lg">
            {/* Video and Product in one card */}
            <div className=" rounded-lg border border-extra-light-gray border-dashed p-6 space-y-6">
              {/* Video Upload */}
              <UploadFile
                className="bg-white"
                label="Video"
                required
                accept="video/*"
                maxSizeMB={2}
                helperText="Click to upload or drag & drop Videos (max 2MB)"
                value={formData.video}
                onChange={(value) => handleChange("video", value)}
                error={errors.video}
                showPreview={true}
              />

              {/* Product Search */}
              <div>
                <label className="text-sm font-medium text-gray-700  block mb-2">
                  Product
                </label>
                <div className="relative">
                  <FiSearch className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                  <input
                    type="text"
                    placeholder="Search products"
                    readOnly
                    onClick={handleOpenProductDialog}
                    className="w-full rounded-lg border border-extra-light-gray pl-10 pr-3 py-2.5 text-sm outline-none transition focus:ring-1 focus:ring-teal-500 bg-white placeholder:text-gray-400 cursor-pointer"
                  />
                </div>

                {/* Selected Products List */}
                <SelectedProductsList
                  selectedProductIds={formData.products}
                  onRemove={handleRemoveProduct}
                />
              </div>
            </div>
          </div>

          {/* Sidebar - Right Side */}
          <div className="lg:col-span-1">
            <div className=" sticky top-20 ">
              <div className="bg-white rounded-lg border border-extra-light-gray p-4 sticky top-20 ">
                <RadioGroup
                  label="Visibility"
                  options={[
                    { label: "Visible", value: true },
                    { label: "Hidden", value: false },
                  ]}
                  value={formData.visibility}
                  onChange={(value) =>
                    handleChange("visibility", value as boolean)
                  }
                  required
                />
              </div>

              {/* Page Selector */}
              <PageSelector
                selectedPages={formData.pages}
                selectedPageProducts={formData.selectedPageProducts || {}}
                onPageToggle={handlePageToggle}
                onPageProductToggle={handlePageProductToggle}
                onSelectAllProducts={handleSelectAllPageProducts}
              />
            </div>

            {/* Product Search Modal */}
            <ProductSearchModal
              isOpen={isProductDialogOpen}
              onClose={() => setIsProductDialogOpen(false)}
              selectedProducts={formData.products}
              onDone={handleProductsDone}
            />
          </div>
        </div>
      </div>
    </div>
  );
}
