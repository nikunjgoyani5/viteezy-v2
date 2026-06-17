import {
  getAuthToken,
  getRefreshToken,
  handleLogout,
  saveAuthToken,
} from "@/lib/token";
import {
  BaseQueryFn,
  FetchArgs,
  FetchBaseQueryError,
  createApi,
  fetchBaseQuery,
} from "@reduxjs/toolkit/query/react";

const createBaseQuery = (useJsonContentType = true) =>
  fetchBaseQuery({
    baseUrl: process.env.NEXT_PUBLIC_API_BASE_URL,

    prepareHeaders: (headers) => {
      const token = getAuthToken();

      if (token) {
        headers.set("authorization", `Bearer ${token}`);
      }

      if (useJsonContentType) {
        headers.set("content-type", "application/json");
      }

      return headers;
    },
  });

const baseQuery = createBaseQuery(true);
const formDataBaseQuery = createBaseQuery(false);

const isFormDataRequest = (args: string | FetchArgs) =>
  typeof args === "object" &&
  args !== null &&
  "body" in args &&
  args.body instanceof FormData;

export const baseQueryWithAuth: BaseQueryFn<
  string | FetchArgs,
  unknown,
  FetchBaseQueryError
> = async (args, api, extraOptions) => {
  const queryFn = isFormDataRequest(args) ? formDataBaseQuery : baseQuery;
  let result = await queryFn(args, api, extraOptions);

  if (result.error?.status === 401) {
    const refreshToken = getRefreshToken();

    if (!refreshToken) {
      handleLogout();
      return result;
    }

    const refreshResult = await baseQuery(
      {
        url: "/auth/refresh",
        method: "POST",
        body: { refreshToken },
      },
      api,
      extraOptions
    );

    if (refreshResult.data) {
      const { accessToken } = refreshResult.data as { accessToken: string };
      saveAuthToken(accessToken);

      result = await queryFn(args, api, extraOptions);
    } else {
      handleLogout();
    }
  }

  return result;
};

export const baseApi = createApi({
  reducerPath: "api",
  baseQuery: baseQueryWithAuth,
  tagTypes: [
    "Auth",
    "Dashboard",
    "Users",
    "TeamMembers",
    "OurTeamPage",
    "FaqCategories",
    "Faqs",
    "BlogCategories",
    "Blogs",
    "BlogBanners",
    "StaticPages",
    "ProductIngredients",
    "MembershipPlans",
    "MembershipPage",
    "BenefitCards",
    "ProductIngredient",
    "ProductCategories",
    "Products",
    "Product",
    "ProductFilters",
    "TopSellingProducts",
    "Coupons",
    "CouponStats",
    "CouponUsage",
    "Orders",
    "Subscriptions",
    "GeneralSettings",
    "Testimonials",
    "AboutUs",
    "LandingPages",
    "Postponements",
    "HeaderBanners",
  ],
  endpoints: () => ({}),
});

export default baseApi;
