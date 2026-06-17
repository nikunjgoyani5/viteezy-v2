import { baseApi } from "./baseApi";
import type {
    MemberRegisterRequest,
    MemberRegisterResponse,
} from "./types/members.types";

/**
 * Helper: Store auth data in localStorage after successful member registration
 */
const storeAuthData = (data: MemberRegisterResponse["data"]) => {
    if (typeof window === "undefined") return;

    if (data.accessToken) {
        localStorage.setItem("accessToken", data.accessToken);
    }
    if (data.refreshToken) {
        localStorage.setItem("refreshToken", data.refreshToken);
    }
    if (data.user) {
        localStorage.setItem("user", JSON.stringify(data.user));
    }
};

/**
 * Members API Endpoints
 * Family member registration and management
 */
export const membersApi = baseApi.injectEndpoints({
    endpoints: (builder) => ({
        /**
         * MEMBER REGISTER
          * Register a new family member using parentMemberId
         */
        memberRegister: builder.mutation<
            MemberRegisterResponse,
            MemberRegisterRequest
        >({
            query: (userData) => ({
                url: "/members/register",
                method: "POST",
                body: userData,
            }),

            // After successful registration, save token and user data
            async onQueryStarted(arg, { queryFulfilled }) {
                try {
                    const { data } = await queryFulfilled;
                    if (data.success) {
                        storeAuthData(data.data);
                    }
                } catch (error) {
                    console.error("Member registration failed:", error);
                }
            },

            invalidatesTags: ["Auth", "User", "Members"],
        }),
    }),
});

export const { useMemberRegisterMutation } = membersApi;
