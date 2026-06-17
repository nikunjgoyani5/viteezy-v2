export interface TeamMember {
    _id: string;
    image: string;
    name: string;
    designation: string;
    content: string;
    sortOrder?: number;
    isDeleted: boolean;
    createdBy: string;
    createdAt: string;
    updatedAt: string;
    updatedBy: string;
}

export interface TeamMembersResponse {
    success: boolean;
    message: string;
    data: TeamMember[];
    pagination: {
        page: number;
        limit: number;
        total: number;
        pages: number;
        hasNext: boolean;
        hasPrev: boolean;
    };
}

export interface GetTeamMembersParams {
    page?: number;
    limit?: number;
}

export interface OurTeamPageData {
    _id: string;
    banner: {
        banner_image: string | null;
        title: string;
        subtitle: string;
    };
    createdAt: string;
    updatedAt: string;
}

export interface OurTeamPageResponse {
    success: boolean;
    message: string;
    data: OurTeamPageData;
}

export interface UpdateOurTeamPageRequest {
    banner: {
        title: string;
        subtitle: string;
    };
}
