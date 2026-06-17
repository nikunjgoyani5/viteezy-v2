import IngredientsForm from "@/components/ingredients-management/IngredientsForm";

export default async function Page({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  return <IngredientsForm mode="edit" id={id} />;
}
