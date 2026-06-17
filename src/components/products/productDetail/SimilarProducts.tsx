"use client";
import Image from "next/image";
import { useMemo, useState } from "react";
import { useGetProductsQuery, useAddCartItemMutation } from "@/store";
import { useCartSidebar } from "@/lib/cartSidebar";
import { toast } from "react-hot-toast";
import { hasAuthToken, resolveLocalizedValue } from "@/lib/utils";
import { useLocale, useTranslations } from "next-intl";
import { Button } from "@/components/ui/button";

interface SimilarProductsProps {
  productData: any; // Using any due to API shape variability
  selectedPreference: "sachets" | "pouch";
}

export default function SimilarProducts({
  productData,
  selectedPreference,
}: SimilarProductsProps) {
  const currentProductId: string | undefined = productData?._id;
  const categorySlug: string | undefined = productData?.categories?.[0]?.slug;
  const [addingToCart, setAddingToCart] = useState<string | null>(null);
  const { openCart } = useCartSidebar();
  const [addCartItem] = useAddCartItemMutation();
  const locale = useLocale();
  const tCommon = useTranslations("Common");
  const t = useTranslations("Products");
  const tCheckout = useTranslations("Checkout");

  const {
    data: productsResp,
    isLoading,
    error,
  } = useGetProductsQuery(
    categorySlug ? { categories: categorySlug, sortBy: "latest" } : undefined
  );

  const similar = useMemo(() => {
    const list: any[] = productsResp?.data || [];
    const filtered = list.filter((p) => p?._id !== currentProductId);
    // "last 4" — take the last four items from the filtered list
    return filtered.slice(-4);
  }, [productsResp, currentProductId]);

  const handleAddToCart = async (
    productId: string,
    hasStandupPouch: boolean
  ) => {
    if (!hasAuthToken()) {
      toast.error(tCommon("loginRequired"));
      return;
    }
    try {
      setAddingToCart(productId);
      const variantType =
        selectedPreference === "pouch" && hasStandupPouch
          ? "STAND_UP_POUCH"
          : "SACHETS";
      const res = await addCartItem({
        productId: productId,
        variantType: variantType,
      }).unwrap();
      openCart();
      toast.success(res?.message || tCheckout("addedToCartSuccessfully"));
    } catch (error: any) {
      console.error("Failed to add item to cart:", error);
      const message =
        error?.data?.message || error?.message || t("failedToAddToCart");
      toast.error(message);
    } finally {
      setAddingToCart(null);
    }
  };

  return (
    <div>
      <h3 className="text-charcol-color font-medium text-base mb-3 3xl:text-xl">
        {t("similarProducts")}
      </h3>

      {isLoading && (
        <div className="space-y-2">
          <div className="h-24 bg-neutral-sand-100 rounded-xl animate-pulse" />
          <div className="h-24 bg-neutral-sand-100 rounded-xl animate-pulse" />
        </div>
      )}

      {Boolean(error) && (
        <p className="text-red-600 text-sm">{t("failedToLoad")}</p>
      )}

      {!isLoading && !error && (
        <div className="space-y-2">
          {similar.map((product) => {
            const productTitle = resolveLocalizedValue(product.title, locale);
            return (
            <div
              key={product._id}
              className="flex items-center gap-4 py-3 3xl:py-3.5 px-3.75 3xl:px-4 bg-neutral-sand-100 rounded-xl"
            >
              <div className="w-20 3xl:w-25 h-20 3xl:h-25 bg-white rounded-md overflow-hidden shrink-0">
                <Image
                  src={product.productImage || "/products/pro_detail0.png"}
                  alt={productTitle}
                  width={120}
                  height={120}
                  className="w-full h-full object-cover"
                  // unoptimized
                />
              </div>
              <div className="flex-1 min-w-0">
                <h4 className="text-charcol-color font-medium text-base 3xl:text-[19px]">
                  {productTitle}
                </h4>
                <p className="text-charcol-color text-sm line-clamp-2 md:line-clamp-1 3xl:text-[17px]">
                A good source of protein, ideal for an active lifestyle
                </p>
                <div className="sm:flex items-center justify-between  mt-1 3xl:mt-2.75">
                  <div className="gap-2 flex items-center">
                    <span className="text-charcol-color font-semibold text-sm 3xl:text-[19px]">
                      $
                      {(
                        product?.sachetPrices?.thirtyDays?.discountedPrice ??
                        product?.price?.amount ??
                        0
                      ).toFixed(2)}
                    </span>
                    {product?.sachetPrices?.thirtyDays?.amount && (
                      <span className="text-gray-warm text-sm line-through 3xl:text-[19px]">
                        ${product.sachetPrices.thirtyDays.amount.toFixed(2)}
                      </span>
                    )}
                  </div>
                  <Button
                    animateText
                    onClick={() =>
                      handleAddToCart(
                        product._id,
                        product?.hasStandupPouch ?? false
                      )
                    }
                    disabled={addingToCart === product._id}
                    className="w-full sm:w-auto mt-1 sm:mt-0 px-8 3xl:px-9.5 !bg-transparent 3xl:pt-0 3xl:min-h-10 border border-charcol-color cursor-pointer rounded-full text-sm font-medium text-charcol-color hover:scale-105 hover:transition-all transition-colors disabled:opacity-50 disabled:cursor-not-allowed 3xl:text-lg truncate"
                  >
                    {addingToCart === product._id ? t("adding") : t("add")}
                  </Button>
                </div>
              </div>
            </div>
          );
          })}
          {similar.length === 0 && (
            <p className="text-gray-warm text-sm">{t("noSimilarProducts")}</p>
          )}
        </div>
      )}
    </div>
  );
}
