import baseApi from "./baseApi";
import type {
  CreateBlogResponse,
  DeleteBlogResponse,
  GetBlogByIdResponse,
  GetBlogsParams,
  GetBlogsResponse,
  UpdateBlogResponse,
  UpdateBlogStatusArgs,
  UpdateBlogStatusResponse,
  GetBlogBannersResponse,
  CreateBlogBannerResponse,
  UpdateBlogBannerResponse,
} from "./types/blog.types";

export const blogApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getBlogs: builder.query<GetBlogsResponse, GetBlogsParams | void>({
      query: (params) => ({
        url: "/admin/blogs",
        params: { limit: 10, ...(params ?? {}) },
      }),
      providesTags: ["Blogs"],
    }),

    getBlogById: builder.query<GetBlogByIdResponse, string>({
      query: (id) => `/admin/blogs/${id}`,
      providesTags: (_res, _err, id) => [{ type: "Blogs", id }],
    }),

    createBlog: builder.mutation<CreateBlogResponse, FormData>({
      query: (body) => ({
        url: "/admin/blogs",
        method: "POST",
        body,
      }),
      invalidatesTags: ["Blogs"],
    }),

    updateBlog: builder.mutation<
      UpdateBlogResponse,
      { id: string; body: FormData }
    >({
      query: ({ id, body }) => ({
        url: `/admin/blogs/${id}`,
        method: "PUT",
        body,
      }),
      invalidatesTags: (_res, _err, arg) => [
        "Blogs",
        { type: "Blogs", id: arg.id },
      ],
    }),

    deleteBlog: builder.mutation<DeleteBlogResponse, string>({
      query: (id) => ({
        url: `/admin/blogs/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["Blogs"],
    }),

    updateBlogStatus: builder.mutation<
      UpdateBlogStatusResponse,
      UpdateBlogStatusArgs
    >({
      query: ({ id, isActive }) => ({
        url: `/admin/blogs/${id}/status`,
        method: "PATCH",
        body: { isActive },
      }),

      invalidatesTags: ["Blogs"],
      
      async onQueryStarted(
        { id, isActive, listArgs },
        { dispatch, queryFulfilled }
      ) {
        const patchList =
          listArgs != null
            ? dispatch(
                blogApi.util.updateQueryData("getBlogs", listArgs, (draft) => {
                  const item = draft?.data?.blogs?.find((b) => b._id === id);
                  if (item) item.isActive = isActive;
                })
              )
            : null;
        const patchDetail = dispatch(
          blogApi.util.updateQueryData("getBlogById", id, (draft) => {
            if (draft?.data?.blog) draft.data.blog.isActive = isActive;
          })
        );
        try {
          await queryFulfilled;
        } catch {
          patchList?.undo();
          patchDetail.undo();
        }
      },
    }),

    // Blog Banners endpoints
    getBlogBanner: builder.query<GetBlogBannersResponse, void>({
      query: () => "/admin/blog-banners",
      providesTags: ["BlogBanners"],
    }),

    createBlogBanner: builder.mutation<CreateBlogBannerResponse, FormData>({
      query: (body) => ({
        url: "/admin/blog-banners",
        method: "POST",
        body,
      }),
      invalidatesTags: ["BlogBanners"],
    }),

    updateBlogBanner: builder.mutation<
      UpdateBlogBannerResponse,
      { id: string; body: FormData }
    >({
      query: ({ id, body }) => ({
        url: `/admin/blog-banners/${id}`,
        method: "PUT",
        body,
      }),
      invalidatesTags: ["BlogBanners"],
    }),
  }),
});

export const {
  useGetBlogsQuery,
  useGetBlogByIdQuery,
  useLazyGetBlogsQuery,
  useCreateBlogMutation,
  useUpdateBlogMutation,
  useDeleteBlogMutation,
  useUpdateBlogStatusMutation,
  useGetBlogBannerQuery,
  useCreateBlogBannerMutation,
  useUpdateBlogBannerMutation,
} = blogApi;
