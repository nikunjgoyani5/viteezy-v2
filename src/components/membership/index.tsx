"use client";

import React, { useState, useMemo } from "react";
import { useRouter } from "next/navigation";
import BenefitCard from "@/components/home/memberBenefits/BenefitCard";
import { benefitsData } from "@/components/constants";
import { Button } from "../ui/button";
import FAQSection from "../home/faq";
import {
  useGetMembershipPlansQuery,
  useBuyMembershipMutation,
} from "@/store/api/membershipApi";
import Spinner from "../ui/spinner";
import { toast } from "react-hot-toast";
import PortalDialog, { DialogHeader, DialogFooter } from "@/components/ui/portalDialog";
import { hasAuthToken, getCurrencySymbol } from "@/lib/utils";
import { useTranslations } from "next-intl";

export default function MembershipPage() {
  const { data: plansData, isLoading } = useGetMembershipPlansQuery();
  const [buyMembership, { isLoading: isBuying }] = useBuyMembershipMutation();
  const [selectedPlanIndex, setSelectedPlanIndex] = useState<number>(0);
  const [isPaymentDialogOpen, setIsPaymentDialogOpen] = useState(false);
  const [selectedPaymentMethod, setSelectedPaymentMethod] = useState<"Stripe" | "Mollie">("Stripe");
  const router = useRouter();
  const tCommon = useTranslations("Common");
  const tCheckout = useTranslations("Checkout");
  const tMembership = useTranslations("Membership");
  const tConstants = useTranslations("Constants");

  const localizedBenefits = useMemo(
    () =>
      benefitsData.map((b) => ({
        ...b,
        title: tConstants(b.title),
        description: tConstants(b.description),
      })),
    [tConstants],
  );

  const plans = plansData?.data?.plans || [];
  const selectedPlan = plans[selectedPlanIndex];

  // Format price for display
  // Format price for display
  const formattedPrice = useMemo(() => {
    if (!selectedPlan) return { amount: "0", currency: "USD" };
    return {
      amount: selectedPlan.price.amount.toFixed(2),
      currency: selectedPlan.price.currency,
    };
  }, [selectedPlan]);

  // Calculate per-month price
  const perMonthPrice = useMemo(() => {
    if (!selectedPlan) return "0";
    const monthlyRate =
      selectedPlan.price.amount / (selectedPlan.durationDays / 30);
    return monthlyRate.toFixed(2);
  }, [selectedPlan]);

  const handleBuyMembership = async () => {
    if (!selectedPlan) {
      toast.error(tCommon("selectPlanRequired"));
      return;
    }
    if (!hasAuthToken()) {
      toast.error(tCommon("loginRequired"));
      return;
    }
    // Open payment method dialog instead of calling API directly
    setIsPaymentDialogOpen(true);
  };

  const handleConfirmPayment = async () => {
    if (!selectedPlan) return;
    if (!hasAuthToken()) {
      toast.error(tCommon("loginRequired"));
      return;
    }
    try {
      const response = await buyMembership({
        planId: selectedPlan.id,
        paymentMethod: selectedPaymentMethod,
      }).unwrap();

      // Redirect to payment URL from API response
      if (response.data?.payment?.redirectUrl) {
        window.location.href = response.data.payment.redirectUrl;
      } else if (response.data?.payment?.paymentUrl) {
        window.location.href = response.data.payment.paymentUrl;
      } else {
        toast.success(tCommon("membershipPurchaseInitiated"));
        router.push("/account?tab=subscribe");
      }
    } catch (error: unknown) {
      const apiMessage =
        typeof error === "object" && error !== null && "data" in error
          ? (error as { data?: { message?: string } }).data?.message
          : undefined;
      const message: string =
        typeof apiMessage === "string" && apiMessage.length > 0
          ? apiMessage
          : String(tCommon("failedToPurchaseMembership"));
      toast.error(message);
      console.error("Buy membership error:", error);
    } finally {
      setIsPaymentDialogOpen(false);
    }
  };

  if (isLoading) {
    return (
      <section className="min-h-screen bg-linear-to-b from-[#F7F6F0] to-[#FAF9F600] section-padding flex items-center justify-center">
        <Spinner />
      </section>
    );
  }

  return (
    <section className="min-h-screen bg-linear-to-b from-[#F7F6F0] to-[#FAF9F600] section-padding section-pb">
      <div className="max-w-6xl 3xl:max-w-7xl w-full mx-auto">
        <div className="flex flex-col items-start gap-4 py-10 3xl:py-12">
          <h1 className="max-w-md 3xl:max-w-xl text-3xl lg:text-5xl 3xl:text-6xl font-medium">
            {tMembership("pageHeroTitle")}
          </h1>
          <div className="max-w-xl 3xl:max-w-2xl text-start text-black-color text-base 3xl:text-xl">
            {tMembership("pageHeroDescription")}
          </div>
        </div>

        {/* Mobile Benefits Section - visible only below lg */}
        <div className="lg:hidden mb-6 relative rounded-3xl overflow-hidden">
          {/* Background Image */}
          <div
            className="absolute inset-0 bg-cover bg-center"
            style={{
              backgroundImage: `url('/memberBenefits.jpg')`,
            }}
          >
            {/* Overlay */}
            <div className="absolute inset-0 bg-black/10" />
          </div>

          {/* Benefits Content */}
          <div className="relative z-10 mx-3 mt-16 p-3 mb-3 space-y-5 bg-[#FFFFFF]/10 backdrop-blur-lg radius-style">
            {localizedBenefits.map((benefit) => (
              <BenefitCard key={benefit.id} benefit={benefit} layout="row" />
            ))}
          </div>
        </div>

        <div className="lg:bg-white rounded-3xl lg:border border-neutral-sand-100">
          {/* <div className="grid lg:grid-cols-5 gap-12 items-center max-w-7xl mx-auto"> */}
          <div className="grid lg:grid-cols-5 items-center max-w-7xl mx-auto">
            {/* Left Side - Image with Benefits */}
            <div className="rounded-3xl overflow-hidden h-[400px] lg:h-[450px] 3xl:h-[550px] relative z-10 hidden lg:grid grid-cols-2 lg:col-span-3 gap-6 lg:gap-8  bg-white/10 backdrop-blur-lg px-9 pt-3">
              {/* Background Image */}
              <div
                className="absolute inset-0 bg-cover bg-center"
                style={{
                  backgroundImage: `url('/memberBenefits.jpg')`,
                }}
              >
                {/* Subtle overlay */}
                <div className="absolute inset-0 bg-linear-to-b from-transparent to-black/30" />
              </div>

              {/* Benefits Cards - Bottom Section */}
              <div className="absolute bottom-0 left-0 right-0 p-3">
                <div className=" rounded-xl relative z-10 hidden lg:grid grid-cols-2 lg:grid-cols-3 gap-6 lg:gap-8  bg-white/10 backdrop-blur-lg radius-style px-9 pt-3 ">
                  {localizedBenefits.map((benefit) => (
                    <BenefitCard key={benefit.id} benefit={benefit} />
                  ))}
                </div>
              </div>
            </div>

            {/* Right Side - Pricing Card */}
            <div className="flex flex-col justify-center items-center lg:pl-8 lg:col-span-2">
              <div className="w-full max-w-md flex flex-col items-center">
                {/* Plan Toggle */}
                {plans.length > 0 && (
                  <div className="inline-flex gap-1 bg-gains-light-boro/50 rounded-full p-0.5 mb-8">
                    {plans.map((plan, index) => (
                      <button
                        key={plan.id}
                        onClick={() => setSelectedPlanIndex(index)}
                        className={`px-5 py-2.5 cursor-pointer rounded-full font-saans font-medium text-sm 3xl:text-base transition-all duration-300 ${selectedPlanIndex === index
                          ? "bg-white text-black-color"
                          : "bg-transparent text-slightly-gray hover:text-gray-900"
                          }`}
                      >
                        {plan.name}
                      </button>
                    ))}
                  </div>
                )}

                {/* Pricing Display */}
                {selectedPlan && (
                  <>
                    <div className="mb-8 3xl:mb-11 text-center">
                      <div className="flex items-baseline gap-1 justify-center">
                        <span className="text-3xl lg:text-4xl font-medium 3xl:font-semibold font-saans">
                          {getCurrencySymbol(formattedPrice.currency)}
                          {formattedPrice.amount}
                        </span>
                        <span className="text-2xl font-saans font-medium">
                          / {selectedPlan.interval?.toLowerCase()}
                        </span>
                      </div>
                      <p className="mt-1 3xl:mt-2 font-medium text-slightly-gray text-sm 3xl:text-lg">
                        {tMembership("justPerMonth", {
                          symbol: getCurrencySymbol(formattedPrice.currency),
                          price: perMonthPrice,
                        })}
                      </p>
                    </div>

                    {/* CTA Button */}
                    <div className="mb-6 3xl:mb-8 w-full flex justify-center">
                      <Button
                        variant="elevate"
                        size="elevate"
                        animateText
                        className="bg-teal-green-color hover:bg-dark-teal-green-color h-12! 3xl:h-14.5! text-base! 3xl:text-lg! lg:pt-1! 3xl:pt-0!"
                        onClick={handleBuyMembership}
                        disabled={isBuying}
                      >
                        {isBuying
                          ? tCheckout("processing")
                          : tMembership("getPlanButtonText", {
                              interval: selectedPlan.interval ?? "",
                            })}
                      </Button>
                    </div>

                    {/* Additional Info */}
                    <div className="text-center min-h-12 flex items-center justify-center">
                      <p className="text-slightly-gray max-w-44 font-saans font-medium text-sm 3xl:text-lg">
                        {selectedPlan.isAutoRenew
                          ? tMembership("autoRenewsCancelAnytime")
                          : tMembership("oneTimePurchase")}
                      </p>
                    </div>
                  </>
                )}
              </div>
            </div>
          </div>
        </div>
        <FAQSection />
      </div>

      {/* Payment Method Dialog */}
      <PortalDialog
        isShow={isPaymentDialogOpen}
        onClose={() => setIsPaymentDialogOpen(false)}
        title={tMembership("choosePaymentMethodTitle")}
        width={520}
        animationType="center"
      >
        <DialogHeader>
          <p className="text-sm text-gray-600">
            {tMembership("selectProviderToContinue")}
          </p>
        </DialogHeader>
        <div className="mt-2 space-y-3">
          {/* Credit Card / PayPal (Stripe) */}
          <button
            type="button"
            onClick={() => setSelectedPaymentMethod("Stripe")}
            className={`w-full text-left rounded-xl p-4 flex items-center justify-between transition-colors ${selectedPaymentMethod === "Stripe" ? "border border-teal-500 bg-teal-50" : "border border-extra-light-gray"}`}
          >
            <span className="flex items-center gap-2">
              <span className={`inline-block size-3 rounded-full border ${selectedPaymentMethod === "Stripe" ? "bg-teal-500 border-teal-500" : "border-gray-300 bg-white"}`} />
              {tCheckout("creditCardPayPal")}
            </span>
            <span className="flex items-center gap-2">
              <span className="bg-white border-2 border-linen-color px-2 py-1 rounded-md flex items-center justify-center">
                <img src="/payments/p3.webp" alt={tMembership("paymentAltVisa")} className="h-3 w-auto" />
              </span>
              <span className="bg-white border-2 border-linen-color px-2 py-1 rounded-md flex items-center justify-center">
                <img src="/payments/p4.webp" alt={tMembership("paymentAltMastercard")} className="h-3 w-auto" />
              </span>
              <span className="bg-white border-2 border-linen-color px-2 py-1 rounded-md flex items-center justify-center">
                <img src="/payments/p5.webp" alt={tMembership("paymentAltPayPal")} className="h-3 w-auto" />
              </span>
            </span>
          </button>

          {/* Mollie */}
          <button
            type="button"
            onClick={() => setSelectedPaymentMethod("Mollie")}
            className={`w-full text-left rounded-xl p-4 flex items-center justify-between transition-colors ${selectedPaymentMethod === "Mollie" ? "border border-teal-500 bg-teal-50" : "border border-extra-light-gray"}`}
          >
            <span className="flex items-center gap-2">
              <span className={`inline-block size-3 rounded-full border ${selectedPaymentMethod === "Mollie" ? "bg-teal-500 border-teal-500" : "border-gray-300 bg-white"}`} />
              {tMembership("mollieLabel")}
            </span>
            <span className="flex items-center gap-2">
              <span className="bg-white border-2 border-linen-color px-2 py-1 rounded-md flex items-center justify-center">
                <img src="/payments/p1.webp" alt={tMembership("paymentAltIdeal")} className="h-3 w-auto" />
              </span>
              <span className="bg-white border-2 border-linen-color px-2 py-1 rounded-md flex items-center justify-center">
                <img src="/payments/p2.webp" alt={tMembership("paymentAltBancontact")} className="h-3 w-auto" />
              </span>
            </span>
          </button>
        </div>
        <DialogFooter>
          <Button
            variant="elevate"
            size="elevate"
            className="bg-teal-green-color hover:bg-dark-teal-green-color"
            onClick={handleConfirmPayment}
            disabled={isBuying}
          >
            {isBuying ? tCheckout("processing") : tCheckout("payNow")}
          </Button>
        </DialogFooter>
      </PortalDialog>
    </section>
  );
}
