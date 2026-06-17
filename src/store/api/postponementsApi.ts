import baseApi from "./baseApi";
import type {
  GetPostponementsParams,
  GetPostponementsResponse,
  ApprovePostponementBody,
  RejectPostponementBody,
  PostponementMutationResponse,
} from "./types/postponement.types";

export const postponementsApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getPostponements: builder.query<
      GetPostponementsResponse,
      GetPostponementsParams | void
    >({
      query: (params) => ({
        url: "/admin/postponements",
        params: params ?? { page: 1, limit: 10 },
      }),
      providesTags: ["Postponements"],
    }),
    approvePostponement: builder.mutation<
      PostponementMutationResponse,
      { id: string; body: ApprovePostponementBody }
    >({
      query: ({ id, body }) => ({
        url: `/admin/postponements/${id}/approve`,
        method: "POST",
        body: Object.keys(body).length > 0 ? body : {},
      }),
      invalidatesTags: ["Postponements"],
    }),
    rejectPostponement: builder.mutation<
      PostponementMutationResponse,
      { id: string; body: RejectPostponementBody }
    >({
      query: ({ id, body }) => ({
        url: `/admin/postponements/${id}/reject`,
        method: "POST",
        body,
      }),
      invalidatesTags: ["Postponements"],
    }),
    updateApprovedDate: builder.mutation<
      PostponementMutationResponse,
      { id: string; approvedDeliveryDate: string }
    >({
      query: ({ id, approvedDeliveryDate }) => ({
        url: `/admin/postponements/${id}/approved-date`,
        method: "PATCH",
        body: { approvedDeliveryDate },
      }),
      invalidatesTags: ["Postponements"],
    }),
  }),
});

export const {
  useGetPostponementsQuery,
  useApprovePostponementMutation,
  useRejectPostponementMutation,
  useUpdateApprovedDateMutation,
} = postponementsApi;
