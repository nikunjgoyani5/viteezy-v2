import React from "react";
import { PageHeader } from "@/components/layout/PageHeader";
import HeaderBannerForm from "@/components/header-banners/HeaderBannerForm";

export default function CreateHeaderBannerPage() {
  return (
    <div className="max-w-4xl 3xl:max-w-5xl mx-auto">
      <HeaderBannerForm mode="create" />
    </div>
  );
}
