"use client";

import { useEffect, useState } from "react";
import ProductImageGallery from "./productDetail/ProductImageGallery";
import ProductInfo from "./productDetail/ProductInfo";
import ProductAccordion from "./productDetail/ProductAccordion";
import SimilarProducts from "./productDetail/SimilarProducts";
import { useProduct } from "@/hooks";
import { useTranslations } from "next-intl";

interface ProductDetailsContentProps {
  productId: string;
  mode?: "default" | "modal";
}

export default function ProductDetailsContent({
  productId,
  mode = "default",
}: ProductDetailsContentProps) {
  const [selectedPreference, setSelectedPreference] = useState<
    "sachets" | "pouch"
  >("sachets");
  const [manualSelectedImage, setManualSelectedImage] = useState<string | null>(
    null,
  );
  const t = useTranslations("Products");

  const {
    product,
    productData,
    isLoading: loading,
    error,
  } = useProduct(productId);

  // Derive the default image based on preference
  const preferenceImage = (() => {
    if (!productData) return "";
    const hasStandupPouch = Boolean(productData?.hasStandupPouch);
    if (selectedPreference === "pouch" && hasStandupPouch) {
      return (
        productData.standupPouchImages?.[0] || productData.productImage || ""
      );
    }
    return productData.productImage || product?.images.front || "";
  })();

  const selectedImage = manualSelectedImage || preferenceImage;

  // Ensure preference is valid per product
  useEffect(() => {
    if (!productData) return;
    const hasStandupPouch = Boolean(productData?.hasStandupPouch);
    if (!hasStandupPouch && selectedPreference === "pouch") {
      setSelectedPreference("sachets");
    }
  }, [selectedPreference, productData]);

  // Reset manual selection when preference or product changes
  useEffect(() => {
    setManualSelectedImage(null);
  }, [selectedPreference, productId]);

  if (loading) {
    return (
      <div className="flex items-center justify-center p-12 h-100">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-teal-green-color"></div>
      </div>
    );
  }

  if (error || !product || !productData) {
    return (
      <div className="flex items-center justify-center p-12 text-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">
            {t("productNotFound")}
          </h1>
          <p className="text-gray-600 mt-2">{t("productNotFoundDesc")}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-2 md:gap-12 3xl:gap-15 items-start">
      {/* Left Column - Product Images (50%) */}
      <ProductImageGallery
        product={product}
        selectedImage={selectedImage}
        setSelectedImage={setManualSelectedImage}
        // Pass productData and selectedPreference to drive mobile-first image logic
        productData={productData}
        selectedPreference={selectedPreference}
      />

      {/* Right Column - Product Information (50%) */}
      <div className="space-y-6">
        <ProductInfo
          product={product}
          productData={productData}
          selectedPreference={selectedPreference}
          setSelectedPreference={setSelectedPreference}
          mode={mode}
        />

        {/* Accordion Sections */}
        <ProductAccordion productData={productData} />

        {/* Similar Products */}
        {mode !== "modal" && (
          <SimilarProducts
            productData={productData}
            selectedPreference={selectedPreference}
          />
        )}
      </div>
    </div>
  );
}
