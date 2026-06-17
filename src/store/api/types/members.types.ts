/**
 * Members API Types
 * Type definitions for family member registration
 */

import { User } from "./auth.types";

// ==================== MEMBER REGISTER ====================
export interface MemberRegisterRequest {
    parentMemberId: string;
    firstName: string;
    lastName: string;
    password: string;
    email?: string;
}

export interface MemberRegisterResponse {
    success: boolean;
    message: string;
    data: {
        user: User;
        accessToken: string;
        refreshToken?: string;
    };
}
