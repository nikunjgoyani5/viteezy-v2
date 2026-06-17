import baseApi from "./baseApi";
import type { GetLandingPagesResponse } from "./types/landingPage.types";

export type SaveLandingPageResponse = {
  success: boolean;
  message: string;
  data?: unknown;
};

export const landingPageApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getLandingPages: builder.query<GetLandingPagesResponse, void>({
      query: () => ({
        url: "/admin/landing-pages",
        method: "GET",
      }),
      providesTags: ["LandingPages"],
    }),
    updateLandingPage: builder.mutation<
      SaveLandingPageResponse,
      { id: string; body: FormData }
    >({
      query: ({ id, body }) => ({
        url: `/admin/landing-pages/${id}`,
        method: "PUT",
        body,
      }),
      invalidatesTags: ["LandingPages", "StaticPages"],
    }),
  }),
});

export const { useGetLandingPagesQuery, useUpdateLandingPageMutation } = landingPageApi;
