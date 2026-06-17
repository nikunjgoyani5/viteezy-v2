"use client";

import React from "react";
import BannerSection from "./BannerSection";
import FounderNoteSection from "./FounderNoteSection";
import FounderStorySection from "./FounderStorySection";
import OurBeginningSection from "./OurBeginningSection";
import TheStorySection from "./TheStorySection";
import TimelineSection from "./TimelineSection";
import TeamMembersSection from "./TeamMembersSection";

interface TimelineItem {
    date: string;
    title: string;
    subtitle: string;
}

interface TeamMember {
    id: string;
    image: string;
    imageId?: string;
    isExisting?: boolean;
}

interface AboutUsSidebarProps {
    heading: string;
    subtitle: string;
    bannerImage: string;
    ctaText: string;
    ctaLink: string;
    founderNote: {
        heading: string;
        description: string;
    };
    founderStory: {
        heading: string;
        description: string;
        image: string;
        founderName: string;
        position: string;
    };
    meetOurTeam: {
        heading: string;
        content: string;
        image: string;
    };
    ourJourney: {
        heading: string;
        description: string;
    };
    timeline: TimelineItem[];
    teamMembers: TeamMember[];
    onHeadingChange: (value: string) => void;
    onSubtitleChange: (value: string) => void;
    onBannerImageChange: (value: string, file?: File) => void;
    onCtaTextChange: (value: string) => void;
    onCtaLinkChange: (value: string) => void;
    onFounderNoteChange: (field: 'heading' | 'description', value: string) => void;
    onFounderStoryChange: (field: 'heading' | 'description' | 'image' | 'founderName' | 'position', value: string, file?: File) => void;
    onMeetOurTeamChange: (field: 'heading' | 'content' | 'image', value: string, file?: File) => void;
    onOurJourneyChange: (field: 'heading' | 'description', value: string) => void;
    onTimelineChange: (timeline: TimelineItem[]) => void;
    onTeamMembersChange: (members: TeamMember[]) => void;
    onTeamMemberFilesChange: (files: File[]) => void;
    onSave: () => void;
    isSaving?: boolean;
}

export default function AboutUsSidebar({
    heading,
    subtitle,
    bannerImage,
    ctaText,
    ctaLink,
    founderNote,
    founderStory,
    meetOurTeam,
    ourJourney,
    timeline,
    teamMembers,
    onHeadingChange,
    onSubtitleChange,
    onBannerImageChange,
    onCtaTextChange,
    onCtaLinkChange,
    onFounderNoteChange,
    onFounderStoryChange,
    onMeetOurTeamChange,
    onOurJourneyChange,
    onTimelineChange,
    onTeamMembersChange,
    onTeamMemberFilesChange,
    onSave,
    isSaving = false,
}: AboutUsSidebarProps) {

    return (
        <aside className="fixed right-0 top-0 w-72 4xl:w-88 h-screen bg-white border-l border-gray-200 hidden sm:flex flex-col">
            {/* Scrollable content */}
            <div className="flex-1 overflow-y-auto overflow-x-hidden pb-20">
                <div className="p-3 space-y-4">
                    {/* Banner Section */}
                    <BannerSection
                        heading={heading}
                        subtitle={subtitle}
                        bannerImage={bannerImage}
                        ctaText={ctaText}
                        ctaLink={ctaLink}
                        onHeadingChange={onHeadingChange}
                        onSubtitleChange={onSubtitleChange}
                        onBannerImageChange={onBannerImageChange}
                        onCtaTextChange={onCtaTextChange}
                        onCtaLinkChange={onCtaLinkChange}
                    />

                    {/* Divider */}
                    <div className="border-t border-gray-200"></div>

                    {/* Founder's Note Section */}
                    <FounderNoteSection
                        founderNote={founderNote}
                        onFounderNoteChange={onFounderNoteChange}
                    />

                    {/* Divider */}
                    <div className="border-t border-gray-200"></div>

                    {/* Founder's Story Section */}
                    <FounderStorySection
                        founderStory={founderStory}
                        onFounderStoryChange={onFounderStoryChange}
                    />

                    {/* Divider */}
                    <div className="border-t border-gray-200"></div>

                    {/* Our Beginning Section */}
                    <OurBeginningSection
                        meetOurTeam={meetOurTeam}
                        onMeetOurTeamChange={onMeetOurTeamChange}
                    />

                    {/* Divider */}
                    <div className="border-t border-gray-200"></div>

                    {/* The Story Section */}
                    <TheStorySection
                        ourJourney={ourJourney}
                        onOurJourneyChange={onOurJourneyChange}
                    />

                    {/* Divider */}
                    <div className="border-t border-gray-200"></div>

                    {/* Timeline Section */}
                    <TimelineSection
                        timeline={timeline}
                        onTimelineChange={onTimelineChange}
                    />

                    {/* Team Members Section */}
                    <TeamMembersSection
                        teamMembers={teamMembers}
                        onTeamMembersChange={onTeamMembersChange}
                        onFilesChange={onTeamMemberFilesChange}
                    />
                </div>
            </div>

            {/* Save Button */}
            <div className="fixed bottom-0 right-0 w-72 4xl:w-88 p-4 bg-white border-t border-gray-200 shadow-lg z-10">
                <button
                    onClick={onSave}
                    disabled={isSaving}
                    className="w-full px-4 py-3 text-sm font-semibold text-white bg-teal-500 rounded-lg hover:bg-teal-600 transition-colors disabled:bg-gray-400 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                >
                    {isSaving ? (
                        <>
                            <svg className="animate-spin h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                            </svg>
                            Saving...
                        </>
                    ) : (
                        'Save Changes'
                    )}
                </button>
            </div>
        </aside>
    );
}
