import { PaginationData } from "./user.types";

export interface SubscriptionUser {
    id: string;
    firstName: string;
    lastName: string;
    email: string;
    fullName: string;
}

export interface SubscriptionOrder {
    id: string;
    orderNumber: string;
}

export interface SubscriptionProduct {
    id: string;
    title: string;
    slug: string;
}

export interface SubscriptionItem {
    productId: string | null;
    product: SubscriptionProduct | null;
    name: string;
    amount: number;
    discountedPrice: number;
    totalAmount: number;
    durationDays: number;
    capsuleCount: number | null;
}

export interface Subscription {
    id: string;
    subscriptionNumber: string;
    status: "Active" | "Cancelled" | "Paused" | "Expired";
    planType: string;
    cycleDays: number;
    subscriptionStartDate: string;
    subscriptionEndDate: string;
    user: SubscriptionUser | null;
    order: SubscriptionOrder;
    items: SubscriptionItem[];
    initialDeliveryDate: string;
    nextDeliveryDate: string;
    nextBillingDate: string;
    lastBilledDate: string;
    lastDeliveredDate: string | null;
    cancelledAt: string | null;
    cancelledBy: string | null;
    cancellationReason: string | null;
    pausedAt: string | null;
    pausedUntil: string | null;
    createdAt: string;
    updatedAt: string;
}

export interface GetSubscriptionsParams {
    page?: number;
    limit?: number;
    status?: string;
    search?: string;
    planType?: string;
    startDate?: string;
    endDate?: string;
}

export interface GetSubscriptionsResponse {
    success: boolean;
    message: string;
    data: Subscription[];
    pagination: PaginationData;
}
