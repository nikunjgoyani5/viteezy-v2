import { baseApi } from "./baseApi";

export interface SocialMedia {
    facebook?: string;
    instagram?: string;
    youtube?: string;
    linkedin?: string;
    tiktok?: string;
}

export interface Address {
    street?: string;
    city?: string;
    state?: string;
    zip?: string;
    country?: string;
    addressLine1?: string | null;
    addressLine2?: string | null;
}

export interface Language {
    code: string;
    name: string;
    isEnabled: boolean;
}

export interface GeneralSettings {
    _id: string;
    socialMedia?: SocialMedia;
    address?: Address;
    supportPhone: string;
    supportEmail: string;
    tagline?: string;
    logoLight?: string | null;
    logoDark?: string | null;
    languages?: Language[];
    isDeleted: boolean;
    deletedAt: string | null;
    createdBy: string;
    updatedBy: string;
    createdAt: string;
    updatedAt: string;
}

export interface GetGeneralSettingsResponse {
    success: boolean;
    message: string;
    data: {
        settings: GeneralSettings;
    };
}

export interface UpdateGeneralSettingsRequest {
    socialMedia?: SocialMedia;
    address?: string;
    supportPhone?: string;
    supportEmail?: string;
    tagline?: string;
    logoLight?: File | string;
    logoDark?: File | string;
}

export interface UpdateGeneralSettingsResponse {
    success: boolean;
    data: GeneralSettings;
    message?: string;
}

export const settingsApi = baseApi.injectEndpoints({
    endpoints: (builder) => ({
        getGeneralSettings: builder.query<GetGeneralSettingsResponse, void>({
            query: () => ({
                url: "admin/general-settings",
                method: "GET",
            }),
            providesTags: ["GeneralSettings"],
        }),
        updateGeneralSettings: builder.mutation<
            UpdateGeneralSettingsResponse,
            UpdateGeneralSettingsRequest
        >({
            query: (data) => {
                // Check if we have files to upload
                const hasFiles = data.logoLight instanceof File || data.logoDark instanceof File;

                if (hasFiles) {
                    // Use FormData for file upload
                    const formData = new FormData();

                    if (data.socialMedia) {
                        formData.append("socialMedia", JSON.stringify(data.socialMedia));
                    }
                    if (data.address) formData.append("address", data.address);
                    if (data.supportPhone) formData.append("supportPhone", data.supportPhone);
                    if (data.supportEmail) formData.append("supportEmail", data.supportEmail);
                    if (data.tagline) formData.append("tagline", data.tagline);

                    if (data.logoLight instanceof File) {
                        formData.append("logoLight", data.logoLight);
                    }
                    if (data.logoDark instanceof File) {
                        formData.append("logoDark", data.logoDark);
                    }

                    return {
                        url: "admin/general-settings",
                        method: "PUT",
                        body: formData,
                        formData: true,
                    };
                }

                // Use JSON for non-file updates
                return {
                    url: "admin/general-settings",
                    method: "PUT",
                    body: data,
                };
            },
            invalidatesTags: ["GeneralSettings"],
        }),
    }),
});

export const {
    useGetGeneralSettingsQuery,
    useUpdateGeneralSettingsMutation,
} = settingsApi;
