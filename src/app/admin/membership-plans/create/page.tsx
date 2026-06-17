"use client";

import React from "react";
import { useRouter } from "next/navigation";
import toast from "react-hot-toast";
import MembershipPlanForm, {
    type MembershipPlanFormData,
} from "@/components/forms/MembershipPlanForm";
import { useCreateMembershipPlanMutation } from "@/store/api/membershipPlansApi";

export default function CreateMembershipPlanPage() {
    const router = useRouter();
    const [createPlan] = useCreateMembershipPlanMutation();

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

            await createPlan(payload).unwrap();
            toast.success("Membership plan created successfully");
            router.push("/admin/membership-plans");
        } catch (error: unknown) {
            const errorMessage =
                (error as { data?: { message?: string } })?.data?.message ||
                "Failed to create membership plan";
            toast.error(errorMessage);
            console.error("Failed to create membership plan:", error);
        }
    };

    return (
        <MembershipPlanForm
            titleLabel="Add Plan"
            submitLabel="Save"
            onSubmit={handleSubmit}
        />
    );
}
