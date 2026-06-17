export interface LoginRequest {
    email: string;
    password: string;
    deviceInfo: string;
    /** e.g. `"admin"` — admin panel login */
    type?: string;
}

export interface LoginResponse {
    success: boolean;
    message: string;
    data: {
        user: {
            id: string;
            email: string;
            name?: string;
            role?: string;
        };
        accessToken: string;
        refreshToken: string;
    };
}

export interface AuthError {
    message: string;
    status?: number;
}

export interface ForgotPasswordRequest {
    email: string;
    deviceInfo: string;
    /** e.g. `"admin"` — sent by admin forgot-password flow */
    type?: string;
}

export interface ForgotPasswordResponse {
    success: boolean;
    message: string;
}

export interface ResetPasswordRequest {
    email: string;
    password: string;
    confirmPassword: string;
    token: string;
}

export interface ResetPasswordResponse {
    success: boolean;
    message: string;
}
