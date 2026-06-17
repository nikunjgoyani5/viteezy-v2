export interface MembershipPlanPrice {
    currency: string;
    amount: number;
    taxRate: number;
}

export interface MembershipPlanMetadata {
    discountPercentage?: number;
}

export interface MembershipPlanResponse {
    _id: string;
    name: string;
    slug: string;
    shortDescription: string;
    description: string;
    price: MembershipPlanPrice;
    interval: string;
    durationDays: number;
    discountPercentage: number;
    benefits: string[];
    isActive: boolean;
    isAutoRenew: boolean;
    metadata: MembershipPlanMetadata;
    isDeleted: boolean;
    createdBy: string;
    updatedBy: string;
    createdAt: string;
    updatedAt: string;
}

export interface GetMembershipPlansParams {
    page?: number;
    limit?: number;
    search?: string;
    status?: string;
}

export interface Pagination {
    page: number;
    limit: number;
    total: number;
    pages: number;
    hasNext: boolean;
    hasPrev: boolean;
}

export interface GetMembershipPlansResponse {
    success: boolean;
    message: string;
    data: MembershipPlanResponse[];
    pagination: Pagination;
}

export interface GetSingleMembershipPlanResponse {
    success: boolean;
    message: string;
    data: {
        plan: MembershipPlanResponse;
    };
}

export interface UpdateMembershipPlanPayload {
    name?: string;
    slug?: string;
    shortDescription?: string;
    description?: string;
    price?: {
        currency?: string;
        amount?: number;
    };
    interval?: string;
    durationDays?: number;
    discountPercentage?: number;
    benefits?: string[];
    isActive?: boolean;
    isAutoRenew?: boolean;
}

// Membership Page types
export interface MembershipPageResponse {
    success: boolean;
    message: string;
    data: {
        heading: string;
        description: string;
    };
}

export interface UpdateMembershipPageRequest {
    heading: string;
    description: string;
}

// Benefit Card types
export interface BenefitCardResponse {
    _id: string;
    title: string;
    subtitle: string;
    image: string;
    order?: number;
    isActive: boolean;
    createdAt: string;
    updatedAt: string;
}

export interface GetBenefitCardsResponse {
    success: boolean;
    message: string;
    data: BenefitCardResponse[];
}
