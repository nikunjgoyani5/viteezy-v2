"use client";

import ImageUploadField from "./ImageUploadField";

interface FounderStorySectionProps {
    founderStory: {
        heading: string;
        description: string;
        image: string;
        founderName: string;
        position: string;
    };
    onFounderStoryChange: (field: 'heading' | 'description' | 'image' | 'founderName' | 'position', value: string, file?: File) => void;
}

export default function FounderStorySection({
    founderStory,
    onFounderStoryChange,
}: FounderStorySectionProps) {
    return (
        <div>
            <h3 className="text-sm font-medium mb-4">Founder&apos;s Story</h3>

            {/* Heading */}
            <div className="mb-4">
                <label className="block text-sm font-medium mb-2">
                    Heading
                </label>
                <input
                    type="text"
                    value={founderStory.heading}
                    onChange={(e) => onFounderStoryChange('heading', e.target.value)}
                    className="w-full px-3 py-2 text-xs border border-extra-light-gray rounded-sm focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none transition-colors"
                    placeholder="Enter heading"
                />
            </div>

            {/* Description */}
            <div className="mb-4">
                <label className="block text-sm font-medium mb-2">
                    Description
                </label>
                <textarea
                    value={founderStory.description}
                    onChange={(e) => onFounderStoryChange('description', e.target.value)}
                    className="text-xs text-black leading-relaxed w-full border border-extra-light-gray rounded-sm p-3 focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none transition-colors resize-none"
                    rows={4}
                    placeholder="Enter description"
                />
            </div>

            {/* Image */}
            <div className="mb-4">
                <ImageUploadField
                    label="Image"
                    image={founderStory.image}
                    onImageChange={(imageData, file) => onFounderStoryChange('image', imageData, file)}
                />
            </div>

            {/* Founder Name */}
            <div className="mb-4">
                <label className="block text-sm font-medium mb-2">
                    Founder Name
                </label>
                <input
                    type="text"
                    value={founderStory.founderName}
                    onChange={(e) => onFounderStoryChange('founderName', e.target.value)}
                    className="w-full px-3 py-2 text-xs border border-extra-light-gray rounded-sm focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none transition-colors"
                    placeholder="Enter founder name"
                />
            </div>

            {/* Position */}
            <div>
                <label className="block text-sm font-medium mb-2">
                    Position
                </label>
                <input
                    type="text"
                    value={founderStory.position}
                    onChange={(e) => onFounderStoryChange('position', e.target.value)}
                    className="w-full px-3 py-2 text-xs border border-extra-light-gray rounded-sm focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none transition-colors"
                    placeholder="Enter position"
                />
            </div>
        </div>
    );
}
