"use client";

import React, { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { ChevronLeft } from "lucide-react";
import InputField from "@/components/ui/inputs/input";
import TextareaField from "@/components/ui/inputs/textarea";
import { ToggleSwitch } from "@/components/ui/table";

export interface MembershipPlanFormData {
    name: string;
    shortDescription?: string;
    description?: string;
    durationDays: number;
    price: {
        amount: number;
        currency?: string;
    };
    discountPercentage?: number;
    benefits?: string[];
    isActive?: boolean;
    isAutoRenew?: boolean;
}

type MembershipPlanFormState = {
    name: string;
    shortDescription: string;
    description: string;
    durationDays: string;
    amount: string;
    discountPercentage: string;
    benefitsText: string;
    isActive: boolean;
    isAutoRenew: boolean;
};

type MembershipPlanFieldErrorKey =
    | "name"
    | "durationDays"
    | "amount"
    | "discountPercentage"
    | "benefits";

function membershipFieldToErrorKey(
    field: keyof MembershipPlanFormState
): MembershipPlanFieldErrorKey | undefined {
    if (field === "benefitsText") return "benefits";
    if (
        field === "name" ||
        field === "durationDays" ||
        field === "amount" ||
        field === "discountPercentage"
    ) {
        return field;
    }
    return undefined;
}

type MembershipPlanFormProps = {
    initialData?: Partial<MembershipPlanFormData>;
    submitLabel?: string;
    titleLabel?: string;
    onSubmit?: (data: MembershipPlanFormData) => Promise<void> | void;
};

export default function MembershipPlanForm({
    initialData,
    submitLabel = "Save",
    titleLabel = "Add Plan",
    onSubmit,
}: MembershipPlanFormProps) {
    const router = useRouter();
    const [isLoading, setIsLoading] = useState(false);
    const [errors, setErrors] = useState<
        Partial<Record<MembershipPlanFieldErrorKey, string>>
    >({});

    const [formData, setFormData] = useState<MembershipPlanFormState>({
        name: initialData?.name ?? "",
        shortDescription: initialData?.shortDescription ?? "",
        description: initialData?.description ?? "",
        durationDays:
            initialData?.durationDays !== undefined ? String(initialData.durationDays) : "",
        amount:
            initialData?.price?.amount !== undefined ? String(initialData.price.amount) : "",
        discountPercentage:
            initialData?.discountPercentage !== undefined
                ? String(initialData.discountPercentage)
                : "",
        benefitsText: initialData?.benefits?.join(", ") ?? "",
        isActive: initialData?.isActive ?? true,
        isAutoRenew: initialData?.isAutoRenew ?? true,
    });

    useEffect(() => {
        if (initialData) {
            setFormData((prev) => ({
                ...prev,
                name: initialData.name ?? prev.name,
                shortDescription: initialData.shortDescription ?? prev.shortDescription,
                description: initialData.description ?? prev.description,
                durationDays:
                    initialData.durationDays !== undefined
                        ? String(initialData.durationDays)
                        : prev.durationDays,
                amount:
                    initialData.price?.amount !== undefined
                        ? String(initialData.price.amount)
                        : prev.amount,
                discountPercentage:
                    initialData.discountPercentage !== undefined
                        ? String(initialData.discountPercentage)
                        : prev.discountPercentage,
                benefitsText: initialData.benefits?.join(", ") ?? prev.benefitsText,
                isActive: initialData.isActive ?? prev.isActive,
                isAutoRenew: initialData.isAutoRenew ?? prev.isAutoRenew,
            }));
        }
    }, [initialData]);

    const handleChange = (
        field: keyof MembershipPlanFormState,
        value: string | boolean
    ) => {
        setFormData((prev) => ({
            ...prev,
            [field]: value,
        }));
        // Clear error when user types (map form fields to validation keys, e.g. benefitsText → benefits)
        const errorKey = membershipFieldToErrorKey(field);
        if (errorKey && errors[errorKey]) {
            setErrors((prev) => ({
                ...prev,
                [errorKey]: undefined,
            }));
        }
    };

    const validate = (): MembershipPlanFormData | null => {
        const newErrors: Partial<Record<MembershipPlanFieldErrorKey, string>> =
            {};

        const durationDays = Number(formData.durationDays);
        const amount = Number(formData.amount);
        const discountPercentage =
            formData.discountPercentage.trim() === ""
                ? undefined
                : Number(formData.discountPercentage);
        const benefits = formData.benefitsText
            .split(",")
            .map((item) => item.trim())
            .filter(Boolean);

        if (!formData.name.trim()) {
            newErrors.name = "Name is required";
        }

        if (!Number.isInteger(durationDays) || durationDays < 1) {
            newErrors.durationDays = "Duration days must be an integer >= 1";
        }

        if (Number.isNaN(amount) || amount < 0) {
            newErrors.amount = "Price amount must be a number >= 0";
        }

        if (
            discountPercentage !== undefined &&
            (Number.isNaN(discountPercentage) ||
                discountPercentage < 0 ||
                discountPercentage > 100)
        ) {
            newErrors.discountPercentage = "Discount must be between 0 and 100";
        }

        if (benefits.some((benefit) => !benefit)) {
            newErrors.benefits = "Benefits can only contain non-empty values";
        }

        setErrors(newErrors);
        if (Object.keys(newErrors).length > 0) {
            return null;
        }

        return {
            name: formData.name.trim(),
            shortDescription: formData.shortDescription.trim() || undefined,
            description: formData.description.trim() || undefined,
            durationDays,
            price: {
                amount,
                currency: "USD",
            },
            discountPercentage,
            benefits: benefits.length > 0 ? benefits : undefined,
            isActive: formData.isActive,
            isAutoRenew: formData.isAutoRenew,
        };
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();

        const payload = validate();
        if (!payload) {
            return;
        }

        setIsLoading(true);

        try {
            if (onSubmit) {
                await onSubmit(payload);
            } else {
                // TODO: Replace with actual API call
                console.log("Form submitted:", payload);
                await new Promise((resolve) => setTimeout(resolve, 1000));
                router.push("/admin/membership-plans");
            }
        } catch (error) {
            console.error("Failed to save membership plan:", error);
            // Handle error (show toast, etc.)
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="min-h-screen bg-gray-50 py-6">
            <div className="max-w-5xl mx-auto px-6">
                {/* Header */}

                <div className="flex items-center justify-between mb-6">
                    <div className="flex items-center gap-3 cursor-pointer">
                        <button
                            onClick={() => router.back()}
                            className="p-2 hover:bg-gray-100 rounded-lg transition-colors flex items-center gap-3 cursor-pointer"
                        >
                            <ChevronLeft className="w-5 h-5 text-gray-600" />
                            <h1 className="text-2xl font-semibold text-gray-900">{titleLabel}</h1>
                        </button>
                    </div>

                    <button
                        onClick={handleSubmit}
                        disabled={isLoading}
                        className="px-6 py-2.5 bg-teal-500 text-white rounded-lg hover:bg-teal-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed font-medium"
                    >
                        {isLoading ? "Saving..." : submitLabel}
                    </button>
                </div>

                {/* Form Content */}
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    {/* Left Side - Main Fields */}
                    <div className="lg:col-span-2 space-y-6">
                        <div className="bg-white rounded-lg border border-gray-200 p-6 space-y-5">
                            {/* Title */}
                            <InputField
                                label="Name"
                                placeholder="Enter membership plan name"
                                value={formData.name}
                                onChange={(e) => handleChange("name", e.target.value)}
                                error={errors.name}
                                required
                            />

                            {/* Short Description */}
                            <InputField
                                label="Short Description"
                                placeholder="Enter short description (optional)"
                                value={formData.shortDescription}
                                onChange={(e) => handleChange("shortDescription", e.target.value)}
                            />

                            {/* Description */}
                            <TextareaField
                                label="Description"
                                placeholder="Enter detailed description (optional)"
                                value={formData.description}
                                onChange={(e) => handleChange("description", e.target.value)}
                            />

                            {/* Duration (Days) */}
                            <InputField
                                label="Duration (Days)"
                                type="number"
                                placeholder="Enter duration in days"
                                value={formData.durationDays}
                                onChange={(e) => handleChange("durationDays", e.target.value)}
                                error={errors.durationDays}
                                required
                                min={1}
                                step={1}
                                noDecimals
                            />

                            <TextareaField
                                label="Benefits"
                                placeholder="Enter benefits separated by commas (optional)"
                                value={formData.benefitsText}
                                onChange={(e) => handleChange("benefitsText", e.target.value)}
                                error={errors.benefits}
                            />
                        </div>
                    </div>

                    {/* Right Side - Price */}
                    <div className="lg:col-span-1">
                        <div className="bg-white rounded-lg border border-gray-200 p-6">
                            <div className="flex flex-col gap-2">
                                <label className="text-sm font-medium text-gray-700">
                                    Price Amount <span className="text-red-500">*</span>
                                </label>
                                <div className="relative">
                                    <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500">
                                        $
                                    </span>
                                    <input
                                        type="number"
                                        step="0.01"
                                        min="0"
                                        placeholder="0.00"
                                        value={formData.amount}
                                        onChange={(e) => handleChange("amount", e.target.value)}
                                        className={`w-full h-10 rounded-lg border pl-7 pr-3 py-2 text-sm outline-none transition focus:ring-1 focus:ring-teal-500 bg-white placeholder:text-gray-400 ${errors.amount ? "border-red-500" : "border-gray-300"
                                            }`}
                                    />
                                </div>
                                {errors.amount && (
                                    <p className="text-xs text-red-500">{errors.amount}</p>
                                )}
                            </div>

                            <div className="flex flex-col gap-2 mt-4">
                                <InputField
                                    label="Discount Percentage"
                                    type="number"
                                    min={0}
                                    max={100}
                                    step={0.01}
                                    placeholder="0 - 100 (optional)"
                                    value={formData.discountPercentage}
                                    onChange={(e) =>
                                        handleChange("discountPercentage", e.target.value)
                                    }
                                    error={errors.discountPercentage}
                                />
                            </div>

                            <div className="mt-5 space-y-3">
                                <div className="flex items-center justify-between gap-4">
                                    <span className="text-sm text-gray-700">Is Active</span>
                                    <ToggleSwitch
                                        checked={formData.isActive}
                                        onChange={(checked) => handleChange("isActive", checked)}
                                    />
                                </div>
                                <div className="flex items-center justify-between gap-4">
                                    <span className="text-sm text-gray-700">Is Auto Renew</span>
                                    <ToggleSwitch
                                        checked={formData.isAutoRenew}
                                        onChange={(checked) =>
                                            handleChange("isAutoRenew", checked)
                                        }
                                    />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
