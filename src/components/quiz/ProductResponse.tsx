"use client";

import React from "react";
import ProductCard from "./ProductCard";
import { Product } from "@/store/api/types/quiz.types";
import { Button } from "../ui/button";
import { useAddCartItemMutation } from "@/store";
import { useCartSidebar } from "@/lib/cartSidebar";
import { useUpdateSubscriptionProductsMutation } from "@/store/api/subscriptionApi";
import { toast } from "react-hot-toast";
import type { AddCartItemsRequest } from "@/store/api/types/cart.types";
import { useTranslations } from "next-intl";

interface ProductResponseProps {
  products: Product[];
  onProductSelect?: (productId: string) => void;
  selectedProductId?: string;
  subscriptionId?: string;
  onSubscriptionProductsAdded?: (cartId?: string) => void;
}

const ProductResponse: React.FC<ProductResponseProps> = ({
  products,
  onProductSelect,
  selectedProductId,
  subscriptionId,
  onSubscriptionProductsAdded,
}) => {
  const t = useTranslations("Header");
  const tCheckout = useTranslations("Checkout");
  const tProducts = useTranslations("Products");
  const [addCartItem, { isLoading: isAdding }] = useAddCartItemMutation();
  const [updateSubscriptionProducts, { isLoading: isUpdating }] =
    useUpdateSubscriptionProductsMutation();
  const { openCart } = useCartSidebar();

  const handleAddToCart = async () => {
    if (!products?.length) {
      toast.error(t("noProductsToAdd"));
      return;
    }

    try {
      if (subscriptionId) {
        // Add to subscription cart
        const productIds = products.map((product) => product.id);
        const res = await updateSubscriptionProducts({
          subscriptionId,
          productIds,
        }).unwrap();

        toast.success(
          res?.message || t("productsAddedToSubscriptionSuccessfully"),
        );

        // In subscription quiz modal, parent will close modal + open subscription sidebar
        if (onSubscriptionProductsAdded) {
          onSubscriptionProductsAdded(res?.data?.cartId);
        }
        return;
      } else {
        // Add to regular cart
        const payload: AddCartItemsRequest = {
          productId: products[0].id,
          variantType: "SACHETS",
        };

        products.slice(1).forEach((product, index) => {
          payload[`productId_${index + 1}`] = product.id;
          payload[`variantType_${index + 1}`] = "SACHETS";
        });

        const res = await addCartItem(payload).unwrap();
        toast.success(
          res?.message || tCheckout("addedToCartSuccessfully"),
        );
      }
      
      openCart();
    } catch (error: any) {
      console.error("Failed to add items:", error);
      const message =
        error?.data?.message ||
        error?.message ||
        tProducts("failedToAddToCart");
      toast.error(message);
    }
  };

  return (
    <div>
      <div className="flex flex-wrap gap-3">
        {products.map((product) => (
          <ProductCard
            key={product.id}
            id={product.id}
            title={product.title}
            description={product.shortDescription}
            image={product.productImage}
            isSelected={selectedProductId === product.id}
            onSelect={() => onProductSelect?.(product.id)}
          />
        ))}
      </div>
      <Button
        variant="elevate"
        size="elevate"
        animateText
        className="mt-6 block truncate"
        onClick={handleAddToCart}
        disabled={isAdding || isUpdating}
      >
        {isAdding || isUpdating
          ? t("adding")
          : products?.length > 1
          ? t("addAllItemsToCart")
          : t("addItemToCart")}
      </Button>
    </div>
  );
};

export default ProductResponse;
