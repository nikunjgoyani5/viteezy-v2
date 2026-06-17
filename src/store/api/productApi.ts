import { baseApi } from "./baseApi";
import type { CategoriesWithProductsResponse, GetProductsResponse } from "./types/product.types";
import { getLanguageQueryForApi, getLanguageCode } from "@/lib/services/language";

export const productApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    /**
     * GET ALL PRODUCTS
     * Fetch list of all products
     * Language handling:
     * - If user logged in: language fetched from user/me
     * - If user not logged in: language passed as query parameter
     */
    getProducts: builder.query<
      GetProductsResponse,
      {
        categories?: string;
        sortBy?: string;
        page?: number;
        limit?: number;
        search?: string;
      } | void
    >({
      query: (params) => {
        const queryParams = new URLSearchParams();

        // Add language parameter for all users
        const lang = getLanguageCode();
        queryParams.append("lang", lang);

        if (params?.categories) {
          queryParams.append("categories", params.categories);
        }
        if (params?.sortBy) {
          queryParams.append("sortBy", params.sortBy);
        }
        if (params?.search) {
          queryParams.append("search", params.search);
        }
        if (typeof params?.page === "number") {
          queryParams.append("page", String(params.page));
        }
        if (typeof params?.limit === "number") {
          queryParams.append("limit", String(params.limit));
        }
        return `/products${queryParams.toString() ? `?${queryParams.toString()}` : ""
          }`;
      },
      providesTags: ["Product"],
    }),

    /**
     * GET ALL PRODUCTS CATEGORIES
     * Fetch list of all products categories
     * Language handling:
     * - If user logged in: language fetched from user/me
     * - If user not logged in: language passed as query parameter
     */
    getCategories: builder.query<GetProductsResponse, void>({
      query: () => {
        const queryParams = new URLSearchParams();

        // Add language parameter for all users
        const lang = getLanguageCode();
        queryParams.append("lang", lang);

        return `/products/categories${queryParams.toString() ? `?${queryParams.toString()}` : ""
          }`;
      },
      providesTags: ["Product"],
    }),

    /**
     * GET SINGLE PRODUCT
     * Fetch one product by ID
     * Language: `lang` query mirrors UI locale (localStorage), including logged-in users.
     */
    getProductById: builder.query<unknown, string>({
      query: (id) => {
        const queryParams = new URLSearchParams();
        queryParams.append("lang", getLanguageQueryForApi());
        return `/products/${id}?${queryParams.toString()}`;
      },
      providesTags: (result, error, id) => [{ type: "Product", id }],
    }),

    /**
     * GET PRODUCT TESTIMONIALS
     * Fetch testimonials for a given product ID
     */
    getProductTestimonials: builder.query<any, string | undefined>({
      query: (productId) => {
        if (!productId) return "/product-testimonials";
        const params = new URLSearchParams({ productId });
        return `/product-testimonials?${params.toString()}`;
      },
      providesTags: ["Product"],
    }),

    /**
     * ADD PRODUCT REVIEW
     * Submit a review for a product
     */
    addReview: builder.mutation<void, { productId: string; rating: number; content: string }>({
      query: ({ productId, rating, content }) => ({
        url: `/reviews/products/${productId}`,
        method: "POST",
        body: { rating, content },
      }),
      invalidatesTags: (result, error, { productId }) => [{ type: "Product", id: productId }],
    }),

    getCategoriesWithProducts: builder.query<
      CategoriesWithProductsResponse,
      { lang?: string } | void
    >({
      query: (params) => {
        const qp = new URLSearchParams();
        if (params?.lang) qp.set("lang", params.lang);
        return `/products/categories/list${qp.toString() ? `?${qp}` : ""}`;
      },
      providesTags: ["Product"],
    }),
  }),
});

export const {
  useGetProductsQuery,
  useLazyGetProductsQuery,
  useGetProductByIdQuery,
  useLazyGetProductByIdQuery,
  useGetCategoriesQuery,
  useGetProductTestimonialsQuery,
  useGetCategoriesWithProductsQuery,
  useLazyGetCategoriesWithProductsQuery,
  useAddReviewMutation,
} = productApi;
