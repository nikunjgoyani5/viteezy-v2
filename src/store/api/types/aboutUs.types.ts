export interface ImageType {
    type: string;
    url: string;
    sortOrder: number;
}

export interface Banner {
    banner_image: ImageType;
    banner_title: string;
    banner_description: string;
    banner_button_text: string;
    banner_button_link: string;
}

export interface FounderNote {
    headline: string;
    description: string;
}

export interface FounderStory {
    headline: string;
    description: string;
    image: ImageType;
    name: string;
    position: string;
}

export interface MeetBrains {
    meet_brains_title: string;
    meet_brains_subtitle: string;
    meet_brains_main_image: ImageType;
}

export interface TimelineEvent {
    year: string;
    title: string;
    description: string;
    order: number;
}

export interface Timeline {
    timeline_section_title: string;
    timeline_section_description: string;
    timeline_events: TimelineEvent[];
}

export interface People {
    title: string;
    subtitle: string;
    images: ImageType[];
}

export interface TheStory {
    heading: string;
    description: string;
    _id: string;
}

export interface AboutUs {
    _id: string;
    banner: Banner;
    founderNote: FounderNote;
    founderStory: FounderStory;
    meetBrains: MeetBrains;
    timeline: Timeline;
    people: People;
    theStory: TheStory;
    isDeleted: boolean;
    createdBy: string;
    createdAt: string;
    updatedAt: string;
    updatedBy: string;
}

export interface AboutUsResponse {
    success: boolean;
    message: string;
    data: {
        aboutUs: AboutUs;
    };
}
