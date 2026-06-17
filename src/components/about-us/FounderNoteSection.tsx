"use client";

interface FounderNoteSectionProps {
    founderNote: {
        heading: string;
        description: string;
    };
    onFounderNoteChange: (field: 'heading' | 'description', value: string) => void;
}

export default function FounderNoteSection({
    founderNote,
    onFounderNoteChange,
}: FounderNoteSectionProps) {
    return (
        <div>
            <h3 className="text-sm font-medium mb-4">Founder&apos;s Note</h3>

            {/* Founder's Note Heading */}
            <div className="mb-4">
                <label className="block text-sm font-medium mb-2">
                    Heading
                </label>
                <textarea
                    value={founderNote.heading}
                    onChange={(e) => onFounderNoteChange('heading', e.target.value)}
                    className="text-xs text-black leading-relaxed w-full border border-extra-light-gray rounded-sm p-3 focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none transition-colors resize-none"
                    rows={4}
                    placeholder="Enter founder's note heading"
                />
            </div>

            {/* Founder's Note Description */}
            <div>
                <label className="block text-sm font-medium mb-2">
                    Description
                </label>
                <textarea
                    value={founderNote.description}
                    onChange={(e) => onFounderNoteChange('description', e.target.value)}
                    className="text-xs text-black leading-relaxed w-full border border-extra-light-gray rounded-sm p-3 focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none transition-colors resize-none"
                    rows={3}
                    placeholder="Enter founder's note description"
                />
            </div>
        </div>
    );
}
