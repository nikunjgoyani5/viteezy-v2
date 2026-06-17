import { baseApi } from "./baseApi";
import { GetTeamMembersParams, TeamMembersResponse, OurTeamPageResponse, UpdateOurTeamPageRequest } from "./types/team.types";

export const teamApi = baseApi.injectEndpoints({
    endpoints: (builder) => ({
        getTeamMembers: builder.query<TeamMembersResponse, GetTeamMembersParams>({
            query: (params) => ({
                url: "/admin/team-members",
                method: "GET",
                params,
            }),
            providesTags: ["TeamMembers"],
        }),
        createTeamMember: builder.mutation<any, FormData>({
            query: (formData) => ({
                url: "/admin/team-members",
                method: "POST",
                body: formData,
                formData: true,
            }),
            invalidatesTags: ["TeamMembers"],
        }),
        updateTeamMember: builder.mutation<any, { id: string; formData: FormData }>({
            query: ({ id, formData }) => ({
                url: `/admin/team-members/${id}`,
                method: "PUT",
                body: formData,
                formData: true,
            }),
            invalidatesTags: ["TeamMembers"],
        }),
        deleteTeamMember: builder.mutation<any, string>({
            query: (id) => ({
                url: `/admin/team-members/${id}`,
                method: "DELETE",
            }),
            invalidatesTags: ["TeamMembers"],
        }),
        getOurTeamPage: builder.query<OurTeamPageResponse, void>({
            query: () => ({
                url: "/admin/our-team-page",
                method: "GET",
            }),
            providesTags: ["OurTeamPage"],
        }),
        updateOurTeamPage: builder.mutation<any, UpdateOurTeamPageRequest>({
            query: (data) => {
                const formData = new FormData();
                formData.append("banner[title]", data.banner.title);
                formData.append("banner[subtitle]", data.banner.subtitle);
                return {
                    url: "/admin/our-team-page",
                    method: "PUT",
                    body: formData,
                    formData: true,
                };
            },
            invalidatesTags: ["OurTeamPage"],
        }),
    }),
});

export const { useGetTeamMembersQuery, useCreateTeamMemberMutation, useUpdateTeamMemberMutation, useDeleteTeamMemberMutation, useGetOurTeamPageQuery, useUpdateOurTeamPageMutation } = teamApi;
