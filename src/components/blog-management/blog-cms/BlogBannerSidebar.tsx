"use client";

import React, { useRef } from "react";
import AppImage from "@/components/ui/appImage";
import { Upload, Pencil } from "lucide-react";
import toast from "react-hot-toast";

interface BlogBannerSidebarProps {
    heading: string;
    description: string;
    bannerImage: string;
    onHeadingChange: (value: string) => void;
    onDescriptionChange: (value: string) => void;
    onBannerImageChange: (imageData: string, file: File) => void;
    onSave: () => void;
    isSaving?: boolean;
    errors?: {
        heading?: string;
        description?: string;
        bannerImage?: string;
    };
    showErrors?: boolean;
}

export default function BlogBannerSidebar({
    heading,
    description,
    bannerImage,
    onHeadingChange,
    onDescriptionChange,
    onBannerImageChange,
    onSave,
    isSaving = false,
    errors = {},
    showErrors = false,
}: BlogBannerSidebarProps) {
    const fileInputRef = useRef<HTMLInputElement>(null);

    const handleImageSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (file) {
            if (!file.type.startsWith("image/")) {
                toast.error("Please select an image file");
                return;
            }
            if (file.size > 5 * 1024 * 1024) {
                toast.error("Image size should be less than 5MB");
                return;
            }
            const reader = new FileReader();
            reader.onloadend = () => {
                onBannerImageChange(reader.result as string, file);
            };
            reader.readAsDataURL(file);
        }
    };

    return (
        <aside className="fixed right-0 top-0 w-72 3xl:w-75 h-screen bg-white border-l border-gray-200 hidden sm:flex flex-col">
            {/* Scrollable content */}
            <div className="flex-1 overflow-y-auto overflow-x-hidden">
                <div className="p-3 space-y-3">
                    {/* Banner Settings Header */}
                    <div>
                        <div className="flex items-center justify-between mt-12 3xl:mt-18 mb-4">
                            <h2 className="text-lg font-semibold">Banner Settings</h2>
                        </div>
                    </div>

                    {/* Heading Section */}
                    <div>
                        <label className="block text-sm font-medium text-text-gray mb-2">
                            Heading <span className="text-red-500">*</span>
                        </label>
                        <textarea
                            value={heading}
                            onChange={(e) => onHeadingChange(e.target.value)}
                            className={`text-xs text-black leading-relaxed w-full border rounded-sm p-3 focus:ring-1 focus:outline-none transition-colors resize-none ${
                                showErrors && errors.heading
                                    ? 'border-red-500 focus:border-red-500 focus:ring-red-500'
                                    : 'border-extra-light-gray focus:border-teal-500 focus:ring-teal-500'
                            }`}
                            rows={3}
                            placeholder="Enter banner heading"
                        />
                        {showErrors && errors.heading && (
                            <p className="mt-1 text-xs text-red-500">{errors.heading}</p>
                        )}
                    </div>

                    {/* Description Section */}
                    <div>
                        <label className="block text-sm font-medium text-text-gray mb-2">
                            Description <span className="text-red-500">*</span>
                        </label>
                        <textarea
                            value={description}
                            onChange={(e) => onDescriptionChange(e.target.value)}
                            className={`text-xs text-black leading-relaxed w-full border rounded-sm p-3 focus:ring-1 focus:outline-none transition-colors resize-none ${
                                showErrors && errors.description
                                    ? 'border-red-500 focus:border-red-500 focus:ring-red-500'
                                    : 'border-extra-light-gray focus:border-teal-500 focus:ring-teal-500'
                            }`}
                            rows={6}
                            placeholder="Enter banner description"
                        />
                        {showErrors && errors.description && (
                            <p className="mt-1 text-xs text-red-500">{errors.description}</p>
                        )}
                    </div>

                    {/* Image Section */}
                    <div>
                        <label className="block text-sm font-medium text-text-gray mb-2">
                            Banner Image <span className="text-red-500">*</span>
                        </label>
                        <input
                            ref={fileInputRef}
                            type="file"
                            accept="image/*"
                            onChange={handleImageSelect}
                            className="hidden"
                        />
                        <div
                            onClick={() => fileInputRef.current?.click()}
                            className={`relative bg-slate-gray rounded-lg overflow-hidden flex items-center justify-center w-38 h-44 border-2 border-dashed cursor-pointer group ${
                                showErrors && errors.bannerImage
                                    ? 'border-red-500 hover:border-red-500'
                                    : 'border-extra-light-gray hover:border-teal-500'
                            }`}
                        >
                            {bannerImage ? (
                                <>
                                    <AppImage
                                        src={bannerImage}
                                        alt="Banner Image"
                                        width={200}
                                        height={208}
                                        className="w-38 h-44 object-contain"
                                    />
                                    {/* Hover Overlay with Pencil Icon */}
                                    <div className="absolute inset-0 bg-black/0 group-hover:bg-black/10 transition-all duration-300 z-10">
                                        <div className="absolute top-2 right-2">
                                            <div className="bg-white rounded-full p-1.5 shadow-md opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                                                <Pencil className="w-4 h-4 text-gray-700" />
                                            </div>
                                        </div>
                                    </div>
                                </>
                            ) : (
                                <div className="flex items-center gap-2 px-4 py-2 text-xs font-medium text-gray-700 bg-white border border-extra-light-gray rounded-lg hover:bg-gray-50">
                                    <Upload className="w-4 h-4" />
                                    Upload Image
                                </div>
                            )}
                        </div>
                        {showErrors && errors.bannerImage && (
                            <p className="mt-1 text-xs text-red-500">{errors.bannerImage}</p>
                        )}
                    </div>
                </div>
            </div>

            {/* Save Button - Fixed at Bottom */}
            <div className="p-3 border-t border-gray-200 bg-white">
                <button
                    onClick={onSave}
                    disabled={isSaving}
                    className="w-full px-4 py-2 text-sm font-medium text-white bg-teal-500 rounded-lg hover:bg-teal-600 transition-colors cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed"
                >
                    {isSaving ? 'Saving...' : 'Save Changes'}
                </button>
            </div>
        </aside>
    );
}
