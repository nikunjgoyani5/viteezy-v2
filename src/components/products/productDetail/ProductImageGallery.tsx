"use client";
import Image from "next/image";
import { MediaRenderer } from "./MediaRenderer";
import { useEffect, useRef, useState } from "react";
import { Product } from "@/components/types";
import { formatIngredientDriDisplay, resolveLocalizedValue } from "@/lib/utils";
import { useLocale } from "next-intl";
import { ReadMoreDialog } from "./ReadMoreDialog";
import FavoriteButton from "@/components/ui/FavoriteButton";

interface ProductImageGalleryProps {
  product: Product;
  selectedImage: string;
  setSelectedImage: (image: string) => void;
  productData?: any;
  selectedPreference?: "sachets" | "pouch";
}

export default function ProductImageGallery({
  product,
  selectedImage,
  setSelectedImage,
  productData,
  selectedPreference,
}: ProductImageGalleryProps) {
  const locale = useLocale();

  // Determine which images to show based on preference
  const hasPouchImages = Array.isArray(productData?.standupPouchImages) && (productData?.standupPouchImages?.length ?? 0) > 0;
  
  let mobileImages: string[];
  if (selectedPreference === "pouch" && hasPouchImages) {
    // Show standupPouchImages when pouch is selected
    mobileImages = productData.standupPouchImages;
  } else {
    // Show default gallery images for sachets or when pouch images are not available
    const preferenceImage = productData?.productImage || product.images.front;
    mobileImages = [preferenceImage, ...product.images.gallery];
  }

  // Mobile carousel state
  const [activeIndex, setActiveIndex] = useState(0);
  const scrollRef = useRef<HTMLDivElement | null>(null);

  const handleScroll = () => {
    const el = scrollRef.current;
    if (!el) return;
    const width = el.clientWidth;
    if (width === 0) return;
    const index = Math.round(el.scrollLeft / width);
    if (index !== activeIndex) {
      setActiveIndex(index);
      const image = mobileImages[index];
      if (image) setSelectedImage(image);
    }
  };

  const scrollToIndex = (index: number) => {
    const el = scrollRef.current;
    if (!el) return;
    const width = el.clientWidth;
    el.scrollTo({ left: index * width, behavior: "smooth" });
    setActiveIndex(index);
    const image = mobileImages[index];
    if (image) setSelectedImage(image);
  };

  return (
    <div className="space-y-4 3xl:space-y-5">
      {/* Mobile: Horizontal scrollable images */}
      <div className="block lg:hidden">
        <div className="relative">
          {/* Favorite Button - Mobile Only */}
          <FavoriteButton
            product={product}
            productData={productData}
            variant="mobile"
          />
          
          <div
            ref={scrollRef}
            onScroll={handleScroll}
            className="flex overflow-x-auto snap-x snap-mandatory scroll-smooth rounded-2xl"
            style={{ scrollbarWidth: "none" }}
          >
            {mobileImages.map((image, idx) => (
              <div
                key={idx}
                className="min-w-full max-w-96 max-h-96 snap-start aspect-square overflow-hidden"
              >
                {/* static image change behaviour: first image reflects selected preference */}
                <MediaRenderer
                  src={image}
                  alt={`${product.name} view ${idx + 1}`}
                  width={600}
                  height={600}
                  className="w-full h-full object-cover md:object-contain"
                />
              </div>
            ))}
          </div>

          {/* Dots indicator */}
          <div className="absolute bottom-3 left-1/2 -translate-x-1/2 flex items-center gap-1.5">
            {mobileImages.map((_, idx) => (
              <button
                key={idx}
                aria-label={`Go to image ${idx + 1}`}
                onClick={() => scrollToIndex(idx)}
                className={`h-2 w-2 rounded-full transition-colors ${activeIndex === idx ? "bg-white" : "bg-white/50"
                  }`}
              />
            ))}
          </div>
        </div>
      </div>

      {/* Desktop: Current behaviour unchanged */}
      <div className="hidden lg:block">
        <ReadMoreDialog
          title={product.name}
          trigger={
            <div className="aspect-square rounded-2xl overflow-hidden cursor-pointer hover:opacity-95 transition-opacity">
              {/* static image change behaviour of selected Ready? Choose your preference */}
              <MediaRenderer
                src={selectedImage}
                alt={product.name}
                width={600}
                height={600}
                className="w-full h-full object-cover"
              />
            </div>
          }
          modelImages={mobileImages}
        />
      </div>

      {/* Image Gallery Thumbnails - desktop only */}
      <div className="hidden lg:grid grid-cols-2 gap-3 3xl:gap-4">
        {mobileImages.slice(1).map((image, index) => (
          <ReadMoreDialog
            key={index}
            title={product.name}
            trigger={
              <div
                className={`relative aspect-square rounded-lg overflow-hidden transition-all duration-200 cursor-pointer ${selectedImage === image
                  ? "border-teal-green-color"
                  : "border-transparent hover:border-gray-300"
                  }`}
              >
                {/* Blurred background */}
                <MediaRenderer
                  src={image}
                  alt=""
                  width={150}
                  height={150}
                  className="absolute inset-0 w-full h-full object-cover blur-lg opacity-90 backdrop-blur-2xl scale-110"
                />
                {/* Main image */}
                <MediaRenderer
                  src={image}
                  alt={`${product.name} view ${index + 1}`}
                  width={150}
                  height={150}
                  className="relative z-10 w-full h-full object-contain"
                />
              </div>
            }
            modelImages={mobileImages}
            initialIndex={index + 1}
          />
        ))}
      </div>

      {/* More Information */}
      {productData?.ingredientCompositions && productData.ingredientCompositions.length > 0 && (
        <div
          className="hidden lg:block relative w-full p-3.5 3xl:p-4.5 rounded-2xl 3xl:rounded-3xl"
          style={{
            backgroundImage: "url('/products/pro_detail_moreinfor.png')",
            backgroundSize: "cover",
            backgroundPosition: "center",
          }}
        >
          {/* Glass container */}
          <div className="max-w-4xl mx-auto rounded-2xl p-4 3xl:p-5 bg-white/5 backdrop-blur-md ">
            <div
              className={`space-y-6 ${productData.ingredientCompositions.length > 4
                  ? "max-h-[400px] overflow-y-auto pr-2 scrollbar-thin scrollbar-thumb-white/30 scrollbar-track-transparent"
                  : ""
                }`}
            >
              {productData.ingredientCompositions.map((ingComp: any, index: number) => {
                const ingredient = ingComp.ingredient;
                const ingredientName =
                  resolveLocalizedValue(ingredient?.name, locale) ||
                  "Unknown Ingredient";
                const ingredientDescription = resolveLocalizedValue(
                  ingredient?.description,
                  locale,
                );
                const driDisplay = formatIngredientDriDisplay(ingComp.driPercentage);
                return (
                  <div
                    key={ingComp._id}
                    className="flex items-center gap-6 md:gap-6"
                  >
                    {/* Left image */}
                    <Image
                      width={150}
                      height={150}
                      src={ingredient?.image?.url || ingredient?.image || "/products/default-ingredient.png"}
                      alt={ingredientName}
                      className="w-20 3xl:w-25 h-20 3xl:h-25 object-cover rounded-full"
                      // unoptimized
                    />

                    {/* Content */}
                    <div className="pr-5 flex-1">
                      <h3 className="text-white text-base 3xl:text-xl font-medium 3xl:font-semibold mb-1">
                        {index + 1}. {ingredientName}
                      </h3>
                      <p className="text-white/90 text-sm 3xl:text-base line-clamp-3 mb-2">
                        {ingredientDescription}
                      </p>
                      <div className="text-white/80 text-xs 3xl:text-sm">
                        <span className="font-medium">Quantity:</span> {ingComp.quantity || 0}
                        {driDisplay != null && (
                          <span className="ml-3">
                            <span className="font-medium">DRI:</span> {driDisplay}
                          </span>
                        )}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
