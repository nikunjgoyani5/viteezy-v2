"use client";

import { useGetTopSellingProductsQuery } from "@/store/api/dashboardApi";
import ProductTable from "./ProductTable";
import OverlayLoader from "@/components/common/OverlayLoader";

const SellingProducts = () => {
  const {
    data: productData,
    isLoading,
    isFetching,
    isError,
  } = useGetTopSellingProductsQuery();

  const data = productData?.data.products || [];

  if (isError) {
    return (
      <div className="bg-white border rounded-lg p-5 text-red-600">
        Failed to load top selling products.
      </div>
    );
  }

  return (
    <div className="relative">
      <ProductTable data={data} />
      <OverlayLoader show={isLoading || isFetching} />
    </div>
  );
};

export default SellingProducts;
