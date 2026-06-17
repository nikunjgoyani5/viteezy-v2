import baseApi from "./baseApi";
import { dashboardApi } from "./dashboardApi";
import type {
  CreateProductResponse,
  DeleteProductResponse,
  GetProductByIdResponse,
  GetProductFiltersResponse,
  GetProductsParams,
  GetProductsResponse,
  UpdateProductResponse,
  UpdateProductStatusResponse,
  GetPublicProductsParams,
  GetPublicProductsResponse,
} from "./types/products.types";

export const productsApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getProducts: builder.query<GetProductsResponse, GetProductsParams>({
      query: (params) => ({
        url: "/admin/products",
        params: { page: 1, limit: 10, ...(params ?? {}) },
      }),
      providesTags: ["Products"],
    }),

    getProductFilters: builder.query<GetProductFiltersResponse, void>({
      query: () => ({ url: "/products/filters" }),
      providesTags: ["ProductFilters"],
    }),

    createProduct: builder.mutation<CreateProductResponse, FormData>({
      query: (body) => ({
        url: "/products",
        method: "POST",
        body,
      }),
      invalidatesTags: ["Products", "ProductCategories", "ProductIngredients"],
    }),

    updateProduct: builder.mutation<
      UpdateProductResponse,
      { id: string; body: FormData }
    >({
      query: ({ id, body }) => ({
        url: `/products/${id}`,
        method: "PUT",
        body,
      }),
      invalidatesTags: (_res, _err, arg) => [
        "Products",
        { type: "Product", id: arg.id },
        "TopSellingProducts",
        "ProductCategories",
        "ProductIngredients",
      ],
    }),

    getProductById: builder.query<GetProductByIdResponse, string>({
      query: (id) => `/products/${id}`,
      providesTags: (_res, _err, id) => [{ type: "Product", id }],
    }),

    deleteProduct: builder.mutation<DeleteProductResponse, string>({
      query: (id) => ({
        url: `/products/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: (_res, _err, id) => [
        "Products",
        { type: "Product", id },
        "TopSellingProducts",
        "ProductCategories",
        "ProductIngredients",
      ],
    }),

    updateProductStatus: builder.mutation<
      UpdateProductStatusResponse,
      { id: string; enabled: boolean; listArgs?: GetProductsParams }
    >({
      query: ({ id, enabled }) => ({
        url: `/products/${id}/status`,
        method: "PATCH",
        body: { enabled },
      }),

      invalidatesTags: (_res, _err, arg) => (!arg.listArgs ? ["Products"] : []),

      async onQueryStarted(
        { id, enabled, listArgs },
        { dispatch, queryFulfilled },
      ) {
        try {
          await queryFulfilled;

          if (listArgs) {
            dispatch(
              productsApi.util.updateQueryData(
                "getProducts",
                listArgs,
                (draft) => {
                  const product = draft.data.find((p) => p._id === id);
                  if (product) {
                    product.status = enabled;
                  }
                },
              ),
            );
          }

          dispatch(
            productsApi.util.updateQueryData("getProductById", id, (draft) => {
              if (draft.data?.product) {
                draft.data.product.status = enabled;
              }
            }),
          );

          dispatch(
            dashboardApi.util.updateQueryData(
              "getTopSellingProducts",
              undefined,
              (draft) => {
                if (draft.data?.products) {
                  const product = draft.data.products.find(
                    (p) => p.productId === id,
                  );
                  if (product) {
                    product.status = enabled;
                  }
                }
              },
            ),
          );
        } catch { }
      },
    }),

    // Public API endpoint for fetching products (used in testimonials, etc.)
    getPublicProducts: builder.query<GetPublicProductsResponse, GetPublicProductsParams | void>({
      query: (params) => ({
        url: "/products",
        params: params ?? {},
      }),
      providesTags: ["Products"],
    }),
  }),
});

export const {
  useLazyGetProductsQuery,
  useGetProductsQuery,
  useGetProductFiltersQuery,
  useCreateProductMutation,
  useUpdateProductMutation,
  useGetProductByIdQuery,
  useLazyGetProductByIdQuery,
  useDeleteProductMutation,
  useUpdateProductStatusMutation,
  useLazyGetPublicProductsQuery,
  useGetPublicProductsQuery,
} = productsApi;
