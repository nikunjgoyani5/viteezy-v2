// -------- Testimonial Types --------

export type Product = {
    _id: string;
    title: string;
    slug: string;
    productImage: string;
};

export type User = {
    _id: string;
    name: string;
    email: string;
};

export type Testimonial = {
    _id: string;
    videoUrl: string;
    videoThumbnail: string | null;
    products: Product[];
    productsForDetailsPage: Product[];
    isVisibleOnHomepage: boolean;
    isFeatured: boolean;
    isVisibleInLP: boolean;
    isActive: boolean;
    displayOrder: number;
    isDeleted: boolean;
    createdBy: User;
    updatedBy: User;
    createdAt: string;
    updatedAt: string;
    __v: number;
};

export type GetTestimonialsParams = {
    page?: number;
    limit?: number;
    search?: string;
    isActive?: boolean;
};

export type GetTestimonialsResponse = {
    success: boolean;
    message: string;
    data: {
        testimonials: Testimonial[];
    };
    pagination: {
        page: number;
        limit: number;
        total: number;
        pages: number;
        hasNext: boolean;
        hasPrev: boolean;
    };
};

export type UpdateTestimonialStatusPayload = {
    isActive: boolean;
};

export type UpdateTestimonialStatusResponse = {
    success: boolean;
    message: string;
    data: Testimonial;
};

export type DeleteTestimonialResponse = {
    success: boolean;
    message: string;
};

export type CreateTestimonialResponse = {
    success: boolean;
    message: string;
    data: Testimonial;
};

export type GetTestimonialByIdResponse = {
    success: boolean;
    message: string;
    data: {
        testimonial: Testimonial;
    };
};

export type UpdateTestimonialResponse = {
    success: boolean;
    message: string;
    data: Testimonial;
};
