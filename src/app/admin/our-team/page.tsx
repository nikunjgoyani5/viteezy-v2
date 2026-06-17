"use client";

import React, { useState, useEffect, useRef } from "react";
import toast from "react-hot-toast";
import AppImage from "@/components/ui/appImage";
import TeamSidebar from "@/components/ourTeam/TeamSidebar";
import Pagination from "@/components/ui/Pagination";
import { useGetTeamMembersQuery, useGetOurTeamPageQuery, useUpdateOurTeamPageMutation } from "@/store/api/teamApi";

// Utility function to strip HTML tags
const stripHtmlTags = (html: string): string => {
    const temp = document.createElement('div');
    temp.innerHTML = html;
    return temp.textContent || temp.innerText || '';
};

export default function OurTeamPage() {
    const [heading, setHeading] = useState("");
    const [description, setDescription] = useState("");
    const [isSaving, setIsSaving] = useState(false);
    const [currentPage, setCurrentPage] = useState(1);
    const saveTimeoutRef = useRef<NodeJS.Timeout | null>(null);

    // Fetch team members
    const { data, isLoading, isError, refetch } = useGetTeamMembersQuery({
        page: currentPage,
        limit: 10,
    });

    // Fetch our team page data
    const { data: pageData, isLoading: isPageLoading } = useGetOurTeamPageQuery();

    // Update our team page mutation
    const [updateOurTeamPage] = useUpdateOurTeamPageMutation();

    // Update heading and description when data is fetched
    useEffect(() => {
        if (pageData?.data?.banner) {
            setHeading(pageData.data.banner.title);
            // Strip HTML tags from subtitle
            const cleanSubtitle = stripHtmlTags(pageData.data.banner.subtitle);
            setDescription(cleanSubtitle);
        }
    }, [pageData]);

    const teamMembers = data?.data || [];
    const pagination = data?.pagination;

    const handlePageChange = (page: number) => {
        setCurrentPage(page);
        window.scrollTo({ top: 0, behavior: "smooth" });
    };

    const handleMemberAdded = () => {
        // Reset to page 1 to show the newly added member
        if (currentPage !== 1) {
            setCurrentPage(1);
        } else {
            // If already on page 1, manually refetch
            refetch();
        }
    };

    // Auto-save function with debounce
    const autoSave = async (field: string, value: string) => {
        setIsSaving(true);

        // Clear previous timeout
        if (saveTimeoutRef.current) {
            clearTimeout(saveTimeoutRef.current);
        }

        // Set new timeout for auto-save
        saveTimeoutRef.current = setTimeout(async () => {
            try {
                const currentHeading = field === 'heading' ? value : heading;
                const currentDescription = field === 'description' ? value : description;

                await updateOurTeamPage({
                    banner: {
                        title: currentHeading,
                        subtitle: currentDescription,
                    },
                }).unwrap();

                console.log(`Auto-saved ${field} successfully`);
            } catch (error: any) {
                toast.error(error?.data?.message || `Failed to save ${field}`);
                console.error(`Failed to save ${field}:`, error);
            } finally {
                setIsSaving(false);
            }
        }, 1000); // Save after 1 second of no typing
    };

    const handleHeadingChange = (value: string) => {
        setHeading(value);
        autoSave("heading", value);
    };

    const handleDescriptionChange = (value: string) => {
        setDescription(value);
        autoSave("description", value);
    };

    // Cleanup timeout on unmount
    useEffect(() => {
        return () => {
            if (saveTimeoutRef.current) {
                clearTimeout(saveTimeoutRef.current);
            }
        };
    }, []);

    return (
        <div className="grid grid-cols-1 xl:grid-cols-[1fr_258px] 3xl:grid-cols-[1fr_280px] gap-5">
            {/* Left: gallery list */}
            <section className="space-y-5">
                <div className="flex flex-col items-start  justify-between gap-2 py-4">
                    {/* heading of page */}
                    <h1 className="text-3xl font-semibold wrap-break-word">{heading}</h1>
                    <p className="text-sm max-w-xl wrap-break-word">{description}</p>
                </div>

                {/* Loading State */}
                {isLoading && (
                    <div className="flex items-center justify-center py-12">
                        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
                    </div>
                )}

                {/* Error State */}
                {isError && (
                    <div className="flex items-center justify-center py-12">
                        <p className="text-red-500">Failed to load team members. Please try again.</p>
                    </div>
                )}

                {/* Card grid */}
                {!isLoading && !isError && (
                    <>
                        <div className="grid grid-cols-1  lg:grid-cols-3 2xl:grid-cols-4 gap-5">
                            {teamMembers.map((member) => (
                                <article
                                    key={member._id}
                                    className="rounded-xl overflow-hidden border border-extra-light-gray bg-white transition-all duration-300 hover:-translate-y-2 "
                                >
                                    <div className="relative h-72">
                                        {/* Blurred Background Image */}
                                        <AppImage
                                            src={member.image}
                                            alt={`${member.name} background`}
                                            width={600}
                                            height={800}
                                            className="absolute inset-0 w-full h-full object-cover blur-lg scale-110 opacity-30"
                                        />
                                        {/* Main Image */}
                                        <AppImage
                                            src={member.image}
                                            alt={member.name}
                                            width={600}
                                            height={800}
                                            className="relative w-full h-72 object-contain"
                                        />
                                        <div className="absolute top-2 left-2 flex gap-2 whitespace-nowrap ">
                                            <span className="inline-flex items-center rounded-full bg-white/20 text-white text-xs px-2 py-0.5 backdrop-blur-lg text-nowrap">
                                                {member.name}
                                            </span>
                                            <span className="inline-flex items-center rounded-full bg-white/20 text-white text-xs px-2 py-0.5 backdrop-blur-3xl text-nowrap">
                                                {member.designation}
                                            </span>
                                        </div>
                                    </div>
                                </article>
                            ))}
                        </div>

                        {/* Pagination */}
                        {pagination && (
                            <Pagination
                                currentPage={pagination.page}
                                totalPages={pagination.pages}
                                hasNext={pagination.hasNext}
                                hasPrev={pagination.hasPrev}
                                onPageChange={handlePageChange}
                            />
                        )}
                    </>
                )}
            </section>

            {/* Right: Fixed sidebar */}
            <TeamSidebar
                heading={heading}
                description={description}
                members={teamMembers.map((m) => ({
                    id: m._id,
                    name: m.name,
                    role: m.designation,
                    image: m.image,
                    content: m.content,
                }))}
                onHeadingChange={handleHeadingChange}
                onDescriptionChange={handleDescriptionChange}
                onMemberAdded={handleMemberAdded}
                isSaving={isSaving}
            />
        </div>
    );
}
