import baseApi from "./baseApi";
import type {
  GetDashboardStatsResponse,
  GetRevenueOverviewParams,
  GetRevenueOverviewResponse,
  GetTopSellingPlansParams,
  GetTopSellingPlansResponse,
  TopSellingProductsResponse,
} from "./types/dashboard.types";

export const dashboardApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getDashboardStats: builder.query<GetDashboardStatsResponse, void>({
      query: () => `/admin/dashboard/stats`,
      providesTags: ["Dashboard"],
    }),

    getRevenueOverview: builder.query<
      GetRevenueOverviewResponse,
      GetRevenueOverviewParams
    >({
      query: (params) => ({
        url: "/admin/dashboard/revenue-overview",
        params,
      }),
      providesTags: ["Dashboard"],
    }),

    getTopSellingPlans: builder.query<
      GetTopSellingPlansResponse,
      GetTopSellingPlansParams
    >({
      query: (params) => ({
        url: "/admin/dashboard/top-selling-plans",
        params,
      }),
      providesTags: ["Dashboard"],
    }),

    getTopSellingProducts: builder.query<TopSellingProductsResponse, void>({
      query: () => ({
        url: "/admin/dashboard/top-selling-products",
        params: { limit: 20 },
      }),
      providesTags: ["Dashboard", "TopSellingProducts"],
    }),
  }),
});

export const {
  useGetDashboardStatsQuery,
  useLazyGetDashboardStatsQuery,
  useGetRevenueOverviewQuery,
  useLazyGetRevenueOverviewQuery,
  useGetTopSellingPlansQuery,
  useLazyGetTopSellingPlansQuery,
  useGetTopSellingProductsQuery,
  useLazyGetTopSellingProductsQuery,
} = dashboardApi;
