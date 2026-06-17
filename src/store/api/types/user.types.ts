export interface UserStatus {
    userType: "New User" | "Recurring User";
    isActive: boolean;
}

export interface User {
    _id: string;
    firstName: string;
    lastName: string;
    email: string;
    phone: string | null;
    memberId: string;
    countryCode: string | null;
    registeredAt: string;
    status: UserStatus;
}

export interface PaginationData {
    page: number;
    limit: number;
    total: number;
    pages: number;
    hasNext: boolean;
    hasPrev: boolean;
}

export interface GetUsersRequest {
    page?: number;
    limit?: number;
    userType?: "New User" | "Recurring User";
    isActive?: boolean;
    search?: string;
    registrationDate?: string; // YYYY-MM-DD
}

export interface GetUsersResponse {
    success: boolean;
    message: string;
    data: User[];
    pagination: PaginationData;
}

// Detail page types
export interface UserTotalSpent {
    amount: number;
    currency: string;
}

export interface SubscriptionDetail {
    purchaseDate: string;
    nextBillingDate: string;
    dayPlans: number;
    subscriptionNumber: string;
    status: string;
}

export interface MembershipInfo {
    planStartDate: string;
    planEndDate: string;
    membershipStatus: string;
    planName: string;
}

export interface AddressInfo {
    _id: string;
    firstName: string;
    lastName: string;
    streetName: string;
    houseNumber: string;
    houseNumberAddition?: string | null;
    postalCode: string;
    address: string;
    phone: string;
    country: string;
    city: string;
    isDefault: boolean;
    note?: string | null;
}

export interface PersonalDetails {
    address?: AddressInfo | null;
    email: string;
    phone: string;
    countryCode?: string | null;
    language: string;
}

export interface LinkedFamilyMember {
    profileImage: string | null;
    firstName: string;
    lastName: string;
    email: string;
    phone: string | null;
    countryCode: string | null;
    registeredAt: string;
}

export interface OrderItemPrice {
    amount: number;
    discountedPrice?: number;
    taxRate?: number;
    totalAmount: number;
    currency: string;
}

export interface RecentOrderItem {
    productName: string;
    planDays: number;
    productImage: string;
    productPrice: OrderItemPrice;
}

export interface RecentOrder {
    orderId: string;
    orderNumber: string;
    paymentMethod: string; // e.g., "Stripe" | "Mollie"
    orderCreatedDate: string;
    orderTotalAmount: number;
    items: RecentOrderItem[];
    paymentStatus: string;
}

export interface UserDetail {
    firstName: string;
    lastName: string;
    profileImage?: string | null;
    isPremiumMember: boolean;
    isActive: boolean;
    registrationDate: string;
    membershipId: string;
    totalOrderCount: number;
    totalSpent: UserTotalSpent;
    subscriptionDetails: SubscriptionDetail[];
    membership: MembershipInfo;
    personalDetails: PersonalDetails;
    linkedFamilyList: LinkedFamilyMember[];
    recentOrders: RecentOrder[];
}

export interface GetUserDetailResponse {
    success: boolean;
    message: string;
    data: {
        user: UserDetail;
    };
}
