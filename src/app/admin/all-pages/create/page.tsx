"use client";

import toast from "react-hot-toast";
import AddPageForm, { PageFormData } from "@/components/forms/AddPageForm";
import { useCreateStaticPageMutation } from "@/store/api/staticPagesApi";
import { useRouter } from "next/navigation";

export default function CreatePagePage() {
    const router = useRouter();
    const [createPage, { isLoading }] = useCreateStaticPageMutation();

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
            await createPage(payload).unwrap();
            toast.success("Page created successfully");
            router.push("/admin/all-pages");
        } catch (error: any) {
            toast.error(error?.data?.message || "Failed to create page");
            console.error("Failed to create page:", error);
        }
    };

    return <AddPageForm onSubmit={handleSubmit} />;
}
