import baseApi from "./baseApi";
import type {
  GetHeaderBannersParams,
  GetHeaderBannersResponse,
  HeaderBanner,
} from "./types/headerBanner.types";

export const headerBannerApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getHeaderBanners: builder.query<
      GetHeaderBannersResponse,
      GetHeaderBannersParams | void
    >({
      query: (params) => ({
        url: "/admin/header-banners",
        params: { page: 1, limit: 10, ...(params ?? {}) },
      }),
      providesTags: ["HeaderBanners"],
    }),

    updateHeaderBannerStatus: builder.mutation<
      HeaderBanner,
      { id: string; isActive: boolean; listArgs?: GetHeaderBannersParams }
    >({
      query: ({ id }) => ({
        url: `/admin/header-banners/${id}/toggle-status`,
        method: "PATCH",
        body: {},
      }),
      invalidatesTags: (_result, _error, { id }) => [
        { type: "HeaderBanners", id },
        "HeaderBanners",
      ],

      async onQueryStarted(
        { id, isActive, listArgs },
        { dispatch, queryFulfilled }
      ) {
        const patchResult =
          listArgs &&
          dispatch(
            headerBannerApi.util.updateQueryData(
              "getHeaderBanners",
              listArgs,
              (draft) => {
                const item = draft.data.find((b) => b._id === id);
                if (item) {
                  item.isActive = isActive;
                }
              }
            )
          );

        try {
          await queryFulfilled;
          dispatch(
            headerBannerApi.endpoints.getHeaderBannerById.initiate(id, {
              forceRefetch: true,
            })
          );
        } catch {
          if (patchResult) patchResult.undo();
        }
      },
    }),

    createHeaderBanner: builder.mutation<
      HeaderBanner,
      Partial<Pick<HeaderBanner, "text" | "deviceType" | "isActive" | "isScheduled" | "startDate" | "endDate">>
    >({
      query: (body) => ({
        url: "/admin/header-banners",
        method: "POST",
        body,
      }),
      invalidatesTags: ["HeaderBanners"],
    }),

    updateHeaderBanner: builder.mutation<
      HeaderBanner,
      { id: string; body: Partial<Pick<HeaderBanner, "text" | "deviceType" | "isActive" | "isScheduled" | "startDate" | "endDate">> }
    >({
      query: ({ id, body }) => ({
        url: `/admin/header-banners/${id}`,
        method: "PUT",
        body,
      }),
      invalidatesTags: ["HeaderBanners"],
    }),

    getHeaderBannerById: builder.query<HeaderBanner | undefined, string>({
      query: (id) => `/admin/header-banners/${id}`,
      transformResponse: (response: {
        data?: { headerBanner?: HeaderBanner };
      }) => response?.data?.headerBanner,
      providesTags: (_res, _err, id) => [{ type: "HeaderBanners", id }],
    }),

    deleteHeaderBanner: builder.mutation<void, string>({
      query: (id) => ({
        url: `/admin/header-banners/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: (_result, _error, id) => [
        { type: "HeaderBanners", id },
        "HeaderBanners",
      ],
    }),
  }),
});

export const {
  useGetHeaderBannersQuery,
  useUpdateHeaderBannerStatusMutation,
  useCreateHeaderBannerMutation,
  useUpdateHeaderBannerMutation,
  useGetHeaderBannerByIdQuery,
  useDeleteHeaderBannerMutation,
} = headerBannerApi;
