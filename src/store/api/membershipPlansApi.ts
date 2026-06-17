import baseApi from "./baseApi";
import type {
    GetMembershipPlansParams,
    GetMembershipPlansResponse,
    GetSingleMembershipPlanResponse,
    MembershipPlanResponse,
    UpdateMembershipPlanPayload,
    MembershipPageResponse,
    UpdateMembershipPageRequest,
    BenefitCardResponse,
    GetBenefitCardsResponse,
} from "./types/membershipPlan.types";

export const membershipPlansApi = baseApi.injectEndpoints({
    endpoints: (builder) => ({
        getMembershipPlans: builder.query<
            GetMembershipPlansResponse,
            GetMembershipPlansParams | void
        >({
            query: (params) => ({
                url: "/admin/membership-plans",
                params: { page: 1, limit: 10, ...(params ?? {}) },
            }),
            providesTags: ["MembershipPlans"],
        }),

        getMembershipPlan: builder.query<GetSingleMembershipPlanResponse, string>({
            query: (id) => ({
                url: `/admin/membership-plans/${id}`,
            }),
            providesTags: ["MembershipPlans"],
        }),

        createMembershipPlan: builder.mutation<
            { success: boolean; message: string; data: MembershipPlanResponse },
            UpdateMembershipPlanPayload
        >({
            query: (data) => ({
                url: "/admin/membership-plans",
                method: "POST",
                body: data,
            }),
            invalidatesTags: ["MembershipPlans"],
        }),

        updateMembershipPlan: builder.mutation<
            { success: boolean; message: string; data: MembershipPlanResponse },
            { id: string; data: UpdateMembershipPlanPayload }
        >({
            query: ({ id, data }) => ({
                url: `/admin/membership-plans/${id}`,
                method: "PUT",
                body: data,
            }),
            invalidatesTags: ["MembershipPlans"],
        }),

        updateMembershipPlanStatus: builder.mutation<
            { success: boolean; message: string; data: MembershipPlanResponse },
            { id: string; isActive: boolean }
        >({
            query: ({ id, isActive }) => ({
                url: `/admin/membership-plans/${id}/status`,
                method: "PATCH",
                body: { isActive },
            }),
            invalidatesTags: ["MembershipPlans"],
        }),

        deleteMembershipPlan: builder.mutation<
            { success: boolean; message: string },
            string
        >({
            query: (id) => ({
                url: `/admin/membership-plans/${id}`,
                method: "DELETE",
            }),
            invalidatesTags: ["MembershipPlans"],
        }),

        // Membership Page endpoints
        getMembershipPage: builder.query<MembershipPageResponse, void>({
            query: () => ({
                url: "/admin/membership-page",
                method: "GET",
            }),
            providesTags: ["MembershipPage"],
        }),

        updateMembershipPage: builder.mutation<any, UpdateMembershipPageRequest>({
            query: (data) => ({
                url: "/admin/membership-page",
                method: "PUT",
                body: data,
            }),
            invalidatesTags: ["MembershipPage"],
        }),

        updateMembershipCMS: builder.mutation<any, FormData>({
            query: (data) => ({
                url: "/admin/membership-cms",
                method: "POST",
                body: data,
            }),
            invalidatesTags: ["MembershipPage"],
        }),

        // Benefit Cards endpoints
        getBenefitCards: builder.query<GetBenefitCardsResponse, void>({
            query: () => ({
                url: "/admin/membership-benefits",
                method: "GET",
            }),
            providesTags: ["BenefitCards"],
        }),

        createBenefitCard: builder.mutation<any, FormData>({
            query: (formData) => ({
                url: "/admin/membership-benefits",
                method: "POST",
                body: formData,
                formData: true,
            }),
            invalidatesTags: ["BenefitCards"],
        }),

        updateBenefitCard: builder.mutation<any, { id: string; formData: FormData }>({
            query: ({ id, formData }) => ({
                url: `/admin/membership-benefits/${id}`,
                method: "PUT",
                body: formData,
                formData: true,
            }),
            invalidatesTags: ["BenefitCards"],
        }),

        deleteBenefitCard: builder.mutation<any, string>({
            query: (id) => ({
                url: `/admin/membership-benefits/${id}`,
                method: "DELETE",
            }),
            invalidatesTags: ["BenefitCards"],
        }),
    }),
});

export const {
    useGetMembershipPlansQuery,
    useGetMembershipPlanQuery,
    useCreateMembershipPlanMutation,
    useUpdateMembershipPlanMutation,
    useUpdateMembershipPlanStatusMutation,
    useDeleteMembershipPlanMutation,
    useGetMembershipPageQuery,
    useUpdateMembershipPageMutation,
    useUpdateMembershipCMSMutation,
    useGetBenefitCardsQuery,
    useCreateBenefitCardMutation,
    useUpdateBenefitCardMutation,
    useDeleteBenefitCardMutation,
} = membershipPlansApi;
