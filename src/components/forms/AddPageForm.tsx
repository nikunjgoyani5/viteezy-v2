"use client";

import React, { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { ChevronLeft } from "lucide-react";
import InputField from "@/components/ui/inputs/input";
import SlugInput from "@/components/ui/inputs/SlugInput";
import RichTextEditor from "@/components/ui/inputs/RichTextEditor";
import RadioGroup from "@/components/ui/inputs/RadioGroup";
import { Button } from "../ui/button";
import { validateSlug, generateSlugFromTitle } from "@/lib/slugUtils";

export interface PageFormData {
  title: string;
  slug: string;
  description: string;
  visibility: boolean;
  metaTitle: string;
  metaKeywords: string;
  metaDescription: string;
}

type AddPageFormProps = {
  initialData?: Partial<PageFormData>;
  submitLabel?: string;
  titleLabel?: string;
  onSubmit?: (data: PageFormData) => Promise<void> | void;
};

export default function AddPageForm({
  initialData,
  submitLabel = "Save Page",
  titleLabel = "Add Page",
  onSubmit,
}: AddPageFormProps) {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const [errors, setErrors] = useState<
    Partial<Record<keyof PageFormData, string>>
  >({});

  const [formData, setFormData] = useState<PageFormData>({
    title: initialData?.title ?? "",
    slug: initialData?.slug ?? "",
    description: initialData?.description ?? "",
    visibility: initialData?.visibility ?? true,
    metaTitle: initialData?.metaTitle ?? "",
    metaKeywords: initialData?.metaKeywords ?? "",
    metaDescription: initialData?.metaDescription ?? "",
  });

  useEffect(() => {
    if (initialData) {
      setFormData((prev) => ({
        ...prev,
        title: initialData.title ?? prev.title,
        slug: initialData.slug ?? prev.slug,
        description: initialData.description ?? prev.description,
        visibility: initialData.visibility ?? prev.visibility,
        metaTitle: initialData.metaTitle ?? prev.metaTitle,
        metaKeywords: initialData.metaKeywords ?? prev.metaKeywords,
        metaDescription: initialData.metaDescription ?? prev.metaDescription,
      }));
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [
    initialData?.title,
    initialData?.slug,
    initialData?.description,
    initialData?.visibility,
    initialData?.metaTitle,
    initialData?.metaKeywords,
    initialData?.metaDescription,
  ]);

  const handleChange = (field: keyof PageFormData, value: string | boolean) => {
    setFormData((prev) => ({
      ...prev,
      [field]: value,
    }));
    // Clear error when user types
    if (errors[field]) {
      setErrors((prev) => ({
        ...prev,
        [field]: undefined,
      }));
    }
  };

  const validate = (): boolean => {
    const newErrors: Partial<Record<keyof PageFormData, string>> = {};

    if (!formData.title.trim()) {
      newErrors.title = "Title is required";
    }

    if (!formData.slug.trim()) {
      newErrors.slug = "Slug is required";
    } else {
      const slugValidation = validateSlug(formData.slug);
      if (!slugValidation.isValid) {
        newErrors.slug = slugValidation.message;
      }
    }

    if (!formData.description.trim() || formData.description === "<br>") {
      newErrors.description = "Description is required";
    }

    if (!formData.metaTitle.trim()) {
      newErrors.metaTitle = "Meta title is required";
    }

    if (!formData.metaKeywords.trim()) {
      newErrors.metaKeywords = "Meta keywords are required";
    }

    if (!formData.metaDescription.trim()) {
      newErrors.metaDescription = "Meta description is required";
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
        // TODO: Replace with actual API call
        console.log("Form submitted:", formData);
        await new Promise((resolve) => setTimeout(resolve, 1000));
        router.push("/admin/all-pages");
      }
    } catch (error) {
      console.error("Failed to create page:", error);
      // Handle error (show toast, etc.)
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-5xl mx-auto px-6">
        {/* Header */}
        <div className="flex items-center justify-between mb-5">
          <div className="flex items-center gap-3">
            <button
              onClick={() => router.back()}
              className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <ChevronLeft className="w-5 h-5 text-gray-600" />
            </button>
            <h1 className="text-2xl font-semibold text-gray-900">
              {titleLabel}
            </h1>
          </div>

          <Button
            type="button"
            variant="teal"
            size="lg"
            onClick={handleSubmit}
            disabled={isLoading}
            // className="px-6 py-2.5 bg-teal-500 text-white rounded-lg hover:bg-teal-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed font-medium"
          >
            {isLoading ? "Saving..." : submitLabel}
          </Button>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Main Content - Left Side */}
          <div className="lg:col-span-2 space-y-6">
            {/* Title */}
            <div className="bg-white rounded-lg border border-gray-200 p-6 gap-5 flex flex-col">
              <InputField
                label="Title"
                placeholder="e.g., about us, sizing chart, FAQ"
                value={formData.title}
                onChange={(e) => handleChange("title", e.target.value)}
                error={errors.title}
                required
              />

              <SlugInput
                label="Slug"
                placeholder="e.g., about-us, sizing-chart, faq"
                value={formData.slug}
                onChange={(value) => handleChange("slug", value)}
                error={errors.slug}
                required
                titleForGeneration={formData.title}
                maxLength={80}
              />

              {/* Description */}
              <RichTextEditor
                label="Description"
                placeholder="Enter Description"
                value={formData.description}
                onChange={(value) => handleChange("description", value)}
                error={errors.description}
                required
              />
            </div>

            {/* SEO Fields */}
            <div className="bg-white rounded-lg border border-gray-200 p-6 space-y-6">
              <h2 className="text-lg font-semibold text-gray-900 mb-4">
                SEO Fields
              </h2>

              <InputField
                label="Meta Title"
                placeholder="Enter a meta title..."
                value={formData.metaTitle}
                onChange={(e) => handleChange("metaTitle", e.target.value)}
                error={errors.metaTitle}
                required
              />

              <InputField
                label="Meta Keywords"
                placeholder="Enter a meta keywords..."
                value={formData.metaKeywords}
                onChange={(e) => handleChange("metaKeywords", e.target.value)}
                error={errors.metaKeywords}
                required
              />

              <div className="flex flex-col gap-2">
                <label className="text-sm font-medium text-gray-700">
                  Meta Description <span className="text-red-500">*</span>
                </label>
                <textarea
                  placeholder="Enter a meta description..."
                  value={formData.metaDescription}
                  onChange={(e) =>
                    handleChange("metaDescription", e.target.value)
                  }
                  rows={4}
                  className={`w-full rounded-lg border px-3 py-2 text-sm outline-none transition focus:ring-1 focus:ring-teal-500 bg-white placeholder:text-gray-400 resize-none ${
                    errors.metaDescription
                      ? "border-red-500"
                      : "border-gray-300"
                  }`}
                />
                {errors.metaDescription && (
                  <p className="text-xs text-red-500">
                    {errors.metaDescription}
                  </p>
                )}
              </div>
            </div>
          </div>

          {/* Sidebar - Right Side */}
          <div className="lg:col-span-1">
            <div className="bg-white rounded-lg border border-gray-200 p-6 sticky top-20">
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
          </div>
        </div>
      </div>
    </div>
  );
}
