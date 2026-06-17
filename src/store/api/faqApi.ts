import baseApi from "./baseApi";
import {
  CreateFaqPayload,
  CreateFaqResponse,
  DeleteFaqResponse,
  GetFaqsByCategoryParams,
  GetFaqsByCategoryResponse,
  GetFaqResponse,
  UpdateFaqPayload,
  UpdateFaqResponse,
} from "./types/faq.types";

export const faqsApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    createFaq: builder.mutation<CreateFaqResponse, CreateFaqPayload>({
      query: (body) => ({
        url: "/admin/faqs",
        method: "POST",
        body,
      }),
      invalidatesTags: ["Faqs"],
    }),

    getFaqsByCategory: builder.query<
      GetFaqsByCategoryResponse,
      GetFaqsByCategoryParams
    >({
      query: ({ categoryId, page = 1, limit = 10 }) => ({
        url: "/admin/faqs/",
        params: { categoryId, page, limit },
      }),
      providesTags: ["Faqs"],
    }),

    getFaqById: builder.query<GetFaqResponse, string>({
      query: (id) => ({ url: `/admin/faqs/${id}` }),
      providesTags: ["Faqs"],
    }),

    updateFaq: builder.mutation<
      UpdateFaqResponse,
      { id: string; body: UpdateFaqPayload }
    >({
      query: ({ id, body }) => ({
        url: `/admin/faqs/${id}`,
        method: "PUT",
        body,
      }),
      invalidatesTags: ["Faqs"],
    }),

    deleteFaq: builder.mutation<DeleteFaqResponse, string>({
      query: (id) => ({
        url: `/admin/faqs/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["Faqs"],
    }),
  }),
});

export const {
  useCreateFaqMutation,
  useGetFaqsByCategoryQuery,
  useLazyGetFaqsByCategoryQuery,
  useGetFaqByIdQuery,
  useUpdateFaqMutation,
  useDeleteFaqMutation,
} = faqsApi;
