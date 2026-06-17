import ProductCategoriesPage from "@/components/product-management/category";
import React, { Suspense } from "react";

const ProductCategories = () => {
  return (
    <div>
      <Suspense fallback={null}>
        <ProductCategoriesPage />
      </Suspense>
    </div>
  );
};

export default ProductCategories;
