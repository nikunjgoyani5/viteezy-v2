"use client";

import React, { useMemo } from "react";
import { useParams } from "next/navigation";
import TestimonialForm from "@/components/testimonials/TestimonialForm";
import { useGetTestimonialByIdQuery } from "@/store/api/testimonialApi";
import { useGetCategoriesListQuery } from "@/store/api/productCategoriesApi";
import { TestimonialFormData } from "@/components/testimonials/TestimonialForm";

export default function EditTestimonialPage() {
    const params = useParams();
    const id = params.id as string;

    const { data, isLoading, error } = useGetTestimonialByIdQuery(id);
    const { data: categoriesData, isLoading: categoriesLoading } = useGetCategoriesListQuery();

    const initialData = useMemo(() => {
        if (!data?.data?.testimonial) return undefined;

        const testimonial = data.data.testimonial;

        // Transform API response to form data
        const formData: Partial<TestimonialFormData> = {
            video: testimonial.videoUrl, // URL string
            products: testimonial.products.map((p) => p._id),
            visibility: testimonial.isActive,
            pages: testimonial.isVisibleOnHomepage ? ["home"] : [],
            selectedPageProducts: {},
        };

        // Map productsForDetailsPage to selectedPageProducts by finding which category each product belongs to
        if (testimonial.productsForDetailsPage && testimonial.productsForDetailsPage.length > 0 && categoriesData?.data?.categories) {
            const pageProductMap: Record<string, string[]> = {};

            testimonial.productsForDetailsPage.forEach((product) => {
                // Find which category this product belongs to
                const category = categoriesData.data.categories.find((cat) =>
                    cat.products.some((p) => p._id === product._id)
                );

                if (category) {
                    if (!pageProductMap[category._id]) {
                        pageProductMap[category._id] = [];
                    }
                    pageProductMap[category._id].push(product._id);
                }
            });

            formData.selectedPageProducts = pageProductMap;
        }

        return formData;
    }, [data, categoriesData]);

    if (isLoading || categoriesLoading) {
        return (
            <div className="p-6 flex items-center justify-center min-h-screen">
                <div className="text-gray-600">Loading...</div>
            </div>
        );
    }

    if (error || !data?.data?.testimonial) {
        return (
            <div className="p-6">
                <div className="text-red-500">
                    Failed to load testimonial. Please try again.
                </div>
            </div>
        );
    }

    return (
        <div className="p-6">
            <TestimonialForm
                mode="edit"
                testimonialId={id}
                initialData={initialData}
                submitLabel="Update Testimonial"
                titleLabel="Edit Testimonial"
            />
        </div>
    );
}
