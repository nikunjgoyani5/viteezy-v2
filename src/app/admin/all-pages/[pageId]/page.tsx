"use client";

import React, { useMemo } from "react";
import { useParams, useRouter } from "next/navigation"; import toast from "react-hot-toast"; import AddPageForm, { PageFormData } from "@/components/forms/AddPageForm";
import {
    useGetStaticPageByIdQuery,
    useUpdateStaticPageMutation,
} from "@/store/api/staticPagesApi";

const EditStaticPage = () => {
    const { pageId } = useParams();
    const router = useRouter();
    const id = pageId as string;

    const { data, isLoading, isError } = useGetStaticPageByIdQuery(id);
    const [updatePage] = useUpdateStaticPageMutation();

    const initialData: Partial<PageFormData> | undefined = useMemo(() => {
        const p = data?.data?.staticPage;
        if (!p) return undefined;

        const html = p.content || "";
        // Keep HTML as-is for the rich text editor
        const metaTitle = p.seo?.title ?? "";
        const metaDesc = p.seo?.description ?? "";
        const metaKeywords = p.seo?.keywords ?? "";
        const visibility = (p.status || "").toLowerCase() === "published";

        return {
            title: p.title ?? "",
            slug: p.slug ?? "",
            description: html,
            visibility,
            metaTitle,
            metaDescription: metaDesc,
            metaKeywords,
        };
    }, [data]);

    if (isLoading) {
        return (
            <div className="min-h-screen bg-gray-50 flex items-center justify-center">
                <div className="text-gray-500">Loading page details...</div>
            </div>
        );
    }

    if (isError || !initialData) {
        return (
            <div className="min-h-screen bg-gray-50 flex items-center justify-center">
                <div className="text-red-500">Failed to load static page.</div>
            </div>
        );
    }

    const handleSubmit = async (form: PageFormData) => {
        try {
            const payload = {
                title: form.title,
                slug: form.slug,
                content: form.description,
                status: form.visibility ? "Published" : "Unpublished",
                seo: {
                    title: form.metaTitle,
                    description: form.metaDescription,
                    keywords: form.metaKeywords,
                },
            };
            await updatePage({ id, body: payload }).unwrap();
            toast.success("Page updated successfully");
            router.push("/admin/all-pages");
        } catch (error: any) {
            toast.error(error?.data?.message || "Failed to update page");
            console.error("Failed to update page:", error);
        }
    };

    return (
        <AddPageForm
            initialData={initialData}
            titleLabel="Edit Page"
            submitLabel="Save Changes"
            onSubmit={handleSubmit}
        />
    );
};

export default EditStaticPage;
