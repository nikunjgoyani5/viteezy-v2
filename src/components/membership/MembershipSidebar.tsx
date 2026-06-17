"use client";

import React, { useRef } from "react";
import AppImage from "@/components/ui/appImage";
import { Pencil, Upload } from "lucide-react";

export type BenefitItem = {
    title: string;
    subtitle: string;
    imagePreview: string | null;
    imageFile: File | null;
};

interface MembershipSidebarProps {
    heading: string;
    onHeadingChange: (val: string) => void;
    description: string;
    onDescriptionChange: (val: string) => void;

    ctaButtonText: string;
    onCtaButtonTextChange: (val: string) => void;

    note: string;
    onNoteChange: (val: string) => void;

    coverImagePreview: string | null;
    onCoverImageChange: (file: File) => void;

    benefits: BenefitItem[];
    onBenefitChange: (index: number, field: keyof BenefitItem, value: any) => void;

    onSave: () => void;
    isSaving: boolean;
}

export default function MembershipSidebar({
    heading,
    onHeadingChange,
    description,
    onDescriptionChange,
    ctaButtonText,
    onCtaButtonTextChange,
    note,
    onNoteChange,
    coverImagePreview,
    onCoverImageChange,
    benefits,
    onBenefitChange,
    onSave,
    isSaving,
}: MembershipSidebarProps) {
    const coverImageInputRef = useRef<HTMLInputElement>(null);
    const benefitImageInputRefs = useRef<(HTMLInputElement | null)[]>([]);

    const handleCoverImageUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (file) {
            onCoverImageChange(file);
        }
    };

    const handleBenefitImageUpload = (index: number, e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (file) {
            onBenefitChange(index, "imageFile", file);
            // Also create preview
            const reader = new FileReader();
            reader.onload = (ev) => {
                onBenefitChange(index, "imagePreview", ev.target?.result as string);
            };
            reader.readAsDataURL(file);
        }
    };

    return (
        <aside className="fixed right-0 top-0 w-72 4xl:w-88 h-screen bg-white border-l border-extra-light-gray hidden sm:flex flex-col ">
            {/* Scrollable content */}
            <div className="flex-1 overflow-y-auto overflow-x-hidden pb-20">
                <div className="p-3 space-y-3">


                    {/* Header Section */}
                    <div className="mt-16">
                        <label className="block text-xs font-medium text-text-gray mb-1">Heading</label>
                        <input
                            type="text"
                            value={heading}
                            onChange={(e) => onHeadingChange(e.target.value)}
                            className="w-full px-3 py-2 text-xs border border-extra-light-gray rounded-sm focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none transition-colors"
                            placeholder="Enter heading"
                        />
                    </div>

                    {/* Description */}
                    <div>
                        <label className="block text-xs font-medium text-text-gray mb-1">Description</label>
                        <textarea
                            value={description}
                            onChange={(e) => onDescriptionChange(e.target.value)}
                            className="text-xs text-black leading-relaxed w-full border border-extra-light-gray rounded-sm p-3 focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none transition-colors resize-none"
                            rows={4}
                            placeholder="Enter description"
                        />
                    </div>

                    {/* CTA Button Text */}
                    <div>
                        <label className="block text-xs font-medium text-text-gray mb-1">CTA Button Text</label>
                        <input
                            type="text"
                            value={ctaButtonText}
                            onChange={(e) => onCtaButtonTextChange(e.target.value)}
                            className="w-full px-3 py-2 text-xs border border-extra-light-gray rounded-sm focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none transition-colors"
                            placeholder="Enter button text (e.g. Join Now)"
                        />
                    </div>

                    {/* Note */}
                    <div>
                        <label className="block text-xs font-medium text-text-gray mb-1">Note</label>
                        <textarea
                            value={note}
                            onChange={(e) => onNoteChange(e.target.value)}
                            className="text-xs text-black leading-relaxed w-full border border-extra-light-gray rounded-sm p-3 focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none transition-colors resize-none"
                            rows={3}
                            placeholder="Terms and conditions..."
                        />
                    </div>

                    {/* Cover Image */}
                    <div>
                        <label className="block text-xs font-medium text-text-gray mb-1">Cover Image</label>
                        <input
                            ref={coverImageInputRef}
                            type="file"
                            accept="image/*"
                            onChange={handleCoverImageUpload}
                            className="hidden"
                        />
                        <div
                            onClick={() => coverImageInputRef.current?.click()}
                            className="relative bg-slate-gray rounded-lg overflow-hidden flex items-center justify-center w-full h-44 border-2 border-dashed border-extra-light-gray group cursor-pointer hover:bg-gray-100 transition-colors"
                        >
                            {coverImagePreview ? (
                                <img
                                    src={coverImagePreview}
                                    alt="Cover Preview"
                                    className="w-full h-full object-contain"
                                />
                            ) : (
                                <div className="flex flex-col items-center gap-2 text-gray-500">
                                    <Upload className="w-5 h-5" />
                                    <span className="text-xs">Upload Cover Image</span>
                                </div>
                            )}
                            {coverImagePreview && (
                                <div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none">
                                    <div className="w-7 h-7 rounded-full bg-black/60 flex items-center justify-center">
                                        <Pencil className="text-white w-4 h-4" />
                                    </div>
                                </div>
                            )}
                        </div>
                    </div>

                    <div className="border-t border-extra-light-gray pt-4">
                        <h3 className="text-base font-medium mb-4">Membership Benefits</h3>

                        <div className="space-y-6">
                            {benefits.map((benefit, index) => (
                                <div key={index} className="border-t border-extra-light-gray pt-4">
                                    <div className="flex justify-between items-center mb-2">
                                        <span className="text-sm font-semibold ">Cart {index + 1}</span>
                                    </div>

                                    {/* Benefit Image */}
                                    <div className="mb-3">
                                        <label className="block text-sm text-text-gray mb-1">Image</label>
                                        <input
                                            ref={(el) => { benefitImageInputRefs.current[index] = el; }}
                                            type="file"
                                            accept="image/*"
                                            onChange={(e) => handleBenefitImageUpload(index, e)}
                                            className="hidden"
                                        />
                                        <div
                                            onClick={() => benefitImageInputRefs.current[index]?.click()}
                                            className="relative bg-white rounded-lg overflow-hidden flex items-center justify-center w-44 h-44 border border-dashed border-extra-light-gray cursor-pointer hover:border-teal-500 transition-colors group"
                                        >
                                            {benefit.imagePreview ? (
                                                <img
                                                    src={benefit.imagePreview}
                                                    alt={`Benefit ${index + 1}`}
                                                    className="w-full h-full object-contain"
                                                />
                                            ) : (
                                                <div className="flex items-center gap-1 text-gray-400">
                                                    <Upload className="w-4 h-4" />
                                                    <span className="text-[10px]">Upload</span>
                                                </div>
                                            )}
                                            {benefit.imagePreview && (
                                                <div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none">
                                                    <div className="w-6 h-6 rounded-full bg-black/60 flex items-center justify-center">
                                                        <Pencil className="text-white w-3.5 h-3.5" />
                                                    </div>
                                                </div>
                                            )}
                                        </div>
                                    </div>

                                    {/* Benefit Title */}
                                    <div className="mb-3">
                                        <label className="block text-sm text-text-gray mb-1">Title</label>
                                        <input
                                            type="text"
                                            value={benefit.title}
                                            onChange={(e) => onBenefitChange(index, "title", e.target.value)}
                                            className="w-full px-2 py-2.5 text-xs border border-extra-light-gray rounded-md bg-white focus:border-teal-500 focus:outline-none"
                                            placeholder="Title"
                                        />
                                    </div>

                                    {/* Benefit Subtitle */}
                                    <div>
                                        <label className="block text-sm text-text-gray mb-1">Subtitle</label>
                                        <textarea
                                            value={benefit.subtitle}
                                            onChange={(e) => onBenefitChange(index, "subtitle", e.target.value)}
                                            className="w-full px-2 py-3 text-xs border border-extra-light-gray rounded-md bg-white focus:border-teal-500 focus:outline-none resize-none"
                                            rows={2}
                                            placeholder="Subtitle"
                                        />
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            </div>

            {/* Footer / Save Button */}
            <div className="block absolute bottom-0 w-full bg-white border-t border-gray-200 p-4">
                <button
                    onClick={onSave}
                    disabled={isSaving}
                    className="w-full flex justify-center items-center px-4 py-2 bg-teal-green text-white text-sm font-medium rounded-md hover:bg-teal-green/80 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-teal-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors cursor-pointer"
                >
                    {isSaving ? "Saving..." : "Save Changes"}
                </button>
            </div>
        </aside>
    );
}
