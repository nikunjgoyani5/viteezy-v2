"use client";

import React, { useState, useEffect } from "react";
import toast from "react-hot-toast";
import AppImage from "@/components/ui/appImage";
import BlogBannerSidebar from "@/components/blog-management/blog-cms/BlogBannerSidebar";
import {
  useGetBlogBannerQuery,
  useCreateBlogBannerMutation,
  useUpdateBlogBannerMutation,
} from "@/store/api/blogApi";

export default function BlogCMSPage() {
  const [heading, setHeading] = useState("");
  const [description, setDescription] = useState("");
  const [bannerImage, setBannerImage] = useState("");
  const [bannerImageFile, setBannerImageFile] = useState<File | null>(null);
  const [isSaving, setIsSaving] = useState(false);
  const [bannerId, setBannerId] = useState<string | null>(null);
  const [errors, setErrors] = useState<{
    heading?: string;
    description?: string;
    bannerImage?: string;
  }>({});
  const [showErrors, setShowErrors] = useState(false);

  // Fetch blog banner data
  const { data: bannerData, isLoading } = useGetBlogBannerQuery();

  // Mutations
  const [createBlogBanner] = useCreateBlogBannerMutation();
  const [updateBlogBanner] = useUpdateBlogBannerMutation();

  // Update local state when API data loads
  useEffect(() => {
    if (bannerData?.data?.length) {
      const banner = bannerData.data[0];
      setHeading(banner.heading || "");
      setDescription(banner.description || "");
      setBannerId(banner._id);

      // Set banner image if exists
      if (banner.banner_image?.url) {
        setBannerImage(banner.banner_image.url);
      }
    } else {
      setHeading("");
      setDescription("");
      setBannerId(null);
      setBannerImage("");
    }
  }, [bannerData]);

  // Auto-save function with debounce
  const autoSave = async () => {
    setIsSaving(true);

    try {
      const formData = new FormData();
      formData.append("heading", heading);
      formData.append("description", description);

      if (bannerImageFile) {
        formData.append("banner_image", bannerImageFile);
      }

      if (bannerId) {
        // Update existing banner
        await updateBlogBanner({ id: bannerId, body: formData }).unwrap();
        toast.success("Banner updated successfully!");
      } else {
        // Create new banner
        const result = await createBlogBanner(formData).unwrap();
        setBannerId(result.data.blogBanner._id);
        toast.success("Banner created successfully!");
      }
    } catch (error: any) {
      toast.error(error?.data?.message || "Failed to save banner");
      console.error("Failed to save banner:", error);
    } finally {
      setIsSaving(false);
    }
  };

  const handleHeadingChange = (value: string) => {
    setHeading(value);
    if (showErrors && errors.heading) {
      setErrors(prev => ({ ...prev, heading: undefined }));
    }
  };

  const handleDescriptionChange = (value: string) => {
    setDescription(value);
    if (showErrors && errors.description) {
      setErrors(prev => ({ ...prev, description: undefined }));
    }
  };

  const handleBannerImageChange = (imageData: string, file: File) => {
    setBannerImage(imageData);
    setBannerImageFile(file);
    if (showErrors && errors.bannerImage) {
      setErrors(prev => ({ ...prev, bannerImage: undefined }));
    }
  };

  const validateForm = () => {
    const newErrors: {
      heading?: string;
      description?: string;
      bannerImage?: string;
    } = {};

    if (!heading.trim()) {
      newErrors.heading = "Heading is required";
    }

    if (!description.trim()) {
      newErrors.description = "Description is required";
    }

    if (!bannerImage && !bannerImageFile) {
      newErrors.bannerImage = "Banner image is required";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSave = async () => {
    setShowErrors(true);
    
    if (!validateForm()) {
      return;
    }

    await autoSave();
  };

  return (
    <div className="grid grid-cols-1 xl:grid-cols-[1fr_258px] 3xl:grid-cols-[1fr_280px] gap-5">
      {/* Left: Banner Preview */}
      <section className="space-y-5">
        <div className="flex flex-col items-start justify-between gap-2 py-4">
          <h1 className="text-3xl font-semibold">Blog Banner</h1>
        </div>

        {/* Loading State */}
        {isLoading && (
          <div className="flex items-center justify-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
          </div>
        )}

        {/* Banner Preview */}
        {!isLoading && (
          <div className="bg-white border border-extra-light-gray rounded-lg overflow-hidden">
            {/* Banner Image Section */}
            <div className="relative w-full h-64 bg-linear-to-br from-teal-50 to-blue-50">
              {bannerImage ? (
                <AppImage
                  src={bannerImage}
                  alt="Blog Banner"
                  width={1200}
                  height={400}
                  className="w-full h-full object-cover"
                />
              ) : (
                <div className="flex items-center justify-center h-full">
                  <p className="text-gray-400 text-sm">
                    No banner image uploaded
                  </p>
                </div>
              )}

              {/* Overlay with heading and description */}
              {(heading || description) && (
                <div className="absolute inset-0 bg-linear-to-r from-black/60 to-transparent flex items-center">
                  <div className="max-w-2xl px-8 md:px-12 lg:px-16 text-white">
                    {heading && (
                      <h2 className="text-2xl md:text-3xl lg:text-4xl font-bold mb-4 max-w-xl">
                        {heading}
                      </h2>
                    )}
                    {description && (
                      <p className="text-sm md:text-base lg:text-lg opacity-90">
                        {description}
                      </p>
                    )}
                  </div>
                </div>
              )}
            </div>
          </div>
        )}
      </section>

      {/* Right: Fixed sidebar */}
      <BlogBannerSidebar
        heading={heading}
        description={description}
        bannerImage={bannerImage}
        onHeadingChange={handleHeadingChange}
        onDescriptionChange={handleDescriptionChange}
        onBannerImageChange={handleBannerImageChange}
        onSave={handleSave}
        isSaving={isSaving}
        errors={errors}
        showErrors={showErrors}
      />
    </div>
  );
}
