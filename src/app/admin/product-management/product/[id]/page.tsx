import React from "react";
import ProductForm from "@/components/product-management/product/manage/index";

export default async function EditProductPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  return <ProductForm mode="edit" id={id} />;
}
