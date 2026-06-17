"use client";
import React, { useEffect, useState } from "react";
import { useSubscriptionSidebar } from "@/lib/subscriptionSidebar";
import { X, Trash2, Plus } from "lucide-react";
import Image from "next/image";
import { Button } from "./button";
import Spinner from "./spinner";
import { getCurrencySymbol } from "@/lib/utils";
import {
  useGetSubscriptionProductsQuery,
  useUpdateSubscriptionProductsMutation,
  useRemoveSubscriptionProductMutation,
  useConfirmSubscriptionUpdateMutation,
} from "@/store/api/subscriptionApi";
import {
  useGetCartBySubscriptionIdQuery,
  useValidateCouponMutation,
  useRemoveCouponMutation,
} from "@/store/api/cartApi";
import { useParams } from "next/navigation";
import Backdrop from "./backdrop";
import CartHeader from "../addToCart/CartHeader";
import { toast } from "react-hot-toast";
import InputField from "./input";
import { useLocale, useTranslations } from "next-intl";

interface SubscriptionCartSidebarProps {
  subscriptionId?: string;
  cartId?: string;
}

export default function SubscriptionCartSidebar({
  subscriptionId: propSubscriptionId,
  cartId: propCartId,
}: SubscriptionCartSidebarProps) {
  const {
    isOpen,
    closeSidebar,
    cartId: contextCartId,
  } = useSubscriptionSidebar();
  const params = useParams();
  const subscriptionId = propSubscriptionId || (params?.id as string);
  const cartId = propCartId || contextCartId;
  const t = useTranslations("Cart");
  const locale = useLocale();

  const {
    data: subscriptionData,
    isLoading: isSubscriptionLoading,
    isFetching: isSubscriptionFetching,
  } = useGetSubscriptionProductsQuery(subscriptionId, {
    skip: !isOpen || !subscriptionId,
  });

  const {
    data: cartData,
    isLoading: isCartLoading,
    isFetching: isCartFetching,
  } = useGetCartBySubscriptionIdQuery(subscriptionId!, {
    skip: !isOpen || !subscriptionId,
  });
  const [deletingId, setDeletingId] = useState<string | null>(null);

  const [updateSubscriptionProducts, { isLoading: isUpdating }] =
    useUpdateSubscriptionProductsMutation();

  const [removeSubscriptionProduct, { isLoading: isRemoving }] =
    useRemoveSubscriptionProductMutation();

  const [confirmSubscriptionUpdate, { isLoading: isConfirming }] =
    useConfirmSubscriptionUpdateMutation();

  const [validateCoupon, { isLoading: isApplyingCoupon }] =
    useValidateCouponMutation();

  const [removeCoupon, { isLoading: isRemovingCoupon }] =
    useRemoveCouponMutation();

  const [couponCode, setCouponCode] = useState<string>("");
  const [isCouponApplied, setIsCouponApplied] = useState<boolean>(false);

  // Get planDurationDays from first cart item
  const planDurationDays = cartData?.data?.cart?.items?.[0]?.planDays;

  const handleDelete = async (productId: string) => {
    setDeletingId(productId);
    try {
      await removeSubscriptionProduct({
        subscriptionId,
        productId,
      }).unwrap();
      toast.success(t("productRemovedFromSubscription"));
    } catch (error) {
      toast.error(t("failedToRemoveProduct"));
    } finally {
      setDeletingId(null);
    }
  };

  const handleApplyCoupon = async () => {
    if (!couponCode || !cartId || !planDurationDays) {
      toast.error(t("enterCouponCodeCartIdPlanDuration"));
      return;
    }
    try {
      await validateCoupon({
        cartId,
        couponCode,
        planDurationDays,
        language: locale || "en",
      }).unwrap();
      toast.success(t("couponAppliedSuccessfully"));
      setIsCouponApplied(true);
    } catch (error) {
      toast.error(t("failedToApplyCoupon"));
    }
  };

  const handleRemoveCoupon = async () => {
    try {
      await removeCoupon({ 
        cartId: cartId!, 
        couponCode, 
        planDurationDays: planDurationDays!, 
        language: locale || "en" 
      }).unwrap();
      toast.success(t("couponRemovedSuccessfully"));
      setCouponCode("");
      setIsCouponApplied(false);
    } catch (error) {
      toast.error(t("failedToRemoveCoupon"));
    }
  };

  const handleConfirm = async () => {
    try {
      await confirmSubscriptionUpdate({
        subscriptionId,
        cartId: cartId!,
      }).unwrap();
      toast.success(t("subscriptionUpdatedSuccessfully"));
      closeSidebar();
    } catch (error) {
      toast.error(t("failedToConfirmSubscriptionUpdate"));
    }
  };

  const products =
    cartData?.data?.cart?.items || subscriptionData?.data?.items || [];
  const isLoading = isCartLoading || isSubscriptionLoading;
  const isRefetching = isCartFetching || isSubscriptionFetching;
  const showSkeleton = isLoading || isRefetching;

  // Skeleton component
  const CartItemSkeleton = () => (
    <div className="bg-white rounded-xl p-3 border border-gray-100">
      <div className="flex gap-4">
        <div className="w-24 h-24 bg-gray-200 rounded-lg animate-pulse" />
        <div className="flex-1 py-1">
          <div className="flex justify-between items-start">
            <div className="w-32 h-6 bg-gray-200 rounded animate-pulse" />
            <div className="w-6 h-6 bg-gray-200 rounded animate-pulse" />
          </div>
          <div className="w-20 h-4 bg-gray-200 rounded animate-pulse mt-2" />
          <div className="flex items-baseline gap-2 mt-3">
            <div className="w-16 h-6 bg-gray-200 rounded animate-pulse" />
            <div className="w-12 h-4 bg-gray-200 rounded animate-pulse" />
          </div>
        </div>
      </div>
    </div>
  );

  // Use cart API data for calculations when available
  const cart = cartData?.data?.cart;
  
  // Helper function to extract numeric value from Price object or number
  const getAmount = (value: any): number => {
    if (typeof value === 'number') return value;
    if (value?.amount) return value.amount;
    return 0;
  };
  
  const subtotal = getAmount((cart as any)?.totalAmount) || getAmount(cart?.subtotal) || products.reduce(
    (acc: number, item: any) => acc + (item.totalAmount || 0),
    0
  );
  const totalDiscount = getAmount(cart?.discount) || products.reduce(
    (acc: number, item: any) =>
      acc +
      ((item.price?.amount || 0) -
        (item.price?.discountedPrice || item.price?.amount || 0)),
    0
  );
  const total = getAmount((cart as any)?.totalAmount) || getAmount(cart?.total) || products.reduce(
    (acc: number, item: any) => acc + (item.totalAmount || 0),
    0
  );
  const shipping = getAmount(cart?.shipping);
  const tax = getAmount(cart?.tax) || products.reduce(
    (acc: number, item: any) => acc + (item.price?.taxRate || 0),
    0
  );
  // Handle coupon discount from cart API (may not be in Cart interface)
  const couponDiscountAmount = getAmount((cart as any)?.couponDiscountAmount) || 0;
  
  // Use cart API currency first, fallback to product currency or USD
  const currency = (cart as any)?.currency || 
    cartData?.data?.cart?.items?.[0]?.price?.currency ||
    products[0]?.product?.price?.currency ||
    "USD";
  const symbol = getCurrencySymbol(currency);

  // Update coupon state when cart data changes
  useEffect(() => {
    if (cart?.couponCode) {
      setCouponCode(cart.couponCode);
      setIsCouponApplied(true);
    } else {
      setCouponCode("");
      setIsCouponApplied(false);
    }
  }, [cart?.couponCode]);

  // Prevent background scroll when sidebar is open
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "unset";
    }
    return () => {
      document.body.style.overflow = "unset";
    };
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-[100] flex justify-end">
      {/* Backdrop */}
      {/* <div
        className="absolute inset-0 bg-black/40 backdrop-blur-sm transition-opacity"
        onClick={closeSidebar}
      /> */}

      <Backdrop isOpen onClose={closeSidebar} zIndex={-1} />

      {/* Sidebar Content */}
      <div className="relative w-full max-w-[450px] bg-off-white-color h-full shadow-2xl flex flex-col animate-in slide-in-from-right duration-700">
        {/* Header */}

        <CartHeader />

        {/* Main Content */}
        <div className="flex-1 overflow-y-auto px-4 py-6 space-y-4">
          {/* Cart Items */}
          <div className="space-y-3">
            <h3 className="text-lg font-bold mb-2">{t("cartSummary")}</h3>
            {showSkeleton ? (
              <div className="space-y-3">
                {[...Array(3)].map((_, index) => (
                  <CartItemSkeleton key={index} />
                ))}
              </div>
            ) : products.length === 0 ? (
              <div className="text-center py-10 text-gray-500">
                {t("subscriptionEmpty")}
              </div>
            ) : (
              products.map((item: any) => (
                <div
                  key={item.productId}
                  className="bg-white rounded-xl p-3 border border-gray-100 relative group"
                >
                  <div className="flex gap-4">
                    <div className="relative w-24 h-24 bg-[#F3F3F3] rounded-lg overflow-hidden flex-shrink-0">
                      <Image
                        src={
                          item.product?.productImage ||
                          "/products/placeholder.png"
                        }
                        alt={item.name}
                        fill
                        className="object-cover"
                      />
                    </div>
                    <div className="flex-1 py-1">
                      <div className="flex justify-between items-start">
                        <h4 className="font-bold text-lg leading-tight">
                          {cartData?.data?.cart?.items
                            ? item.product?.title
                            : item.name}
                        </h4>
                        <button
                          className="text-red-400 hover:text-red-600 transition-colors cursor-pointer"
                          onClick={() => handleDelete(item.productId)}
                          disabled={deletingId === item.productId}
                        >
                          {deletingId === item.productId ? (
                            <Spinner size="xs" color="gray" />
                          ) : (
                            <Trash2 className="w-5 h-5" />
                          )}
                        </button>
                      </div>
                      <p className="text-gray-500 text-sm mt-1">
                        {cartData?.data?.cart?.items
                          ? `${item.quantity} ${t("items")}`
                          : `${item.capsuleCount} ${t("capsules")}`}
                      </p>
                      <div className="mt-3 flex items-baseline gap-2">
                        <span className="text-xl font-bold">
                          {symbol}
                          {cartData?.data?.cart?.items
                            ? (item.price?.amount || 0).toFixed(2)
                            : (item.discountedPrice || 0).toFixed(2)}
                        </span>
                        {cartData?.data?.cart?.items
                          ? item.price?.discountedPrice &&
                            item.price.discountedPrice < item.price.amount && (
                              <span className="text-gray-400 line-through text-sm">
                                {symbol}
                                {item.price.amount.toFixed(2)}
                              </span>
                            )
                          : item.amount > item.discountedPrice && (
                              <span className="text-gray-400 line-through text-sm">
                                {symbol}
                                {item.amount.toFixed(2)}
                              </span>
                            )}
                      </div>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>

          {/* Payment Details */}
          <div className="space-y-4">
            <h3 className="text-lg font-bold mb-2">{t("paymentDetails")}</h3>

            {/* Coupon Section */}
            <div className="">
              <div className="flex gap-2 items-stretch">
                <InputField
                  floating={false}
                  name="couponCode"
                  type="text"
                  placeholder={t("enterDiscountCode")}
                  value={couponCode}
                  onChange={(e) => setCouponCode(e.target.value)}
                  className={`flex-1 ${
                    isCouponApplied ? "opacity-70 cursor-not-allowed" : ""
                  } py-3`}
                  disabled={isCouponApplied}
                />
                <div className="">
                  {isCouponApplied ? (
                    <Button
                      onClick={handleRemoveCoupon}
                      disabled={isRemovingCoupon}
                      className="h-full! px-7.5 text-base"
                    >
                      {isRemovingCoupon ? (
                        <Spinner size="xs" color="white" />
                      ) : (
                        t("remove")
                      )}
                    </Button>
                  ) : (
                    <Button
                      onClick={handleApplyCoupon}
                      disabled={!couponCode || isApplyingCoupon}
                      className="h-full! px-7.5 text-base"
                    >
                      {isApplyingCoupon ? (
                        <Spinner size="xs" color="white" />
                      ) : (
                        t("apply")
                      )}
                    </Button>
                  )}
                </div>
              </div>
            </div>

            <div className="bg-neutral-sand-100 rounded-xl p-4 space-y-3">
              <div className="flex justify-between">
                <span>{t("subtotal")}</span>
                <span className=" text-gray-900">
                  {symbol}
                  {subtotal.toFixed(2)}
                </span>
              </div>
              {tax > 0 && (
                <div className="flex justify-between">
                  <span>{t("tax")}</span>
                  <span className=" text-gray-900">
                    {symbol}
                    {tax.toFixed(2)}
                  </span>
                </div>
              )}
              {shipping > 0 && (
                <div className="flex justify-between">
                  <span>{t("shipping")}</span>
                  <span className=" text-gray-900">
                    {symbol}
                    {shipping.toFixed(2)}
                  </span>
                </div>
              )}
              {totalDiscount > 0 && (
                <div className="flex justify-between">
                  <span>{t("discount")}</span>
                  <span className=" text-gray-900">
                    -{symbol}
                    {totalDiscount.toFixed(2)}
                  </span>
                </div>
              )}
              {couponDiscountAmount > 0 && (
                <div className="flex justify-between">
                  <span>{t("couponDiscount")}</span>
                  <span className=" text-gray-900">
                    -{symbol}
                    {couponDiscountAmount.toFixed(2)}
                  </span>
                </div>
              )}
              <hr />
              <div className="flex justify-between font-semibold">
                <span>{t("grandTotal")}</span>
                <span className=" text-gray-900">
                  {symbol}
                  {total.toFixed(2)}
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="p-4 bg-white border-t space-y-6">
          {/* Total & Checkout */}
          <div className="flex items-center justify-between gap-8">
            <div>
              <div className="text-2xl font-semibold break-all">
                {symbol}
                {total.toFixed(2)}
              </div>
              <div className="text-sm">{t("incAllTaxes")}</div>
              {cart?.couponCode && (
                <div className="text-xs text-green-600 font-medium">
                  {t("couponLabel")}: {cart.couponCode}
                </div>
              )}
            </div>
            <Button
              animateText={isConfirming ? false : true}
              onClick={handleConfirm}
              variant="elevate"
              size="elevate"
              className="flex-1"
              disabled={isConfirming}
            >
              {isConfirming ? <Spinner size="xs" color="white" /> : t("confirm")}
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
