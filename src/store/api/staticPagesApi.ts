import baseApi from "./baseApi";
import type {
    GetStaticPagesParams,
    GetStaticPagesResponse,
    GetStaticPageResponse,
    CreateStaticPagePayload,
    CreateStaticPageResponse,
    UpdateStaticPagePayload,
    UpdateStaticPageResponse,
    UpdateStaticPageStatusPayload,
    UpdateStaticPageStatusResponse,
    DeleteStaticPageResponse,
} from "./types/staticPage.types";

export const staticPagesApi = baseApi.injectEndpoints({
    endpoints: (builder) => ({
        getStaticPages: builder.query<GetStaticPagesResponse, GetStaticPagesParams | void>({
            query: (params) => ({
                url: "/admin/static-pages",
                params: { page: 1, limit: 10, ...(params ?? {}) },
            }),
            providesTags: ["StaticPages"],
        }),
        getStaticPageById: builder.query<GetStaticPageResponse, string>({
            query: (id) => ({
                url: `/admin/static-pages/${id}`,
                method: "GET",
            }),
            providesTags: (result, error, id) => [{ type: "StaticPages", id }],
        }),
        createStaticPage: builder.mutation<CreateStaticPageResponse, CreateStaticPagePayload>({
            query: (body) => ({
                url: "/admin/static-pages",
                method: "POST",
                body,
            }),
            invalidatesTags: ["StaticPages"],
        }),
        updateStaticPage: builder.mutation<
            UpdateStaticPageResponse,
            { id: string; body: UpdateStaticPagePayload }
        >({
            query: ({ id, body }) => ({
                url: `/admin/static-pages/${id}`,
                method: "PUT",
                body,
            }),
            invalidatesTags: (result, error, { id }) => [{ type: "StaticPages", id }, "StaticPages"],
        }),
        updateStaticPageStatus: builder.mutation<
            UpdateStaticPageStatusResponse,
            { id: string; body: UpdateStaticPageStatusPayload }
        >({
            query: ({ id, body }) => ({
                url: `/admin/static-pages/${id}/status`,
                method: "PATCH",
                body,
            }),
            invalidatesTags: ["StaticPages"],
        }),
        deleteStaticPage: builder.mutation<DeleteStaticPageResponse, string>({
            query: (id) => ({
                url: `/admin/static-pages/${id}`,
                method: "DELETE",
            }),
            invalidatesTags: ["StaticPages"],
        }),
    }),
});

export const {
    useGetStaticPagesQuery,
    useGetStaticPageByIdQuery,
    useCreateStaticPageMutation,
    useUpdateStaticPageMutation,
    useUpdateStaticPageStatusMutation,
    useDeleteStaticPageMutation,
} = staticPagesApi;
