import BlogForm from "@/components/blog-management/blog/BlogForm";

export default async function EditBlogPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  return <BlogForm isEdit={true} id={id} />;
}
