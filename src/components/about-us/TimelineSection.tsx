"use client";

import React from "react";
import { ChevronDown, ChevronUp, Trash2 } from "lucide-react";
import toast from "react-hot-toast";

interface TimelineItem {
    date: string;
    title: string;
    subtitle: string;
}

interface TimelineSectionProps {
    timeline: TimelineItem[];
    onTimelineChange: (timeline: TimelineItem[]) => void;
}

export default function TimelineSection({
    timeline,
    onTimelineChange,
}: TimelineSectionProps) {
    const [expandedTimeline, setExpandedTimeline] = React.useState<number | null>(0);

    const addTimeline = () => {
        const newTimeline: TimelineItem = {
            date: "",
            title: "",
            subtitle: "",
        };
        onTimelineChange([...timeline, newTimeline]);
        setExpandedTimeline(timeline.length);
    };

    const removeTimeline = (index: number) => {
        if (timeline.length === 1) {
            toast.error('At least one timeline item is required');
            return;
        }
        const updatedTimeline = timeline.filter((_, i) => i !== index);
        onTimelineChange(updatedTimeline);
        if (expandedTimeline === index) {
            setExpandedTimeline(null);
        }
    };

    const updateTimeline = (
        index: number,
        field: keyof TimelineItem,
        value: string
    ) => {
        const updatedTimeline = timeline.map((item, i) =>
            i === index ? { ...item, [field]: value } : item
        );
        onTimelineChange(updatedTimeline);
    };

    return (
        <div className="">
            <div className="flex items-center justify-between py-4 border-t border-b border-gray-200 mx-2">
                <h3 className="text-sm font-medium text-gray-700 text-nowrap">
                    Timeline
                </h3>
                <button
                    onClick={addTimeline}
                    className="text-teal-500 text-sm font-medium hover:text-teal-600 cursor-pointer text-nowrap"
                >
                    + Add Timeline
                </button>
            </div>

            <div className="space-y-0 px-2">
                {timeline.map((item, index) => (
                    <div key={index} className="border-b border-gray-200">
                        <div
                            className="flex items-center justify-between py-3 bg-white cursor-pointer hover:bg-gray-50"
                            onClick={() =>
                                setExpandedTimeline(
                                    expandedTimeline === index ? null : index
                                )
                            }
                        >
                            <span className="text-sm font-medium text-gray-900">
                                Item {index + 1}
                            </span>
                            <div className="flex items-center gap-2 text-gray-600">
                                <button
                                    onClick={(e) => {
                                        e.stopPropagation();
                                        removeTimeline(index);
                                    }}
                                    className="text-red-500 hover:text-red-600 transition-colors cursor-pointer"
                                    title="Delete timeline"
                                >
                                    <Trash2 className="w-4 h-4" />
                                </button>
                                {expandedTimeline === index ? (
                                    <ChevronUp className="w-5 h-5" />
                                ) : (
                                    <ChevronDown className="w-5 h-5" />
                                )}
                            </div>
                        </div>

                        {expandedTimeline === index && (
                            <div className="py-2 space-y-4 bg-white">
                                <div>
                                    <label className="block text-sm font-medium text-text-gray mb-2">
                                        Year
                                    </label>
                                    <select
                                        value={item.date}
                                        onChange={(e) =>
                                            updateTimeline(
                                                index,
                                                "date",
                                                e.target.value
                                            )
                                        }
                                        className="w-full px-3 py-2 text-xs border border-extra-light-gray rounded-sm focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none text-black"
                                    >
                                        <option value="">Select Year</option>
                                        {Array.from(
                                            {
                                                length:
                                                    new Date().getFullYear() -
                                                    1949,
                                            },
                                            (_, i) =>
                                                new Date().getFullYear() - i
                                        ).map((year) => (
                                            <option
                                                key={year}
                                                value={year.toString()}
                                            >
                                                {year}
                                            </option>
                                        ))}
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-text-gray mb-2">
                                        Title
                                    </label>
                                    <input
                                        type="text"
                                        value={item.title}
                                        onChange={(e) =>
                                            updateTimeline(
                                                index,
                                                "title",
                                                e.target.value
                                            )
                                        }
                                        className="w-full px-3 py-2 text-xs border border-extra-light-gray rounded-sm focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none text-black"
                                        placeholder="Enter title"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-text-gray mb-2">
                                        Subtitle
                                    </label>
                                    <textarea
                                        value={item.subtitle}
                                        onChange={(e) =>
                                            updateTimeline(
                                                index,
                                                "subtitle",
                                                e.target.value
                                            )
                                        }
                                        className="w-full px-3 py-2 text-xs border border-extra-light-gray rounded-sm focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none text-black resize-none"
                                        rows={3}
                                        placeholder="Enter subtitle"
                                    />
                                </div>
                            </div>
                        )}
                    </div>
                ))}
            </div>
        </div>
    );
}
