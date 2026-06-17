"use client";

import React, { useMemo } from "react";
import { useParams, useRouter } from "next/navigation";
import toast from "react-hot-toast";
import MembershipPlanForm, {
    type MembershipPlanFormData,
} from "@/components/forms/MembershipPlanForm";
import OverlayLoader from "@/components/common/OverlayLoader";
import {
    useGetMembershipPlanQuery,
    useUpdateMembershipPlanMutation,
} from "@/store/api/membershipPlansApi";

export default function EditMembershipPlanPage() {
    const params = useParams();
    const router = useRouter();
    const planId = params?.planId as string;

    const { data, isLoading, isError } = useGetMembershipPlanQuery(planId, {
        skip: !planId,
    });

    const [updatePlan] = useUpdateMembershipPlanMutation();

    const initialData = useMemo(() => {
        if (!data?.data?.plan) return undefined;

        const plan = data.data.plan;
        return {
            name: plan.name,
            shortDescription: plan.shortDescription,
            description: plan.description,
            durationDays: plan.durationDays,
            price: {
                amount: plan.price.amount,
                currency: plan.price.currency,
            },
            discountPercentage: plan.discountPercentage,
            benefits: plan.benefits,
            isActive: plan.isActive,
            isAutoRenew: plan.isAutoRenew,
        };
    }, [data]);

    const handleSubmit = async (formData: MembershipPlanFormData) => {
        try {
            const payload = {
                name: formData.name,
                ...(formData.shortDescription && {
                    shortDescription: formData.shortDescription,
                }),
                ...(formData.description && { description: formData.description }),
                durationDays: formData.durationDays,
                price: formData.price,
                ...(formData.discountPercentage !== undefined && {
                    discountPercentage: formData.discountPercentage,
                }),
                ...(formData.benefits && { benefits: formData.benefits }),
                ...(formData.isActive !== undefined && { isActive: formData.isActive }),
                ...(formData.isAutoRenew !== undefined && {
                    isAutoRenew: formData.isAutoRenew,
                }),
            };

            await updatePlan({ id: planId, data: payload }).unwrap();
            toast.success("Membership plan updated successfully");
            router.push("/admin/membership-plans");
        } catch (error: unknown) {
            const errorMessage =
                (error as { data?: { message?: string } })?.data?.message ||
                "Failed to update membership plan";
            toast.error(errorMessage);
            console.error("Failed to update membership plan:", error);
        }
    };

    if (isError) {
        return (
            <div className="min-h-screen bg-gray-50 py-6">
                <div className="max-w-5xl mx-auto px-6">
                    <div className="bg-white border rounded-lg p-5 text-red-600">
                        Failed to load membership plan data.
                    </div>
                </div>
            </div>
        );
    }

    if (isLoading || !initialData) {
        return <OverlayLoader show={true} />;
    }

    return (
        <MembershipPlanForm
            titleLabel="Edit Plan"
            submitLabel="Update"
            initialData={initialData}
            onSubmit={handleSubmit}
        />
    );
}
