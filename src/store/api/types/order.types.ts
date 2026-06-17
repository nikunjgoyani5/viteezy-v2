import { PaginationData } from "./user.types";

export interface OrderStat {
    count: number;
    currentMonth: number;
    lastMonth: number;
    changePercentage: number;
}

export interface OrderStatsData {
    stats: {
        totalOrders: OrderStat;
        delivered: OrderStat;
        processing: OrderStat;
        shipped: OrderStat;
        cancelled: OrderStat;
        pending: OrderStat;
    };
}

export interface GetOrderStatsResponse {
    success: boolean;
    message: string;
    data: OrderStatsData;
}

export interface Order {
    id: string;
    orderNumber: string;
    orderDate: string;
    itemsTotal: number;
    customer: {
        id: string;
        firstName: string;
        lastName: string;
        email: string;
    } | null;
    paymentStatus: string;
    status: string;
    planType: string;
    items: Array<{
        productId: string;
        product: {
            id: string;
            title: string;
            slug: string;
        };
        name: string;
        amount: number;
        discountedPrice: number;
        taxRate: number;
        totalAmount: number;
        durationDays: number | null;
        capsuleCount: number | null;
        savingsPercentage: number | null;
        features: any[];
    }>;
    paymentMethod: string;
    couponCode: string | null;
    shippingAddress: {
        _id: string;
        firstName: string;
        lastName: string;
        streetName: string;
        houseNumber: string;
        houseNumberAddition: string;
        postalCode: string;
        address: string;
        phone: string;
        country: string;
        city: string;
    } | null;
    billingAddress: any;
    trackingNumber: string | null;
    shippedAt: string | null;
    deliveredAt: string | null;
    metadata: {
        planDetails?: {
            planType: string;
            isOneTime: boolean;
            sachets?: {
                planDurationDays: number;
                interval: string;
                cycleDays: number;
            };
            standUpPouch?: {
                itemQuantities: Array<{
                    productId: string;
                    quantity: number;
                    capsuleCount: number;
                    planDays: number;
                }>;
            };
        };
        addressResolution?: {
            source: string;
            isManual: boolean;
        };
        paymentSessionId?: string;
    };
    createdAt: string;
}

export interface GetOrdersParams {
    page?: number;
    limit?: number;
    status?: string;
    search?: string;
    paymentStatus?: string;
    planType?: string;
    startDate?: string;
    endDate?: string;
    customerId?: string;
    date?: string;
    minTotal?: number;
    maxTotal?: number;
    productName?: string;
}

export interface GetOrdersResponse {
    success: boolean;
    message: string;
    data: {
        orders: Order[];
        pagination: PaginationData;
    };
}

export interface OrderDetail {
    id: string;
    orderNumber: string;
    orderDate: string;
    totalOrders: number;
    subscription: any | null;
    customer: {
        id: string;
        firstName: string | null;
        lastName: string | null;
        email: string;
        phone: string | null;
    } | null;
    planType: string;
    status: string;
    paymentStatus: string;
    items: Array<{
        productId: string;
        product: {
            id: string;
            title: string;
            slug: string;
            description?: string;
            categories?: string[];
            status?: boolean;
            galleryImages?: string[];
            productImage?: string;
        };
        name: string;
        amount: number;
        discountedPrice: number;
        taxRate: number;
        totalAmount: number;
        durationDays: number | null;
        capsuleCount: number | null;
        savingsPercentage: number | null;
        features: any[];
    }>;
    pricing: {
        sachets: {
            subTotal: number;
            discountedPrice: number;
            membershipDiscountAmount: number;
            subscriptionPlanDiscountAmount: number;
            taxAmount: number;
            total: number;
            currency: string;
            _id: string;
        };
        overall: {
            subTotal: number;
            discountedPrice: number;
            couponDiscountAmount: number;
            membershipDiscountAmount: number;
            subscriptionPlanDiscountAmount: number;
            taxAmount: number;
            grandTotal: number;
            currency: string;
            _id: string;
        };
        _id: string;
    };
    paymentMethod: string;
    payment: any | null;
    couponCode: string | null;
    shippingAddress: {
        _id: string;
        firstName: string;
        lastName: string;
        streetName: string;
        houseNumber: string;
        houseNumberAddition: string;
        postalCode: string;
        address: string;
        phone: string;
        country: string;
        city: string;
    } | null;
    trackingNumber: string | null;
    shippedAt: string | null;
    deliveredAt: string | null;
    notes: string | null;
    metadata: {
        isRenewalOrder?: boolean;
        isSubscriptionChange?: boolean;
        subscriptionChangeId?: string;
        effectiveDate?: string;
        originalOrderId?: string;
        planDetails?: {
            planType: string;
            isOneTime: boolean;
            sachets?: {
                planDurationDays: number;
                interval: string;
                cycleDays: number;
            };
            standUpPouch?: {
                itemQuantities: Array<{
                    productId: string;
                    quantity: number;
                    capsuleCount: number;
                    planDays: number;
                }>;
            };
        };
        addressResolution?: {
            source: string;
            isManual: boolean;
        };
        paymentSessionId?: string;
    };
    createdAt: string;
    updatedAt: string;
}

export interface GetOrderDetailResponse {
    success: boolean;
    message: string;
    data: {
        order: OrderDetail;
    };
}
