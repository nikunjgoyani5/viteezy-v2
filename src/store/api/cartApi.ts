import { baseApi } from "./baseApi";
import type {
  GetCartResponse,
  AddCartItemRequest,
  AddCartItemsRequest,
  AddCartItemResponse,
  UpdateCartItemRequest,
  UpdateCartItemResponse,
  DeleteCartItemResponse,
  ClearCartResponse,
  ValidateCartResponse,
  CheckoutPageSummaryResponse,
} from "./types/cart.types";

export const cartApi = baseApi.injectEndpoints({
  endpoints: (builder) => ({
    /**
     * GET CART
     * Retrieve current user's cart with items and suggested products
     */
    getCart: builder.query<GetCartResponse, void>({
      query: () => "/carts",
      providesTags: ["Cart"],
    }),

    /**
     * ADD ITEM TO CART
     * Add a new item to the cart or update quantity if already exists
     */
    addCartItem: builder.mutation<
      AddCartItemResponse,
      AddCartItemRequest | AddCartItemsRequest
    >({
      query: (body) => ({
        url: "/carts/items",
        method: "POST",
        body,
      }),
      invalidatesTags: ["Cart"],
    }),

    /**
     * UPDATE CART ITEM QUANTITY
     * Update the quantity of a specific item in the cart
     */
    updateCartItem: builder.mutation<
      UpdateCartItemResponse,
      { index: number; body: UpdateCartItemRequest }
    >({
      query: ({ index, body }) => ({
        url: `/carts/items/${index}`,
        method: "PUT",
        body,
      }),
      invalidatesTags: ["Cart"],
    }),

    /**
     * REMOVE CART ITEM
     * Remove a specific item from the cart
     */
    removeCartItem: builder.mutation<
      DeleteCartItemResponse,
      { productId: string; variantType?: "SACHETS" | "STAND_UP_POUCH" }
    >({
      query: (body) => ({
        url: `/carts/items`,
        method: "DELETE",
        body,
      }),
      invalidatesTags: ["Cart"],
    }),

    /**
     * CLEAR CART
     * Remove all items from the cart
     */
    clearCart: builder.mutation<ClearCartResponse, void>({
      query: () => ({
        url: "/carts",
        method: "DELETE",
      }),
      invalidatesTags: ["Cart"],
    }),

    /**
     * VALIDATE CART
     * Validate cart items, pricing, and availability
     */
    validateCart: builder.mutation<ValidateCartResponse, void>({
      query: () => ({
        url: "/carts/validate",
        method: "POST",
      }),
      invalidatesTags: ["Cart"],
    }),

    /**
     * GET CHECKOUT PAGE SUMMARY
     * Initial load without payload - just GET request
     */
    getCheckoutPageSummary: builder.query<CheckoutPageSummaryResponse, void>({
      query: () => ({
        url: "/checkout/page-summary",
        method: "POST",
        body: {},
      }),
      providesTags: (result, error, arg) => {
        // Don't provide Cart tag to prevent auto-refetch when mutations invalidate Cart
        return [];
      },
    }),

    /**
     * UPDATE CHECKOUT SELECTIONS
     * Update checkout when user changes sachets plans, capsule counts, or quantities
     */
    updateCheckoutSelections: builder.mutation<
      CheckoutPageSummaryResponse,
      {
        sachets?: { planDurationDays: number };
        standUpPouch?: {
          itemQuantities: Array<{
            capsuleCount: number;
            productId: string;
            quantity: number;
          }>;
        };
        couponCode?: string;
      }
    >({
      query: (body) => ({
        url: "/checkout/page-summary",
        method: "POST",
        body,
      }),
      invalidatesTags: ["Cart"],
      // Update the checkout page summary cache with the response
      async onQueryStarted(arg, { dispatch, queryFulfilled }) {
        try {
          const { data } = await queryFulfilled;
          // Update the checkout page summary cache
          dispatch(
            cartApi.util.updateQueryData(
              "getCheckoutPageSummary",
              undefined,
              (draft) => {
                Object.assign(draft, data);
              }
            )
          );
        } catch {
          // Error handled by mutation
        }
      },
    }),

    /**
     * GET CART BY SUBSCRIPTION ID
     * Retrieve cart by subscription ID
     */
    getCartBySubscriptionId: builder.query<GetCartResponse, string>({
      query: (subscriptionId) => `/carts?type=SUBSCRIPTION_UPDATE&subscriptionId=${subscriptionId}`,
      providesTags: ["Cart"],
      // Force refetch when subscription changes
      serializeQueryArgs: ({ endpointName, queryArgs }) => {
        return `${endpointName}-${queryArgs}`;
      },
    }),

    /**
     * VALIDATE COUPON
     * Validate and apply coupon to cart
     */
    validateCoupon: builder.mutation<
      { success: boolean; message: string; data?: any },
      {
        cartId: string;
        couponCode: string;
        planDurationDays?: number;
        language: string;
      }
    >({
      query: (body) => ({
        url: "/coupons/validate",
        method: "POST",
        body,
      }),
      invalidatesTags: (result, error) => {
        // Only invalidate on success
        if (result && result.success) {
          return ["Cart"];
        }
        return [];
      },
    }),

    /**
     * REMOVE COUPON
     * Remove coupon from cart
     */
    removeCoupon: builder.mutation<
      { success: boolean; message: string },
      { cartId: string; couponCode: string; planDurationDays?: number; language: string }
    >({
      query: ({ cartId, couponCode, planDurationDays, language }) => ({
        url: "/coupons/validate",
        method: "POST",
        body: { cartId, couponCode: null, planDurationDays, language },
      }),
      invalidatesTags: ["Cart"],
    }),

    /**
     * UPDATE PLAN SELECTION (Legacy - kept for backward compatibility)
     * Update the selected plan for checkout (SACHETS or STAND_UP_POUCH)
     */
    updatePlanSelection: builder.mutation<
      CheckoutPageSummaryResponse,
      {
        variantType: string;
        planDurationDays?: number;
        capsuleCount?: number;
        couponCode?: string;
        shippingAddressId?: string;
      }
    >({
      query: (body) => ({
        url: "/checkout/page-summary",
        method: "POST",
        body,
      }),
      invalidatesTags: ["Cart"],
    }),
  }),
});

export const {
  useGetCartQuery,
  useLazyGetCartQuery,
  useAddCartItemMutation,
  useUpdateCartItemMutation,
  useRemoveCartItemMutation,
  useClearCartMutation,
  useValidateCartMutation,
  useGetCheckoutPageSummaryQuery,
  useUpdateCheckoutSelectionsMutation,
  useUpdatePlanSelectionMutation,
  useGetCartBySubscriptionIdQuery,
  useValidateCouponMutation,
  useRemoveCouponMutation,
} = cartApi;
