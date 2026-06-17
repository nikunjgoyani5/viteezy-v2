import baseApi from "./baseApi";
import type { GetMembershipCmsResponse } from "./types/membershipCms.types";

export const membershipCmsApi = baseApi.injectEndpoints({
    endpoints: (builder) => ({
        getMembershipCms: builder.query<GetMembershipCmsResponse, void>({
            query: () => ({
                url: "/admin/membership-cms",
            }),
            providesTags: ["MembershipPage"],
        }),
    }),
});

export const { useGetMembershipCmsQuery } = membershipCmsApi;
