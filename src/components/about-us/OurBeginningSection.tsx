"use client";

import ImageUploadField from "./ImageUploadField";

interface OurBeginningProps {
    meetOurTeam: {
        heading: string;
        content: string;
        image: string;
    };
    onMeetOurTeamChange: (field: 'heading' | 'content' | 'image', value: string, file?: File) => void;
}

export default function OurBeginningSection({
    meetOurTeam,
    onMeetOurTeamChange,
}: OurBeginningProps) {
    return (
        <div>
            <h3 className="text-sm font-medium mb-4">Our Beginning</h3>

            {/* Heading */}
            <div className="mb-4">
                <label className="block text-sm font-medium mb-2">
                    Heading
                </label>
                <input
                    type="text"
                    value={meetOurTeam.heading}
                    onChange={(e) => onMeetOurTeamChange('heading', e.target.value)}
                    className="w-full px-3 py-2 text-xs border border-extra-light-gray rounded-sm focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none transition-colors"
                    placeholder="Enter heading"
                />
            </div>

            {/* Content */}
            <div className="mb-4">
                <label className="block text-sm font-medium mb-2">
                    Content
                </label>
                <textarea
                    value={meetOurTeam.content}
                    onChange={(e) => onMeetOurTeamChange('content', e.target.value)}
                    className="text-xs text-black leading-relaxed w-full border border-extra-light-gray rounded-sm p-3 focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none transition-colors resize-none"
                    rows={4}
                    placeholder="Enter content"
                />
            </div>

            {/* Image */}
            <div>
                <ImageUploadField
                    label="Image"
                    image={meetOurTeam.image}
                    onImageChange={(imageData, file) => onMeetOurTeamChange('image', imageData, file)}
                />
            </div>
        </div>
    );
}
