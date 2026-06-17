"use client";

interface TheStorySectionProps {
    ourJourney: {
        heading: string;
        description: string;
    };
    onOurJourneyChange: (field: 'heading' | 'description', value: string) => void;
}

export default function TheStorySection({
    ourJourney,
    onOurJourneyChange,
}: TheStorySectionProps) {
    return (
        <div>
            <h3 className="text-sm font-medium mb-4">The Story</h3>

            {/* Heading */}
            <div className="mb-4">
                <label className="block text-sm font-medium mb-2">
                    Heading
                </label>
                <input
                    type="text"
                    value={ourJourney.heading}
                    onChange={(e) => onOurJourneyChange('heading', e.target.value)}
                    className="w-full px-3 py-2 text-xs border border-extra-light-gray rounded-sm focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none transition-colors"
                    placeholder="Enter heading"
                />
            </div>

            {/* Description */}
            <div>
                <label className="block text-sm font-medium mb-2">
                    Description
                </label>
                <textarea
                    value={ourJourney.description}
                    onChange={(e) => onOurJourneyChange('description', e.target.value)}
                    className="text-xs text-black leading-relaxed w-full border border-extra-light-gray rounded-sm p-3 focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none transition-colors resize-none"
                    rows={4}
                    placeholder="Enter description"
                />
            </div>
        </div>
    );
}
