import baseApi from "./baseApi";
import type {
  CreateCouponPayload,
  CreateCouponResponse,
  DeleteCouponResponse,
  GetCouponsParams,
  GetCouponsResponse,
  GetCouponByIdResponse,
  GetCouponStatsResponse,
  GetCouponUsageLogsParams,
  GetCouponUsageLogsResponse,
  UpdateCouponResponse,
  UpdateCouponStatusPayload,
  UpdateCouponStatusResponse,
} from "./types/coupon.types";

export const couponApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getCouponStats: builder.query<GetCouponStatsResponse, void>({
      query: () => "/admin/coupons/stats",
      providesTags: ["CouponStats"],
    }),

    getCoupons: builder.query<GetCouponsResponse, GetCouponsParams | void>({
      query: (params) => ({
        url: "/admin/coupons",
        params: { page: 1, limit: 10, ...(params ?? {}) },
      }),
      providesTags: ["Coupons"],
    }),

    createCoupon: builder.mutation<CreateCouponResponse, CreateCouponPayload>({
      query: (body) => ({
        url: "/admin/coupons",
        method: "POST",
        body,
      }),
      invalidatesTags: ["Coupons", "CouponStats"],
    }),

    deleteCoupon: builder.mutation<DeleteCouponResponse, string>({
      query: (id) => ({
        url: `/admin/coupons/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["Coupons", "CouponStats", "CouponUsage"],
    }),

    getCouponById: builder.query<GetCouponByIdResponse, string>({
      query: (id) => `/admin/coupons/${id}`,
      providesTags: (_res, _err, id) => [{ type: "Coupons", id }],
    }),

    updateCouponStatus: builder.mutation<
      UpdateCouponStatusResponse,
      {
        id: string;
        body: UpdateCouponStatusPayload;
        listArgs?: GetCouponsParams | void;
      }
    >({
      query: ({ id, body }) => ({
        url: `/admin/coupons/${id}/status`,
        method: "PATCH",
        body,
      }),
      invalidatesTags: (_res, _err, arg) => [
        { type: "Coupons", id: arg.id },
        "Coupons",
        "CouponStats",
      ],
      async onQueryStarted({ id, body, listArgs }, { dispatch, queryFulfilled }) {
        if (listArgs == null) return;
        const patchResult = dispatch(
          couponApi.util.updateQueryData("getCoupons", listArgs, (draft) => {
            const coupon = (draft.data ?? []).find((c) => c._id === id);
            if (coupon) coupon.isActive = body.isActive;
          })
        );
        try {
          await queryFulfilled;
        } catch {
          patchResult.undo();
        }
      },
    }),

    updateCoupon: builder.mutation<
      UpdateCouponResponse,
      { id: string; body: CreateCouponPayload }
    >({
      query: ({ id, body }) => ({
        url: `/admin/coupons/${id}`,
        method: "PUT",
        body,
      }),
      invalidatesTags: ["Coupons"],
    }),

    getCouponUsageLogs: builder.query<
      GetCouponUsageLogsResponse,
      GetCouponUsageLogsParams | void
    >({
      query: (params) => ({
        url: "/admin/coupons/usage-logs",
        params: { page: 1, limit: 10, ...(params ?? {}) },
      }),
      providesTags: ["CouponUsage"],

      // Put all pages into one cache key (so merge works)
      serializeQueryArgs: ({ endpointName, queryArgs }) => {
        const limit = queryArgs?.limit ?? 10;
        return `${endpointName}?limit=${limit}`;
      },

      // Append when page > 1, replace when page === 1
      merge: (currentCache, incoming, { arg }) => {
        const page = arg?.page ?? 1;

        if (page <= 1) {
          currentCache.data = incoming.data;
          currentCache.pagination = incoming.pagination;
          currentCache.success = incoming.success;
          currentCache.message = incoming.message;
          return;
        }

        const existingIds = new Set(
          (currentCache.data ?? []).map((x) => x._id)
        );
        const toAdd = (incoming.data ?? []).filter(
          (x) => !existingIds.has(x._id)
        );

        currentCache.data = [...(currentCache.data ?? []), ...toAdd];
        currentCache.pagination = incoming.pagination;
        currentCache.success = incoming.success;
        currentCache.message = incoming.message;
      },

      // Refetch when page changes
      forceRefetch: ({ currentArg, previousArg }) =>
        (currentArg?.page ?? 1) !== (previousArg?.page ?? 1) ||
        (currentArg?.limit ?? 10) !== (previousArg?.limit ?? 10),
    }),
  }),
});

export const {
  useGetCouponStatsQuery,
  useGetCouponsQuery,
  useLazyGetCouponsQuery,
  useGetCouponUsageLogsQuery,
  useLazyGetCouponUsageLogsQuery,
  useCreateCouponMutation,
  useDeleteCouponMutation,
  useGetCouponByIdQuery,
  useUpdateCouponStatusMutation,
  useUpdateCouponMutation,
} = couponApi;
