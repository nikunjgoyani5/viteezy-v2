import { baseApi } from "./baseApi";
import { GetUsersRequest, GetUsersResponse, GetUserDetailResponse } from "./types/user.types";

export const userApi = baseApi.injectEndpoints({
    endpoints: (builder) => ({
        getUsers: builder.query<GetUsersResponse, GetUsersRequest>({
            query: (params) => {
                const queryParams = new URLSearchParams();

                if (params.page) queryParams.append("page", params.page.toString());
                if (params.limit) queryParams.append("limit", params.limit.toString());
                if (params.userType) queryParams.append("userType", params.userType);
                if (params.isActive !== undefined) queryParams.append("isActive", params.isActive.toString());
                if (params.search) queryParams.append("search", params.search);
                if (params.registrationDate) queryParams.append("registrationDate", params.registrationDate);

                return {
                    url: `admin/users?${queryParams.toString()}`,
                    method: "GET",
                };
            },
            providesTags: ["Users"],
        }),
        updateUserStatus: builder.mutation<{ success: boolean }, { userId: string; isActive: boolean }>({
            query: ({ userId, isActive }) => ({
                url: `admin/users/${userId}/status`,
                method: "PATCH",
                body: { isActive },
            }),
            invalidatesTags: ["Users"],
        }),
        getUserById: builder.query<GetUserDetailResponse, string>({
            query: (userId) => ({
                url: `admin/users/${userId}`,
                method: "GET",
            }),
            providesTags: (result, error, id) => [{ type: "Users", id }],
        }),
    }),
});

export const { useGetUsersQuery, useUpdateUserStatusMutation, useGetUserByIdQuery } = userApi;
