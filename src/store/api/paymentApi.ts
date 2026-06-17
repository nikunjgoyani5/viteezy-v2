import { baseApi } from "./baseApi";
import type {
    CreatePaymentRequest,
    CreatePaymentResponse,
} from "./types/payment.types";

export const paymentApi = baseApi.injectEndpoints({
    endpoints: (builder) => ({
        /**
         * CREATE PAYMENT
         * Create a payment for an order
         */
        createPayment: builder.mutation<CreatePaymentResponse, CreatePaymentRequest>({
            query: (body) => ({
                url: "/payments/create",
                method: "POST",
                body,
            }),
            invalidatesTags: ["Order"],
        }),
    }),
});

export const {
    useCreatePaymentMutation,
} = paymentApi;
