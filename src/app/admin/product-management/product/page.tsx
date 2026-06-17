import ProductPage from "@/components/product-management/product";
import React, { Suspense } from "react";

const Product = () => {
  return (
    <div>
      <Suspense fallback={null}>
        <ProductPage />
      </Suspense>
    </div>
  );
};

export default Product;
