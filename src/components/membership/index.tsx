"use client";

import React, { useState, useMemo } from "react";
import BenefitCard from "./BenifitsCard";
import { formatCurrencySimple } from "@/lib/currencyUtils";
import { Button } from "@/components/ui/button";
import { useGetMembershipPlansQuery } from "@/store/api/membershipPlansApi";
import { useGetMembershipCmsQuery } from "@/store/api/membershipCmsApi";
import AppImage from "@/components/ui/appImage";
import OverlayLoader from "@/components/common/OverlayLoader";

export default function MembershipComponent() {
    const [selectedPlanIndex, setSelectedPlanIndex] = useState(0);
    const [isBuying, setIsBuying] = useState(false);

    // Fetch membership CMS data from API
    const { data: cmsResponse, isLoading: isCmsLoading } = useGetMembershipCmsQuery();

    // Fetch membership plans from API
    const { data: plansResponse, isLoading } = useGetMembershipPlansQuery({
        page: 1,
        limit: 5,
    });

    // Extract CMS data
    const cmsData = useMemo(() => {
        return cmsResponse?.data?.membershipCms || null;
    }, [cmsResponse]);

    // Extract benefits from CMS data
    const benefitsData = useMemo(() => {
        if (!cmsData?.membershipBenefits) return [];
        return cmsData.membershipBenefits.map((benefit, index) => ({
            id: index + 1,
            title: benefit.title,
            description: benefit.subtitle,
            icon: benefit.image,
            type: "image"
        }));
    }, [cmsData]);

    // Extract plans from API response
    const plans = useMemo(() => {
        return plansResponse?.data || [];
    }, [plansResponse]);

    // Get selected plan
    const selectedPlan = plans[selectedPlanIndex];

    // Format price for display
    const formattedPrice = useMemo(() => {
        if (!selectedPlan?.price) return "0";
        return formatCurrencySimple(selectedPlan.price.amount);
    }, [selectedPlan]);

    // Calculate per-month price
    const perMonthPrice = useMemo(() => {
        if (!selectedPlan?.price || !selectedPlan?.durationDays) return 0;
        const durationMonths = selectedPlan.durationDays / 30;
        if (!durationMonths || !isFinite(durationMonths)) return 0;
        return (selectedPlan.price.amount / durationMonths).toFixed(2);
    }, [selectedPlan]);

    const intervalLabel = useMemo(() => {
        const i = selectedPlan?.interval;
        return typeof i === "string" ? i.toLowerCase() : "";
    }, [selectedPlan]);

    const handleBuyMembership = () => {
        setIsBuying(true);
        // Add your buy membership logic here
        setTimeout(() => {
            setIsBuying(false);
        }, 2000);
    };

    // Show loader while fetching data
    if (isCmsLoading || isLoading) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <div className="relative w-full h-96">
                    <OverlayLoader show={true} label="Loading membership data..." />
                </div>
            </div>
        );
    }

    return (
        <div className="">
            <section className="min-h-screen bg-linear-to-b  ">
                <div className="max-w-6xl w-full mx-auto">
                    <div className="flex flex-col items-start gap-4 py-10">
                        <h1 className="max-w-md text-3xl lg:text-5xl font-medium">
                            {cmsData?.heading || "Become a Member. Unlock More."}
                        </h1>
                        <div className="max-w-xl text-start text-black-color">
                            {cmsData?.description || "Monarch gives you all the tools to plan, track, and improve your financial life. One membership — everything in one place."}
                        </div>
                    </div>

                    {/* Mobile Benefits Section - visible only below lg */}
                    <div className="lg:hidden mb-6 relative rounded-3xl overflow-hidden">
                        {/* Background Image */}
                        {cmsData?.coverImage ? (
                            <AppImage
                                src={cmsData.coverImage}
                                alt="Membership Benefits"
                                fill
                                className="object-cover"
                            />
                        ) : (
                            <div
                                className="absolute inset-0 bg-cover bg-center"
                                style={{
                                    backgroundImage: `url('/memberBenefits.jpg')`,
                                }}
                            />
                        )}
                        {/* Overlay */}
                        <div className="absolute inset-0 bg-black/10" />

                        {/* Benefits Content */}
                        <div className="relative z-10 mx-3 mt-16 p-3 mb-3 space-y-5 bg-[#FFFFFF]/10 backdrop-blur-lg radius-style">
                            {benefitsData.map((benefit) => (
                                <BenefitCard key={benefit.id} benefit={benefit} layout="row" />
                            ))}
                        </div>
                    </div>

                    <div className="lg:bg-white radius-style">
                        <div className="grid lg:grid-cols-5 gap-12 items-center max-w-7xl mx-auto">
                            {/* Left Side - Image with Benefits */}
                            <div className="radius-style overflow-hidden h-[400px] lg:h-[450px] relative z-10 hidden lg:grid grid-cols-2 lg:col-span-3 gap-6 lg:gap-8  bg-white/10 backdrop-blur-lg radius-style px-9 pt-3">
                                {/* Background Image */}
                                {cmsData?.coverImage ? (
                                    <>
                                        <AppImage
                                            src={cmsData.coverImage}
                                            alt="Membership Benefits"
                                            fill
                                            className="object-cover"
                                        />
                                        {/* Subtle overlay */}
                                        <div className="absolute inset-0 bg-linear-to-b from-transparent to-black/30" />
                                    </>
                                ) : (
                                    <div
                                        className="absolute inset-0 bg-cover bg-center"
                                        style={{
                                            backgroundImage: `url('/memberBenefits.jpg')`,
                                        }}
                                    >
                                        {/* Subtle overlay */}
                                        <div className="absolute inset-0 bg-linear-to-b from-transparent to-black/30" />
                                    </div>
                                )}

                                {/* Benefits Cards - Bottom Section */}
                                <div className="absolute bottom-0 left-0 right-0 p-3">
                                    <div className=" rounded-xl relative z-10 hidden lg:grid grid-cols-2 lg:grid-cols-3 gap-6 lg:gap-8  bg-white/10 backdrop-blur-lg radius-style px-9 pt-3 ">
                                        {benefitsData.map((benefit) => (
                                            <BenefitCard key={benefit.id} benefit={benefit} />
                                        ))}
                                    </div>
                                </div>
                            </div>

                            {/* Right Side - Pricing Card */}
                            <div className="flex flex-col justify-center items-center lg:pl-8 lg:col-span-2">
                                <div className="w-full max-w-md flex flex-col items-center">
                                    {/* Plan Toggle */}
                                    {isLoading ? (
                                        <div className="mb-8">Loading plans...</div>
                                    ) : plans.length > 0 ? (
                                        <div className="inline-flex gap-1 bg-porcelain rounded-full p-0.5 mb-8">
                                            {plans.map((plan, index) => (
                                                <button
                                                    key={plan._id}
                                                    onClick={() => setSelectedPlanIndex(index)}
                                                    className={`px-5 py-2.5 cursor-pointer rounded-full font-saans font-medium text-sm transition-all duration-300 ${selectedPlanIndex === index
                                                        ? "bg-white text-black-color"
                                                        : "bg-transparent text-slightly-gray hover:text-gray-900"
                                                        }`}
                                                >
                                                    {plan.interval || "Plan"}
                                                </button>
                                            ))}
                                        </div>
                                    ) : null}

                                    {/* Pricing Display */}
                                    {selectedPlan && (
                                        <>
                                            <div className="mb-8 text-center">
                                                <div className="flex items-baseline gap-1 justify-center">
                                                    <span className="text-3xl lg:text-4xl font-medium font-saans">
                                                        {formattedPrice}
                                                    </span>
                                                    {intervalLabel && (
                                                        <span className="text-2xl font-saans font-semibold ">
                                                            /{intervalLabel}
                                                        </span>
                                                    )}
                                                </div>

                                            </div>

                                            {/* CTA Button */}
                                            <div className="mb-6 w-full flex justify-center">
                                                <Button
                                                    variant="elevate"
                                                    size="elevate"
                                                    animateText
                                                    className="bg-teal-green hover:bg-dark-teal-green-color h-12! font-normal! text-base! lg:pt-1!"
                                                    onClick={handleBuyMembership}
                                                    disabled={isBuying}
                                                >
                                                    {isBuying
                                                        ? "Processing..."
                                                        : cmsData?.ctaButtonText || `Get ${selectedPlan.interval || "Membership"} Plan`}
                                                </Button>
                                            </div>

                                            {/* Additional Info */}
                                            <div className="text-center min-h-12 flex items-center justify-center">
                                                <p className="text-slightly-gray max-w-44 font-saans text-sm">
                                                    {cmsData?.note || (selectedPlan.isAutoRenew
                                                        ? "Auto-renews* Cancel anytime."
                                                        : "One-time purchase*")}
                                                </p>
                                            </div>
                                        </>
                                    )}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    );
}
