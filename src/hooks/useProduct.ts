import { useGetProductByIdQuery } from "@/store/api/productApi";
import { Product } from "@/components/types";
import { resolveLocalizedValue } from "@/lib/utils";
import { useLocale } from "next-intl";

export const useProduct = (productId: string) => {
  const locale = useLocale();
  const { data, isLoading, error } = useGetProductByIdQuery(productId);

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const productData = (data as any)?.data?.product || (data as any)?.data;

  // Transform API data to Product format
  const product: Product | null = productData
    ? {
        id: productData._id,
        name: resolveLocalizedValue(productData.title, locale),
        description:
          resolveLocalizedValue(productData.description, locale).replace(
            /<[^>]*>/g,
            "",
          ) || resolveLocalizedValue(productData.shortDescription, locale),
        price:
          productData.sachetPrices?.thirtyDays?.discountedPrice ||
          productData.price?.amount ||
          0,
        originalPrice:
          productData.sachetPrices?.thirtyDays?.amount ||
          productData.price?.amount ||
          0,
        rating: productData.averageRating || 5.0,
        reviewCount: productData.ratingCount || 0,
        images: {
          front: productData.productImage || "/products/pro_detail0.png",
          gallery: productData.galleryImages || [],
        },
        category:
          resolveLocalizedValue(productData.categories?.[0]?.name, locale) ||
          "Supplements",
        inStock: productData.status !== false,
      }
    : null;

  return {
    product,
    productData,
    isLoading,
    error,
  };
};
