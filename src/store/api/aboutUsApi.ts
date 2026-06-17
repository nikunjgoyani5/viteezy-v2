import { baseApi } from "./baseApi";
import { AboutUsResponse } from "./types/aboutUs.types";

export const aboutUsApi = baseApi.injectEndpoints({
    endpoints: (builder) => ({
        getAboutUs: builder.query<AboutUsResponse, void>({
            query: () => ({
                url: "/admin/about-us",
                method: "GET",
            }),
            providesTags: ["AboutUs"],
        }),
        updateAboutUs: builder.mutation<AboutUsResponse, FormData>({
            query: (formData) => ({
                url: "/admin/about-us",
                method: "POST",
                body: formData,
            }),
            invalidatesTags: ["AboutUs"],
        }),
    }),
});

export const { useGetAboutUsQuery, useUpdateAboutUsMutation } = aboutUsApi;
