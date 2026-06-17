import baseApi from "./baseApi";
import type {
    GetSubscriptionsParams,
    GetSubscriptionsResponse,
} from "./types/subscription.types";

export const subscriptionApi = baseApi.injectEndpoints({
    endpoints: (builder) => ({
        getSubscriptions: builder.query<GetSubscriptionsResponse, GetSubscriptionsParams | void>({
            query: (params) => ({
                url: `/admin/subscriptions`,
                params: params || {},
            }),
            providesTags: ["Subscriptions"],
        }),
        pauseSubscription: builder.mutation<{ success: boolean; message: string }, string>({
            query: (subscriptionId) => ({
                url: `/admin/subscriptions/${subscriptionId}/pause`,
                method: "POST",
            }),
            invalidatesTags: ["Subscriptions"],
        }),
        cancelSubscription: builder.mutation<
            { success: boolean; message: string },
            { subscriptionId: string; data: { cancellationReason: string; customReason?: string; cancelImmediately: boolean } }
        >({
            query: ({ subscriptionId, data }) => ({
                url: `/admin/subscriptions/${subscriptionId}/cancel`,
                method: "POST",
                body: data,
            }),
            invalidatesTags: ["Subscriptions"],
        }),
    }),
});

export const { useGetSubscriptionsQuery, usePauseSubscriptionMutation, useCancelSubscriptionMutation } = subscriptionApi;
