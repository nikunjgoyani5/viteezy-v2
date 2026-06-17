import { baseApi } from "./baseApi";

export interface ValidateCouponRequest {
    couponCode: string;
    cartId: string;
    language?: string;
}

export interface CouponData {
    isValid: boolean;
    coupon?: {
        code: string;
        name: {
            en: string;
            nl: string;
        };
        discountType?: "percentage" | "fixed";
        discountValue?: number;
    };
    discountAmount?: number;
    finalAmount?: number;
}

export interface ValidateCouponResponse {
    success: boolean;
    message: string;
    data: CouponData | null;
}

export const couponApi = baseApi.injectEndpoints({
    overrideExisting: true,
    endpoints: (builder) => ({
        /**
         * VALIDATE COUPON
         * Validate a coupon code and get discount details
         */
        validateCoupon: builder.mutation<ValidateCouponResponse, ValidateCouponRequest>({
            query: (body) => ({
                url: "/coupons/validate",
                method: "POST",
                body,
            }),
            invalidatesTags: ["Cart"],
        }),
    }),
});

export const { useValidateCouponMutation } = couponApi;
