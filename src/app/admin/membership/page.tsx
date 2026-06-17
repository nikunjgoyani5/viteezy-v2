"use client";

import MembershipComponent from "@/components/membership";
import MembershipSidebar, { BenefitItem } from "@/components/membership/MembershipSidebar";
import React, { useState, useEffect } from "react";
import { useUpdateMembershipCMSMutation } from "@/store/api/membershipPlansApi";
import { useGetMembershipCmsQuery } from "@/store/api/membershipCmsApi";
import toast from "react-hot-toast";

export default function MembershipPlansPage() {
    // Form State
    const [heading, setHeading] = useState("");
    const [description, setDescription] = useState("");
    const [ctaButtonText, setCtaButtonText] = useState("Join Now");
    const [note, setNote] = useState("Terms and conditions apply. Membership can be cancelled...");
    const [isActive, setIsActive] = useState("true");

    // Cover Image State
    const [coverImageFile, setCoverImageFile] = useState<File | null>(null);
    const [coverImagePreview, setCoverImagePreview] = useState<string | null>(null);

    // Benefits State (Fixed 3 items)
    const [benefits, setBenefits] = useState<BenefitItem[]>([
        { title: "Exclusive Access", subtitle: "Get access to premium features", imagePreview: null, imageFile: null },
        { title: "Priority Support", subtitle: "24/7 dedicated support team", imagePreview: null, imageFile: null },
        { title: "Special Discounts", subtitle: "Enjoy up to 50% off on all products", imagePreview: null, imageFile: null },
    ]);

    // API Hooks
    const { data: cmsResponse } = useGetMembershipCmsQuery();
    const [updateMembershipCMS, { isLoading: isSaving }] = useUpdateMembershipCMSMutation();

    // Load initial data if available from CMS GET
    useEffect(() => {
        const cms = cmsResponse?.data?.membershipCms;
        if (cms) {
            setHeading(cms.heading || "Become a Member. Unlock More.");
            setDescription(
                cms.description ||
                "Monarch gives you all the tools to plan, track, and improve your financial life. One membership — everything in one place."
            );
            setCtaButtonText(cms.ctaButtonText || "Join Now");
            setNote(cms.note || "Terms and conditions apply. Membership can be cancelled...");
            setIsActive(String(cms.isActive ?? true));

            // Cover image preview from CMS
            if (cms.coverImage && cms.coverImage.trim().length > 0) {
                setCoverImagePreview(cms.coverImage);
            }

            // Benefits from CMS (image previews + text)
            if (Array.isArray(cms.membershipBenefits) && cms.membershipBenefits.length > 0) {
                const mappedBenefits: BenefitItem[] = cms.membershipBenefits.slice(0, 3).map((b) => ({
                    title: b.title || "",
                    subtitle: b.subtitle || "",
                    imagePreview: b.image || null,
                    imageFile: null,
                }));
                // Ensure fixed 3 items
                while (mappedBenefits.length < 3) {
                    mappedBenefits.push({ title: "", subtitle: "", imagePreview: null, imageFile: null });
                }
                setBenefits(mappedBenefits);
            }
        }
    }, [cmsResponse]);

    // Handlers
    const handleBenefitChange = (index: number, field: keyof BenefitItem, value: any) => {
        setBenefits(prev => prev.map((item, i) =>
            i === index ? { ...item, [field]: value } : item
        ));
    };

    const handleCoverImageChange = (file: File) => {
        setCoverImageFile(file);

        const reader = new FileReader();
        reader.onload = (e) => {
            setCoverImagePreview(e.target?.result as string);
        };
        reader.readAsDataURL(file);
    };

    const handleSave = async () => {
        try {
            const formData = new FormData();
            formData.append("heading", heading);
            formData.append("description", description);
            formData.append("ctaButtonText", ctaButtonText);
            formData.append("note", note);
            formData.append("isActive", isActive);

            // Construct benefits JSON payload (without file objects)
            const benefitsPayload = benefits.map(b => ({
                title: b.title,
                subtitle: b.subtitle
            }));
            formData.append("membershipBenefits", JSON.stringify(benefitsPayload));

            // Append Files
            if (coverImageFile) {
                formData.append("coverImage", coverImageFile);
            }

            // Append Benefit Images
            benefits.forEach((benefit, index) => {
                if (benefit.imageFile) {
                    formData.append(`benefitImage_${index}`, benefit.imageFile);
                }
            });

            await updateMembershipCMS(formData).unwrap();
            toast.success("Membership page updated successfully!");
        } catch (error: any) {
            console.error("Failed to update membership page:", error);
            toast.error(error?.data?.message || "Failed to update membership page");
        }
    };

    return (
        <div className="grid grid-cols-1 xl:grid-cols-[1fr_300px] gap-5 pb-5">
            {/* Left: Membership content preview */}
            <section className="space-y-5">
                <MembershipComponent />
            </section>

            {/* Right: Sidebar Form */}
            <MembershipSidebar
                heading={heading}
                onHeadingChange={setHeading}
                description={description}
                onDescriptionChange={setDescription}

                ctaButtonText={ctaButtonText}
                onCtaButtonTextChange={setCtaButtonText}

                note={note}
                onNoteChange={setNote}

                coverImagePreview={coverImagePreview}
                onCoverImageChange={handleCoverImageChange}

                benefits={benefits}
                onBenefitChange={handleBenefitChange}

                onSave={handleSave}
                isSaving={isSaving}
            />
        </div>
    );
}
