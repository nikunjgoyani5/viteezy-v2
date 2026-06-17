"use client";

import React, { useEffect, useState, useRef } from "react";
import { useRouter } from "next/navigation";
import ContactInformation from "./ContactInformation";
import ShippingAddress from "./ShippingAddress";
import OrderSummary from "./OrderSummary";
import PackagingOptions, {
  type PackagingOptionsHandle,
} from "./PackagingOptions";
import DiscountCode from "./DiscountCode";
import AddToOrder from "./AddToOrder";
import SummaryPricing from "./SummaryPricing";
import UserAddresses from "./UserAddresses";
import CheckoutPolicies from "./CheckoutPolicies";
import CheckoutFor from "./CheckoutFor";
import Loading from "@/components/ui/loading";
import {
  useGetCheckoutPageSummaryQuery,
  useValidateCartMutation,
  useGetCartQuery,
  useUpdatePlanSelectionMutation,
  useUpdateCheckoutSelectionsMutation,
} from "@/store";
import { useGetAddressesQuery } from "@/store/api/addressApi";
import MainLayout from "../layouts/MainLayout";
import { useTranslations } from "next-intl";

const Layout = ({ children }: { children: React.ReactNode }) => (
  <MainLayout
    simpleHeader
    headerClassName="border-b border-slate-border-color bg-white"
  >
    {children}
  </MainLayout>
);

const Checkout: React.FC = () => {
  const tCheckout = useTranslations("Checkout");
  // Track selected member for Viteezy tips
  const [selectedMemberId, setSelectedMemberId] = useState<string>("");

  // Get addresses with subMemberId if member is selected
  const {
    data,
    isLoading,
    refetch: refetchAddresses,
  } = useGetAddressesQuery(
    selectedMemberId ? { subMemberId: selectedMemberId } : undefined,
    {
      refetchOnMountOrArgChange: true,
    }
  );
  const addresses = data?.data?.addresses || [];
  const hasAddresses = addresses.length > 0;

  // Track selected plan
  const [selectedPlanKey, setSelectedPlanKey] = useState<string>("");

  // Router and checkout summary should be declared before effects using them
  const router = useRouter();
  const {
    data: checkoutData,
    isLoading: checkoutLoading,
    error,
    refetch: refetchCheckout,
    isFetching,
  } = useGetCheckoutPageSummaryQuery(undefined, {
    refetchOnMountOrArgChange: true,
  });
  const [validateCart, { isLoading: isValidating }] = useValidateCartMutation();
  const [updatePlanSelection] = useUpdatePlanSelectionMutation();
  const [updateCheckoutSelections] = useUpdateCheckoutSelectionsMutation();
  const packagingOptionsRef = useRef<PackagingOptionsHandle>(null);

  // Get cart data to extract cartId for coupon validation
  const {
    data: cartData,
    refetch: refetchCart,
    isSuccess: isCartSuccess,
  } = useGetCartQuery(undefined, {
    refetchOnMountOrArgChange: true,
  });
  const cartId = cartData?.data?.cart?._id || "";
  const variantType = cartData?.data?.cart?.variantType;
  const cartApiItems = cartData?.data?.cart?.items || [];

  const cartItems = checkoutData?.data?.cart?.items || [];
  const sachetsPlans = checkoutData?.data?.sachetsPlans || [];
  const standUpPouchPlans = checkoutData?.data?.standUpPouchPlans || {};
  const pricing = checkoutData?.data?.pricing?.overall;
  const suggestedProducts = checkoutData?.data?.suggestedProducts || [];
  const coupon = checkoutData?.data?.coupon || null;
  const couponPresentButInvalid =
    coupon != null && coupon.isValid !== true;
  const activeCouponCode = couponPresentButInvalid
    ? undefined
    : (coupon?.code || cartData?.data?.cart?.couponCode || undefined);

  const displayPricing =
    pricing && couponPresentButInvalid
      ? { ...pricing, couponDiscountAmount: 0 }
      : pricing;

  // Separate cart items by variant type
  const sachetsItems = cartItems.filter((item) => item.variant === "SACHETS");
  const standUpPouchItems = cartItems.filter(
    (item) => item.variant === "STAND_UP_POUCH"
  );

  // Log extracted data from page-summary for debugging
  // eslint-disable-next-line no-console
  console.log("Checkout data extracted:", {
    cartItems,
    sachetsItems,
    standUpPouchItems,
    sachetsPlans,
    standUpPouchPlans,
    pricing,
    suggestedProducts,
  });

  // Same POST /checkout/page-summary body as quantity/plan updates (not empty {})
  const handleCheckoutSummaryAfterCoupon = async (opts?: {
    appliedCode?: string;
    removed?: boolean;
  }) => {
    try {
      const couponOpts: { couponCode?: string | null } | undefined =
        opts?.removed === true
          ? { couponCode: null }
          : opts?.appliedCode !== undefined
            ? { couponCode: opts.appliedCode }
            : undefined;
      const payload =
        packagingOptionsRef.current?.buildPageSummaryPayload(couponOpts) ??
        {};

      if (Object.keys(payload).length > 0) {
        await updateCheckoutSelections(payload).unwrap();
      } else {
        await refetchCheckout();
      }

      await refetchCart();
    } catch (error) {
      console.error("Failed to refresh checkout summary:", error);
    }
  };

  // Redirect only after cart API succeeds and confirms the cart is empty.
  useEffect(() => {
    if (isCartSuccess && cartApiItems.length === 0) {
      router.replace("/products");
    }
  }, [isCartSuccess, cartApiItems.length, router]);

  // Refetch checkout data and cart on mount to ensure fresh data
  useEffect(() => {
    refetchCheckout();
    refetchCart();
    refetchAddresses();
  }, [refetchCheckout, refetchCart, refetchAddresses]);

  // Validate cart on mount
  useEffect(() => {
    if (cartItems.length > 0) {
      validateCart();
    }
  }, []);

  if (isLoading || checkoutLoading) {
    return (
      <Layout>
        <div className="min-h-screen bg-off-white-color flex items-center justify-center">
          <div className="flex flex-col items-center gap-4">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900"></div>
            <p className="text-gray-600">{tCheckout("loadingCheckout")}</p>
          </div>
        </div>
      </Layout>
    );
  }

  if (error || !checkoutData?.data) {
    return (
      <Layout>
        <div className="min-h-screen bg-off-white-color flex items-center justify-center">
          <div className="text-center">
            <p className="text-red-500 text-lg mb-4">
              {tCheckout("failedToLoadCart")}
            </p>
            <button
              onClick={() => router.push("/products")}
              className="bg-gray-900 text-white px-6 py-2 rounded-full hover:bg-gray-800"
            >
              {tCheckout("continueShopping")}
            </button>
          </div>
        </div>
      </Layout>
    );
  }
  return (
    <Layout>
      <div className="min-h-screen checkout bg-off-white-color border-t border-neutral-sand-100 relative z-0">
        {isFetching && <Loading zIndex={99} className=""/>}
        <div className="max-w-3xl lg:max-w-[1220px] mx-auto px-4">
          <div className="grid grid-cols-1 lg:grid-cols-[52%_48%] gap-0">
            <div className="space-y-7 address z-10 pt-10 pe-0 lg:pe-10 ps-0 lg:pb-10 relative lg:self-start h-full order-2 lg:order-1">
              <div className="address-pin h-fit space-y-7 lg:sticky lg:top-40">
                <ContactInformation />

                <CheckoutFor 
                  onMemberSelect={setSelectedMemberId}
                  selectedMemberId={selectedMemberId}
                />

                {checkoutLoading ? (
                  <div className="flex justify-center items-center py-12">
                    <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-teal-500" />
                  </div>
                ) : hasAddresses ? (
                  <UserAddresses
                    checkoutData={checkoutData?.data}
                    selectedPlanKey={selectedPlanKey}
                    isCheckoutLoading={checkoutLoading}
                    isValidating={isValidating}
                    selectedMemberId={selectedMemberId}
                  />
                ) : (
                  <ShippingAddress
                    isCheckoutLoading={checkoutLoading}
                    isValidating={isValidating}
                  />
                )}

                <CheckoutPolicies />
              </div>
              <div className="absolute hidden lg:block h-full w-screen top-0 end-0 bg-white -z-10 border-e border-slate-border-color"></div>
            </div>

            <div className="checkout-right space-y-7  mb-0 mt-7 lg:mb-10 lg:mt-10 lg:ps-10 order-1 lg:order-2">
              <OrderSummary items={sachetsItems} />
              <PackagingOptions
                ref={packagingOptionsRef}
                sachetsItems={sachetsItems}
                standUpPouchItems={standUpPouchItems}
                sachetsPlans={sachetsPlans}
                standUpPouchPlans={standUpPouchPlans}
                onPlanSelect={(planKey) => setSelectedPlanKey(planKey)}
                couponCode={activeCouponCode}
                onRefreshCheckout={() => {
                  refetchCheckout();
                  refetchCart();
                }}
              />
              <DiscountCode
                coupon={coupon}
                cartId={cartId}
                onRefreshCart={handleCheckoutSummaryAfterCoupon}
              />
              {displayPricing && (
                <SummaryPricing pricing={displayPricing} isValidating={isValidating} />
              )}
              <AddToOrder
                suggestedProducts={suggestedProducts}
                onRefreshCheckout={() => {
                  refetchCheckout();
                  refetchCart();
                }}
              />
            </div>
          </div>

          {/* Mobile Layout - Single Column */}
          {/* <div className="lg:hidden space-y-6">
          <div className="space-y-6">
            <ContactInformation />
            <ShippingAddress />
          </div>
        </div> */}
        </div>
      </div>
    </Layout>
  );
};

export default Checkout;
