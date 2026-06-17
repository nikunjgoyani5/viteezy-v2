// src/store/api/blogCategoryApi.ts
import baseApi from "./baseApi";
import type {
  BlogCategory,
  GetBlogCategoriesParams,
  GetBlogCategoriesResponse,
  CreateBlogCategoryPayload,
  CreateBlogCategoryResponse,
} from "./types/blogCategory.types";

export type UpdateBlogCategoryResponse = {
  success: boolean;
  message: string;
  data: BlogCategory;
};

export type DeleteBlogCategoryResponse = {
  success: boolean;
  message: string;
};

export const blogCategoryApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getBlogCategories: builder.query<
      GetBlogCategoriesResponse,
      GetBlogCategoriesParams | void | Record<string, never>
    >({
      query: (params) => ({
        url: "/admin/blog-categories",
        params: params && Object.keys(params).length > 0 ? { page: 1, limit: 10, ...params } : {},
      }),
      providesTags: ["BlogCategories"],
    }),

    createBlogCategory: builder.mutation<
      CreateBlogCategoryResponse,
      CreateBlogCategoryPayload
    >({
      query: (body) => ({
        url: "/admin/blog-categories",
        method: "POST",
        body,
      }),
      invalidatesTags: ["BlogCategories"],
    }),

    updateBlogCategory: builder.mutation<
      UpdateBlogCategoryResponse,
      { id: string; body: { title: string; isActive: boolean } }
    >({
      query: ({ id, body }) => ({
        url: `/admin/blog-categories/${id}`,
        method: "PUT",
        body,
      }),
      invalidatesTags: ["BlogCategories"],
      async onQueryStarted(
        { id, body },
        { dispatch, queryFulfilled }
      ) {
        const patchResult = dispatch(
          blogCategoryApi.util.updateQueryData(
            "getBlogCategories",
            undefined,
            (draft) => {
              const item = (draft.data ?? []).find((c) => c._id === id);
              if (item) {
                item.title = body.title;
                item.isActive = body.isActive;
              }
            }
          )
        );
        try {
          await queryFulfilled;
        } catch {
          patchResult.undo();
        }
      },
    }),

    deleteBlogCategory: builder.mutation<DeleteBlogCategoryResponse, string>({
      query: (id) => ({
        url: `/admin/blog-categories/${id}`,
        method: "DELETE",
      }),
      async onQueryStarted(id, { dispatch, queryFulfilled }) {
        const patch = dispatch(
          blogCategoryApi.util.updateQueryData(
            "getBlogCategories",
            undefined,
            (draft) => {
              draft.data = draft.data.filter((c) => c._id !== id);
              if (draft.pagination?.total != null) draft.pagination.total -= 1;
            }
          )
        );

        try {
          await queryFulfilled;
        } catch {
          patch.undo();
        }
      },
    }),
  }),
});

export const {
  useGetBlogCategoriesQuery,
  useCreateBlogCategoryMutation,
  useUpdateBlogCategoryMutation,
  useDeleteBlogCategoryMutation,
} = blogCategoryApi;
