"use client";

import React from "react";
import { useParams } from "next/navigation";
import { PageHeader } from "@/components/layout/PageHeader";
import HeaderBannerForm from "@/components/header-banners/HeaderBannerForm";
import { useGetHeaderBannerByIdQuery } from "@/store/api/headerBannerApi";

export default function EditHeaderBannerPage() {
  const params = useParams();
  const id = params?.id as string | undefined;

  const { data, isLoading, isError } = useGetHeaderBannerByIdQuery(id!, {
    skip: !id,
  });

  if (!id) {
    return (
      <div className="p-6 bg-white border rounded-lg">
        <p className="text-red-600 text-sm">Missing banner id.</p>
      </div>
    );
  }

  if (isLoading) {
    return (
      <div className="p-6 bg-white border rounded-lg">
        <p className="text-sm text-gray-600">Loading banner...</p>
      </div>
    );
  }

  if (isError || !data) {
    return (
      <div className="p-6 bg-white border rounded-lg">
        <p className="text-red-600 text-sm">
          Failed to load banner. Please try again.
        </p>
      </div>
    );
  }

  return (
    <div className="max-w-4xl 3xl:max-w-5xl mx-auto">
      <HeaderBannerForm mode="edit" initial={data} bannerId={id} />
    </div>
  );
}
