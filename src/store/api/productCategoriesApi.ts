import baseApi from "./baseApi";
import type {
  CreateProductCategoryResponse,
  DeleteProductCategoryResponse,
  GetProductCategoriesParams,
  GetProductCategoriesResponse,
  UpdateProductCategoryResponse,
  GetCategoriesListResponse,
  GetPublicCategoriesResponse,
} from "./types/productCategory.types";

export const productCategoriesApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getProductCategories: builder.query<
      GetProductCategoriesResponse,
      GetProductCategoriesParams | void
    >({
      query: (params) => ({
        url: "/admin/product-categories",
        params: params ?? {},
      }),
      providesTags: (result) =>
        result?.data
          ? [
            { type: "ProductCategories" as const, id: "LIST" },
            ...result.data.map((c) => ({
              type: "ProductCategories" as const,
              id: c._id,
            })),
          ]
          : [{ type: "ProductCategories" as const, id: "LIST" }],
    }),
    createProductCategory: builder.mutation<
      CreateProductCategoryResponse,
      FormData
    >({
      query: (body) => ({
        url: "/admin/product-categories",
        method: "POST",
        body,
      }),
      invalidatesTags: ["ProductCategories"],
    }),

    updateProductCategory: builder.mutation<
      UpdateProductCategoryResponse,
      { id: string; body: FormData }
    >({
      query: ({ id, body }) => ({
        url: `/admin/product-categories/${id}`,
        method: "PUT",
        body,
      }),
      invalidatesTags: (_res, _err, arg) => [
        { type: "ProductCategories", id: arg.id },
        { type: "ProductCategories", id: "LIST" },
      ],
    }),

    deleteProductCategory: builder.mutation<
      DeleteProductCategoryResponse,
      string
    >({
      query: (id) => ({
        url: `/admin/product-categories/${id}`,
        method: "DELETE",
      }),

      invalidatesTags: (_res, _err, id) => [
        { type: "ProductCategories", id: "LIST" },
        { type: "ProductCategories", id },
      ],
    }),

    getCategoriesList: builder.query<GetCategoriesListResponse, void>({
      query: () => ({
        url: "/products/categories/list",
      }),
      providesTags: [{ type: "ProductCategories" as const, id: "CATEGORIES_LIST" }],
    }),

    // Public API endpoint for fetching product categories
    getPublicCategories: builder.query<GetPublicCategoriesResponse, void>({
      query: () => ({
        url: "/products/categories",
      }),
      providesTags: [{ type: "ProductCategories" as const, id: "PUBLIC_LIST" }],
    }),
  }),
});

export const {
  useGetProductCategoriesQuery,
  useLazyGetProductCategoriesQuery,
  useCreateProductCategoryMutation,
  useUpdateProductCategoryMutation,
  useDeleteProductCategoryMutation,
  useGetCategoriesListQuery,
  useLazyGetCategoriesListQuery,
  useGetPublicCategoriesQuery,
  useLazyGetPublicCategoriesQuery,
} = productCategoriesApi;
