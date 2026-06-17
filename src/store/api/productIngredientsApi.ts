import baseApi from "./baseApi";
import type {
  CreateProductIngredientResponse,
  DeleteProductIngredientResponse,
  GetProductIngredientByIdResponse,
  GetProductIngredientsParams,
  GetProductIngredientsResponse,
  UpdateProductIngredientResponse,
} from "./types/productIngredient.types";

export const productIngredientsApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    getProductIngredients: builder.query<
      GetProductIngredientsResponse,
      GetProductIngredientsParams | void
    >({
      query: (params) => ({
        url: "/admin/product-ingredients",
        params: { page: 1, limit: 10, ...(params ?? {}) },
      }),
      providesTags: ["ProductIngredients"],
    }),

    getProductIngredientById: builder.query<
      GetProductIngredientByIdResponse,
      string
    >({
      query: (id) => `/admin/product-ingredients/${id}`,
      providesTags: (_res, _err, id) => [{ type: "ProductIngredient", id }],
    }),

    createProductIngredient: builder.mutation<
      CreateProductIngredientResponse,
      FormData
    >({
      query: (body) => ({
        url: "/admin/product-ingredients",
        method: "POST",
        body,
      }),
      invalidatesTags: ["ProductIngredients"],
    }),

    updateProductIngredient: builder.mutation<
      UpdateProductIngredientResponse,
      { id: string; body: FormData }
    >({
      query: ({ id, body }) => ({
        url: `/admin/product-ingredients/${id}`,
        method: "PUT",
        body,
      }),
      invalidatesTags: (_res, _err, arg) => [
        "ProductIngredients",
        { type: "ProductIngredient", id: arg.id },
      ],
    }),

    deleteProductIngredient: builder.mutation<
      DeleteProductIngredientResponse,
      { id: string; listArgs: GetProductIngredientsParams }
    >({
      query: ({ id }) => ({
        url: `/admin/product-ingredients/${id}`,
        method: "DELETE",
      }),

      invalidatesTags: ["ProductIngredients"],
    }),

    updateProductIngredientStatus: builder.mutation<
      UpdateProductIngredientResponse,
      { id: string; isActive: boolean; listArgs?: GetProductIngredientsParams }
    >({
      query: ({ id, isActive }) => ({
        url: `/admin/product-ingredients/${id}`,
        method: "PUT",
        body: { isActive },
      }),

      invalidatesTags: ["ProductIngredients"],

      async onQueryStarted(
        { id, isActive, listArgs },
        { dispatch, queryFulfilled }
      ) {
        const patchList = listArgs
          ? dispatch(
              productIngredientsApi.util.updateQueryData(
                "getProductIngredients",
                listArgs,
                (draft) => {
                  const item = draft.data.find((i) => i._id == id);
                  if (item) item.isActive = isActive;
                }
              )
            )
          : null;

        const patchDetails = dispatch(
          productIngredientsApi.util.updateQueryData(
            "getProductIngredientById",
            id,
            (draft) => {
              if (draft.data?.ingredient) {
                draft.data.ingredient.isActive = isActive;
              }
            }
          )
        );

        try {
          await queryFulfilled;
        } catch {
          patchList?.undo();
          patchDetails.undo();
        }
      },
    }),
  }),
});

export const {
  useGetProductIngredientsQuery,
  useLazyGetProductIngredientsQuery,
  useGetProductIngredientByIdQuery,
  useLazyGetProductIngredientByIdQuery,
  useCreateProductIngredientMutation,
  useUpdateProductIngredientMutation,
  useDeleteProductIngredientMutation,
  useUpdateProductIngredientStatusMutation,
} = productIngredientsApi;
