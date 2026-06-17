import baseApi from "./baseApi";
import type {
    GetOrderStatsResponse,
    GetOrdersParams,
    GetOrdersResponse,
    GetOrderDetailResponse,
} from "./types/order.types";

export const orderApi = baseApi.injectEndpoints({
    endpoints: (builder) => ({
        getOrderStats: builder.query<GetOrderStatsResponse, void>({
            query: () => `/admin/orders/stats`,
            providesTags: ["Orders"],
        }),
        getOrders: builder.query<GetOrdersResponse, GetOrdersParams | void>({
            query: (params) => ({
                url: `/admin/orders`,
                params: params || {},
            }),
            providesTags: ["Orders"],
        }),
        getOrderById: builder.query<GetOrderDetailResponse, string>({
            query: (orderId) => `/admin/orders/${orderId}`,
            providesTags: (result, error, orderId) => [{ type: "Orders", id: orderId }],
        }),
    }),
});

export const { useGetOrderStatsQuery, useGetOrdersQuery, useGetOrderByIdQuery } = orderApi;
