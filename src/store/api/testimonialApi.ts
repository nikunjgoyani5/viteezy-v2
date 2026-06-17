import baseApi from "./baseApi";
import type {
    GetTestimonialsParams,
    GetTestimonialsResponse,
    UpdateTestimonialStatusPayload,
    UpdateTestimonialStatusResponse,
    DeleteTestimonialResponse,
    CreateTestimonialResponse,
    GetTestimonialByIdResponse,
    UpdateTestimonialResponse,
} from "./types/testimonial.types";

export const testimonialApi = baseApi.injectEndpoints({
    endpoints: (builder) => ({
        getTestimonials: builder.query<GetTestimonialsResponse, GetTestimonialsParams | void>({
            query: (params) => ({
                url: "/admin/product-testimonials",
                params: { page: 1, limit: 10, ...(params ?? {}) },
            }),
            providesTags: ["Testimonials"],
        }),

        getTestimonialById: builder.query<GetTestimonialByIdResponse, string>({
            query: (id) => `/admin/product-testimonials/${id}`,
            providesTags: (_res, _err, id) => [{ type: "Testimonials", id }],
        }),

        updateTestimonialStatus: builder.mutation<
            UpdateTestimonialStatusResponse,
            {
                id: string;
                body: UpdateTestimonialStatusPayload;
                listArgs?: GetTestimonialsParams | void;
            }
        >({
            query: ({ id, body }) => ({
                url: `/admin/product-testimonials/${id}/status`,
                method: "PATCH",
                body,
            }),
            invalidatesTags: (_res, _err, arg) => [
                { type: "Testimonials", id: arg.id },
                "Testimonials",
            ],
            async onQueryStarted({ id, body, listArgs }, { dispatch, queryFulfilled }) {
                if (listArgs == null) return;
                const patchResult = dispatch(
                    testimonialApi.util.updateQueryData("getTestimonials", listArgs, (draft) => {
                        const testimonial = (draft.data?.testimonials ?? []).find((t) => t._id === id);
                        if (testimonial) testimonial.isActive = body.isActive;
                    })
                );
                try {
                    await queryFulfilled;
                } catch {
                    patchResult.undo();
                }
            },
        }),

        deleteTestimonial: builder.mutation<DeleteTestimonialResponse, string>({
            query: (id) => ({
                url: `/admin/product-testimonials/${id}`,
                method: "DELETE",
            }),
            invalidatesTags: ["Testimonials"],
        }),

        createTestimonial: builder.mutation<CreateTestimonialResponse, FormData>({
            query: (body) => ({
                url: "/admin/product-testimonials",
                method: "POST",
                body,
            }),
            invalidatesTags: ["Testimonials"],
        }),

        updateTestimonial: builder.mutation<UpdateTestimonialResponse, { id: string; body: FormData }>({
            query: ({ id, body }) => ({
                url: `/admin/product-testimonials/${id}`,
                method: "PUT",
                body,
            }),
            invalidatesTags: (_res, _err, arg) => [
                { type: "Testimonials", id: arg.id },
                "Testimonials",
            ],
        }),
    }),
});

export const {
    useGetTestimonialsQuery,
    useGetTestimonialByIdQuery,
    useUpdateTestimonialStatusMutation,
    useDeleteTestimonialMutation,
    useCreateTestimonialMutation,
    useUpdateTestimonialMutation,
} = testimonialApi;
