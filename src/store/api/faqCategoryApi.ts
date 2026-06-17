import baseApi from "./baseApi";
import {
  CreateFaqCategoryResponse,
  DeleteFaqCategoryResponse,
  GetFaqCategoriesParams,
  GetFaqCategoriesResponse,
  UpdateFaqCategoryResponse,
} from "./types/faqCategory.types";

export const faqCategoryApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getFaqCategories: builder.query<
      GetFaqCategoriesResponse,
      GetFaqCategoriesParams | void
    >({
      query: (params) => ({
        url: "/admin/faq-categories",
        params: { ...(params ?? {}) },
      }),
      providesTags: ["FaqCategories"],
    }),

    createFaqCategory: builder.mutation<CreateFaqCategoryResponse, FormData>({
      query: (body) => ({
        url: "/admin/faq-categories",
        method: "POST",
        body,
      }),
      async onQueryStarted(_body, { dispatch, queryFulfilled }) {
        try {
          await queryFulfilled;
          dispatch(faqCategoryApi.util.invalidateTags(["FaqCategories"]));
        } catch {}
      },
    }),

    deleteFaqCategory: builder.mutation<DeleteFaqCategoryResponse, string>({
      query: (id) => ({
        url: `/admin/faq-categories/${id}`,
        method: "DELETE",
      }),
      async onQueryStarted(id, { dispatch, queryFulfilled }) {
        try {
          await queryFulfilled;
          dispatch(
            faqCategoryApi.util.updateQueryData(
              "getFaqCategories",
              undefined,
              (draft) => {
                draft.data = draft.data.filter((c) => c._id !== id);
                if (draft.pagination?.total != null)
                  draft.pagination.total -= 1;
              }
            )
          );
        } catch {
          // Do not invalidate or refetch on error; cache unchanged
        }
      },
    }),

    updateFaqCategory: builder.mutation<
      UpdateFaqCategoryResponse,
      { id: string; body: FormData }
    >({
      query: ({ id, body }) => ({
        url: `/admin/faq-categories/${id}`,
        method: "PUT",
        body,
      }),
      async onQueryStarted(_arg, { dispatch, queryFulfilled }) {
        try {
          await queryFulfilled;
          dispatch(faqCategoryApi.util.invalidateTags(["FaqCategories"]));
        } catch {}
      },
    }),
  }),
});

export const {
  useGetFaqCategoriesQuery,
  useLazyGetFaqCategoriesQuery,
  useCreateFaqCategoryMutation,
  useDeleteFaqCategoryMutation,
  useUpdateFaqCategoryMutation,
} = faqCategoryApi;
