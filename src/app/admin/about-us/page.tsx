"use client";

import AboutUsPage from "@/components/about-us";
import AboutUsSidebar from "@/components/about-us/AboutUsSidebar";
import { useGetAboutUsQuery, useUpdateAboutUsMutation } from "@/store/api/aboutUsApi";
import { useState, useEffect } from "react";
import toast from "react-hot-toast";

interface TimelineItem {
    date: string;
    title: string;
    subtitle: string;
}

interface TeamMember {
    id: string;
    image: string;
    imageId?: string; // For existing images from backend
    isExisting?: boolean; // To track if from backend or new upload
}

export default function AboutUsPageWrapper() {
    const { data, isLoading } = useGetAboutUsQuery();
    const [updateAboutUs] = useUpdateAboutUsMutation();
    const aboutUs = data?.data?.aboutUs;

    const [heading, setHeading] = useState("");
    const [subtitle, setSubtitle] = useState("");
    const [bannerImage, setBannerImage] = useState("");
    const [bannerImageFile, setBannerImageFile] = useState<File | null>(null);
    const [ctaText, setCtaText] = useState("");
    const [ctaLink, setCtaLink] = useState("");
    const [isSaving, setIsSaving] = useState(false);

    const [founderNote, setFounderNote] = useState({
        heading: "",
        description: ""
    });

    const [founderStory, setFounderStory] = useState({
        heading: "",
        description: "",
        image: "",
        founderName: "",
        position: ""
    });
    const [founderStoryImageFile, setFounderStoryImageFile] = useState<File | null>(null);

    const [meetOurTeam, setMeetOurTeam] = useState({
        heading: "",
        content: "",
        image: ""
    });
    const [meetOurTeamImageFile, setMeetOurTeamImageFile] = useState<File | null>(null);

    const [ourJourney, setOurJourney] = useState({
        heading: "",
        description: ""
    });

    const [timelineSection, setTimelineSection] = useState({
        title: "",
        description: ""
    });

    const [peopleSection, setPeopleSection] = useState({
        title: "",
        subtitle: ""
    });

    const [timeline, setTimeline] = useState<TimelineItem[]>([]);
    const [teamMembers, setTeamMembers] = useState<TeamMember[]>([]);
    const [teamMemberFiles, setTeamMemberFiles] = useState<File[]>([]);
    const [existingImageIds, setExistingImageIds] = useState<string[]>([]); // Track existing image IDs to keep

    // Update local state when API data loads
    useEffect(() => {
        if (aboutUs) {
            setHeading(aboutUs.banner?.banner_title || "");
            setSubtitle(aboutUs.banner?.banner_description || "");
            setBannerImage(aboutUs.banner?.banner_image?.url || "");
            setCtaText(aboutUs.banner?.banner_button_text || "");
            setCtaLink(aboutUs.banner?.banner_button_link || "");

            setFounderNote({
                heading: aboutUs.founderNote?.headline || "",
                description: aboutUs.founderNote?.description || ""
            });

            setFounderStory({
                heading: aboutUs.founderStory?.headline || "",
                description: aboutUs.founderStory?.description || "",
                image: aboutUs.founderStory?.image?.url || "",
                founderName: aboutUs.founderStory?.name || "",
                position: aboutUs.founderStory?.position || ""
            });

            setMeetOurTeam({
                heading: aboutUs.meetBrains?.meet_brains_title || "",
                content: aboutUs.meetBrains?.meet_brains_subtitle || "",
                image: aboutUs.meetBrains?.meet_brains_main_image?.url || ""
            });

            setOurJourney({
                heading: aboutUs.theStory?.heading || "",
                description: aboutUs.theStory?.description || ""
            });

            setTimelineSection({
                title: aboutUs.timeline?.timeline_section_title || "",
                description: aboutUs.timeline?.timeline_section_description || ""
            });

            setPeopleSection({
                title: aboutUs.people?.title || "",
                subtitle: aboutUs.people?.subtitle || ""
            });

            // Map timeline events
            if (aboutUs.timeline?.timeline_events) {
                const timelineItems: TimelineItem[] = aboutUs.timeline.timeline_events.map((event: any) => ({
                    date: event.year || "",
                    title: event.title || "",
                    subtitle: event.description || ""
                }));
                setTimeline(timelineItems);
            }

            // Map people images to team members
            if (aboutUs.people?.images) {
                const members: TeamMember[] = aboutUs.people.images.map((img: any, index: number) => ({
                    id: `member-${index}`,
                    image: img.url || "",
                    imageId: img._id || img.id || `existing-${index}`,
                    isExisting: true,
                }));
                setTeamMembers(members);
                // Track existing image IDs
                setExistingImageIds(members.map(m => m.imageId!).filter(Boolean));
            }
        }
    }, [aboutUs]);

    // Helper: turn any image src (URL or data URL) into a File
    const fileFromImageSrc = async (src: string, index: number): Promise<File | null> => {
        try {
            const res = await fetch(src);
            const blob = await res.blob();
            const ext = (blob.type?.split('/')[1]) || 'jpg';
            return new File([blob], `people-image-${index}.${ext}`, { type: blob.type || 'image/jpeg' });
        } catch (e) {
            console.error('Failed to convert image to file:', src, e);
            return null;
        }
    };

    // Build FormData payload
    const buildFormData = async () => {
        const formData = new FormData();

        // Banner fields
        if (bannerImageFile) {
            formData.append('banner_image', bannerImageFile);
        }
        formData.append('banner_banner_title', heading);
        formData.append('banner_banner_description', subtitle);
        formData.append('banner_banner_button_text', ctaText);
        formData.append('banner_banner_button_link', ctaLink);

        // Founder Note
        formData.append('founderNote_headline', founderNote.heading);
        formData.append('founderNote_description', founderNote.description);

        // Meet Brains (Meet Our Team)
        if (meetOurTeamImageFile) {
            formData.append('meet_brains_main_image', meetOurTeamImageFile);
        }
        formData.append('meetBrains_meet_brains_title', meetOurTeam.heading);
        formData.append('meetBrains_meet_brains_subtitle', meetOurTeam.content);

        // Timeline section
        formData.append('timeline_timeline_section_title', timelineSection.title);
        formData.append('timeline_timeline_section_description', timelineSection.description);

        // Timeline events
        timeline.forEach((item, index) => {
            formData.append(`timeline_timeline_events_${index}_year`, item.date);
            formData.append(`timeline_timeline_events_${index}_title`, item.title);
            formData.append(`timeline_timeline_events_${index}_description`, item.subtitle);
            formData.append(`timeline_timeline_events_${index}_order`, index.toString());
        });

        // People section
        formData.append('people_title', peopleSection.title);
        formData.append('people_subtitle', peopleSection.subtitle);

        // Build files directly from current teamMembers images (only current, post-deletion)
        const imageFilePromises = teamMembers.map((m, i) => fileFromImageSrc(m.image, i));
        const imageFiles = (await Promise.all(imageFilePromises)).filter(Boolean) as File[];

        imageFiles.forEach((file) => {
            formData.append('people_images', file);
        });

        // Founder Story
        formData.append('founderStory_headline', founderStory.heading);
        formData.append('founderStory_description', founderStory.description);
        formData.append('founderStory_name', founderStory.founderName);
        formData.append('founderStory_position', founderStory.position);
        if (founderStoryImageFile) {
            formData.append('founderStory_image', founderStoryImageFile);
        }

        // The Story (Our Journey)
        formData.append('theStory_heading', ourJourney.heading);
        formData.append('theStory_description', ourJourney.description);

        return formData;
    };

    // Save function
    const handleSave = async () => {
        setIsSaving(true);
        try {
            const formData = await buildFormData();
            await updateAboutUs(formData).unwrap();
            toast.success('Changes saved successfully!');
        } catch (error: any) {
            toast.error(error?.data?.message || 'Failed to save changes');
            console.error('Failed to save:', error);
        } finally {
            setIsSaving(false);
        }
    };

    const handleHeadingChange = (value: string) => {
        setHeading(value);
    };

    const handleSubtitleChange = (value: string) => {
        setSubtitle(value);
    };

    const handleBannerImageChange = (image: string, file?: File) => {
        setBannerImage(image);
        if (file) {
            setBannerImageFile(file);
        }
    };

    const handleCtaTextChange = (value: string) => {
        setCtaText(value);
    };

    const handleCtaLinkChange = (value: string) => {
        setCtaLink(value);
    };

    const handleFounderNoteChange = (field: 'heading' | 'description', value: string) => {
        setFounderNote(prev => ({ ...prev, [field]: value }));
    };

    const handleFounderStoryChange = (field: 'heading' | 'description' | 'image' | 'founderName' | 'position', value: string, file?: File) => {
        setFounderStory(prev => ({ ...prev, [field]: value }));
        if (field === 'image' && file) {
            setFounderStoryImageFile(file);
        }
    };

    const handleMeetOurTeamChange = (field: 'heading' | 'content' | 'image', value: string, file?: File) => {
        setMeetOurTeam(prev => ({ ...prev, [field]: value }));
        if (field === 'image' && file) {
            setMeetOurTeamImageFile(file);
        }
    };

    const handleOurJourneyChange = (field: 'heading' | 'description', value: string) => {
        setOurJourney(prev => ({ ...prev, [field]: value }));
    };

    const handleTimelineChange = (updatedTimeline: TimelineItem[]) => {
        setTimeline(updatedTimeline);
    };

    const handleTeamMembersChange = (updatedMembers: TeamMember[]) => {
        setTeamMembers(updatedMembers);
        // Update existing image IDs based on remaining members
        const remainingExistingIds = updatedMembers
            .filter(member => member.isExisting && member.imageId)
            .map(member => member.imageId!);
        setExistingImageIds(remainingExistingIds);
    };

    const handleTeamMemberFilesChange = (files: File[]) => {
        setTeamMemberFiles(files);
    };

    if (isLoading) {
        return (
            <div className="flex justify-center items-center min-h-screen">
                <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-teal-500"></div>
            </div>
        );
    }

    return (
        <div className="pr-0 sm:pr-72 4xl:pr-88">
            {/* Main content - About Us Page Component */}
            <AboutUsPage />

            {/* Fixed sidebar */}
            <AboutUsSidebar
                heading={heading}
                subtitle={subtitle}
                bannerImage={bannerImage}
                ctaText={ctaText}
                ctaLink={ctaLink}
                founderNote={founderNote}
                founderStory={founderStory}
                meetOurTeam={meetOurTeam}
                ourJourney={ourJourney}
                timeline={timeline}
                teamMembers={teamMembers}
                onHeadingChange={handleHeadingChange}
                onSubtitleChange={handleSubtitleChange}
                onBannerImageChange={handleBannerImageChange}
                onCtaTextChange={handleCtaTextChange}
                onCtaLinkChange={handleCtaLinkChange}
                onFounderNoteChange={handleFounderNoteChange}
                onFounderStoryChange={handleFounderStoryChange}
                onMeetOurTeamChange={handleMeetOurTeamChange}
                onOurJourneyChange={handleOurJourneyChange}
                onTimelineChange={handleTimelineChange}
                onTeamMembersChange={handleTeamMembersChange}
                onTeamMemberFilesChange={handleTeamMemberFilesChange}
                onSave={handleSave}
                isSaving={isSaving}
            />
        </div>
    );
}
