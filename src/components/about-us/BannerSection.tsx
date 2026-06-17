"use client";

import React from "react";
import ImageUploadField from "./ImageUploadField";

interface BannerSectionProps {
    heading: string;
    subtitle: string;
    bannerImage: string;
    ctaText: string;
    ctaLink: string;
    onHeadingChange: (value: string) => void;
    onSubtitleChange: (value: string) => void;
    onBannerImageChange: (value: string, file?: File) => void;
    onCtaTextChange: (value: string) => void;
    onCtaLinkChange: (value: string) => void;
}

export default function BannerSection({
    heading,
    subtitle,
    bannerImage,
    ctaText,
    ctaLink,
    onHeadingChange,
    onSubtitleChange,
    onBannerImageChange,
    onCtaTextChange,
    onCtaLinkChange,
}: BannerSectionProps) {
    return (
        <div className="space-y-4">
            {/* Title Section */}
            <div>
                <label className="block text-sm font-medium mt-12 3xl:mt-18 mb-2">
                    Title
                </label>
                <textarea
                    value={heading}
                    onChange={(e) => onHeadingChange(e.target.value)}
                    className="text-xs text-black leading-relaxed w-full border border-extra-light-gray rounded-sm p-3 focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none transition-colors resize-none"
                    rows={3}
                    placeholder="Enter title"
                />
            </div>

            {/* Description Section */}
            <div>
                <label className="block text-sm font-medium mb-2">
                    Description
                </label>
                <textarea
                    value={subtitle}
                    onChange={(e) => onSubtitleChange(e.target.value)}
                    className="text-xs text-black leading-relaxed w-full border border-extra-light-gray rounded-sm p-3 focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none transition-colors resize-none"
                    rows={6}
                    placeholder="Enter description"
                />
            </div>

            {/* Image Section */}
            <ImageUploadField
                label="Image"
                image={bannerImage}
                onImageChange={onBannerImageChange}
            />

            {/* CTA Button Text */}
            <div>
                <label className="block text-sm font-medium mb-2">
                    CTA Button Text
                </label>
                <input
                    type="text"
                    value={ctaText}
                    onChange={(e) => onCtaTextChange(e.target.value)}
                    className="w-full px-3 py-2 text-xs border border-extra-light-gray rounded-sm focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none transition-colors"
                    placeholder="Enter button text"
                />
            </div>

            {/* CTA Button Link */}
            <div>
                <label className="block text-sm font-medium mb-2">
                    CTA Button Link
                </label>
                <input
                    type="text"
                    value={ctaLink}
                    onChange={(e) => onCtaLinkChange(e.target.value)}
                    className="w-full px-3 py-2 text-xs border border-extra-light-gray rounded-sm focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none transition-colors"
                    placeholder="Enter button link"
                />
            </div>
        </div>
    );
}
