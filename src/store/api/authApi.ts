import { baseApi } from "./baseApi";
import { LoginRequest, LoginResponse, ForgotPasswordRequest, ForgotPasswordResponse, ResetPasswordRequest, ResetPasswordResponse } from "./types/auth.types";
import { saveAuthToken, saveRefreshToken, saveUser } from "@/lib/token";

export const authApi = baseApi.injectEndpoints({
    endpoints: (builder) => ({
        login: builder.mutation<LoginResponse, LoginRequest>({
            query: (credentials) => ({
                url: "auth/login",
                method: "POST",
                body: credentials,
            }),
            async onQueryStarted(arg, { queryFulfilled }) {
                try {
                    const { data } = await queryFulfilled;

                    // Save tokens to local storage/cookies
                    if (data.data.accessToken) {
                        saveAuthToken(data.data.accessToken);
                    }
                    if (data.data.refreshToken) {
                        saveRefreshToken(data.data.refreshToken);
                    }
                    if (data.data.user) {
                        saveUser({
                            name: data.data.user.name ?? data.data.user.email ?? "Admin User",
                            email: data.data.user.email ?? "",
                        });
                    }
                } catch (error) {
                    console.error("Login failed:", error);
                }
            },
            invalidatesTags: ["Auth"],
        }),
        forgotPassword: builder.mutation<ForgotPasswordResponse, ForgotPasswordRequest>({
            query: (payload) => ({
                url: "auth/forgot-password",
                method: "POST",
                body: payload,
            }),
            invalidatesTags: ["Auth"],
        }),
        resetPassword: builder.mutation<ResetPasswordResponse, ResetPasswordRequest>({
            query: (payload) => ({
                url: "auth/reset-password",
                method: "POST",
                body: payload,
            }),
            invalidatesTags: ["Auth"],
        }),
    }),
});

export const { useLoginMutation, useForgotPasswordMutation, useResetPasswordMutation } = authApi;
