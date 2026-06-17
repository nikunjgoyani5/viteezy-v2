export interface MembershipBenefit {
    title: string;
    subtitle: string;
    image: string;
}

export interface MembershipCms {
    _id: string;
    coverImage: string;
    heading: string;
    description: string;
    membershipBenefits: MembershipBenefit[];
    ctaButtonText: string;
    note: string;
    isActive: boolean;
    isDeleted: boolean;
    createdBy: string;
    createdAt: string;
    updatedAt: string;
    updatedBy: string;
}

export interface GetMembershipCmsResponse {
    success: boolean;
    message: string;
    data: {
        membershipCms: MembershipCms;
    };
}
